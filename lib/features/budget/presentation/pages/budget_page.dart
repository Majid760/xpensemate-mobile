import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/features/budget/presentation/cubit/budget_cubit.dart';
import 'package:xpensemate/features/budget/presentation/cubit/budget_state.dart';
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

class _BudgetPageContentState extends State<BudgetPageContent> with TickerProviderStateMixin {
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
      context.budgetCubit.getBudgetGoalsInsights(period: 'monthly'),
    ]);
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<BudgetCubit, BudgetState>(
        listener: (context, state) {},
        builder: (context, state) => RefreshIndicator(
          onRefresh: () async => _loadBudgetData(),
          color: context.primaryColor,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              BudgetAppBar(
                onChanged: (value) => context.budgetCubit.getBudgetGoalsInsights(period: value),
              ),
              SliverPadding(
                padding: EdgeInsets.all(context.md),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    ExpandableStatsCard(
                      budgetGoalsInsight: state.budgetGoalsInsight,
                    ),
                    SizedBox(height: context.xl),
                    SectionHeader(title: context.l10n.budget),
                    SizedBox(height: context.sm),
                  ]),
                ),
              ),
              BudgetGoalsListWidget(scrollController: _scrollController),
              // Bottom padding for FAB
              SliverToBoxAdapter(child: SizedBox(height: context.xl * 3)),
            ],
          ),
        ),
      );
}

class BudgetAppBar extends StatelessWidget {
  const BudgetAppBar({super.key, this.onChanged});

  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => SliverAppBar(
        expandedHeight: 60,
        pinned: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        flexibleSpace: FlexibleSpaceBar(
          titlePadding: EdgeInsets.only(left: context.md, bottom: context.md),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: context.md),
            decoration: BoxDecoration(
              color: context.colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: PopupMenuButton<String>(
              onSelected: onChanged,
              icon: Icon(
                Icons.tune_rounded,
                color: context.colorScheme.onPrimary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'weekly',
                  child: Text(context.l10n.weeklyInsights),
                ),
                PopupMenuItem(
                  value: 'monthly',
                  child: Text(context.l10n.monthlyInsight),
                ),
                PopupMenuItem(
                  value: 'quarterly',
                  child: Text(context.l10n.quarterInsight),
                ),
                PopupMenuItem(
                  value: 'yearly',
                  child: Text(context.l10n.yearlyInsight),
                ),
              ],
            ),
          ),
        ],
      );
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long_rounded,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ],
          ),
        ],
      );
}
