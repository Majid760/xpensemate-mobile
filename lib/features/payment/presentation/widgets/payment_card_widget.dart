import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/utils/app_utils.dart';
import 'package:xpensemate/core/widget/animated_card_widget.dart';
import 'package:xpensemate/core/widget/app_custom_dialog.dart';
import 'package:xpensemate/core/widget/app_dismissible_widget.dart';
import 'package:xpensemate/features/payment/domain/entities/payment_entity.dart';
import 'package:xpensemate/l10n/app_localizations.dart';

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
    final localizations = AppLocalizations.of(context);
    bool? confirmResult;

    await AppCustomDialogs.showDelete(
      context: context,
      title: localizations?.delete ?? context.l10n.delete,
      message:
          '${localizations?.confirmDelete ?? context.l10n.confirmDelete}\n\n${localizations?.deleteWarning ?? context.l10n.deleteWarning}',
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
            color: Theme.of(context).cardColor,
            shadowColor: Theme.of(context).shadowColor.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Theme.of(context).dividerColor.withValues(alpha: .1),
              ),
            ),
            child: InkWell(
              onTap: () => HapticFeedback.lightImpact,
              onTapDown: (_) => HapticFeedback.selectionClick(),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Payment info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            payment.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            payment.payer,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppUtils.formatDate(payment.date),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
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
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
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
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
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
