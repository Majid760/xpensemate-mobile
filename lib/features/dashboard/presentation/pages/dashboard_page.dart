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
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String? _lastMessage;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.6, curve: Curves.easeOutQuart),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  void _handleStateChange(BuildContext context, DashboardState state) {
    if (state.message != null &&
        state.message!.isNotEmpty &&
        state.message != _lastMessage) {
      _lastMessage = state.message;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          AppSnackBar.show(
            context: context,
            message: state.message!,
            type: state.state == DashboardStates.error
                ? SnackBarType.error
                : SnackBarType.success,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      drawerScrimColor: Colors.transparent,
      body: BlocListener<DashboardCubit, DashboardState>(
        listenWhen: (previous, current) => previous.message != current.message,
        listener: _handleStateChange,
        child: RefreshIndicator(
          onRefresh: () async =>
              context.read<DashboardCubit>().loadDashboardData(),
          color: context.colorScheme.primary,
          child: CustomScrollView(
            cacheExtent: 500,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              AppBarWidget(onProfileTap: widget.onProfileTap),

              // Dashboard Header
              const SliverToBoxAdapter(
                child: RepaintBoundary(
                  child: _DashboardHeader(),
                ),
              ),

              // Main Content
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: const _DashboardContent(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // OPTIMIZATION  Keep state alive to prevent rebuilds when navigating
  @override
  bool get wantKeepAlive => true;
}

/// Dashboard Header Widget
class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<DashboardCubit, DashboardState>(
        // Only rebuild when these specific fields change
        buildWhen: (previous, current) =>
            previous.weeklyStats != current.weeklyStats ||
            previous.state != current.state,
        builder: (context, state) => DashboardHeaderWidget(state: state),
      );
}

/// Dashboard Content Widget
class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weekly Financial Overview
            const _WeeklyFinancialSection(),

            SizedBox(height: context.lg),

            // Active Budget Section
            const _ActiveBudgetSection(),

            // Product Analytics Section
            const RepaintBoundary(
              child: ProductAnalyticsWidget(),
            ),

            SizedBox(height: context.lg),

            SizedBox(height: context.xl),
          ],
        ),
      );
}

/// Weekly Financial Section with optimized rebuilds
class _WeeklyFinancialSection extends StatelessWidget {
  const _WeeklyFinancialSection();

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<DashboardCubit, DashboardState>(
        // ✅ OPTIMIZATION 8: Precise buildWhen conditions
        buildWhen: (previous, current) =>
            previous.weeklyStats != current.weeklyStats ||
            previous.state != current.state,
        builder: (context, state) => RepaintBoundary(
          child: WeeklyFinancialOverviewWidget(
            weeklyStats: state.weeklyStats,
            isLoading: state.state == DashboardStates.loading,
            errorMessage:
                state.state == DashboardStates.error ? state.message : null,
            onRetry: () => context.read<DashboardCubit>().loadDashboardData(),
          ),
        ),
      );
}

/// Active Budget Section
class _ActiveBudgetSection extends StatelessWidget {
  const _ActiveBudgetSection();

  @override
  Widget build(BuildContext context) =>
      BlocSelector<DashboardCubit, DashboardState, BudgetGoalsEntity?>(
        selector: (state) => state.budgetGoals,
        builder: (context, budgetGoals) {
          if (budgetGoals == null) return const SizedBox.shrink();

          return RepaintBoundary(
            child: Column(
              children: [
                ActiveBudgetSectionWidget(budgetGoals: budgetGoals),
                SizedBox(height: context.lg),
              ],
            ),
          );
        },
      );
}

//  wrapper with better controller management
class DashboardPageWrapper extends StatefulWidget {
  const DashboardPageWrapper({super.key});

  @override
  State<DashboardPageWrapper> createState() => _DashboardPageWrapperState();
}

class _DashboardPageWrapperState extends State<DashboardPageWrapper> {
  late final AwesomeDrawerBarController _drawerController;

  @override
  void initState() {
    super.initState();
    _drawerController = AwesomeDrawerBarController();
  }

  @override
  void dispose() {
    // No need to dispose AwesomeDrawerBarController
    super.dispose();
  }

  void _toggleDrawer() => _drawerController.toggle?.call();
  void _closeDrawer() => _drawerController.close?.call ();

  @override
  Widget build(BuildContext context) {
    //  Cache computed values
    final screenWidth = MediaQuery.sizeOf(context).width;

    return AwesomeDrawerBar(
      controller: _drawerController,
      borderRadius: 12,
      angle: -10,
      type: StyleState.popUp,
      showShadow: true,
      trailingWidget:const  SizedBox.shrink(),
      shadowColor: context.colorScheme.primary,
      backgroundColor: context.colorScheme.primary,
      duration: const Duration(milliseconds: 400),
      slideWidth: screenWidth * 0.90,
      mainScreen: DashboardPage(onProfileTap: _toggleDrawer),
      menuScreen: ProfilePage(onBackTap: _closeDrawer),
    );
  }
}
