import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:xpensemate/core/utils/app_utils.dart';
import 'package:xpensemate/core/widget/app_snackbar.dart';
import 'package:xpensemate/core/widget/error_state_widget.dart';
import 'package:xpensemate/features/payment/domain/entities/payment_entity.dart';
import 'package:xpensemate/features/payment/presentation/cubit/payment_cubit.dart';

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
  Widget build(BuildContext context) =>
      BlocConsumer<PaymentCubit, PaymentState>(
        listener: (context, state) {
          // Handle general messages
          if (state.message != null && state.message!.isNotEmpty) {
            AppSnackBar.show(
              context: context,
              message: state.message!,
              type: state.state == PaymentStatus.error
                  ? SnackBarType.error
                  : SnackBarType.success,
            );
          }
        },
        builder: (context, state) => PagingListener(
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
                onDelete: widget.onDelete,
                onEdit: widget.onEdit,
              ),
              noItemsFoundIndicatorBuilder: (context) =>
                  ErrorStateSectionWidget(
                onRetry: () => fetchNextPage,
                errorMsg:
                    (pagingState.error ?? 'No payments found!').toString(),
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
        ),
      );
}

class PaymentItemWidget extends StatelessWidget {
  const PaymentItemWidget({
    super.key,
    required this.payment,
    this.onEdit,
    this.onDelete,
  });

  final PaymentEntity payment;
  final Function(PaymentEntity)? onEdit;
  final Function(String)? onDelete;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Payment info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    payment.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    payment.payer,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppUtils.formatDate(payment.date),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AppUtils.formatLargeNumber(payment.amount),
                  // '\$${payment.amount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 4),
                // Action buttons
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    payment.paymentType.toFormattedPaymentType,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}
