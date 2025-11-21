import 'package:flutter/material.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';

class BudgetAppBar extends StatelessWidget {
  const BudgetAppBar({super.key, this.onChanged, required this.defaultPeriod});

  final ValueChanged<String>? onChanged;
  final String defaultPeriod;

  @override
  Widget build(BuildContext context) => SliverAppBar(
        expandedHeight: 60,
        pinned: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        flexibleSpace: FlexibleSpaceBar(
          titlePadding: EdgeInsets.only(left: context.md, bottom: context.md),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: context.md),
            decoration: BoxDecoration(
              color: context.colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: PopupMenuButton<String>(
              onSelected: onChanged,
              initialValue: defaultPeriod,
              icon: Icon(
                Icons.tune_rounded,
                color: context.colorScheme.onPrimary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'weekly',
                  child: Text(context.l10n.weeklyInsights),
                ),
                PopupMenuItem(
                  value: 'monthly',
                  child: Text(context.l10n.monthlyInsight),
                ),
                PopupMenuItem(
                  value: 'quarterly',
                  child: Text(context.l10n.quarterInsight),
                ),
                PopupMenuItem(
                  value: 'yearly',
                  child: Text(context.l10n.yearlyInsight),
                ),
              ],
            ),
          ),
        ],
      );
}
