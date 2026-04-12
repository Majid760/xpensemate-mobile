import 'package:flutter/material.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/app_spacing.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';

class BudgetMembersTabHeader extends StatelessWidget {
  const BudgetMembersTabHeader({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  final int selectedIndex;
  final void Function(int) onTabSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final tabs = [
      context.l10n.members,
      context.l10n.pending,
      context.l10n.stats,
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: scheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: List.generate(
          tabs.length,
          (index) {
            final isSelected = selectedIndex == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => onTabSelected(index),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      child: Text(
                        tabs[index],
                        style: context.textTheme.labelLarge?.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? scheme.primary : scheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 2,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isSelected ? scheme.primary : Colors.transparent,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
