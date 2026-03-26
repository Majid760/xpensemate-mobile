import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/utils/app_utils.dart';
import 'package:xpensemate/core/widget/animated_card_widget.dart';
import 'package:xpensemate/core/widget/app_custom_dialog.dart';
import 'package:xpensemate/core/widget/app_dismissible_widget.dart';
import 'package:xpensemate/features/payment/domain/entities/payment_entity.dart';

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
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 0.975).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

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

  void _handleDelete() => widget.onDelete?.call(widget.payment.id);

  /// Maps a payment type string to a visually distinct accent color.
  Color _accentColor(BuildContext context) {
    final type = widget.payment.paymentType.toLowerCase();
    if (type.contains('cash')) return const Color(0xFF10B981);
    if (type.contains('credit')) return const Color(0xFF6366F1);
    if (type.contains('debit')) return const Color(0xFF3B82F6);
    if (type.contains('bank') || type.contains('transfer')) {
      return const Color(0xFF8B5CF6);
    }
    if (type.contains('online') || type.contains('digital')) {
      return const Color(0xFF14B8A6);
    }
    return context.colorScheme.primary;
  }

  /// Returns a simple emoji/icon character representing the payment type.
  String _paymentIcon() {
    final type = widget.payment.paymentType.toLowerCase();
    if (type.contains('cash')) return '💵';
    if (type.contains('credit')) return '💳';
    if (type.contains('debit')) return '🏧';
    if (type.contains('bank') || type.contains('transfer')) return '🏦';
    if (type.contains('online') || type.contains('digital')) return '📱';
    return '💸';
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor(context);
    final isDark = context.theme.brightness == Brightness.dark;

    return AnimatedCardWidget(
      index: widget.index,
      child: AppDismissible(
        objectKey: 'payment_${widget.payment.id}',
        onDeleteConfirm: () async {
          final result = await _showDeleteConfirmation(context);
          if (result ?? false) _handleDelete();
          return result ?? false;
        },
        onEdit: () => widget.onEdit?.call(widget.payment),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: GestureDetector(
            onTapDown: (_) {
              HapticFeedback.selectionClick();
              _pressController.forward();
            },
            onTapUp: (_) => _pressController.reverse(),
            onTapCancel: () => _pressController.reverse(),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: isDark
                    ? context.colorScheme.surface
                    : context.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? context.colorScheme.surface
                      : context.colorScheme.surface,
                  width: 0.5,
                ),
                // Subtle glow/shadow using the accent color
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: isDark ? 0.18 : 0.10),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.35)
                        : Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // ── Left accent bar ──────────────────────────────────
                    Positioned(
                      left: 0,
                      top: 12,
                      bottom: 12,
                      child: Container(
                        width: 3,
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),

                    // ── Main content row ─────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                      child: Row(
                        children: [
                          // Icon bubble
                          _IconBubble(
                            icon: _paymentIcon(),
                            accent: accent,
                            isDark: isDark,
                          ),
                          const SizedBox(width: 14),

                          // Name / payer / date
                          Expanded(
                            child: _PaymentInfo(payment: widget.payment),
                          ),
                          const SizedBox(width: 12),

                          // Amount + type badge
                          _AmountColumn(
                            payment: widget.payment,
                            accent: accent,
                            isDark: isDark,
                          ),
                        ],
                      ),
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _IconBubble extends StatelessWidget {
  const _IconBubble({
    required this.icon,
    required this.accent,
    required this.isDark,
  });

  final String icon;
  final Color accent;
  final bool isDark;

  @override
  Widget build(BuildContext context) => Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: isDark ? 0.15 : 0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: accent.withValues(alpha: isDark ? 0.30 : 0.20),
            width: 0.5,
          ),
        ),
        child: Center(
          child: Text(
            icon,
            style: const TextStyle(fontSize: 22),
          ),
        ),
      );
}

class _PaymentInfo extends StatelessWidget {
  const _PaymentInfo({required this.payment});

  final PaymentEntity payment;

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Payment name
        Text(
          payment.name,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF0F0F0F),
            letterSpacing: -0.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 3),

        // Payer name
        Row(
          children: [
            Icon(
              Icons.person_outline_rounded,
              size: 11,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.35)
                  : const Color(0xFF9CA3AF),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                payment.payer,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.45)
                      : const Color(0xFF6B7280),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),

        // Date chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 10,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.35)
                    : const Color(0xFF9CA3AF),
              ),
              const SizedBox(width: 4),
              Text(
                AppUtils.formatDate(payment.date),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.40)
                      : const Color(0xFF9CA3AF),
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AmountColumn extends StatelessWidget {
  const _AmountColumn({
    required this.payment,
    required this.accent,
    required this.isDark,
  });

  final PaymentEntity payment;
  final Color accent;
  final bool isDark;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Amount — monospaced, prominent
          Text(
            AppUtils.formatLargeNumber(payment.amount),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: accent,
              letterSpacing: -0.8,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 6),

          // Payment type pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: isDark ? 0.15 : 0.09),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: accent.withValues(alpha: isDark ? 0.30 : 0.18),
                width: 0.5,
              ),
            ),
            child: Text(
              payment.paymentType.toFormattedPaymentType,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: accent,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      );
}