import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/colors/app_colors.dart';
import 'package:xpensemate/core/theme/theme_constant.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/widget/app_bottom_sheet.dart';
import 'package:xpensemate/core/widget/app_custom_dialog.dart';
import 'package:xpensemate/core/widget/app_dismissible_widget.dart';
import 'package:xpensemate/features/budget/domain/entities/budget_goal_entity.dart';
import 'package:xpensemate/features/budget/presentation/cubit/budget_cubit.dart';
import 'package:xpensemate/features/budget/presentation/pages/budget_expenses_page.dart';
import 'package:xpensemate/features/budget/presentation/widgets/stats_row.dart';

class BudgetGoalCard extends StatefulWidget {
  const BudgetGoalCard({
    super.key,
    required this.budgetGoal,
    this.onStatusChange,
    this.onEdit,
    this.onDelete,
  });

  final BudgetGoalEntity budgetGoal;
  final void Function(String)? onStatusChange;
  final void Function(BudgetGoalEntity)? onEdit;
  final void Function(String id)? onDelete;

  @override
  State<BudgetGoalCard> createState() => _BudgetGoalCardState();
}

class _BudgetGoalCardState extends State<BudgetGoalCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late String _status;
  late BudgetGoalEntity _budgetGoal;

  @override
  void initState() {
    super.initState();
    _budgetGoal = widget.budgetGoal;
    _status = _budgetGoal.status;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  void _updateStatus(
    String value,
    BudgetGoalEntity budgetGoal,
    BuildContext context,
  ) {
    if (value.isNotEmpty && value != _status) {
      widget.onStatusChange?.call(value);
      context.budgetCubit.updateBudgetGoal(
        budgetGoal.copyWith(status: value),
      );
      setState(() {
        _status = value;
      });
    }
  }

  void _updateBudgetGoal(BudgetGoalEntity goal) {
    widget.onEdit?.call(widget.budgetGoal);
    // call the cubit function or drigger the the bottomsheet
  }

  @override
  void dispose() {
    _controller.dispose();
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

  void _handleDelete() {
    widget.onDelete?.call(_budgetGoal.id);
  }

  @override
  Widget build(BuildContext context) {
    final progress = _budgetGoal.amount > 0
        ? math.min(_budgetGoal.currentSpending / _budgetGoal.amount, 1.0)
        : 0.0;
    final remaining = _budgetGoal.amount - _budgetGoal.currentSpending;
    final isCompleted = progress >= 1.0;

    return AppDismissible(
      objectKey: 'budget_${_budgetGoal.id}',
      onDeleteConfirm: () async {
        final result = await _showDeleteConfirmation(context);
        if (result ?? false) {
          _handleDelete();
        }
        return result ?? false;
      },
      onEdit: () => _updateBudgetGoal(widget.budgetGoal),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        onTap: () {},
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              borderRadius: BorderRadius.circular(ThemeConstants.radiusXLarge),
              boxShadow: [
                BoxShadow(
                  color: context.colorScheme.shadow.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                TopSection(
                  title: _budgetGoal.name,
                  category: _budgetGoal.category,
                  amount: _budgetGoal.amount,
                  deadline: _budgetGoal.date.toString(),
                  categoryColor: context.primaryColor,
                  isCompleted: isCompleted,
                  status: _status,
                  isOverdue: false,
                  budgetGoalEntity: _budgetGoal,
                ),
                BottomSection(
                  progress: progress,
                  spent: _budgetGoal.currentSpending,
                  remaining: remaining,
                  deadline: _budgetGoal.date.toString(),
                  isOverdue: false,
                  status: _status,
                  categoryColor: context.primaryColor,
                  onStatusChange: (String value) =>
                      _updateStatus(value, _budgetGoal, context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Top Section Widget
class TopSection extends StatelessWidget {
  const TopSection({
    super.key,
    required this.title,
    required this.category,
    required this.amount,
    required this.deadline,
    required this.categoryColor,
    required this.isCompleted,
    required this.isOverdue,
    required this.status,
    required this.budgetGoalEntity,
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

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.all(context.md),
        decoration: BoxDecoration(
          color: categoryColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(ThemeConstants.radiusXLarge),
            topRight: Radius.circular(ThemeConstants.radiusXLarge),
          ),
        ),
        child: Column(
          children: [
            TopHeader(
              title: title,
              category: category,
              isCompleted: isCompleted,
              isOverdue: isOverdue,
              budgetGoalEntity: budgetGoalEntity,
            ),
            SizedBox(height: context.sm),
            AmountDisplay(
              amount: amount,
              deadline: deadline,
              status: status,
            ),
          ],
        ),
      );
}

// Top Header Widget
class TopHeader extends StatelessWidget {
  const TopHeader({
    super.key,
    required this.title,
    required this.category,
    required this.isCompleted,
    required this.isOverdue,
    required this.budgetGoalEntity,
  });

  final String title;
  final String category;
  final bool isCompleted;
  final bool isOverdue;
  final BudgetGoalEntity budgetGoalEntity;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          if (isCompleted) ...[
            StatusIcon(isCompleted: isCompleted),
            SizedBox(width: context.sm),
          ],
          Expanded(
            child: TitleCategory(title: title, category: category),
          ),
          SizedBox(width: context.sm),
          MenuButton(budgetGoalEntity: budgetGoalEntity),
        ],
      );
}

// Title and Category Widget
class TitleCategory extends StatelessWidget {
  const TitleCategory({
    super.key,
    required this.title,
    required this.category,
  });

  final String title;
  final String category;

  @override
  Widget build(BuildContext context) => Column(
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
          SizedBox(height: context.xs),
          Text(
            category.toUpperCase(),
            style: context.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colorScheme.onPrimary.withValues(alpha: 0.8),
            ),
          ),
        ],
      );
}

// Status Icon Widget
class StatusIcon extends StatelessWidget {
  const StatusIcon({
    super.key,
    required this.isCompleted,
  });

  final bool isCompleted;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.all(context.sm),
        decoration: BoxDecoration(
          color: context.colorScheme.onPrimary.withValues(alpha: 0.25),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isCompleted ? Icons.check_rounded : Icons.warning_rounded,
          size: 20,
          color: context.colorScheme.onPrimary,
        ),
      );
}

// Menu Button Widget
class MenuButton extends StatelessWidget {
  const MenuButton({super.key, required this.budgetGoalEntity});
  final BudgetGoalEntity budgetGoalEntity;

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
          padding: EdgeInsets.all(context.xs),
          onSelected: (value) {
            if (value == 'edit') {
            } else if (value == 'expenses') {
              AppBottomSheet.showScrollable<void>(
                context: context,
                title: context.l10n.budget,
                config: BottomSheetConfig(
                  padding: EdgeInsets.symmetric(horizontal: context.sm),
                  blurSigma: 5,
                  barrierColor:
                      context.theme.primaryColor.withValues(alpha: 0.4),
                ),
                child: ExpenseScreen(budgetGoal: budgetGoalEntity),
              );
            }
          },
          itemBuilder: (context) => [
            MenuItemWidget(
              icon: Icons.edit_outlined,
              text: context.l10n.edit,
              value: 'edit',
            ),
            MenuItemWidget(
              icon: Icons.edit_outlined,
              text: context.l10n.expense,
              value: 'expenses',
            ),
            MenuItemWidget(
              icon: Icons.share_outlined,
              text: context.l10n
                  .share, // Using hardcoded string as no localization available
              value: 'share',
            ),
            MenuItemWidget(
              icon: Icons.archive_outlined,
              text: context.l10n
                  .archive, // Using hardcoded string as no localization available
              value: 'archive',
            ),
            const PopupMenuDivider(),
            MenuItemWidget(
              icon: Icons.delete_outline_rounded,
              text: context.l10n.delete,
              value: 'delete',
              isDestructive: true,
            ),
          ],
        ),
      );
}

// Menu Item Widget
class MenuItemWidget extends PopupMenuItem<String> {
  MenuItemWidget({
    super.key,
    required IconData icon,
    required String text,
    required String value,
    bool isDestructive = false,
  }) : super(
          value: value,
          child: _MenuItemContent(
            icon: icon,
            text: text,
            isDestructive: isDestructive,
          ),
        );
}

class _MenuItemContent extends StatelessWidget {
  const _MenuItemContent({
    required this.icon,
    required this.text,
    required this.isDestructive,
  });

  final IconData icon;
  final String text;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isDestructive
                ? context.colorScheme.error
                : context.colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: context.sm),
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
      );
}

