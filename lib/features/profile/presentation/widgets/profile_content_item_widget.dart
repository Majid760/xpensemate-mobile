import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/features/profile/presentation/cubit/cubit/profile_cubit.dart';
import 'package:xpensemate/features/profile/presentation/cubit/cubit/profile_state.dart';
import 'package:xpensemate/features/profile/presentation/pages/profile_page.dart';
import 'package:xpensemate/features/profile/presentation/widgets/footer_widget.dart';

class ModernContent extends StatelessWidget {
  const ModernContent({super.key, 
    required this.profileState,
    required this.onLogoutTap,
    required this.onComingSoon,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  final ProfileState profileState;
  final VoidCallback onLogoutTap;
  final void Function(String) onComingSoon;
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    if (profileState.status == ProfileStatus.loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (profileState.status == ProfileStatus.error || profileState.user == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(context.xl),
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 64, color: context.colorScheme.error),
              SizedBox(height: context.md),
              Text('Failed to load profile', style: context.textTheme.titleMedium),
              SizedBox(height: context.md),
              ElevatedButton(
                onPressed: (){},
                // onPressed: () => context.profileCubit.refreshProfile(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(height: context.lg),
        _UserInfoCard(profileState: profileState),
        SizedBox(height: context.lg),
        ..._buildMenuSections(context),
        SizedBox(height: context.xl),
        const ModernFooter(),
        SizedBox(height: context.lg),
      ],
    );
  }

  List<Widget> _buildMenuSections(BuildContext context) => [
        _ModernMenuSection(
          title: context.l10n.account,
          items: _accountMenuItems(context),
        ),
        SizedBox(height: context.lg),
        _ModernMenuSection(
          title: context.l10n.preferences,
          items: [
            ThemeToggle(
              isDarkMode: isDarkMode,
              onChanged: onThemeChanged,
            ),
            _ModernMenuItem(
              data: MenuItemData(
                icon: Icons.language_rounded,
                title: context.l10n.language,
                subtitle: context.l10n.choosePreferredLanguage,
                color: const Color(0xFF8B5CF6),
                onTap: () => onComingSoon(context.l10n.language),
              ),
            ),
          ],
        ),
        SizedBox(height: context.lg),
        _ModernMenuSection(
          title: context.l10n.support,
          items: _supportMenuItems(context),
        ),
      ];

  List<MenuItemData> _accountMenuItems(BuildContext context) => [
        MenuItemData(
          icon: Icons.person_outline_rounded,
          title: context.l10n.editProfile,
          subtitle: context.l10n.updatePersonalInfo,
          color: const Color(0xFF3B82F6),
          onTap: () => onComingSoon(context.l10n.edit),
        ),
        MenuItemData(
          icon: Icons.security_rounded,
          title: context.l10n.privacySecurity,
          subtitle: context.l10n.managePrivacySettings,
          color: const Color(0xFF10B981),
          onTap: () => onComingSoon(context.l10n.privacySecurity),
        ),
        MenuItemData(
          icon: Icons.notifications_outlined,
          title: context.l10n.notifications,
          subtitle: context.l10n.configureNotifications,
          color: const Color(0xFFF59E0B),
          onTap: () => onComingSoon(context.l10n.notifications),
        ),
      ];

  List<MenuItemData> _supportMenuItems(BuildContext context) => [
        MenuItemData(
          icon: Icons.help_outline_rounded,
          title: context.l10n.helpSupport,
          subtitle: context.l10n.getHelpWhenNeeded,
          color: const Color(0xFF06B6D4),
          onTap: () => onComingSoon(context.l10n.helpSupport),
        ),
        MenuItemData(
          icon: Icons.info_outline_rounded,
          title: context.l10n.about,
          subtitle: context.l10n.learnMoreAboutExpenseTracker,
          color: const Color(0xFF84CC16),
          onTap: () => onComingSoon(context.l10n.about),
        ),
        MenuItemData(
          icon: Icons.logout_rounded,
          title: context.l10n.signOut,
          subtitle: context.l10n.logoutFromAccount,
          color: const Color(0xFFEF4444),
          onTap: onLogoutTap,
          isDestructive: true,
        ),
      ];
}



class _UserInfoCard extends StatelessWidget {
  const _UserInfoCard({required this.profileState});

