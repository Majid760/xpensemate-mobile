import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/app_spacing.dart';
import 'package:xpensemate/core/theme/colors/app_colors.dart';
import 'package:xpensemate/core/theme/theme_constant.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/utils/app_logger.dart';
import 'package:xpensemate/core/widget/animated_card_widget.dart';
import 'package:xpensemate/core/widget/app_custom_dialog.dart';
import 'package:xpensemate/core/widget/app_dismissible_widget.dart';
import 'package:xpensemate/features/budget/domain/entities/budget_goal_entity.dart';
import 'package:xpensemate/features/budget/presentation/cubit/budget_cubit.dart';
import 'package:xpensemate/features/budget/presentation/widgets/stats_row.dart';

class BudgetGoalCard extends StatefulWidget {
  const BudgetGoalCard({
    super.key,
    required this.budgetGoal,
    required this.index,
    this.onStatusChange,
    this.onEdit,
    this.onDelete,
    this.onSelect,
    this.onTap,
  });

  final BudgetGoalEntity budgetGoal;
  final int index;
  final void Function(String)? onStatusChange;
  final void Function(BudgetGoalEntity)? onEdit;
  final void Function(String id)? onDelete;
  final void Function(String id)? onSelect;
  final void Function()? onTap;

  @override
  State<BudgetGoalCard> createState() => _BudgetGoalCardState();
}