// Amount Display Widget
class AmountDisplay extends StatelessWidget {
  const AmountDisplay({
    super.key,
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
            return deadline.split(' ')[0];
          }
        }
      } else {
        return deadline.split(' ')[0];
      }

      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      final dueDateOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);
      final diffDays = dueDateOnly.difference(todayDate).inDays;

      if (diffDays > 1) {
        return '$diffDays days left'; // Using hardcoded string as no localization available
      } else if (diffDays == 1) {
        return '1 day left'; // Using hardcoded string as no localization available
      } else if (diffDays == 0) {
        return 'Due today'; // Using hardcoded string as no localization available
      } else {
        final absDiff = diffDays.abs();
        final dayText = absDiff > 1
            ? 'days'
            : 'day'; // Using hardcoded string as no localization available
        return 'Overdue by $absDiff $dayText'; // Using hardcoded string as no localization available
      }
    } on Exception catch (_) {
      return deadline.split(' ')[0];
    }
  }

  bool _isOverdue() {
    if (deadline.isEmpty) return false;

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
            return false;
          }
        }
      } else {
        return false;
      }

      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      final dueDateOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);

      return dueDateOnly.isBefore(todayDate);
    } on Exception catch (_) {
      return false;
    }
  }

  // Format amount with k for values >= 1000
  String _formatAmount(double amount) {
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
            r'$',
            style: context.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colorScheme.onPrimary,
              height: 1,
            ),
          ),
          SizedBox(width: context.xs),
          Text(
            _formatAmount(amount), // Use formatted amount
            style: context.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colorScheme.onPrimary,
              height: 1,
              letterSpacing: -1,
            ),
          ),
          if (status == "active") ...[
            SizedBox(width: context.md),
            Padding(
              padding: EdgeInsets.only(bottom: context.xs),
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

// Bottom Section Widget
class BottomSection extends StatelessWidget {
  const BottomSection({
    super.key,
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
  // onChange of status method
  final void Function(String)? onStatusChange;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.all(context.lg),
        child: Column(
          children: [
            ProgressSection(
              progress: progress,
              categoryColor: categoryColor,
              status: status,
              onStatusChange: onStatusChange,
            ),
            SizedBox(height: context.md),
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

// Progress Section Widget
class ProgressSection extends StatefulWidget {
  const ProgressSection({
    super.key,
    required this.progress,
    required this.status,
    required this.categoryColor,
    this.onStatusChange,
  });

  final double progress;
  final Color categoryColor;
  final String status;
  final void Function(String)? onStatusChange;

  @override
  State<ProgressSection> createState() => _ProgressSectionState();
}

class _ProgressSectionState extends State<ProgressSection> {
  late String _status = '';

  @override
  void initState() {
    super.initState();
    _status = widget.status;
  }

  Color _getStatusColor(String status, BuildContext context) {
    switch (status) {
      case 'active':
        return context.theme.colorScheme.primary;
      case 'achieved':
        return AppColors.success;
      case 'failed':
        return AppColors.error;
      case 'terminated':
        return AppColors.onSurfaceVariant;
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
                    '${(widget.progress * 100).toInt()}%',
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: widget.categoryColor,
                    ),
                  ),
                  SizedBox(width: context.xs),
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    icon: Container(
                      padding: EdgeInsets.fromLTRB(
                        context.xs,
                        context.xs,
                        context.md,
                        context.xs,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getStatusColor(_status, context),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.arrow_drop_down,
                            size: 18,
                            color: _getStatusColor(_status, context),
                          ),
                          SizedBox(width: context.xs),
                          Text(
                            _status,
                            style: context.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: _getStatusColor(_status, context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    offset: const Offset(0, 8),
                    initialValue: _status,
                    onSelected: (value) {
                      widget.onStatusChange?.call(value);
                      setState(() {
                        _status = value;
                      });
                    },
                    itemBuilder: (context) => [
                      MenuItemWidget(
                        icon: Icons.local_activity,
                        text:
                            'Active', // Using hardcoded string as no localization available
                        value: 'active',
                      ),
                      MenuItemWidget(
                        icon: Icons.star,
                        text:
                            'Achieved', // Using hardcoded string as no localization available
                        value: 'achieved',
                      ),
                      MenuItemWidget(
                        icon: Icons.sms_failed,
                        text:
                            'Failed', // Using hardcoded string as no localization available
                        value: 'failed',
                      ),
                      MenuItemWidget(
                        icon: Icons.terminal,
                        text:
                            'Terminated', // Using hardcoded string as no localization available
                        value: 'terminated',
                        // isDestructive: true,
                      ),
                      MenuItemWidget(
                        icon: Icons.more_horiz,
                        text: context.l10n.other,
                        value: 'other',
                        // isDestructive: true,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: context.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: widget.progress.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: context.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(widget.categoryColor),
            ),
          ),
        ],
      );
}
