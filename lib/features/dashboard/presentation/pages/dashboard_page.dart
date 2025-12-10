import 'package:awesome_drawer_bar/awesome_drawer_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/service/service_locator.dart';
import 'package:xpensemate/core/theme/app_spacing.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/widget/app_image.dart';
import 'package:xpensemate/core/widget/app_snackbar.dart';
import 'package:xpensemate/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:xpensemate/features/dashboard/presentation/widgets/active_budget_section_widget.dart';
import 'package:xpensemate/features/dashboard/presentation/widgets/dashboard_header_widget.dart';
import 'package:xpensemate/features/dashboard/presentation/widgets/product_analytics_widget.dart';
import 'package:xpensemate/features/dashboard/presentation/widgets/weekly_financial_overview_widget.dart';
import 'package:xpensemate/features/profile/presentation/pages/profile_page.dart';

class DashboardPage extends StatefulWidget {
  DashboardPage({
    super.key,
    this.onProfileTap,
  });
  void Function()? onProfileTap;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late ScrollController _scrollController;

  String _currentSectionTitle = '';
  final Map<String, GlobalKey> _sectionKeys = {
    'weeklyFinancialOverview': GlobalKey(),
    'activeBudgets': GlobalKey(),
    'productAnalytics': GlobalKey(),
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeScrollController();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutQuart),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  void _initializeScrollController() {
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Add a check to ensure the widget is still mounted
    if (!mounted) return;
    
    // Determine which section is currently visible
    var newTitle = context.l10n.dashboard;

    // Check each section to see which one is in view
    _sectionKeys.forEach((key, globalKey) {
      final renderBox = globalKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null && mounted) {
        final position = renderBox.localToGlobal(Offset.zero);
        final size = renderBox.size;

        // If the section is in the viewport (top 30% of screen)
        if (position.dy < MediaQuery.of(context).size.height * 0.3 &&
            position.dy + size.height > 0) {
          switch (key) {
            case 'weeklyFinancialOverview':
              newTitle = context.l10n.weeklyFinancialOverview;
              break;
            case 'activeBudgets':
              newTitle = context.l10n.activeBudgets;
              break;
            case 'productAnalytics':
              newTitle = context.l10n.dashboard;
              break;
          }
        }
      }
    });

