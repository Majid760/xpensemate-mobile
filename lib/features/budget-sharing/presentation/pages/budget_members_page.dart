import 'package:flutter/material.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/app_spacing.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/features/auth/presentation/widgets/background_decoration_widget.dart' show BackgroundDecoration;
import 'package:xpensemate/features/budget-sharing/presentation/widgets/budget_member_list_item.dart';
import 'package:xpensemate/features/budget-sharing/presentation/widgets/budget_members_card.dart';
import 'package:xpensemate/features/budget-sharing/presentation/widgets/budget_members_stats_tab.dart';
import 'package:xpensemate/features/budget-sharing/presentation/widgets/budget_members_tab_header.dart';
import 'package:xpensemate/features/budget-sharing/presentation/widgets/invite_member_button.dart';
import 'package:xpensemate/features/budget-sharing/presentation/widgets/member_options_sheet.dart';
import 'package:xpensemate/features/budget-sharing/presentation/widgets/pending_invite_card.dart';

class BudgetMembersPage extends StatefulWidget {
  const BudgetMembersPage({super.key});

  @override
  State<BudgetMembersPage> createState() => _BudgetMembersPageState();
}

class _BudgetMembersPageState extends State<BudgetMembersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
      _tabController.animateTo(index);
    });
  }

  // ── Shows the member-options bottom sheet ──────────────────────────────
  void _showMemberOptions(BuildContext context, BudgetMember member) {
    final scheme = context.colorScheme;
    final isDark = context.theme.brightness == Brightness.dark;

    // Which roles can be assigned depends on the current role.
    // Owner cannot be changed from within this sheet; Editor/Viewer can swap.
    final assignableRoles = [context.l10n.editor, context.l10n.viewer];

    MemberOptionsSheet.show(
      context: context,
      name: member.name,
      email: member.email,
      initials: member.initials,
      currentRole: member.role,
      avatarColor: isDark
          ? scheme.primary.withValues(alpha: 0.15)
          : scheme.primaryContainer,
      avatarTextColor: isDark ? scheme.primary : scheme.onPrimaryContainer,
      availableRoles: assignableRoles,
      onSave: (newRole) {
        // TODO: dispatch cubit event with newRole
      },
      onRevoke: () {
        // TODO: dispatch cubit revoke event
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final isDark = context.theme.brightness == Brightness.dark;

    final members = [
      BudgetMember(
        name: 'Majid Khan',
        email: 'majid@email.com',
        initials: 'MK',
        role: context.l10n.owner,
        avatarColor: scheme.primaryContainer,
        roleColor: isDark
            ? scheme.primary.withValues(alpha: 0.15)
            : scheme.primaryContainer,
        roleTextColor: isDark ? scheme.primary : scheme.onPrimaryContainer,
      ),
      BudgetMember(
        name: 'Sara Raza',
        email: 'sara@email.com',
        initials: 'SR',
        role: context.l10n.editor,
        avatarColor: scheme.secondaryContainer,
        roleColor: isDark
            ? scheme.secondary.withValues(alpha: 0.15)
            : scheme.secondaryContainer,
        roleTextColor: isDark ? scheme.secondary : scheme.onSecondaryContainer,
      ),
      BudgetMember(
        name: 'Ahmed Khan',
        email: 'ahmed@email.com',
        initials: 'AK',
        role: context.l10n.viewer,
        avatarColor: scheme.tertiaryContainer,
        roleColor: isDark
            ? scheme.tertiary.withValues(alpha: 0.15)
            : scheme.tertiaryContainer,
        roleTextColor: isDark ? scheme.tertiary : scheme.onTertiaryContainer,
      ),
      BudgetMember(
        name: 'Nadia Fatima',
        email: 'nadia@email.com',
        initials: 'NF',
        role: context.l10n.editor,
        avatarColor: scheme.secondaryContainer,
        roleColor: isDark
            ? scheme.secondary.withValues(alpha: 0.15)
            : scheme.secondaryContainer,
        roleTextColor: isDark ? scheme.secondary : scheme.onSecondaryContainer,
      ),
    ];

    return Stack(
      
      children:[
            // ── Decorative background geometry ──────────────────────────
     BackgroundDecoration(isDark: isDark),
        Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: scheme.onPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          context.l10n.budgetMembers,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: scheme.onPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: BudgetMembersTabHeader(
            selectedIndex: _selectedIndex,
            onTabSelected: _onTabSelected,
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _MembersTab(
            members: members,
            onMenuPressed: (m) => _showMemberOptions(context, m),
          ),
          const _PendingTab(),
          const BudgetMembersStatsTab(),
        ],
      ),
    ),

      ],
    );
  }
}

// ── Members tab ────────────────────────────────────────────────────────────
class _MembersTab extends StatelessWidget {
  const _MembersTab({
    required this.members,
    required this.onMenuPressed,
  });

  final List<BudgetMember> members;
  final void Function(BudgetMember) onMenuPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final spentAmounts = [null, '12', '0', '5'];

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm1, AppSpacing.md, AppSpacing.md),
            itemCount: members.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm1),
                  child: Text(
                    context.l10n.memberCount(members.length).toUpperCase(),
                    style: context.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface.withValues(alpha: 0.6),
                      letterSpacing: 1.2,
                    ),
                  ),
                );
              }
              
              final mIndex = index - 1;
              final m = members[mIndex];
              final rawAmount = mIndex < spentAmounts.length ? spentAmounts[mIndex] : null;

              return BudgetMemberListItem(
                name: mIndex == 0 ? '${m.name} (you)' : m.name,
                email: m.email,
                spentAmount: rawAmount != null
                    ? context.l10n.spentWithAmount(rawAmount)
                    : null,
                initials: m.initials,
                role: m.role,
                roleColor: m.roleColor,
                roleTextColor: m.roleTextColor,
                showMenu: mIndex != 0, // owner has no options menu
                onMenuPressed: () => onMenuPressed(m),
              );
            },
          ),
        ),
        Container(
          padding: EdgeInsets.only(
            left: AppSpacing.md,
            right: AppSpacing.md,
            top: AppSpacing.lg,
            bottom: MediaQuery.paddingOf(context).bottom + AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: scheme.surface,
            border: Border(
              top: BorderSide(
                color: scheme.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
          ),
          child: InviteMemberButton(onPressed: () {}),
        ),
      ],
    );
  }
}


// ── Pending tab ────────────────────────────────────────────────────────────
class _PendingTab extends StatelessWidget {
  const _PendingTab();

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.md),
          Text(
            context.l10n.sentInvites.toUpperCase(),
            style: context.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colorScheme.onSurface.withValues(alpha: 0.5),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          PendingInviteCard(
            email: 'zara@email.com',
            initials: 'ZA',
            roleDescription: context.l10n.invitedAs(
              context.l10n.editor,
              context.l10n.daysAgo(2),
            ),
            statusLabel: context.l10n.pending,
            revokeLabel: context.l10n.revoke,
            resendLabel: context.l10n.resend,
            onRevoke: () {},
            onResend: () {},
          ),
          PendingInviteCard(
            email: 'fatima@email.com',
            initials: 'FM',
            roleDescription: context.l10n.invitedAs(
              context.l10n.viewer,
              context.l10n.daysAgo(5),
            ),
            statusLabel: context.l10n.pending,
            revokeLabel: context.l10n.revoke,
            resendLabel: context.l10n.resend,
            onRevoke: () {},
            onResend: () {},
          ),
        ],
      ),
    );
}
