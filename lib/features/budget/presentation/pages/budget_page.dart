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
  Widget build(BuildContext context) => const Scaffold(
        backgroundColor: Color(0xFFF8F9FE),
        body: BudgetPageBody(),
      );
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
    with TickerProviderStateMixin {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
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
  Widget build(BuildContext context) => BlocConsumer<BudgetCubit, BudgetState>(
        listener: (context, state) {},
        builder: (context, state) => RefreshIndicator(
          onRefresh: () async => [
            _loadBudgetData(),
            context.budgetCubit.pagingController.refresh(),
          ],
          color: context.primaryColor,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              CustomAppBar(
                defaultPeriod: state.defaultPeriod,
                onChanged: (value) =>
                    context.budgetCubit.getBudgetGoalsInsights(period: value),
              ),
              SliverPadding(
                padding: EdgeInsets.all(context.md),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    ExpandableStatsCard(
                      budgetGoalsInsight: state.budgetGoalsInsight,
                      period: state.defaultPeriod.name,
                    ),
                    SizedBox(height: context.xl),
                    AnimatedSectionHeader(
                      title: context.l10n.budget,
                      onSearchChanged: (value) {
                        if (value.trim().isEmpty) return;
                        AppUtils.debounce(
                          () => context.budgetCubit.updateSearchTerm(value),
                          delay: const Duration(milliseconds: 700),
                        );
                      },
                      onSearchCleared: () =>
                          context.budgetCubit.updateSearchTerm(''),
                    ),
                    SizedBox(height: context.sm),
                  ]),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: context.md),
                sliver:
                    BudgetGoalsListWidget(scrollController: _scrollController),
              ),
              // Bottom padding for FAB
              SliverToBoxAdapter(child: SizedBox(height: context.xl * 3)),
            ],
          ),
        ),
      );
}

// This function can be called from other pages or components
// to trigger the add budget action
void addBudget(
    {required BuildContext context,
    required void Function(BudgetGoalEntity)? onSave}) {
  final screenHeight = MediaQuery.of(context).size.height;
  AppBottomSheet.show<void>(
    context: context,
    title: 'Add Budget',
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