    if (_currentSectionTitle != newTitle && mounted) {
      setState(() {
        _currentSectionTitle = newTitle;
      });
    }
  }

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<DashboardCubit, DashboardState>(
        listener: (context, state) {
          // Add a mounted check to prevent setState after dispose
          if (!mounted) return;
          
          if (state.state == DashboardStates.error &&
              state.errorMessage != null) {
            AppSnackBar.show(
              context: context,
              message: state.errorMessage!,
              type: SnackBarType.error,
            );
          }
        },
        builder: (context, state) => Scaffold(
          backgroundColor: context.colorScheme.surface,
          drawerScrimColor: Colors.transparent,
          // endDrawer: ,
          body: RefreshIndicator(
            onRefresh: () async =>
                context.read<DashboardCubit>().loadDashboardData(),
            color: context.colorScheme.primary,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // App Bar with Actions
                SliverAppBar(
                  pinned: true,
                  elevation: 0,
                  leadingWidth: 70,
                  leading: Builder(
                    builder: (BuildContext builderContext) => UnconstrainedBox(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: InkWell(
                          onTap: () {
                            // Check if widget is still mounted before calling callback
                            if (mounted) {
                              widget.onProfileTap?.call();
                            }
                          },
                          child: AppImage.network(
                            sl.authService.currentUser?.profilePhotoUrl ?? '',
                            // The height/width here defines how the image fits within the 40x40 container
                            height: 50, // Use the full parent height/width
                            width: 50,
                            border: Border.all(
                              width: 2,
                              color: context.colorScheme.primary,
                            ),
                            shadows: [
                              BoxShadow(
                                color: const Color(0xFF6366F1)
                                    .withValues(alpha: 0.3),
                                blurRadius: 9,
                                offset: const Offset(0, 5),
                              ),
                            ],
                            shape: ImageShape
                                .circle, // This parameter might not be necessary if ClipOval is used
                            heroTag: 'profilelDP',
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Builder(
                  //   builder: (BuildContext builderContext) => Padding(
                  //     padding: const EdgeInsets.only(left: 16),
                  //     child: InkWell(
                  //       onTap: () {
                  //         // 3. Open the drawer programmatically
                  //         Scaffold.of(builderContext).openDrawer();
                  //       },
                  //       child: AppImage.network(
                  //         sl.authService.currentUser?.profilePhotoUrl ?? '',
                  //         height: 40,
                  //         width: 40,
                  //         shape: ImageShape.circle,
                  //         heroTag: 'profilelDP',
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  backgroundColor: context.colorScheme.surface,
                  automaticallyImplyLeading: false,
                  toolbarHeight: 60,
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.md),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1)
                                  .withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.notifications_outlined,
                                color: context.colorScheme.onPrimary,
                                size: 28,
                              ),
                              onPressed: () {},
                            ),
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: context.colorScheme.tertiary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: context.colorScheme.onPrimary,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: context.colorScheme.tertiary
                                          .withValues(alpha: 0.5),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Dashboard Header Widget (Expandable Card)
                SliverToBoxAdapter(
                  child: DashboardHeaderWidget(state: state),
                ),

                // Rest of the content
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Weekly Financial Overview Section
                            KeyedSubtree(
                              key: _sectionKeys['weeklyFinancialOverview'],
                              child: WeeklyFinancialOverviewWidget(
                                state: state,
                                onRetry: () => context
                                    .read<DashboardCubit>()
                                    .loadDashboardData(),
                              ),
                            ),

                            if (state.state != DashboardStates.error) ...[
                              SizedBox(height: context.lg),

                              // Active Budget Section
                              if (state.budgetGoals != null)
                                KeyedSubtree(
                                  key: _sectionKeys['activeBudgets'],
                                  child: ActiveBudgetSectionWidget(
                                    budgetGoals: state.budgetGoals!,
                                  ),
                                ),
                              if (state.budgetGoals != null)
                                SizedBox(height: context.lg),

                              // Product Analytics Section
                              KeyedSubtree(
                                key: _sectionKeys['productAnalytics'],
                                child: const ProductAnalyticsWidget(),
                              ),

                              SizedBox(height: context.lg),
                            ],

                            // Additional padding at bottom for better scrolling
                            SizedBox(height: context.xl),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class DashboardPageWrapper extends StatefulWidget {
  const DashboardPageWrapper({super.key});

  @override
  State<DashboardPageWrapper> createState() => _DashboardPageWrapperState();
}

class _DashboardPageWrapperState extends State<DashboardPageWrapper> {
  final _drawerController = AwesomeDrawerBarController();
  @override
  Widget build(BuildContext context) => AwesomeDrawerBar(
        controller: _drawerController,
        borderRadius: 12,
        angle: -10,
        type: StyleState.popUp,
        showShadow: true,
        shadowColor: context.colorScheme.primary,
        backgroundColor: context.colorScheme.primary,
        duration: const Duration(milliseconds: 400),
        slideWidth: context.screenWidth * 0.90,
        // openCurve:
        mainScreen: DashboardPage(onProfileTap: () {
          (_drawerController.toggle as void Function()?)?.call();
        }
            // onDrawerChanged: (bool isOpened) {
            //   print('1234 $isOpened');
            //   if (isOpened) {
            //     (_drawerController.open as void Function()?)?.call();
            //   } else {
            //     (_drawerController.close as void Function()?)?.call();
            //   }
            // },
            // onEndDrawerChanged: (bool isOpened) {
            //   print('89789 $isOpened');

            //   if (isOpened) {
            //     (_drawerController.close as void Function()?)?.call();
            //   } else {
            //     (_drawerController.open as void Function()?)?.call();
            //   }
            // },
            ),
        menuScreen: ProfilePage(
          onBackTap: () =>
              (_drawerController.close as void Function()?)?.call(),
        ),
      );
}
