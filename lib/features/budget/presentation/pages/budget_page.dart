import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/core/enums.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/utils/app_utils.dart';
import 'package:xpensemate/core/widget/animated_section_header.dart';
import 'package:xpensemate/core/widget/app_bar_widget.dart';
import 'package:xpensemate/core/widget/app_bottom_sheet.dart';
import 'package:xpensemate/features/budget/domain/entities/budget_goal_entity.dart';
import 'package:xpensemate/features/budget/presentation/cubit/budget_cubit.dart';
import 'package:xpensemate/features/budget/presentation/cubit/budget_state.dart';
import 'package:xpensemate/features/budget/presentation/pages/budget_form_page.dart';
import 'package:xpensemate/features/budget/presentation/widgets/budget_goal_list.dart';
import 'package:xpensemate/features/budget/presentation/widgets/insight_card_section.dart';

class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        body: const BudgetPageBody(),
      );

  static void showAddBudgetSheet({
    required BuildContext context,
    void Function(BudgetGoalEntity)? onSave,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    AppBottomSheet.show<void>(
      context: context,
      title: context.l10n.addBudget,
      config: BottomSheetConfig(
        minHeight: screenHeight * 0.8,
        maxHeight: screenHeight * 0.95,
        padding: EdgeInsets.zero,
        blurSigma: 5,
        barrierColor: Colors.transparent,
      ),
      child: BudgetFormPage(
        onSave: onSave ??
            (goal) async {
              await context.budgetCubit.createBudgetGoal(goal);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }
}

class BudgetPageBody extends StatelessWidget {
  const BudgetPageBody({super.key});

  @override
  Widget build(BuildContext context) => const BudgetPageContent();
}

class BudgetPageContent extends StatefulWidget {
  const BudgetPageContent({super.key});

  @override
  State<BudgetPageContent> createState() => _BudgetPageContentState();
}

class _BudgetPageContentState extends State<BudgetPageContent>
    with AutomaticKeepAliveClientMixin {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _loadBudgetData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadBudgetData() {
    Future.wait([
      context.budgetCubit.refreshBudgetGoals(),
      context.budgetCubit.getBudgetGoalsInsights(period: FilterValue.monthly),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Essential for AutomaticKeepAliveClientMixin
    return RefreshIndicator(
      onRefresh: () async => [
        _loadBudgetData(),
        context.budgetCubit.pagingController.refresh(),
      ],
      color: context.primaryColor,
      child: CustomScrollView(
        controller: _scrollController,
        // ✅ OPTIMIZATION: Add cacheExtent for smoother scrolling
        cacheExtent: 500,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // Filter Section
         const _FilterSection(),
          

          // Stats Section
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            sliver: SliverToBoxAdapter(
              child: _StatsSection(),
              ),
            
          ),

          SliverToBoxAdapter(child: SizedBox(height: context.xl)),

          // Search Header Section
          const _SearchHeaderSection(),

          SliverToBoxAdapter(child: SizedBox(height: context.sm)),

          // Budget List Widget
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: context.md),
            sliver: BudgetGoalsListWidget(scrollController: _scrollController),
          ),

          // Bottom padding for FAB
          SliverToBoxAdapter(child: SizedBox(height: context.xl * 3)),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

// ✅ OPTIMIZATION: Extracted Filter Section
class _FilterSection extends StatelessWidget {
  const _FilterSection();

  @override
  Widget build(BuildContext context) =>
      BlocSelector<BudgetCubit, BudgetState, FilterValue>(
        selector: (state) => state.defaultPeriod,
        builder: (context, defaultPeriod) => CustomAppBar(
          defaultPeriod: defaultPeriod,
          onChanged: (value) =>
              context.budgetCubit.getBudgetGoalsInsights(period: value),
        ),
      );
}

// ✅ OPTIMIZATION: Extracted Stats Section with RepaintBoundary
class _StatsSection extends StatelessWidget {
  const _StatsSection();

  @override
  Widget build(BuildContext context) => BlocBuilder<BudgetCubit, BudgetState>(
        buildWhen: (previous, current) =>
            previous.budgetGoalsInsight != current.budgetGoalsInsight ||
            previous.defaultPeriod != current.defaultPeriod,
        builder: (context, state) => RepaintBoundary(
          child: ExpandableStatsCard(
            budgetGoalsInsight: state.budgetGoalsInsight,
            period: state.defaultPeriod.name,
          ),
        ),
      );
}

// ✅ OPTIMIZATION: Extracted Search Header Section
class _SearchHeaderSection extends StatelessWidget {
  const _SearchHeaderSection();

  @override
  Widget build(BuildContext context) => SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: context.md),
        sliver: SliverToBoxAdapter(
          child: AnimatedSectionHeader(
            title: context.l10n.budget,
            onSearchChanged: (value) {
              if (value.trim().isEmpty) return;
              AppUtils.debounce(
                () => context.budgetCubit.updateSearchTerm(value),
                delay: const Duration(milliseconds: 700),
              );
            },
            onSearchCleared: () => context.budgetCubit.updateSearchTerm(''),
          ),
        ),
      );
}

// Function exposed for external calls
void addBudget({
  required BuildContext context,
  void Function(BudgetGoalEntity)? onSave,
}) {
  BudgetPage.showAddBudgetSheet(context: context, onSave: onSave);
}
