import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/route/utils/router_extension.dart';
import 'package:xpensemate/core/service/permission_service.dart';
import 'package:xpensemate/core/service/service_locator.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/utils/app_utils.dart';
import 'package:xpensemate/core/widget/app_button.dart';
import 'package:xpensemate/core/widget/app_custom_dialog.dart';
import 'package:xpensemate/core/widget/app_dialogs.dart';
import 'package:xpensemate/core/widget/app_snackbar.dart';
import 'package:xpensemate/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:xpensemate/features/profile/presentation/cubit/cubit/profile_cubit.dart';
import 'package:xpensemate/features/profile/presentation/cubit/cubit/profile_state.dart';
import 'package:xpensemate/features/profile/presentation/pages/profile_edit_page.dart';
import 'package:xpensemate/features/profile/presentation/widgets/profile_content_item_widget.dart';
import 'package:xpensemate/features/profile/presentation/widgets/profile_widgets.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.onBackTap});

  final void Function()? onBackTap;

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

  final ScrollController _scrollController = ScrollController();
  bool _showUserName = false;
  double _titleProgress = 0;

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
        setState(() => _titleProgress = progress);
      }
    });
  }

  void _handleLogout(BuildContext context) {
    AppCustomDialogs.showLogout(
      context: context,
      onConfirm: () async {
        await context.read<AuthCubit>().signOut();
        if (context.mounted) context.goToLogin();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileError) {
          AppSnackBar.show(
            context: context,
            message: state.message,
            type: SnackBarType.error,
          );
        } else if (state is ProfileLoaded && state.message != null) {
          AppSnackBar.show(
            context: context,
            message: state.message!,
            type: state.message == 'updated'
                ? SnackBarType.success
                : SnackBarType.info,
          );
          context.read<ProfileCubit>().clearError();
        }
      },
      child: BlocBuilder<ProfileCubit, ProfileState>(
        buildWhen: (previous, current) =>
            current is ProfileLoaded ||
            current is ProfileLoading ||
            current is ProfileError,
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is ProfileError) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message),
                    context.md.heightBox,
                    AppButton.primary(
                      text: l10n.retry,
                      onPressed: () =>
                          context.read<ProfileCubit>().updateProfile({}),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is! ProfileLoaded) {
            return Scaffold(
              body: Center(child: Text(l10n.userSessionNotFound)),
            );
          }

          final profileState = state;
          return Scaffold(
            backgroundColor: colorScheme.surface,
            body: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.tertiary,
                  ],
                  stops: const [0.0, 0.5],
                ),
              ),
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    expandedHeight: 250,
                    pinned: true,
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    centerTitle: true,
                    title: AppBarTitle(
                      displayName: profileState.displayName,
                      progress: _titleProgress,
                    ),
                    leading: Padding(
                      padding: EdgeInsets.only(left: context.md),
                      child: GestureDetector(
                        onTap: widget.onBackTap,
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    actions: [
                      Padding(
                        padding: EdgeInsets.only(right: context.md),
                        child: AppBarActions(
                          progress: _titleProgress,
                          profileState: profileState,
                          onEditTap: () => showEditProfile(context),
                        ),
                      ),
                    ],
                    flexibleSpace: CustomFlexibleSpace(
                      profileState: profileState,
                      fadeAnimation: _fadeAnimation,
                      slideAnimation: _slideAnimation,
                      titleProgress: _titleProgress,
                      onCameraTap: () => _handleImagePicker(context),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: ModernContent(
                            profileState: profileState,
                            onLogoutTap: () => _handleLogout(context),
                            onComingSoon: (str) => showEditProfile(context),
                            isDarkMode:
                                profileState.themeMode == ThemeMode.dark,
                            onThemeChanged: (bool value) {
                              context
                                  .read<ProfileCubit>()
                                  .toggleTheme(isDark: value);
                              HapticFeedback.selectionClick();
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleImagePicker(BuildContext context) async {
    final result = await sl.permissions.requestMultiplePermissions(
      [AppPermission.camera, AppPermission.gallery],
    );
    if (mounted && (result[AppPermission.camera]?.isGranted ?? false)) {
      final currentContext = context;
      if (currentContext.mounted) {
        await AppDialogs.showImagePicker(
          context: currentContext,
          onImageSelected: (file) {
            if (file != null) {
              currentContext.read<ProfileCubit>().updateProfileImage(file);
            }
          },
        );
      }
    }
  }
}