  final ProfileState profileState;

  @override
  Widget build(BuildContext context) {
    final user = profileState.user!;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: context.lg),
      padding: EdgeInsets.symmetric(vertical: context.lg),
      child: Column(
        children: [
          // Email chip
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.sm,
              vertical: context.xs,
            ),
            decoration: BoxDecoration(
              color: context.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: context.colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              user.email,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colorScheme.primary,
              ),
            ),
          ),
          // Bio under email if available
          if ((user.about ?? '').isNotEmpty) ...[
            SizedBox(height: context.sm),
            Text(
              user.about!,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (!profileState.isProfileComplete) ...[
            SizedBox(height: context.md),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.sm,
                vertical: context.xs,
              ),
              decoration: BoxDecoration(
                color: context.colorScheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.colorScheme.secondary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: context.colorScheme.secondary,
                  ),
                  SizedBox(width: context.xs),
                  Text(
                    context.l10n.completeYourProfile,
                    style: context.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}




class UserInfoCard extends StatelessWidget {
  const UserInfoCard({super.key, required this.profileState});

  final ProfileState profileState;

  @override
  Widget build(BuildContext context) {
    final user = profileState.user!;
    final displayName = context.profileCubit.displayName;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: context.lg),
      padding: EdgeInsets.symmetric(vertical: context.lg),
      child: Column(
        children: [
          Text(
            displayName,
            style: context.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: context.colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: context.sm),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.sm,
              vertical: context.xs,
            ),
            decoration: BoxDecoration(
              color: context.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: context.colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              user.email,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colorScheme.primary,
              ),
            ),
          ),
          if (!profileState.isProfileComplete) ...[
            SizedBox(height: context.md),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.sm,
                vertical: context.xs,
              ),
              decoration: BoxDecoration(
                color: context.colorScheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.colorScheme.secondary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: context.colorScheme.secondary,
                  ),
                  SizedBox(width: context.xs),
                  Text(
                    'Complete your profile',
                    style: context.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}




class _ModernMenuSection extends StatelessWidget {
  const _ModernMenuSection({required this.title, required this.items});

  final String title;
  final List<dynamic> items;

  @override
  Widget build(BuildContext context) => Container(
      margin: EdgeInsets.symmetric(horizontal: context.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: context.sm, bottom: context.md),
            child: Text(
              title,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: context.colorScheme.onSurface,
                letterSpacing: 0.2,
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: context.colorScheme.shadow.withValues(alpha: 0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: context.colorScheme.primary.withValues(alpha: 0.08),
              ),
            ),
            child: Column(
              children: items.asMap().entries.map<Widget>((entry) {
                final index = entry.key;
                final item = entry.value;
                final isLast = index == items.length - 1;

                Widget child;
                if (item is MenuItemData) {
                  child = _ModernMenuItem(data: item);
                } else if (item is Widget) {
                  child = item;
                } else {
                  child = const SizedBox.shrink();
                }

                return Column(
                  children: [
                    child,
                    if (!isLast)
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: context.lg),
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              context.colorScheme.outline.withValues(alpha: 0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
}




class _ModernMenuItem extends StatelessWidget {
  const _ModernMenuItem({required this.data});

  final MenuItemData data;

  @override
  Widget build(BuildContext context) => Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          data.onTap();
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: EdgeInsets.all(context.md),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.sm),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      data.color.withValues(alpha: 0.15),
                      data.color.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: data.color.withValues(alpha: 0.2),
                  ),
                ),
                child: Icon(data.icon, color: data.color, size: 20),
              ),
              SizedBox(width: context.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: context.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: data.isDestructive
                            ? context.colorScheme.error
                            : context.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: context.xs),
                    Text(
                      data.subtitle,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(context.xs),
                decoration: BoxDecoration(
                  color: context.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: context.colorScheme.onSurfaceVariant,
                  size: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
}
