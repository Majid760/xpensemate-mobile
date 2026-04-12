import 'package:flutter/material.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/widget/app_button.dart';

class BudgetActivityItem {

  const BudgetActivityItem({
    required this.description,
    required this.time,
    required this.dotColor,
  });
  final String description;
  final String time;
  final Color dotColor;
}

class BudgetActivityCard extends StatelessWidget {
  const BudgetActivityCard({
    super.key,
    required this.activities,
    required this.onSeeAll,
  });

  final List<BudgetActivityItem> activities;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Activity Feed',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
              AppButton.outline(
                height: 36,
                minWidth: 80,
                isFullWidth: false,
                borderRadius: 10,
                text: 'Share',
                backgroundColor: scheme.primary.withValues(alpha: 0.1),
                textColor: scheme.primary,
                borderColor: scheme.primary.withValues(alpha: 0.5),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._buildActivityList(context, activities),
        ],
      ),
    );
  }

  List<Widget> _buildActivityList(BuildContext context, List<BudgetActivityItem> activities) {
    final children = <Widget>[];
    final scheme = context.colorScheme;

    for (var i = 0; i < activities.length; i++) {
      final act = activities[i];
      final isLast = i == activities.length - 1;

      children.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: scheme.onSurface.withValues(alpha: 0.4),
                        margin: const EdgeInsets.only(top: 4, bottom: 4),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        act.description,
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            act.time,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                          const Spacer(),
                          if (!isLast && i == 0) // The little downward arrow shown in the photo
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: scheme.primary.withValues(alpha: 0.3)),
                              ),
                              child: Icon(Icons.arrow_downward, size: 12, color: scheme.primary),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return children;
  }
}
