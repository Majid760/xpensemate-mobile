import 'package:flutter/material.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/route/utils/router_extension.dart';
import 'package:xpensemate/core/theme/app_spacing.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/widget/app_button.dart';
import 'package:xpensemate/features/dashboard/domain/entities/budget_goals_entity.dart';
import 'package:xpensemate/features/dashboard/presentation/widgets/budget_card_widget.dart';
import 'package:xpensemate/features/dashboard/presentation/widgets/section_header_widget.dart';

class ActiveBudgetSectionWidget extends StatelessWidget {
  const ActiveBudgetSectionWidget({
    super.key,
    required this.budgetGoals,
  });

  final BudgetGoalsEntity budgetGoals;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.all(context.md),
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSpacing.md1),
          border: Border.all(
            color: context.colorScheme.outline.withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: context.colorScheme.shadow.withValues(alpha: 0.08),
              blurRadius: AppSpacing.md1,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: context.colorScheme.primary.withValues(alpha: 0.02),
              blurRadius: AppSpacing.sm,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: context.md),
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppSpacing.md),
            border: Border.all(
              color: context.colorScheme.outline.withValues(alpha: 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: context.colorScheme.shadow.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeaderWidget(
                title: context.l10n.activeBudgets,
                icon: Icons.account_balance_wallet_outlined,
                action: AppButton.textButton(
                  text: context.l10n.seeDetail,
                  textColor: context.primaryColor,
                  onPressed: context.goToBudget,
                ),
              ),
              SizedBox(height: context.lg),
              SizedBox(height: context.md),
              _BudgetList(budgetGoals: budgetGoals),
              SizedBox(height: context.md),
            ],
          ),
        ),
      );
}

class _BudgetList extends StatelessWidget {
  const _BudgetList({
    required this.budgetGoals,
  });

  final BudgetGoalsEntity budgetGoals;

  @override
  Widget build(BuildContext context) {
    // Filter active goals (status != 'completed') and take top 3
    final activeGoals = budgetGoals.goals
        .where((goal) => !goal.status.toLowerCase().contains('completed'))
        .take(3)
        .toList();

    if (activeGoals.isEmpty) {
      return const _EmptyState();
    }

    return LayoutBuilder(
      builder: (context, constraints) => Column(
        children: [
          ...activeGoals.map(
            (goal) => Padding(
              padding: EdgeInsets.only(bottom: context.md),
              child: BudgetCard(goal: goal),
            ),
          ),
          AppButton.textButton(
            text: context.l10n.seeDetail,
            textColor: context.primaryColor,
            onPressed: context.goToBudget,
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => Container(
        height: AppSpacing.xxxl * 2, // 128
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bubble_chart,
              size: AppSpacing.iconLg,
              color: context.colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: context.sm),
            Text(
              context.l10n.noBudgetsActive,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
}
