import 'package:flutter/material.dart';
import 'dart:math' as math;

class BudgetGoalCard extends StatefulWidget {
  const BudgetGoalCard({
    super.key,
    required this.title,
    required this.category,
    required this.amount,
    required this.spent,
    required this.deadline,
    required this.overdueDays,
    required this.progress,
    required this.categoryColor,
  });

  final String title;
  final String category;
  final double amount;
  final double spent;
  final String deadline;
  final int overdueDays;
  final double progress;
  final Color categoryColor;

  @override
  State<BudgetGoalCard> createState() => _BudgetGoalCardState();
}

class _BudgetGoalCardState extends State<BudgetGoalCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.amount - widget.spent;
    final isOverdue = widget.overdueDays > 0;
    final isCompleted = widget.progress >= 1.0;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: () {},
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Smaller top section with colored background
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: widget.categoryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    _buildTopHeader(isCompleted, isOverdue),
                    const SizedBox(height: 8),
                    _buildAmountDisplay(),
                  ],
                ),
              ),
              // Bottom white section
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    _buildProgressSection(),
                    const SizedBox(height: 14),
                    _buildStatsRow(remaining, isOverdue),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(bool isCompleted, bool isOverdue) => Row(
      children: [
        // Category icon
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.directions_car_rounded,
            size: 22,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        // Title and category
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
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
                widget.category.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
        // Status and menu
        if (isCompleted || isOverdue)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? Icons.check_rounded : Icons.warning_rounded,
              size: 20,
              color: Colors.white,
            ),
          ),
        const SizedBox(width: 8),
        _buildMenuButton(),
      ],
    );

  Widget _buildMenuButton() => Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(10),
      ),
      child: PopupMenuButton<String>(
        icon:
            const Icon(Icons.more_vert_rounded, size: 20, color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        offset: const Offset(0, 8),
        padding: const EdgeInsets.all(6),
        itemBuilder: (context) => <PopupMenuEntry<String>>[
          _buildMenuItem(Icons.edit_outlined, 'Edit', 'edit'),
          _buildMenuItem(Icons.share_outlined, 'Share', 'share'),
          _buildMenuItem(Icons.archive_outlined, 'Archive', 'archive'),
          const PopupMenuDivider(),
          _buildMenuItem(
            Icons.delete_outline_rounded,
            'Delete',
            'delete',
            isDestructive: true,
          ),
        ],
      ),
    );

  PopupMenuItem<String> _buildMenuItem(
    IconData icon,
    String text,
    String value, {
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
        ),
      );

  Widget _buildAmountDisplay() => Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          '\$',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            height: 1,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '${widget.amount.toInt()}',
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(width: 16),
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            'budget goal',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );

  Widget _buildProgressSection() => Column(
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
                const Text(
                  'complete',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
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

  Widget _buildStatsRow(double remaining, bool isOverdue) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _StatBox(
            label: 'Spent',
            value: '\$${widget.spent.toInt()}',
            icon: Icons.trending_up_rounded,
            color: widget.categoryColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatBox(
            label: 'Left',
            value: '\$${remaining.toInt()}',
            icon: Icons.account_balance_wallet_rounded,
            color: remaining > 0
                ? const Color(0xFF10B981)
                : const Color(0xFFEF4444),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatBox(
            label: isOverdue ? 'Overdue' : 'Due',
            value: isOverdue
                ? '${widget.overdueDays}d'
                : widget.deadline.split(' ')[0],
            icon: Icons.calendar_today_rounded,
            color:
                isOverdue ? const Color(0xFFEF4444) : const Color(0xFF3B82F6),
          ),
        ),
      ],
    );
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
}
