import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/utils/currency_formatter.dart';
import 'package:xpensemate/core/widget/app_bottom_sheet.dart';
import 'package:xpensemate/core/widget/app_custom_dialog.dart';
import 'package:xpensemate/features/expense/domain/entities/expense_entity.dart';
import 'package:xpensemate/features/expense/presentation/cubit/expense_cubit.dart';
import 'package:xpensemate/features/expense/presentation/widgets/expense_form_widget.dart';
import 'package:xpensemate/l10n/app_localizations.dart';

// Main ExpenseListItem Widget with smooth entrance animations
class ExpenseListItem extends StatefulWidget {
  const ExpenseListItem({
    super.key,
    required this.expense,
    this.isLast = false,
    this.onDelete,
    this.onEdit,
    this.index = 0,
  });

  final ExpenseEntity expense;
  final bool isLast;
  final void Function(String expenseId)? onDelete;
  final void Function(ExpenseEntity expenseEntity)? onEdit;
  final int index;

  @override
  State<ExpenseListItem> createState() => _ExpenseListItemState();
}

class _ExpenseListItemState extends State<ExpenseListItem>
    with TickerProviderStateMixin {
  // Smooth entrance animation controller
  late AnimationController _entranceController;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  // Interaction animation controller (for tap effects)
  late AnimationController _interactionController;
  late Animation<double> _interactionScaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<Offset> _translateAnimation;
  late Animation<double> _shadowOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _initializeEntranceAnimations();
    _initializeInteractionAnimations();
    _startEntranceAnimation();
  }

  void _initializeEntranceAnimations() {
    // Slower animation duration for smoothness
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Smooth slide animation
    _slideAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutQuad,
    );

    // Gentle scale animation
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.05, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 100,
      ),
    ]).animate(_entranceController);

    // Fade in animation
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    ));
  }

  void _initializeInteractionAnimations() {
    _interactionController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _interactionScaleAnimation = Tween<double>(begin: 1, end: 0.96).animate(
      CurvedAnimation(parent: _interactionController, curve: Curves.easeInOut),
    );

    _elevationAnimation = Tween<double>(begin: 2, end: 10).animate(
      CurvedAnimation(parent: _interactionController, curve: Curves.easeInOut),
    );

    _translateAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -2),
    ).animate(
      CurvedAnimation(parent: _interactionController, curve: Curves.easeInOut),
    );

    _shadowOpacityAnimation = Tween<double>(begin: 0.1, end: 0.3).animate(
      CurvedAnimation(parent: _interactionController, curve: Curves.easeInOut),
    );
  }

  void _startEntranceAnimation() {
    // Stagger delay based on index - 150ms per item
    Future.delayed(Duration(milliseconds: 150 * widget.index), () {
      if (mounted) {
        _entranceController.forward();
      }
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _interactionController.dispose();
    super.dispose();
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    bool? confirmResult;

    await AppCustomDialogs.showDelete(
      context: context,
      title: localizations?.delete ?? 'Delete',
      message:
          '${localizations?.confirmDelete ?? 'Are you sure you want to delete this item?'}\n\n${localizations?.deleteWarning ?? 'This action cannot be undone.'}',
      onConfirm: () => confirmResult = true,
      onCancel: () => confirmResult = false,
    );

    return confirmResult;
  }

  void _handleDelete() {
    widget.onDelete?.call(widget.expense.id);
  }

  void _addExpense(ExpenseEntity entity, BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    AppBottomSheet.show<ExpenseEntity>(
      context: context,
      title: entity.id.isEmpty ? 'Add Expense' : 'Edit Expense',
      config: BottomSheetConfig(
        minHeight: screenHeight * 0.8,
        maxHeight: screenHeight * 0.95,
        padding: EdgeInsets.zero,
      ),
      child: ExpenseFormWidget(
        expense: entity.id.isEmpty ? null : entity,
        onSave: (updatedEntity) {
          if (entity.id.isEmpty) {
            context.expenseCubit.createExpense(expense: updatedEntity);
          } else {
            context.expenseCubit.updateExpense(expense: updatedEntity);
          }
          Navigator.of(context).pop();
        },
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation:
            Listenable.merge([_entranceController, _interactionController]),
        builder: (context, child) {
          return Transform.translate(
            // Smooth entrance slide up from 50px below
            offset: Offset(0, 50 * (1 - _slideAnimation.value)) +
                _translateAnimation.value,
            child: Transform.scale(
              // Combine entrance scale with interaction scale
              scale: _scaleAnimation.value * _interactionScaleAnimation.value,
              alignment: Alignment.center,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Container(
                  margin: EdgeInsets.only(
                    bottom: widget.isLast ? 0 : 12,
                  ),
                  child: ExpenseDismissible(
                    expense: widget.expense,
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
                      elevation: _elevationAnimation.value,
                      shadowOpacity: _shadowOpacityAnimation.value,
                      onTapDown: (_) {
                        HapticFeedback.selectionClick();
                        _interactionController.forward();
                      },
                      onTapUp: (_) => _interactionController.reverse(),
                      onTapCancel: () => _interactionController.reverse(),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
}

// Dismissible Wrapper Widget with fade-out effect
class ExpenseDismissible extends StatelessWidget {
  const ExpenseDismissible({
    super.key,
    required this.expense,
    required this.child,
    required this.onDeleteConfirm,
    required this.onEdit,
  });

  final ExpenseEntity expense;
  final Widget child;
  final Future<bool> Function() onDeleteConfirm;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => Dismissible(
        key: Key('dismissible_${expense.id}'),
        background: const DismissBackground(
          alignment: Alignment.centerLeft,
          color: Colors.red,
          icon: Icons.delete,
          label: 'Delete',
        ),
        secondaryBackground: const DismissBackground(
          alignment: Alignment.centerRight,
          color: Colors.blue,
          icon: Icons.edit,
          label: 'Edit',
        ),
        confirmDismiss: (direction) async {
          await HapticFeedback.mediumImpact();
          if (direction == DismissDirection.startToEnd) {
            return await onDeleteConfirm();
          } else if (direction == DismissDirection.endToStart) {
            onEdit();
            return false;
          }
          return false;
        },
        dismissThresholds: const {
          DismissDirection.startToEnd: 0.4,
          DismissDirection.endToStart: 0.4,
        },
        child: child,
      );
}

// Static Dismiss Background Widget
class DismissBackground extends StatelessWidget {
  const DismissBackground({
    super.key,
    required this.alignment,
    required this.color,
    required this.icon,
    required this.label,
  });

  final Alignment alignment;
  final Color color;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: alignment,
        padding: EdgeInsets.only(
          left: alignment == Alignment.centerLeft ? 20 : 0,
          right: alignment == Alignment.centerRight ? 20 : 0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
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
        shadowColor: Theme.of(context).shadowColor.withOpacity(shadowOpacity),
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExpenseIcon(expense: expense),
                const SizedBox(width: 16),
                Expanded(
                  child: ExpenseContent(expense: expense),
                ),
                ExpenseStatusIndicator(expense: expense),
              ],
            ),
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
          if (expense.location.isNotEmpty) ...[
            const SizedBox(height: 4),
            ExpenseLocationRow(expense: expense),
          ],
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
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            CurrencyFormatter.format(expense.amount),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: expense.amount < 0
                      ? Theme.of(context).colorScheme.error
                      : Colors.green,
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
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formattedDate,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
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
          Icon(
            Icons.location_on_outlined,
            size: 14,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              expense.location,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
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
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.autorenew, size: 12, color: Colors.blue),
                const SizedBox(width: 4),
                Text(
                  expense.recurring.frequency,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.blue,
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
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
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
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(
              Icons.check,
              size: 12,
              color: Colors.green,
            ),
          ),
        ],
      );
}
