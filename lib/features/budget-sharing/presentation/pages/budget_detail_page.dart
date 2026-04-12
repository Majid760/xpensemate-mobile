import 'package:flutter/material.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/features/budget-sharing/presentation/pages/budget_members_page.dart';
import 'package:xpensemate/features/budget-sharing/presentation/widgets/budget_activity_card.dart';
import 'package:xpensemate/features/budget-sharing/presentation/widgets/budget_detail_header.dart';
import 'package:xpensemate/features/budget-sharing/presentation/widgets/budget_members_card.dart';
import 'package:xpensemate/features/budget-sharing/presentation/widgets/budget_progress_card.dart';
import 'package:xpensemate/features/budget-sharing/presentation/widgets/budget_spending_breakdown_card.dart';

class BudgetDetailPage extends StatefulWidget {
  const BudgetDetailPage({super.key});

  @override
  State<BudgetDetailPage> createState() => _BudgetDetailPageState();
}
class _BudgetDetailPageState extends State<BudgetDetailPage> {
  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final isDark = context.theme.brightness == Brightness.dark;

    // Stubbed members for UI demonstration
    final members = [
      BudgetMember(
        name: 'Majid Khan',
        email: 'you@email.com',
        initials: 'MK',
        role: context.l10n.owner,
        avatarColor: scheme.primaryContainer,
        roleColor: isDark ? scheme.primary.withValues(alpha: 0.15) : scheme.primaryContainer,
        roleTextColor: isDark ? scheme.primary : scheme.onPrimaryContainer,
      ),
      BudgetMember(
        name: 'Sara Raza',
        email: 'sara@email.com',
        initials: 'SR',
        role: context.l10n.editor,
        avatarColor: scheme.secondaryContainer,
        roleColor: isDark ? scheme.secondary.withValues(alpha: 0.15) : scheme.secondaryContainer,
        roleTextColor: isDark ? scheme.secondary : scheme.onSecondaryContainer,
      ),
      BudgetMember(
        name: 'Ahmed Khan',
        email: 'ahmed@email.com',
        initials: 'AK',
        role: context.l10n.viewer,
        avatarColor: scheme.tertiaryContainer,
        roleColor: isDark ? scheme.tertiary.withValues(alpha: 0.15) : scheme.tertiaryContainer,
        roleTextColor: isDark ? scheme.tertiary : scheme.onTertiaryContainer,
      ),
    ];

    // Stubbed activities for UI demonstration
    final activities = [
      BudgetActivityItem(
        description: r'Sara added a transaction $12 Groceries',
        time: '2 hours ago',
        dotColor: scheme.onPrimary,
      ),
      BudgetActivityItem(
        description: 'Ahmed joined as Viewer',
        time: '5 hours ago',
        dotColor: scheme.onPrimary,
      ),
    ];

    // Stubbed spending breakdown
    final spendingMembers = [
      const SpendingMember(
        name: 'Majid Khan (you)',
        initials: 'MK',
        amount: r'$0',
        avatarColor: Color(0xFFE0F2F1), // Very light teal
        progress: 0.1,
      ),
      const SpendingMember(
        name: 'Sara Raza',
        initials: 'SR',
        amount: r'$12',
        avatarColor: Color(0xFFE3F2FD), // Very light blue
        progress: 0.9,
      ),
    ];

    return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            const BudgetDetailHeader(
              category: 'ENTERTAINMENT',
              name: 'fun',
              amount: r'$23',
            ),
            const SizedBox(height: 16),
            const BudgetProgressCard(
              progress: 0,
              statusText: 'achieved',
            ),
            const SizedBox(height: 8),
            BudgetMembersCard(
              members: members,
              onViewAll: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (context) => const BudgetMembersPage()),
              ),
            ),
            const SizedBox(height: 8),
            BudgetSpendingBreakdownCard(
              members: spendingMembers,
            ),
            const SizedBox(height: 8),
            BudgetActivityCard(
              activities: activities,
              onSeeAll: () {},
            ),
            const SizedBox(height: 24), // Padding bottom
          ],
        ),
      
    );
  }
}
