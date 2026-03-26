import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/app_spacing.dart';
import 'package:xpensemate/core/widget/custom_app_loader.dart';
import 'package:xpensemate/core/widget/error_state_widget.dart';
import 'package:xpensemate/features/budget/presentation/widgets/no_more_widget.dart';
import 'package:xpensemate/features/payment/domain/entities/payment_entity.dart';
import 'package:xpensemate/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:xpensemate/features/payment/presentation/widgets/payment_card_widget.dart';

class PaymentListWidget extends StatefulWidget {
  const PaymentListWidget({
    super.key,
    this.onDelete,
    this.onEdit,
    this.scrollController,
  });

  final void Function(String paymentId)? onDelete;
  final void Function(PaymentEntity paymentEntity)? onEdit;
  final ScrollController? scrollController;

  @override
  State<PaymentListWidget> createState() => _PaymentListWidgetState();
}

class _PaymentListWidgetState extends State<PaymentListWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PagingListener(
        controller: context.paymentCubit.pagingController,
        builder: (context, pagingState, fetchNextPage) =>
            PagedSliverList<int, PaymentEntity>.separated(
          state: pagingState,
          fetchNextPage: fetchNextPage,
          builderDelegate: PagedChildBuilderDelegate<PaymentEntity>(
            animateTransitions: true,
            transitionDuration: const Duration(milliseconds: 400),
            itemBuilder: (context, payment, index) => PaymentItemWidget(
              payment: payment,
              index: index,
              onDelete: widget.onDelete,
              onEdit: widget.onEdit,
            ),
            noItemsFoundIndicatorBuilder: (context) => ErrorStateSectionWidget(
              onRetry: () => fetchNextPage,
              errorMsg: (pagingState.error ?? context.l10n.noPaymentsFound)
                  .toString(),
            ),
            firstPageProgressIndicatorBuilder: (_) => const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Center(child: CustomAppLoader()),
            ),
            newPageProgressIndicatorBuilder: (_) => const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: CustomAppLoader(),
              ),
            ),
            firstPageErrorIndicatorBuilder: (_) => ErrorStateSectionWidget(
              errorMsg: (pagingState.error ?? context.l10n.errorLoadingPayments)
                  .toString(),
              onRetry: context.paymentCubit.pagingController.refresh,
            ),
            newPageErrorIndicatorBuilder: (_) => ErrorStateSectionWidget(
              onRetry: () => fetchNextPage,
              errorMsg: (pagingState.error ?? context.l10n.errorLoadingPayments)
                  .toString(),
            ),
            noMoreItemsIndicatorBuilder: (_) => Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xl),
              child: AllCaughtUpWidget(title: context.l10n.noMorePayments),
            ),
          ),
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppSpacing.sm),
        ),
      );
}