class _BudgetGoalCardState extends State<BudgetGoalCard>
    with SingleTickerProviderStateMixin {
  late String _status;
  late BudgetGoalEntity _budgetGoal;

  @override
  void initState() {
    super.initState();
    _budgetGoal = widget.budgetGoal;
    _status = _budgetGoal.status;
  }

  @override
  void didUpdateWidget(BudgetGoalCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.budgetGoal != oldWidget.budgetGoal) {
      _budgetGoal = widget.budgetGoal;
      _status = _budgetGoal.status;
    }
  }

  void _updateStatus(String value) {
    if (value.isNotEmpty && value != _status) {
      widget.onStatusChange?.call(value);
      try {
        context.budgetCubit.updateBudgetGoal(
          _budgetGoal.copyWith(status: value),
        );
        setState(() {
          _status = value;
        });
      } on Exception catch (e, stack) {
        AppLogger.e('Failed to update budget status', e, stack);
      }
    }
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

  @override
  Widget build(BuildContext context) {
    final progress = _budgetGoal.amount > 0
        ? math.min(_budgetGoal.currentSpending / _budgetGoal.amount, 1)
        : 0.0;
    final remaining = _budgetGoal.amount - _budgetGoal.currentSpending;
    final isCompleted = progress >= 1.0;

    return AnimatedCardWidget(
      index: widget.index,
      child: AppDismissible(
          objectKey: 'budget_${_budgetGoal.id}',
          onDeleteConfirm: () async {
            final result = await _showDeleteConfirmation(context);
            if (result ?? false) {
              widget.onDelete?.call(_budgetGoal.id);
            }
            return result ?? false;
          },
          onEdit: () => widget.onEdit?.call(widget.budgetGoal),
          child: Card(
            elevation: 2,
            color: context.theme.cardColor,
            shadowColor: context.theme.shadowColor.withValues(alpha: .1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ThemeConstants.radiusLarge),
              side: BorderSide(
                color: context.theme.dividerColor.withValues(alpha: .1),
              ),
            ),
            child: InkWell(
              onTap:widget.onTap,
              onTapDown: (_) => HapticFeedback.selectionClick(),
              borderRadius: BorderRadius.circular(ThemeConstants.radiusLarge),
              child: Column(
                children: [
                  _BudgetTopSection(
                    title: _budgetGoal.name,
                    category: _budgetGoal.category,
                    amount: _budgetGoal.amount,
                    deadline: _budgetGoal.date.toString(),
                    categoryColor: context.primaryColor,
                    isCompleted: isCompleted,
                    isOverdue:
                        false, // Logic moved inside if needed or kept simple
                    status: _status,
                    budgetGoalEntity: _budgetGoal,
                    onSelected: widget.onSelect,
                  ),
                  _BudgetBottomSection(
                    progress: progress.toDouble(),
                    spent: _budgetGoal.currentSpending,
                    remaining: remaining,
                    deadline: _budgetGoal.date.toString(),
                    isOverdue: false,
                    status: _status,
                    categoryColor: context.primaryColor,
                    onStatusChange: _updateStatus,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }
}

class _BudgetTopSection extends StatelessWidget {
  const _BudgetTopSection({
    required this.title,
    required this.category,
    required this.amount,
    required this.deadline,
    required this.categoryColor,
    required this.isCompleted,
    required this.isOverdue,
    required this.status,
    required this.budgetGoalEntity,
    this.onSelected,
  });

  final String title;
  final String category;
  final double amount;
  final String deadline;
  final Color categoryColor;
  final bool isCompleted;
  final bool isOverdue;
  final String status;
  final BudgetGoalEntity budgetGoalEntity;
  final void Function(String)? onSelected;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: categoryColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(ThemeConstants.radiusXLarge),
            topRight: Radius.circular(ThemeConstants.radiusXLarge),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                if (isCompleted) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color:
                          context.colorScheme.onPrimary.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 20,
                      color: context.colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.colorScheme.onPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        category.toUpperCase(),
                        style: context.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.colorScheme.onPrimary
                              .withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _MenuButton(
                  budgetGoalEntity: budgetGoalEntity,
                  onSelected: onSelected,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            _AmountDisplay(
              amount: amount,
              deadline: deadline,
              status: status,
            ),
          ],
        ),
      );
}

class _AmountDisplay extends StatelessWidget {
  const _AmountDisplay({
    required this.amount,
    required this.deadline,
    required this.status,
  });

  final double amount;
  final String deadline;
  final String status;

  String _calculateDaysStatus(BuildContext context) {
    if (deadline.isEmpty) return '';

    try {
      final DateTime dueDate;
      if (deadline.contains('-')) {
        if (deadline.contains('T')) {
          dueDate = DateTime.parse(deadline);
        } else {
          final parts = deadline.split(' ');
          if (parts.isNotEmpty) {
            dueDate = DateTime.parse(parts[0]);
          } else {
            return '';
          }
        }
      } else {
        return '';
      }

      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      final dueDateOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);
      final diffDays = dueDateOnly.difference(todayDate).inDays;

      if (diffDays > 0) {
        return context.l10n.daysLeft(diffDays);
      } else if (diffDays == 0) {
        return context.l10n.dueToday;
      } else {
        return context.l10n.overdueBy(diffDays.abs(), context.l10n.day);
      }
    } on Exception catch (_) {
      return '';
    }
  }

  bool _isOverdue() {
    if (deadline.isEmpty) return false;
    try {
      final dueDate = DateTime.parse(deadline);
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      final dueDateOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);
      return dueDateOnly.isBefore(todayDate);
    } on Exception catch (_) {
      return false;
    }
  }

  String _formatAmount(double amount, BuildContext context) {
    if (amount >= 10000) {
      return '${(amount / 1000).toStringAsFixed(1)}k';
    }
    return amount.toInt().toString();
  }

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            context.l10n.currencySymbol,
            style: context.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colorScheme.onPrimary,
              height: 1,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            _formatAmount(amount, context),
            style: context.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colorScheme.onPrimary,
              height: 1,
              letterSpacing: -1,
            ),
          ),
          if (status == "active") ...[
            const SizedBox(width: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Text(
                _calculateDaysStatus(context),
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: status == "active" && _isOverdue()
                      ? context.colorScheme.error
                      : context.colorScheme.onPrimary.withValues(alpha: 0.8),
                ),
              ),
            ),
          ],
        ],
      );
}

class _BudgetBottomSection extends StatelessWidget {
  const _BudgetBottomSection({
    required this.progress,
    required this.spent,
    required this.remaining,
    required this.deadline,
    required this.isOverdue,
    required this.status,
    required this.categoryColor,
    this.onStatusChange,
  });

