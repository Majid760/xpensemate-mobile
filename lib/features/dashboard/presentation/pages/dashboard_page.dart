import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/widget/app_snackbar.dart';
import 'package:xpensemate/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:xpensemate/features/dashboard/presentation/widgets/active_budget_section_widget.dart';
import 'package:xpensemate/features/dashboard/presentation/widgets/weekly_financial_overview_widget.dart';
import 'package:xpensemate/features/dashboard/presentation/widgets/product_analytics_widget.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadDashboardData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutQuart),
    );

    _fadeController.forward();
  }

  void _loadDashboardData() {
    context.read<DashboardCubit>().loadDashboardData();
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<DashboardCubit, DashboardState>(
      listener: (context, state) {
        if (state.state == DashboardStates.error && state.errorMessage != null) {
          AppSnackBar.show(
            context: context,
            message: state.errorMessage!,
            type: SnackBarType.error,
          );
        }
      },
      builder: (context, state) => Scaffold(
          backgroundColor: context.colorScheme.surface,
          body: RefreshIndicator(
            onRefresh: () async => _loadDashboardData(),
            color: context.colorScheme.primary,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: 80,
                  floating: true,
                  elevation: 0,
                  backgroundColor: context.colorScheme.surface,
                  title: Text(
                    context.l10n.dashboard,
                    style: context.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: context.colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: context.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Weekly Financial Overview Section
                          WeeklyFinancialOverviewWidget(
                            state: state,
                            onRetry: _loadDashboardData,
                          ),
                          SizedBox(height: context.lg),
                          
                          // Active Budget Section
                          if (state.budgetGoals != null)
                            ActiveBudgetSectionWidget(
                              budgetGoals: state.budgetGoals!,
                            ),
                          if (state.budgetGoals != null)
                            SizedBox(height: context.lg),
                          
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
              ],
            ),
          ),
        ),
    );
}