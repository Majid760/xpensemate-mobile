import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:xpensemate/core/theme/colors/app_colors.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/widget/app_bottom_sheet.dart';
import 'package:xpensemate/features/budget/domain/entities/budget_goal_entity.dart';
import 'package:xpensemate/features/budget/presentation/cubit/budget_cubit.dart';
import 'package:xpensemate/features/budget/presentation/widgets/budget_expenses.dart';
import 'package:xpensemate/features/budget/presentation/widgets/stats_row.dart';

class BudgetGoalCard extends StatefulWidget {
  const BudgetGoalCard({
    super.key,
    required this.budgetGoal,
    this.onStatusChange,
  });

  final BudgetGoalEntity budgetGoal;
  final void Function(String)? onStatusChange;

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
      String value, BudgetGoalEntity budgetGoal, BuildContext context) {
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _budgetGoal.amount > 0
        ? math.min(_budgetGoal.currentSpending / _budgetGoal.amount, 1.0)
        : 0.0;
    final remaining = _budgetGoal.amount - _budgetGoal.currentSpending;
    final isCompleted = progress >= 1.0;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: () {},
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
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
  });

  final String title;
  final String category;
  final double amount;
  final String deadline;
  final Color categoryColor;
  final bool isCompleted;
  final bool isOverdue;
  final String status;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: categoryColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            TopHeader(
              title: title,
              category: category,
              isCompleted: isCompleted,
              isOverdue: isOverdue,
            ),
            const SizedBox(height: 8),
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
  });

  final String title;
  final String category;
  final bool isCompleted;
  final bool isOverdue;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          if (isCompleted) ...[
            StatusIcon(isCompleted: isCompleted),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: TitleCategory(title: title, category: category),
          ),
          const SizedBox(width: 8),
          const MenuButton(),
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
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            category.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white.withValues(alpha: 0.8),
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
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.25),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isCompleted ? Icons.check_rounded : Icons.warning_rounded,
          size: 20,
          color: Colors.white,
        ),
      );
}

// Menu Button Widget
class MenuButton extends StatelessWidget {
  const MenuButton({super.key});

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(10),
        ),
        child: PopupMenuButton<String>(
          icon: const Icon(
            Icons.more_vert_rounded,
            size: 20,
            color: Colors.white,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          offset: const Offset(0, 8),
          padding: const EdgeInsets.all(6),
          onSelected: (value) {
            if (value == 'edit') {
            } else if (value == 'expenses') {
              AppBottomSheet.showScrollable(
                context: context,
                title: 'Expenses',
                config: BottomSheetConfig(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  blurSigma: 5,
                  barrierColor:
                      context.theme.primaryColor.withValues(alpha: 0.4),
                ),
                child: const ExpenseScreen(),
              );
            }
          },
          itemBuilder: (context) => [
            MenuItemWidget(
              icon: Icons.edit_outlined,
              text: 'Edit',
              value: 'edit',
            ),
            MenuItemWidget(
              icon: Icons.edit_outlined,
              text: 'Expenses',
              value: 'expenses',
            ),
            MenuItemWidget(
              icon: Icons.share_outlined,
              text: 'Share',
              value: 'share',
            ),
            MenuItemWidget(
              icon: Icons.archive_outlined,
              text: 'Archive',
              value: 'archive',
            ),
            const PopupMenuDivider(),
            MenuItemWidget(
              icon: Icons.delete_outline_rounded,
              text: 'Delete',
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
                ? const Color(0xFFEF4444)
                : const Color(0xFF6B7280),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isDestructive
                  ? const Color(0xFFEF4444)
                  : const Color(0xFF111827),
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

  String _calculateDaysStatus() {
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
        return '$diffDays days left';
      } else if (diffDays == 1) {
        return '1 day left';
      } else if (diffDays == 0) {
        return 'Due today';
      } else {
        final absDiff = diffDays.abs();
        return 'Overdue by $absDiff day${absDiff > 1 ? 's' : ''}';
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
          const Text(
            r'$',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _formatAmount(amount), // Use formatted amount
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1,
              letterSpacing: -1,
            ),
          ),
          if (status == "active") ...[
            const SizedBox(width: 16),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                _calculateDaysStatus(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: status == "active" && _isOverdue()
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF64748B),
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
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            ProgressSection(
              progress: progress,
              categoryColor: categoryColor,
              status: status,
              onStatusChange: onStatusChange,
            ),
            const SizedBox(height: 14),
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
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progress',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(widget.progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: widget.categoryColor,
                    ),
                  ),
                  const SizedBox(width: 6),
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    icon: Container(
                      padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
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
                          const SizedBox(width: 6),
                          Text(
                            _status,
                            style: TextStyle(
                              fontSize: 14,
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
                        text: 'Active',
                        value: 'active',
                      ),
                      MenuItemWidget(
                        icon: Icons.star,
                        text: 'Achieved',
                        value: 'achieved',
                      ),
                      MenuItemWidget(
                        icon: Icons.sms_failed,
                        text: 'Failed',
                        value: 'failed',
                      ),
                      MenuItemWidget(
                        icon: Icons.terminal,
                        text: 'Terminated',
                        value: 'terminated',
                        // isDestructive: true,
                      ),
                      MenuItemWidget(
                        icon: Icons.more_horiz,
                        text: 'Other',
                        value: 'other',
                        // isDestructive: true,
                      ),
                    ],
                  ),

                  // const Text(
                  //   'complete',
                  //   style: TextStyle(
                  //     fontSize: 14,
                  //     fontWeight: FontWeight.w500,
                  //     color: Color(0xFF9CA3AF),
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: widget.progress.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation<Color>(widget.categoryColor),
            ),
          ),
        ],
      );
}
