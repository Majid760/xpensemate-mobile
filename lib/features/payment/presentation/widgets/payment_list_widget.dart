import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:xpensemate/core/widget/error_state_widget.dart';
import 'package:xpensemate/features/payment/domain/entities/payment_entity.dart';
import 'package:xpensemate/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:xpensemate/features/payment/presentation/widgets/payment_item_widget.dart';

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
              errorMsg: (pagingState.error ?? 'No payments found!').toString(),
            ),
            firstPageProgressIndicatorBuilder: (_) => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator.adaptive()),
            ),
            newPageProgressIndicatorBuilder: (_) => const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator.adaptive(),
              ),
            ),
            firstPageErrorIndicatorBuilder: (_) => ErrorStateSectionWidget(
              errorMsg: (pagingState.error ?? 'Error while loading payments!')
                  .toString(),
              onRetry: context.paymentCubit.pagingController.refresh,
            ),
            newPageErrorIndicatorBuilder: (_) => ErrorStateSectionWidget(
              onRetry: () => fetchNextPage,
              errorMsg: (pagingState.error ?? 'Error while loading payments!')
                  .toString(),
            ),
          ),
          separatorBuilder: (context, index) => const SizedBox(height: 8),
        ),
      );
}
