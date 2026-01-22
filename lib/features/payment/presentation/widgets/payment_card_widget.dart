import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/app_spacing.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/utils/app_utils.dart';
import 'package:xpensemate/core/widget/animated_card_widget.dart';
import 'package:xpensemate/core/widget/app_custom_dialog.dart';
import 'package:xpensemate/core/widget/app_dismissible_widget.dart';
import 'package:xpensemate/features/payment/domain/entities/payment_entity.dart';

class PaymentItemWidget extends StatelessWidget {
  const PaymentItemWidget({
    super.key,
    required this.payment,
    required this.index,
    this.onEdit,
    this.onDelete,
  });

  final PaymentEntity payment;
  final int index;
  final void Function(PaymentEntity)? onEdit;
  final void Function(String)? onDelete;

  Future<bool?> _showDeleteConfirmation(BuildContext context) async {
    bool? confirmResult;

    await AppCustomDialogs.showDelete(
      context: context,
      title: context.l10n.delete,
      message: '${context.l10n.confirmDelete}\n\n${context.l10n.deleteWarning}',
      onConfirm: () => confirmResult = true,
      onCancel: () => confirmResult = false,
    );

    return confirmResult;
  }

  void _handleDelete() {
    onDelete?.call(payment.id);
  }

  @override
  Widget build(BuildContext context) => AnimatedCardWidget(
        index: index,
        child: AppDismissible(
          objectKey: 'payment_${payment.id}',
          onDeleteConfirm: () async {
            final result = await _showDeleteConfirmation(context);
            if (result ?? false) {
              _handleDelete();
            }
            return result ?? false;
          },
          onEdit: () => onEdit?.call(payment),
          child: Card(
            color: context.colorScheme.surface,
            shadowColor: context.colorScheme.shadow.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.md),
              side: BorderSide(
                color: context.colorScheme.outlineVariant.withValues(alpha: .1),
              ),
            ),
            child: InkWell(
              onTap: () => HapticFeedback.lightImpact,
              onTapDown: (_) => HapticFeedback.selectionClick(),
              borderRadius: BorderRadius.circular(AppSpacing.md),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    // Payment info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            payment.name,
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            payment.payer,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            AppUtils.formatDate(payment.date),
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
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
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: context.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        // Action buttons
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: context.colorScheme.primary
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppSpacing.sm),
                          ),
                          child: Text(
                            payment.paymentType.toFormattedPaymentType,
                            style: context.textTheme.labelSmall?.copyWith(
                              color: context.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
