import 'package:flutter/material.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';

enum FilterValue { weekly, monthly, quarterly, yearly }

extension FilterValueX on FilterValue {
  String getLocalizedInsightsTitle(BuildContext context) {
    switch (this) {
      case FilterValue.weekly:
        return context.l10n.weeklyInsights;
      case FilterValue.monthly:
        return context.l10n.monthlyInsight;
      case FilterValue.quarterly:
        return context.l10n.quarterlyInsights;
      case FilterValue.yearly:
        return context.l10n.yearlyInsights;
    }
  }
}

enum BudgetStatus { active, completed, terminated, failed, archived, other }
