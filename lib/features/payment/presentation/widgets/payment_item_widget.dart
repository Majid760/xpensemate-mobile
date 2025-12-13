import 'package:flutter/material.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/utils/app_utils.dart';
import 'package:xpensemate/core/widget/app_custom_dialog.dart';
import 'package:xpensemate/core/widget/app_dismissible_widget.dart';
import 'package:xpensemate/features/payment/domain/entities/payment_entity.dart';
import 'package:xpensemate/l10n/app_localizations.dart';

class PaymentItemWidget extends StatefulWidget {
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

  @override
  State<PaymentItemWidget> createState() => _PaymentItemWidgetState();
}

class _PaymentItemWidgetState extends State<PaymentItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _initializeEntranceAnimations();
    _startEntranceAnimation();
  }

  void _initializeEntranceAnimations() {
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutQuad,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.05, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 100,
      ),
    ]).animate(_entranceController);

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0, 0.7, curve: Curves.easeOut),
      ),
    );
  }

  void _startEntranceAnimation() {
    Future.delayed(Duration(milliseconds: 100 * widget.index), () {
      if (mounted) {
        _entranceController.forward();
      }
    });
  }

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
    widget.onDelete?.call(widget.payment.id);
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _entranceController,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, 50 * (1 - _slideAnimation.value)),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: AppDismissible(
                objectKey: 'payment_${widget.payment.id}',
                onDeleteConfirm: () async {
                  final result = await _showDeleteConfirmation(context);
                  if (result ?? false) {
                    _handleDelete();
                  }
                  return result ?? false;
                },
                onEdit: () => widget.onEdit?.call(widget.payment),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .shadowColor
                            .withValues(alpha: 0.08),
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
                              widget.payment.name,
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
                              widget.payment.payer,
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
                              AppUtils.formatDate(widget.payment.date),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
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
                            AppUtils.formatLargeNumber(widget.payment.amount),
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
                              widget.payment.paymentType.toFormattedPaymentType,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
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
        ),
      );
}
