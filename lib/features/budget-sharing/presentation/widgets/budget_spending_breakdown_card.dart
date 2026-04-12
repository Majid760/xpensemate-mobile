import 'package:flutter/material.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';

class SpendingMember {

  const SpendingMember({
    required this.name,
    required this.initials,
    required this.amount,
    required this.avatarColor,
    required this.progress,
  });
  final String name;
  final String initials;
  final String amount;
  final Color avatarColor;
  final double progress;
}

class BudgetSpendingBreakdownCard extends StatelessWidget {
  const BudgetSpendingBreakdownCard({
    super.key,
    required this.members,
  });

  final List<SpendingMember> members;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.3)),
      ),
      child: Column(  
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spending breakdown',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          ...members.asMap().entries.map((entry) {
            final index = entry.key;
            final m = entry.value;
            final isLast = index == members.length - 1;
            
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                     CircleAvatar(
          radius: 20,
          backgroundColor: scheme.primary.withValues(alpha: 0.1),
          child: Text(
            m.initials,
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.primary,
            ),
          ),
        ),
                      const SizedBox(width: 12),
                      Text(
                        m.name,
                        style: context.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        m.amount,
                        style: context.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                   Divider(color: scheme.onPrimary.withValues(alpha: 0.1), height: 1),
              ],
            );
          }),
          const SizedBox(height: 16),
          // Multi-segmented or single progress bar
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: scheme.onPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: (members.isNotEmpty ? members.first.progress * 100 : 0).toInt(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(3)),
                    ),
                  ),
                ),
                Expanded(
                  flex: 100 - (members.isNotEmpty ? members.first.progress * 100 : 0).toInt(),
                  child: const SizedBox(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
