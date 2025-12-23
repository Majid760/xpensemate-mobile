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

// Main ExpenseListItem Widget with smooth entrance animations
class ExpenseCardWidget extends StatefulWidget {
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

  @override
  State<ExpenseCardWidget> createState() => _ExpenseCardWidgetState();
}

class _ExpenseCardWidgetState extends State<ExpenseCardWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
    widget.onDelete?.call(widget.expense.id);
  }

  @override
  Widget build(BuildContext context) => AnimatedCardWidget(
        shouldAnimate: widget.shouldAnimate,
        index: widget.index,
        child: AppDismissible(
          objectKey: 'expense_${widget.expense.id}',
          onDeleteConfirm: () async {
            final result = await _showDeleteConfirmation(context);
            if (result ?? false) {
              _handleDelete();
            }
            return result ?? false;
          },
          onEdit: () => widget.onEdit?.call(widget.expense),
          child: ExpenseCard(
            expense: widget.expense,
            onTapDown: (_) {
              HapticFeedback.selectionClick();
            },
          ),
        ),
      );
}

// Main Expense Card Widget with enhanced interaction animations
class ExpenseCard extends StatelessWidget {
  const ExpenseCard({
    super.key,
    required this.expense,
    this.elevation = 2,
    this.shadowOpacity = 0.1,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
  });

  final ExpenseEntity expense;
  final double elevation;
  final double shadowOpacity;
  final void Function(TapDownDetails)? onTapDown;
  final void Function(TapUpDetails)? onTapUp;
  final VoidCallback? onTapCancel;

  @override
  Widget build(BuildContext context) => Card(
        elevation: elevation,
        color: Theme.of(context).cardColor,
        shadowColor:
            Theme.of(context).shadowColor.withValues(alpha: shadowOpacity),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: .1),
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: HapticFeedback.lightImpact,
          onTapDown: onTapDown,
          onTapUp: onTapUp,
          onTapCancel: onTapCancel,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExpenseIcon(expense: expense),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ExpenseContent(expense: expense),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 12,
                right: 16,
                child: ExpenseStatusIndicator(expense: expense),
              ),
            ],
          ),
        ),
      );
}

// Expense Icon Widget
class ExpenseIcon extends StatelessWidget {
  const ExpenseIcon({
    super.key,
    required this.expense,
  });

  final ExpenseEntity expense;

  @override
  Widget build(BuildContext context) => Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: context.colorScheme.tertiary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          Icons.category_rounded,
          color: context.colorScheme.primary,
          size: 24,
        ),
      );
}

// Expense Content Widget
class ExpenseContent extends StatelessWidget {
  const ExpenseContent({
    super.key,
    required this.expense,
  });

  final ExpenseEntity expense;

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '$difference days ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExpenseHeaderRow(expense: expense),
          const SizedBox(height: 4),
          ExpenseCategoryDateRow(
            expense: expense,
            formattedDate: _formatDate(expense.date),
          ),
          const SizedBox(height: 8),
          ExpenseDetailsRow(expense: expense),
          const SizedBox(height: 4),
          ExpenseLocationRow(expense: expense),
          if (expense.recurring.isRecurring) ...[
            const SizedBox(height: 8),
            ExpenseRecurringIndicator(expense: expense),
          ],
        ],
      );
}

// Expense Header Row (Name + Amount)
class ExpenseHeaderRow extends StatelessWidget {
  const ExpenseHeaderRow({
    super.key,
    required this.expense,
  });

  final ExpenseEntity expense;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Text(
              expense.name,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            CurrencyFormatter.format(expense.amount),
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: expense.amount < 0
                  ? context.colorScheme.error
                  : context.colorScheme.primary,
            ),
          ),
        ],
      );
}

// Category and Date Row
class ExpenseCategoryDateRow extends StatelessWidget {
  const ExpenseCategoryDateRow({
    super.key,
    required this.expense,
    required this.formattedDate,
  });

  final ExpenseEntity expense;
  final String formattedDate;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: context.colorScheme.tertiary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              expense.categoryName,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.primary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formattedDate,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      );
}

// Details Row (Payment Method + Time)
class ExpenseDetailsRow extends StatelessWidget {
  const ExpenseDetailsRow({
    super.key,
    required this.expense,
  });

  final ExpenseEntity expense;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          if (expense.paymentMethod.isNotEmpty) ...[
            ExpenseDetailItem(
              icon: Icons.account_balance_wallet_outlined,
              text: expense.paymentMethod,
            ),
            const SizedBox(width: 12),
          ],
          ExpenseDetailItem(
            icon: Icons.access_time_outlined,
            text: expense.time,
          ),
        ],
      );
}

// Location Row
class ExpenseLocationRow extends StatelessWidget {
  const ExpenseLocationRow({
    super.key,
    required this.expense,
  });

  final ExpenseEntity expense;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          if (expense.location.isNotEmpty)
            Icon(
              Icons.location_on_outlined,
              size: 14,
              color: context.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              expense.location,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
}

// Recurring Indicator
class ExpenseRecurringIndicator extends StatelessWidget {
  const ExpenseRecurringIndicator({
    super.key,
    required this.expense,
  });

  final ExpenseEntity expense;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: context.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: context.colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.autorenew,
                  size: 12,
                  color: context.colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  expense.recurring.frequency,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}

// Detail Item Widget (Reusable for payment method, time, etc.)
class ExpenseDetailItem extends StatelessWidget {
  const ExpenseDetailItem({
    super.key,
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: context.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
        ],
      );
}

// Status Indicator Widget
class ExpenseStatusIndicator extends StatelessWidget {
  const ExpenseStatusIndicator({
    super.key,
    required this.expense,
  });

  final ExpenseEntity expense;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Green checkmark indicator (always shown)
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: context.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              Icons.check,
              size: 12,
              color: context.colorScheme.primary,
            ),
          ),
          // Show budget goal indicator at the bottom if expense is linked to a budget goal
          if (expense.budgetGoalId != null &&
              expense.budgetGoalId!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: context.colorScheme.tertiary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: context.colorScheme.secondary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.account_balance_outlined,
                    size: 12,
                    color: context.colorScheme.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    context.l10n.budget, // Using localization
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.secondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      );
}
