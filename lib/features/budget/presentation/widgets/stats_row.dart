import 'package:flutter/material.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/colors/app_colors.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/utils/app_utils.dart';

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

  DateTime? _parseDate(String dateStr) {
    if (dateStr.isEmpty) return null;
    try {
      if (dateStr.contains('T')) {
        return DateTime.parse(dateStr);
      }
      final parts = dateStr.split(' ');
      if (parts.isNotEmpty) {
        return DateTime.parse(parts[0]);
      }
    } catch (_) {
      // ignore
    }
    return null;
  }

  String _formatDateStr(String dateStr) {
    final date = _parseDate(dateStr);
    if (date != null) {
      // Use AppUtils to format
      return AppUtils.formatDate(date);
    }
    return dateStr.split(' ')[0];
  }

  bool _isOverdue() {
    final date = _parseDate(deadline);
    if (date == null) return false;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final dueDateOnly = DateTime(date.year, date.month, date.day);

    return dueDateOnly.isBefore(todayDate);
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
                label: context.l10n.spent,
                value: '${AppUtils.formatLargeNumber(spent)} \$',
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
                label: context.l10n.remaining,
                value: '${AppUtils.formatLargeNumber(remaining)} \$',
                iconColor: remaining > 0
                    ? AppColors.success
                    : context.theme.colorScheme.error,
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
                label: context.l10n.closestDeadline,
                value: _formatDateStr(deadline),
                iconColor: _isOverdue()
                    ? context.theme.colorScheme.error
                    : context.theme.colorScheme.primary,
                valueStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _isOverdue()
                      ? context.theme.colorScheme.error
                      : context.theme.colorScheme.onSurfaceVariant,
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
                context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colorScheme.onSurfaceVariant,
              letterSpacing: 0.2,
            ),
          ),
        ],
      );
}
