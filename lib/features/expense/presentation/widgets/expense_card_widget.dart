import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/utils/currency_formatter.dart';
import 'package:xpensemate/core/widget/animated_card_widget.dart';
import 'package:xpensemate/core/widget/app_custom_dialog.dart';
import 'package:xpensemate/core/widget/app_dismissible_widget.dart';
import 'package:xpensemate/features/expense/domain/entities/expense_entity.dart';
import 'package:xpensemate/l10n/app_localizations.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ExpenseCardWidget — animated entrance + swipe-to-dismiss shell
// (unchanged logic, redesigned visual layer)
// ─────────────────────────────────────────────────────────────────────────────

class ExpenseCardWidget extends StatelessWidget {
  const ExpenseCardWidget({
    super.key,
    required this.expense,
    this.isLast = false,
    this.onDelete,
    this.onEdit,
    this.index = 0,
    this.shouldAnimate = true,
  });

  final ExpenseEntity expense;
  final bool isLast;
  final void Function(String expenseId)? onDelete;
  final void Function(ExpenseEntity expenseEntity)? onEdit;
  final int index;
  final bool shouldAnimate;

  Future<bool?> _showDeleteConfirmation(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    bool? confirmResult;

    await AppCustomDialogs.showDelete(
      context: context,
      title: localizations?.delete ?? context.l10n.delete,
      message:
          '${localizations?.confirmDelete ?? context.l10n.confirmDelete}\n\n'
          '${localizations?.deleteWarning ?? context.l10n.deleteWarning}',
      onConfirm: () => confirmResult = true,
      onCancel: () => confirmResult = false,
    );

    return confirmResult;
  }

  @override
  Widget build(BuildContext context) => AnimatedCardWidget(
        shouldAnimate: shouldAnimate,
        index: index,
        child: AppDismissible(
          objectKey: 'expense_${expense.id}',
          onDeleteConfirm: () async {
            final result = await _showDeleteConfirmation(context);
            if (result ?? false) onDelete?.call(expense.id);
            return result ?? false;
          },
          onEdit: () => onEdit?.call(expense),
          child: ExpenseCard(
            expense: expense,
            onTapDown: (_) => HapticFeedback.selectionClick(),
          ),
        ),
      );
}


class ExpenseCard extends StatelessWidget {
  const ExpenseCard({
    super.key,
    required this.expense,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
  });

