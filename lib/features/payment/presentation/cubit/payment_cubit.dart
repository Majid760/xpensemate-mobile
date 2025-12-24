import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:xpensemate/core/enums.dart';
import 'package:xpensemate/core/utils/app_logger.dart';
import 'package:xpensemate/features/payment/domain/entities/payment_entity.dart';
import 'package:xpensemate/features/payment/domain/entities/payment_pagination_entity.dart';
import 'package:xpensemate/features/payment/domain/entities/payment_stats_entity.dart';
import 'package:xpensemate/features/payment/domain/usecases/create_payment_usecase.dart';
import 'package:xpensemate/features/payment/domain/usecases/delete_payment_usecase.dart';
import 'package:xpensemate/features/payment/domain/usecases/get_payment_stats_usecase.dart';
import 'package:xpensemate/features/payment/domain/usecases/get_payments_usecase.dart';
import 'package:xpensemate/features/payment/domain/usecases/update_payment_usecase.dart';

part 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  PaymentCubit(
    this._getPaymentsUseCase,
    this._deletePaymentUseCase,
    this._updatePaymentUseCase,
    this._createPaymentUseCase,
    this._getPaymentStatsUseCase,
  ) : super(const PaymentState()) {
    AppLogger.breadcrumb('Initializing PaymentCubit...');
    _pagingController.addListener(_showPaginationError);
    fetchPaymentStats(FilterValue.monthly);
  }

  final GetPaymentsUseCase _getPaymentsUseCase;
  final DeletePaymentUseCase _deletePaymentUseCase;
  final UpdatePaymentUseCase _updatePaymentUseCase;
  final CreatePaymentUseCase _createPaymentUseCase;
  final GetPaymentStatsUseCase _getPaymentStatsUseCase;

  static const int _limit = 10;
  String filterQuery = '';

  late final _pagingController = PagingController<int, PaymentEntity>(
    getNextPageKey: (state) =>
        state.lastPageIsEmpty ? null : state.nextIntPageKey,
    fetchPage: (pageKey) async => fetchPayments(pageKey, filterQuery),
  );
  PagingController<int, PaymentEntity> get pagingController =>
      _pagingController;

  @override
  Future<void> close() async {
    _pagingController.dispose();
    return super.close();
  }

  /// Fetches payments for a specific page
  Future<List<PaymentEntity>> fetchPayments(
    int pageKey,
    String filterQuery,
  ) async {
    AppLogger.breadcrumb('Fetching payments page: $pageKey...');
    try {
      final params = GetPaymentsParams(
        page: pageKey,
        limit: _limit,
        filterQuery: filterQuery,
      );
      final result = await _getPaymentsUseCase(params);
      return result.fold(
        (failure) {
          AppLogger.breadcrumb('Fetch payments failed: ${failure.message}');
          return [];
        },
        (paginationEntity) {
          AppLogger.breadcrumb(
              'Fetch payments success (${paginationEntity.payments.length} items)');
          return paginationEntity.payments;
        },
      );
    } on Exception catch (e, stackTrace) {
      AppLogger.e('fetchPayments failed', e, stackTrace);
      debugPrint('getPayments error: $e, stack: $stackTrace');
      return [];
    }
  }

  /// Load all payment data with pagination support
  Future<void> fetchPaymentStats(FilterValue filterValue) async {
    AppLogger.breadcrumb('Fetching payment stats for: ${filterValue.name}...');
    try {
      final statsResult = await _getPaymentStatsUseCase(
        GetPaymentsStatsParams(filterQuery: filterValue.name),
      );
      statsResult.fold(
        (failure) {
          AppLogger.breadcrumb(
              'Fetch payment stats failed: ${failure.message}');
          emit(
            state.copyWith(
              status: PaymentStatus.error,
              message: failure.message,
            ),
          );
        },
        (stats) {
          AppLogger.breadcrumb('Fetch payment stats success');
          emit(
            state.copyWith(
              paymentStats: stats,
              filterValue: filterValue,
              status: PaymentStatus.loaded,
            ),
          );
        },
      );
    } on Exception catch (e, s) {
      AppLogger.e('fetchPaymentStats failed', e, s);
      emit(
        state.copyWith(
          status: PaymentStatus.error,
          message: 'An unexpected error occurred: $e',
          stackTrace: s,
        ),
      );
    }
  }

  /// Update payment with optimistic updates and rollback on failure
  Future<void> updatePayment({required PaymentEntity payment}) async {
    AppLogger.breadcrumb('Updating payment: ${payment.id}...');
    try {
      // Find the page and index of the payment to update
      final pages = _pagingController.value.pages ?? [];
      var pageIndex = -1;
      var itemIndex = -1;
      for (var i = 0; i < pages.length; i++) {
        final page = pages[i];
        final index = page.indexWhere((e) => e.id == payment.id);
        if (index != -1) {
          pageIndex = i;
          itemIndex = index;
          break;
        }
      }
      // If found, update in the paging controller
      if (pageIndex != -1 && itemIndex != -1) {
        final updatedPages = List<List<PaymentEntity>>.from(pages);
        final updatedPage = List<PaymentEntity>.from(updatedPages[pageIndex]);
        updatedPage[itemIndex] = payment;
        updatedPages[pageIndex] = updatedPage;

        _pagingController.value = _pagingController.value.copyWith(
          pages: updatedPages,
        );
      }
      final result = await _updatePaymentUseCase(payment);
      await result.fold((failure) {
        AppLogger.breadcrumb('Update payment failed: ${failure.message}');
        // Refresh to rollback changes on failure
        _pagingController.refresh();
        emit(
          state.copyWith(
            status: PaymentStatus.error,
            message: failure.message,
          ),
        );
      }, (updatedPayment) async {
        AppLogger.breadcrumb('Update payment success');
        emit(
          state.copyWith(
            status: PaymentStatus.loaded,
            message: 'Payment updated successfully!',
          ),
        );
      });
    } on Exception catch (e, stackTrace) {
      AppLogger.e('updatePayment failed', e, stackTrace);
      emit(
        state.copyWith(
          status: PaymentStatus.error,
          message: 'An unexpected error occurred: $e',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Create payment with optimistic updates
  Future<void> createPayment({required PaymentEntity payment}) async {
    AppLogger.breadcrumb('Creating payment...');
    try {
      // Make the API call
      final result = await _createPaymentUseCase(payment);

      await result.fold(
        (failure) {
          AppLogger.breadcrumb('Create payment failed: ${failure.message}');
          // Refresh to rollback changes on failure
          _pagingController.refresh();
          emit(
            state.copyWith(
              status: PaymentStatus.error,
              message: failure.message,
              stackTrace: failure.stackTrace,
            ),
          );
        },
        (createdPayment) async {
          AppLogger.breadcrumb('Create payment success');
          final pages = _pagingController.value.pages ?? [];
          if (pages.isNotEmpty) {
            final updatedPages = List<List<PaymentEntity>>.from(pages);
            final firstPage = [payment, ...updatedPages[0]];
            updatedPages[0] = firstPage;
            _pagingController.value = _pagingController.value.copyWith(
              pages: updatedPages,
            );
          }
          emit(
            state.copyWith(
              status: PaymentStatus.loaded,
              message: 'Payment created successfully!',
            ),
          );
        },
      );
    } on Exception catch (e, stackTrace) {
      AppLogger.e('createPayment failed', e, stackTrace);
      emit(
        state.copyWith(
          status: PaymentStatus.error,
          message: 'An unexpected error occurred: $e',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Delete payment with optimistic updates and rollback on failure
  Future<void> deletePayment({required String paymentId}) async {
    AppLogger.breadcrumb('Deleting payment: $paymentId...');
    try {
      final result = await _deletePaymentUseCase(paymentId);
      await result.fold(
        (failure) {
          AppLogger.breadcrumb('Delete payment failed: ${failure.message}');
          // Refresh to rollback changes on failure
          _pagingController.refresh();
          emit(
            state.copyWith(
              status: PaymentStatus.error,
              message: failure.message,
            ),
          );
        },
        (success) async {
          AppLogger.breadcrumb('Delete payment success');
          // Remove from all pages
          final pages = _pagingController.value.pages ?? [];
          final updatedPages = <List<PaymentEntity>>[];
          for (final page in pages) {
            final updatedPage = page.where((e) => e.id != paymentId).toList();
            updatedPages.add(updatedPage);
          }
          _pagingController.value = _pagingController.value.copyWith(
            pages: updatedPages,
          );
          emit(
            state.copyWith(
              status: PaymentStatus.loaded,
              message: 'Payment deleted successfully!',
            ),
          );
        },
      );
    } on Exception catch (e, stackTrace) {
      AppLogger.e('deletePayment failed', e, stackTrace);
      emit(
        state.copyWith(
          status: PaymentStatus.error,
          message: 'An unexpected error occurred: $e',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  void _showPaginationError() {
    if (_pagingController.value.status == PagingStatus.subsequentPageError) {
      emit(
        state.copyWith(
          status: PaymentStatus.error,
          message: 'Something went wrong while fetching payments.',
        ),
      );
    }
  }

  void updateSearchTerm(String filterQuery) {
    this.filterQuery = filterQuery;
    _pagingController.refresh();
  }

  /// Refresh payments (reload from first page)
  Future<void> refreshPayments() async {
    filterQuery = '';
    _pagingController.refresh();
  }
}

// Extension for easy access to cubit
extension PaymentCubitX on BuildContext {
  PaymentCubit get paymentCubit => read<PaymentCubit>();
}
