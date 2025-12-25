import 'package:awesome_drawer_bar/awesome_drawer_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/widget/app_snackbar.dart';
import 'package:xpensemate/features/dashboard/domain/entities/budget_goals_entity.dart';
import 'package:xpensemate/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:xpensemate/features/dashboard/presentation/widgets/active_budget_section_widget.dart';
import 'package:xpensemate/features/dashboard/presentation/widgets/app_bar_widget.dart';
import 'package:xpensemate/features/dashboard/presentation/widgets/dashboard_header_widget.dart';
import 'package:xpensemate/features/dashboard/presentation/widgets/product_analytics_widget.dart';
import 'package:xpensemate/features/dashboard/presentation/widgets/weekly_financial_overview_widget.dart';
import 'package:xpensemate/features/profile/presentation/pages/profile_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    super.key,
    this.onProfileTap,
  });
  final void Function()? onProfileTap;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
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

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.colorScheme.surface,
        drawerScrimColor: Colors.transparent,
        body: BlocListener<DashboardCubit, DashboardState>(
          listenWhen: (previous, current) =>
              previous.state != current.state ||
              previous.message != current.message,
          listener: (context, state) {
            if (state.message != null && state.message!.isNotEmpty) {
              AppSnackBar.show(
                context: context,
                message: state.message!,
                type: state.state == DashboardStates.error
                    ? SnackBarType.error
                    : SnackBarType.success,
              );
            }
          },
          child: RefreshIndicator(
            onRefresh: () async =>
                context.read<DashboardCubit>().loadDashboardData(),
            color: context.colorScheme.primary,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // App Bar with Actions
                AppBarWidget(onProfileTap: widget.onProfileTap),

                // Dashboard Header Widget (Expandable Card)
                SliverToBoxAdapter(
                  child: BlocBuilder<DashboardCubit, DashboardState>(
                    buildWhen: (previous, current) =>
                        previous.weeklyStats != current.weeklyStats ||
                        previous.state != current.state,
                    builder: (context, state) =>
                        DashboardHeaderWidget(state: state),
                  ),
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
                            BlocBuilder<DashboardCubit, DashboardState>(
                              buildWhen: (previous, current) =>
                                  previous.weeklyStats != current.weeklyStats ||
                                  previous.state != current.state ||
                                  previous.message != current.message,
                              builder: (context, state) =>
                                  WeeklyFinancialOverviewWidget(
                                weeklyStats: state.weeklyStats,
                                isLoading:
                                    state.state == DashboardStates.loading,
                                errorMessage:
                                    state.state == DashboardStates.error
                                        ? state.message
                                        : null,
                                onRetry: () => context
                                    .read<DashboardCubit>()
                                    .loadDashboardData(),
                              ),
                            ),

                            SizedBox(height: context.lg),

                            // Active Budget Section
                            BlocSelector<DashboardCubit, DashboardState,
                                BudgetGoalsEntity?>(
                              selector: (state) => state.budgetGoals,
                              builder: (context, budgetGoals) {
                                if (budgetGoals != null) {
                                  return Column(
                                    children: [
                                      ActiveBudgetSectionWidget(
                                        budgetGoals: budgetGoals,
                                      ),
                                      SizedBox(height: context.lg),
                                    ],
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),

                            // Product Analytics Section
                            const ProductAnalyticsWidget(),

                            SizedBox(height: context.lg),

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
        mainScreen: DashboardPage(
          onProfileTap: () {
            (_drawerController.toggle as void Function()?)?.call();
          },
        ),
        menuScreen: ProfilePage(
          onBackTap: () =>
              (_drawerController.close as void Function()?)?.call(),
        ),
      );
}