  final double progress;
  final double spent;
  final double remaining;
  final String deadline;
  final bool isOverdue;
  final Color categoryColor;
  final String status;
  final void Function(String)? onStatusChange;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            _ProgressSection(
              progress: progress,
              categoryColor: categoryColor,
              status: status,
              onStatusChange: onStatusChange,
            ),
            const SizedBox(height: AppSpacing.md),
            StatsRow(
              spent: spent,
              remaining: remaining,
              deadline: deadline,
              isOverdue: isOverdue,
              categoryColor: categoryColor,
            ),
          ],
        ),
      );
}

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({
    required this.progress,
    required this.status,
    required this.categoryColor,
    this.onStatusChange,
  });

  final double progress;
  final Color categoryColor;
  final String status;
  final void Function(String)? onStatusChange;

  Color _getStatusColor(String status, BuildContext context) {
    switch (status) {
      case 'active':
        return context.theme.colorScheme.primary;
      case 'achieved':
        return AppColors.success;
      case 'failed':
        return context.colorScheme.error;
      case 'terminated':
        return context.colorScheme.onSurfaceVariant;
      case 'other':
        return AppColors.warning;
      default:
        return context.colorScheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.budgetProgress,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: categoryColor,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _buildStatusDropdown(context),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(ThemeConstants.radiusSmall),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: context.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
            ),
          ),
        ],
      );

  Widget _buildStatusDropdown(BuildContext context) => PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        icon: Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xs,
            AppSpacing.xs,
            AppSpacing.md,
            AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _getStatusColor(status, context),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.arrow_drop_down,
                size: 18,
                color: _getStatusColor(status, context),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                status,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _getStatusColor(status, context),
                ),
              ),
            ],
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMedium),
        ),
        offset: const Offset(0, 8),
        initialValue: status,
        onSelected: onStatusChange,
        itemBuilder: (context) => [
          _buildPopupMenuItem(context, 'active', Icons.local_activity,
              context.l10n.statusActive,),
          _buildPopupMenuItem(
              context, 'achieved', Icons.star, context.l10n.statusAchieved,),
          _buildPopupMenuItem(
              context, 'failed', Icons.sms_failed, context.l10n.statusFailed,),
          _buildPopupMenuItem(context, 'terminated', Icons.terminal,
              context.l10n.statusTerminated,),
          _buildPopupMenuItem(
              context, 'other', Icons.more_horiz, context.l10n.other,),
        ],
      );

  PopupMenuItem<String> _buildPopupMenuItem(
    BuildContext context,
    String value,
    IconData icon,
    String text,
  ) =>
      PopupMenuItem<String>(
        value: value,
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: context.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              text,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.budgetGoalEntity,
    this.onSelected,
  });

  final BudgetGoalEntity budgetGoalEntity;
  final void Function(String)? onSelected;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: context.colorScheme.onPrimary.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(10),
        ),
        child: PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert_rounded,
            size: 20,
            color: context.colorScheme.onPrimary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          offset: const Offset(0, 8),
          padding: const EdgeInsets.all(AppSpacing.xs),
          onSelected: onSelected,
          itemBuilder: (context) => [
            _buildMenuItem(
                context, 'edit', Icons.edit_outlined, context.l10n.edit,),
            _buildMenuItem(context, 'expenses', Icons.edit_outlined,
                context.l10n.expense,), // Used 'Expense' key
            _buildMenuItem(
                context, 'share', Icons.share_outlined, context.l10n.share,),
            _buildMenuItem(context, 'archive', Icons.archive_outlined,
                context.l10n.archive,),
            const PopupMenuDivider(),
            _buildMenuItem(context, 'delete', Icons.delete_outline_rounded,
                context.l10n.delete,
                isDestructive: true,),
          ],
        ),
      );

  PopupMenuItem<String> _buildMenuItem(
    BuildContext context,
    String value,
    IconData icon,
    String text, {
    bool isDestructive = false,
  }) =>
      PopupMenuItem<String>(
        value: value,
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDestructive
                  ? context.colorScheme.error
                  : context.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              text,
              style: context.textTheme.bodyMedium?.copyWith(
                color: isDestructive
                    ? context.colorScheme.error
                    : context.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
}
