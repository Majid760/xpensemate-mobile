// Stats Row Widget
import 'package:flutter/material.dart';

class StatsRow extends StatelessWidget {
  const StatsRow({
    super.key,
    required this.spent,
    required this.remaining,
    required this.deadline,
    required this.isOverdue,
    required this.categoryColor,
  });

  final double spent;
  final double remaining;
  final String deadline;
  final bool isOverdue;
  final Color categoryColor;

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

  // Format date to show only last two digits of year
  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';

    try {
      final DateTime dueDate;
      if (dateStr.contains('-')) {
        if (dateStr.contains('T')) {
          dueDate = DateTime.parse(dateStr);
        } else {
          final parts = dateStr.split(' ');
          if (parts.isNotEmpty) {
            dueDate = DateTime.parse(parts[0]);
          } else {
            return dateStr.split(' ')[0];
          }
        }
      } else {
        return dateStr;
      }

      // Format as MM/dd/yy
      final year = dueDate.year.toString().substring(2); // Last two digits
      return '${dueDate.month.toString().padLeft(2, '0')}/${dueDate.day.toString().padLeft(2, '0')}/$year';
    } on Exception catch (_) {
      // If parsing fails, try to extract the date part and format it
      try {
        final parts = dateStr.split(' ');
        if (parts.isNotEmpty) {
          final datePart = parts[0];
          if (datePart.contains('-')) {
            final dateParts = datePart.split('-');
            if (dateParts.length >= 3) {
              final year = dateParts[0].substring(2); // Last two digits of year
              return '${dateParts[1]}/${dateParts[2]}/$year';
            }
          }
        }
      } catch (_) {
        // If all else fails, return original string
      }
      return dateStr.split(' ')[0];
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              categoryColor.withValues(alpha: 0.05),
              categoryColor.withValues(alpha: 0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: categoryColor.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: ModernStat(
                icon: Icons.trending_up_rounded,
                label: 'Spent',
                value: '\$${_formatAmount(spent)}', // Use formatted amount
                iconColor: categoryColor,
              ),
            ),
            Container(
              height: 40,
              width: 1,
              color: const Color(0xFFE5E7EB),
            ),
            Expanded(
              child: ModernStat(
                icon: Icons.account_balance_wallet_rounded,
                label: 'Left',
                value: '\$${_formatAmount(remaining)}', // Use formatted amount
                iconColor: remaining > 0
                    ? const Color(0xFF10B981)
                    : const Color(0xFFEF4444),
              ),
            ),
            Container(
              height: 40,
              width: 1,
              color: const Color(0xFFE5E7EB),
            ),
            Expanded(
              child: ModernStat(
                icon: Icons.calendar_today_rounded,
                label: 'Due',
                value: _formatDate(deadline), // Use formatted date
                iconColor: _isOverdue()
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF3B82F6),
                valueStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _isOverdue()
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF64748B),
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ],
        ),
      );
}

// Modern Stat Widget
class ModernStat extends StatelessWidget {
  const ModernStat({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    this.valueStyle,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: valueStyle ??
                const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                  letterSpacing: -0.5,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9CA3AF),
              letterSpacing: 0.2,
            ),
          ),
        ],
      );
}
