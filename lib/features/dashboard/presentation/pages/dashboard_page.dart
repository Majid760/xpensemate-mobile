import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/colors/app_colors.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/widget/app_snackbar.dart';
import 'package:xpensemate/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:xpensemate/features/dashboard/presentation/widgets/active_budget_section_widget.dart';
import 'package:xpensemate/features/dashboard/presentation/widgets/financial_overview_card_widget.dart';
import 'package:xpensemate/features/dashboard/presentation/widgets/product_analytics_widget.dart';
import 'package:xpensemate/features/dashboard/presentation/widgets/weekly_financial_overview_widget.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
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
    _loadDashboardData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scrollController.dispose();
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

  void _initializeScrollController() {
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final scrollPosition = _scrollController.offset;

    // Determine which section is currently visible
    var newTitle = context.l10n.dashboard;

    // Check each section to see which one is in view
    _sectionKeys.forEach((key, globalKey) {
      final renderBox =
          globalKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
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

    if (_currentSectionTitle != newTitle) {
      setState(() {
        _currentSectionTitle = newTitle;
      });
    }
  }

  void _loadDashboardData() {
    context.read<DashboardCubit>().loadDashboardData();
  }

  // Get appropriate greeting based on time of day
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return context.l10n.goodMorning;
    } else if (hour < 17) {
      return context.l10n.goodAfternoon;
    } else {
      return context.l10n.goodEvening;
    }
  }

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<DashboardCubit, DashboardState>(
        listener: (context, state) {
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
          body: RefreshIndicator(
            onRefresh: () async => _loadDashboardData(),
            color: context.colorScheme.primary,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: 320,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: AppColors.primary,
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.notifications_outlined,
                              color: Colors.white,
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
                                color: Colors.amber,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.amber.withValues(alpha: 0.5),
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
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: DashboardHeaderWidget(
                      state: state,
                      getGreeting: _getGreeting,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Weekly Financial Overview Section
                          KeyedSubtree(
                            key: _sectionKeys['weeklyFinancialOverview'],
                            child: WeeklyFinancialOverviewWidget(
                              state: state,
                              onRetry: _loadDashboardData,
                            ),
                          ),
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

// Separate widget for the dashboard header
class DashboardHeaderWidget extends StatelessWidget {
  const DashboardHeaderWidget({
    super.key,
    required this.state,
    required this.getGreeting,
  });
  final DashboardState state;
  final String Function() getGreeting;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 50, 24, 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                context.colorScheme.primary,
                context.colorScheme.secondary.withValues(alpha: 0.9),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: context.colorScheme.primary.withValues(alpha: 0.2),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Greeting Text
              Row(
                children: [
                  Text(
                    '${getGreeting()} ',
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colorScheme.onPrimary,
                      letterSpacing: -0.5,
                      shadows: [
                        Shadow(
                          color: context.colorScheme.primaryContainer
                              .withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '👋',
                    style: context.textTheme.headlineMedium?.copyWith(
                      color: context.colorScheme.onPrimary,
                      shadows: [
                        Shadow(
                          color: context.colorScheme.onPrimary
                              .withValues(alpha: 0.2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                context.l10n.financialOverviewSubtitle,
                style: context.textTheme.titleMedium?.copyWith(
                  color: context.colorScheme.onPrimary.withValues(alpha: 0.95),
                  fontWeight: FontWeight.w400,
                  shadows: [
                    Shadow(
                      color: context.colorScheme.primary.withValues(alpha: 0.2),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Financial Overview Card (now using separate widget)
              FinancialOverviewCardWidget(state: state),
            ],
          ),
        ),
      );
}
