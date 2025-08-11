import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/colors/app_colors.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/features/auth/presentation/cubit/auth_cubit.dart';
import 'dart:ui' show lerpDouble;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  final ScrollController _scrollController = ScrollController();
  bool _showUserName = false;
  double _titleProgress = 0.0;

  bool isDarkMode = false;
  static const String userName = 'John Doe';
  static const String userEmail = 'john.doe@example.com';
  static const String profileImageUrl =
      'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face';

  // Modern gradient colors
  static const _gradientColors = [
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
    Color(0xFFA855F7),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeScrollListener();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutQuart),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _pulseAnimation = Tween<double>(begin: 1, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    _fadeController.forward();
    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  void _initializeScrollListener() {
    _scrollController.addListener(() {
      final showUserName = _scrollController.offset > 140;
      final progress = (_scrollController.offset / 140).clamp(0.0, 1.0);
      if (_showUserName != showUserName) {
        setState(() {
          _showUserName = showUserName;
          _titleProgress = progress;
        });
      } else {
        // Update progress to drive opacity even if threshold state doesn't flip
        setState(() {
          _titleProgress = progress;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.colorScheme.surface,
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _gradientColors,
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 180,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: Colors.transparent,
                centerTitle: true,
                title: Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(
                      opacity: 1.0 - _titleProgress,
                      child: Text(
                        context.l10n.profile,
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Opacity(
                      opacity: _titleProgress,
                      child: Text(
                        userName,
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                leading: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color:  Colors.white,
                      ),
                    )),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Opacity(
                      opacity: (1.0 - _titleProgress).clamp(0.0, 1.0),
                      child: IgnorePointer(
                        ignoring: _titleProgress > 0.05,
                        child: _buildGlassmorphicButton(
                          icon: Icons.edit_rounded,
                          onTap: () => _showComingSoon(context.l10n.edit),
                        ),
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _gradientColors,
                        stops: [0.0, 0.5, 1.0],
                      ),
                    ),
                    child: SafeArea(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final Alignment targetAlignment = Alignment.lerp(
                                const Alignment(0, 0.25),
                                const Alignment(0.85, -0.75),
                                _titleProgress,
                              ) ??
                              const Alignment(0, 0.25);
                          final double scale = lerpDouble(1.0, 0.5, _titleProgress) ?? 1.0;
                          final double topBarHeight = MediaQuery.of(context).padding.top + kToolbarHeight;
                          return Stack(
                            children: [
                              // Gradient overlay for the app bar area when collapsed
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                height: topBarHeight + 20, // Extend slightly to cover shadow area
                                child: Opacity(
                                  opacity: _titleProgress,
                                  child: const DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: _gradientColors,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: targetAlignment,
                                child: Transform.scale(
                                  scale: scale,
                                  child: FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: SlideTransition(
                                      position: _slideAnimation,
                                      child: _buildFloatingProfileImage(),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: context.colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildModernContent(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildGlassmorphicButton(
          {required IconData icon, required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
      );

  Widget _buildFloatingProfileImage() => Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF6366F1),
                  Color(0xFF8B5CF6),
                  Color(0xFFA855F7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: ClipOval(
                  child: Image.network(
                    profileImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _gradientColors,
                        ),
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 2,
            right: 2,
            child: GestureDetector(
              onTap: () => _showComingSoon(context.l10n.changeProfilePhoto),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ),
        ],
      );

  Widget _buildModernContent(BuildContext context) => Column(
        children: [
          SizedBox(height: context.lg),
          _buildUserInfoCard(context),
          SizedBox(height: context.lg),
          ..._buildMenuSections(context),
          SizedBox(height: context.xl),
          _buildModernFooter(context),
          SizedBox(height: context.lg),
        ],
      );

  Widget _buildUserInfoCard(BuildContext context) => Container(
        margin: EdgeInsets.symmetric(horizontal: context.lg),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Text(
              userName,
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: context.colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: context.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                userEmail,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6366F1),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildCompactStatCard(BuildContext context, String title,
          String amount, IconData icon, Color color, String change) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    change,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              amount,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: context.colorScheme.onSurface,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      );

  Widget _buildQuickActionButton(
          BuildContext context, String label, IconData icon, Color color) =>
      GestureDetector(
        onTap: () => _showComingSoon(label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.1),
                color.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );

  List<Widget> _buildMenuSections(BuildContext context) => [
        _buildModernMenuSection(
            context, context.l10n.account, _getAccountMenuItems(context)),
        SizedBox(height: context.lg),
        _buildModernMenuSection(context, context.l10n.preferences,
            _getPreferencesMenuItems(context)),
        SizedBox(height: context.lg),
        _buildModernMenuSection(
            context, context.l10n.support, _getSupportMenuItems(context)),
      ];

  List<MenuItemData> _getAccountMenuItems(BuildContext context) => [
        MenuItemData(
          icon: Icons.person_outline_rounded,
          title: context.l10n.editProfile,
          subtitle: context.l10n.updatePersonalInfo,
          color: const Color(0xFF3B82F6),
          onTap: () => _showComingSoon(context.l10n.edit),
        ),
        MenuItemData(
          icon: Icons.security_rounded,
          title: context.l10n.privacySecurity,
          subtitle: context.l10n.managePrivacySettings,
          color: const Color(0xFF10B981),
          onTap: () => _showComingSoon(context.l10n.privacySecurity),
        ),
        MenuItemData(
          icon: Icons.notifications_outlined,
          title: context.l10n.notifications,
          subtitle: context.l10n.configureNotifications,
          color: const Color(0xFFF59E0B),
          onTap: () => _showComingSoon(context.l10n.notifications),
        ),
      ];

  List<Widget> _getPreferencesMenuItems(BuildContext context) => [
        _buildModernThemeToggle(context),
        _buildModernMenuItem(
          MenuItemData(
            icon: Icons.language_rounded,
            title: context.l10n.language,
            subtitle: context.l10n.choosePreferredLanguage,
            color: const Color(0xFF8B5CF6),
            onTap: () => _showComingSoon(context.l10n.language),
          ),
        ),
      ];

  List<MenuItemData> _getSupportMenuItems(BuildContext context) => [
        MenuItemData(
          icon: Icons.help_outline_rounded,
          title: context.l10n.helpSupport,
          subtitle: context.l10n.getHelpWhenNeeded,
          color: const Color(0xFF06B6D4),
          onTap: () => _showComingSoon(context.l10n.helpSupport),
        ),
        MenuItemData(
          icon: Icons.info_outline_rounded,
          title: context.l10n.about,
          subtitle: context.l10n.learnMoreAboutExpenseTracker,
          color: const Color(0xFF84CC16),
          onTap: () => _showComingSoon(context.l10n.about),
        ),
        MenuItemData(
          icon: Icons.logout_rounded,
          title: context.l10n.signOut,
          subtitle: context.l10n.logoutFromAccount,
          color: const Color(0xFFEF4444),
          onTap: _showLogoutDialog,
          isDestructive: true,
        ),
      ];

  Widget _buildModernMenuSection(
          BuildContext context, String title, List<dynamic> items) =>
      Container(
        margin: EdgeInsets.symmetric(horizontal: context.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 16),
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
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.08),
                ),
              ),
              child: Column(
                children: items.asMap().entries.map<Widget>((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isLast = index == items.length - 1;

                  Widget child;
                  if (item is MenuItemData) {
                    child = _buildModernMenuItem(item);
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
                          margin: const EdgeInsets.symmetric(horizontal: 18),
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                context.colorScheme.outline
                                    .withValues(alpha: 0.3),
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

  Widget _buildModernMenuItem(MenuItemData item) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            item.onTap();
          },
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        item.color.withValues(alpha: 0.15),
                        item.color.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: item.color.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Icon(item.icon, color: item.color, size: 20),
                ),
                SizedBox(width: context.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: context.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: item.isDestructive
                              ? const Color(0xFFEF4444)
                              : context.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: context.xs),
                      Text(
                        item.subtitle,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
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

  Widget _buildModernThemeToggle(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF8B5CF6).withValues(alpha: 0.18),
                    const Color(0xFFA855F7).withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.22),
                ),
              ),
              child: Icon(
                isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: const Color(0xFF8B5CF6),
                size: 20,
              ),
            ),
            SizedBox(width: context.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.darkMode,
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: context.xs),
                  Text(
                    context.l10n.switchBetweenLightAndDarkTheme,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: isDarkMode
                    ? const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)])
                    : const LinearGradient(colors: [Color(0xFFE5E7EB), Color(0xFFD1D5DB)]),
                boxShadow: [
                  BoxShadow(
                    color: (isDarkMode ? const Color(0xFF8B5CF6) : Colors.black)
                        .withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ), 
              child: Transform.scale(
                scale: 0.6,
                child: Switch.adaptive(
                  value: isDarkMode,
                  onChanged: (value) {
                    setState(() => isDarkMode = value);
                    HapticFeedback.selectionClick();
                  },
                  activeColor: Colors.white,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.transparent,
                  activeTrackColor: Colors.transparent,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildModernFooter(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        margin: EdgeInsets.symmetric(horizontal: context.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF6366F1).withValues(alpha: 0.03),
              const Color(0xFF8B5CF6).withValues(alpha: 0.03),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF6366F1).withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            SizedBox(height: context.md),
            Text(
              context.l10n.expenseTracker,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: context.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: context.xs),
            Text(
              context.l10n.version,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: context.sm),
            Text(
              context.l10n.craftedWithLove,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );

  void _showComingSoon(String feature) => showDialog<void>(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.rocket_launch_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  SizedBox(height: context.xl),
                  Text(
                    feature,
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: context.md),
                  Text(
                    'This amazing feature is coming soon!\nStay tuned for updates.',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.xl),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ).copyWith(
                        backgroundColor:
                            WidgetStateProperty.all(Colors.transparent),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            context.l10n.gotIt,
                            style: context.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  void _showLogoutDialog() => showDialog<void>(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFEF4444).withValues(alpha: 0.1),
                          const Color(0xFFEF4444).withValues(alpha: 0.05),
                        ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: Color(0xFFEF4444),
                      size: 40,
                    ),
                  ),
                  SizedBox(height: context.xl),
                  Text(
                    context.l10n.signOut,
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: context.md),
                  Text(
                    context.l10n.areYouSureYouWantToSignOut,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.xl),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            backgroundColor:
                                context.colorScheme.surfaceContainerHighest,
                          ),
                          child: Text(
                            context.l10n.cancel,
                            style: context.textTheme.bodyLarge?.copyWith(
                              color: context.colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: context.md),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            context.read<AuthCubit>().signOut();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ).copyWith(
                            backgroundColor:
                                WidgetStateProperty.all(Colors.transparent),
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                context.l10n.signOut,
                                style: context.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class MenuItemData {
  const MenuItemData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool isDestructive;
}