  final ExpenseEntity expense;
  final void Function(TapDownDetails)? onTapDown;
  final void Function(TapUpDetails)? onTapUp;
  final VoidCallback? onTapCancel;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final primary = context.primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? scheme.surface : scheme.surface,
          width: 0.5,
        ),
        boxShadow: [
          // Subtle glow/shadow using the primary color
          BoxShadow(
            color: primary.withValues(alpha: isDark ? 0.18 : 0.10),
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
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: HapticFeedback.lightImpact,
            onTapDown: onTapDown,
            onTapUp: onTapUp,
            onTapCancel: onTapCancel,
            child: Stack(
              children: [
                // ── Left accent bar ──────────────────────────────────
                Positioned(
                  left: 0,
                  top: 14,
                  bottom: 14,
                  child: Container(
                    width: 3.5,
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(3),
                        bottomRight: Radius.circular(3),
                      ),
                    ),
                  ),
                ),

                // ── Main content row ─────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 16, 16, 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Category icon ────────────────────────────────────────
                      _ExpenseIcon(expense: expense),

                      const SizedBox(width: 14),

                      // ── Main content ─────────────────────────────────────────
                      Expanded(child: _ExpenseBody(expense: expense)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Icon — mirrors ProfilePage's row-icon style
// ─────────────────────────────────────────────────────────────────────────────

class _ExpenseIcon extends StatelessWidget {
  const _ExpenseIcon({required this.expense});

  final ExpenseEntity expense;

  @override
  Widget build(BuildContext context) {
    final primary = context.primaryColor;

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        // ── Same alpha as login's prefixIcon tint ───────────────────────
        color: primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: primary.withValues(alpha: 0.18),
          width: 0.5,
        ),
      ),
      child: Icon(
        Icons.category_rounded,
        // ── Exact same icon color as login/profile prefix icons ─────────
        color: primary.withValues(alpha: 0.7),
        size: 22,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Body — all content to the right of the icon
// ─────────────────────────────────────────────────────────────────────────────

class _ExpenseBody extends StatelessWidget {
  const _ExpenseBody({required this.expense});

  final ExpenseEntity expense;

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final primary = context.primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Row 1: Name + Amount ─────────────────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                expense.name,
                // ── titleMedium w600 — same as ProfilePage info value ───
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                  letterSpacing: -0.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              CurrencyFormatter.format(expense.amount),
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                // ── primary for positive, error for negative ────────────
                color: expense.amount < 0 ? scheme.error : primary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        // ── Row 2: Category badge + Date ─────────────────────────────────
        Row(
          children: [
            // Category badge — same style as RecurringIndicator / profile badges
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: primary.withValues(alpha: 0.2),
                  width: 0.5,
                ),
              ),
              child: Text(
                expense.categoryName,
                style: context.textTheme.labelSmall?.copyWith(
                  color: primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Date — same onSurfaceVariant muted style as profile subtitles
            Text(
              _formatDate(expense.date),
              style: context.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // ── Row 3: Payment method + Time (thin 0.5px divider above) ──────
        Divider(
          height: 1,
          thickness: 0.5,
          // ── Same divider style used throughout profile page ─────────
          color: scheme.outlineVariant.withValues(alpha: 0.5),
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            if (expense.paymentMethod.isNotEmpty) ...[
              _DetailChip(
                icon: Icons.account_balance_wallet_outlined,
                text: expense.paymentMethod,
              ),
              const SizedBox(width: 12),
            ],
            _DetailChip(
              icon: Icons.access_time_outlined,
              text: expense.time,
            ),

            // ── Right-aligned status badge ───────────────────────────────
            const Spacer(),
            _StatusBadge(expense: expense),
          ],
        ),

        // ── Row 4: Location ───────────────────────────────────────────────
        if (expense.location.isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 13,
                color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  expense.location,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],

        // ── Row 5: Recurring badge ────────────────────────────────────────
        if (expense.recurring.isRecurring) ...[
          const SizedBox(height: 8),
          _RecurringBadge(expense: expense),
        ],

        // ── Row 6: Budget goal badge ──────────────────────────────────────
        if (expense.budgetGoalId != null &&
            expense.budgetGoalId!.isNotEmpty) ...[
          const SizedBox(height: 6),
          _BudgetBadge(expense: expense),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Detail chip (payment method, time) — muted icon + text pair
// ─────────────────────────────────────────────────────────────────────────────

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final muted =
        context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: muted),
        const SizedBox(width: 4),
        Text(
          text,
          style: context.textTheme.bodySmall?.copyWith(
            color: muted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status badge — compact check pill using primary color system
// ─────────────────────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.expense});

  final ExpenseEntity expense;

  @override
  Widget build(BuildContext context) {
    final primary = context.primaryColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        // ── Same fill/border as biometric button in LoginPage ───────────
        color: primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: primary.withValues(alpha: 0.25),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_rounded, size: 11, color: primary),
          const SizedBox(width: 3),
          Text(
            context.l10n.paid,
            style: context.textTheme.labelSmall?.copyWith(
              color: primary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Recurring badge
// ─────────────────────────────────────────────────────────────────────────────

class _RecurringBadge extends StatelessWidget {
  const _RecurringBadge({required this.expense});

  final ExpenseEntity expense;

  @override
  Widget build(BuildContext context) {
    final primary = context.primaryColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: primary.withValues(alpha: 0.25),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.autorenew_rounded, size: 12, color: primary),
          const SizedBox(width: 4),
          Text(
            expense.recurring.frequency,
            style: context.textTheme.labelSmall?.copyWith(
              color: primary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Budget goal badge — uses colorScheme.secondary, same badge pattern
// ─────────────────────────────────────────────────────────────────────────────

class _BudgetBadge extends StatelessWidget {
  const _BudgetBadge({required this.expense});

  final ExpenseEntity expense;

  @override
  Widget build(BuildContext context) {
    final secondary = context.colorScheme.secondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: secondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: secondary.withValues(alpha: 0.25),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.account_balance_outlined,
            size: 12,
            color: secondary,
          ),
          const SizedBox(width: 4),
          Text(
            context.l10n.budget,
            style: context.textTheme.labelSmall?.copyWith(
              color: secondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}