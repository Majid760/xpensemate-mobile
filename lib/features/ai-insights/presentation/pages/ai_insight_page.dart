import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/core/theme/app_spacing.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/utils/currency_formatter.dart';
import 'package:xpensemate/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:xpensemate/features/expense/domain/entities/expense_stats_entity.dart';
import 'package:xpensemate/features/expense/presentation/cubit/expense_cubit.dart';
import 'package:xpensemate/features/payment/domain/entities/payment_stats_entity.dart';
import 'package:xpensemate/features/payment/presentation/cubit/payment_cubit.dart';

// ─── Page ──────────────────────────────────────────────────────────────────

class AiInsightPage extends StatefulWidget {
  const AiInsightPage({super.key});

  @override
  State<AiInsightPage> createState() => _AiInsightPageState();
}                                   

class _AiInsightPageState extends State<AiInsightPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _headerAnim;
  bool _chatOpen = false;

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              _AiAppBar(animation: _headerAnim),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: AppSpacing.md),
                    // ── Expense snapshot ──────────────────────────────────
                    BlocBuilder<ExpenseCubit, ExpenseState>(
                      buildWhen: (p, c) => p.expenseStats != c.expenseStats,
                      builder: (ctx, expState) => BlocBuilder<PaymentCubit, PaymentState>(
                          buildWhen: (p, c) =>
                              p.paymentStats != c.paymentStats,
                          builder: (ctx2, payState) => BlocBuilder<DashboardCubit, DashboardState>(
                              buildWhen: (p, c) =>
                                  p.weeklyStats != c.weeklyStats,
                              builder: (ctx3, dashState) {
                                final exp = expState.expenseStats;
                                final pay = payState.paymentStats;
                                final dash = dashState.weeklyStats;

                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const _SectionTitle(
                                      icon: Icons.auto_awesome_rounded,
                                      title: 'AI Snapshot',
                                      subtitle: 'Your finances at a glance',
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    _SnapshotGrid(
                                      exp: exp,
                                      pay: pay,
                                      weekTotal: dash?.weekTotal,
                                      balanceLeft: dash?.balanceLeft,
                                    ),
                                    const SizedBox(height: AppSpacing.lg),
                                    const _SectionTitle(
                                      icon: Icons.tips_and_updates_rounded,
                                      title: 'Smart Insights',
                                      subtitle:
                                          'Personalised to your spending',
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    _InsightCards(exp: exp, pay: pay),
                                    const SizedBox(height: AppSpacing.lg),
                                    if (exp != null &&
                                        exp.categories.isNotEmpty) ...[
                                      const _SectionTitle(
                                        icon: Icons.donut_small_rounded,
                                        title: 'Spending Breakdown',
                                        subtitle:
                                            'Where your money is going',
                                      ),
                                      const SizedBox(height: AppSpacing.sm),
                                      _CategoryBreakdown(exp: exp),
                                      const SizedBox(height: AppSpacing.lg),
                                    ],
                                    if (pay != null &&
                                        pay.monthlyTrend.isNotEmpty) ...[
                                      const _SectionTitle(
                                        icon: Icons.show_chart_rounded,
                                        title: 'Payment Trend',
                                        subtitle:
                                            'Monthly income over time',
                                      ),
                                      const SizedBox(height: AppSpacing.sm),
                                      _PaymentTrendCard(pay: pay),
                                      const SizedBox(height: AppSpacing.lg),
                                    ],
                                    const _SectionTitle(
                                      icon: Icons.psychology_rounded,
                                      title: 'Ask Your AI',
                                      subtitle:
                                          'Tap a question or open chat',
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    _QuickQuestions(
                                      exp: exp,
                                      pay: pay,
                                      onQuestionTap: (q) => setState(() {
                                        _chatOpen = true;
                                        _pendingQuestion = q;
                                      }),
                                    ),
                                    const SizedBox(
                                        height: AppSpacing.xxxl + 40,),
                                  ],
                                );
                              },
                            ),
                        ),
                    ),
                  ]),
                ),
              ),
            ],
          ),

          // ── Floating Chat Panel ─────────────────────────────────────────
          if (_chatOpen)
            _ChatPanel(
              initialQuestion: _pendingQuestion,
              onClose: () => setState(() {
                _chatOpen = false;
                _pendingQuestion = null;
              }),
            ),

          // ── Chat FAB ───────────────────────────────────────────────────
          if (!_chatOpen)
            Positioned(
              bottom: 100,
              right: AppSpacing.md,
              child: _ChatFab(
                onTap: () => setState(() => _chatOpen = true),
              ),
            ),
        ],
      ),
    );

  String? _pendingQuestion;
}

// ─── App Bar ───────────────────────────────────────────────────────────────

class _AiAppBar extends StatelessWidget {
  const _AiAppBar({required this.animation});
  final AnimationController animation;

  @override
  Widget build(BuildContext context) => SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: context.colorScheme.surface,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: AnimatedBuilder(
          animation: animation,
          builder: (_, __) {
            final t = Curves.easeOut.transform(animation.value);
            return Opacity(
              opacity: t,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - t)),
                child: _HeaderGradient(),
              ),
            );
          },
        ),
        titlePadding: EdgeInsets.zero,
        title: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'AI Insights',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
}

class _HeaderGradient extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.primaryColor,
                context.colorScheme.tertiary,
              ],
            ),
          ),
        ),
        // decorative circles
        Positioned(
          top: -30,
          right: -30,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
        ),
        Positioned(
          bottom: -20,
          left: 40,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 52, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'AI Insights',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Your smart financial assistant',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
}

// ─── Section Title ─────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                context.primaryColor.withValues(alpha: 0.15),
                context.colorScheme.tertiary.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: context.primaryColor, size: 18),
        ),
        const SizedBox(width: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
}

// ─── Snapshot Grid ─────────────────────────────────────────────────────────

class _SnapshotGrid extends StatelessWidget {
  const _SnapshotGrid({
    required this.exp,
    required this.pay,
    required this.weekTotal,
    required this.balanceLeft,
  });
  final ExpenseStatsEntity? exp;
  final PaymentStatsEntity? pay;
  final double? weekTotal;
  final double? balanceLeft;

  @override
  Widget build(BuildContext context) {
    final items = [
      _SnapItem(
        label: 'Total Spent',
        value: exp != null
            ? CurrencyFormatter.format(exp!.totalSpent)
            : '—',
        icon: Icons.arrow_upward_rounded,
        color: context.colorScheme.error,
      ),
      _SnapItem(
        label: 'Income',
        value: pay != null
            ? CurrencyFormatter.format(pay!.totalAmount)
            : '—',
        icon: Icons.arrow_downward_rounded,
        color: const Color(0xFF22C55E),
      ),
      _SnapItem(
        label: 'Daily Avg',
        value: exp != null
            ? CurrencyFormatter.format(exp!.dailyAverage)
            : '—',
        icon: Icons.today_rounded,
        color: context.colorScheme.secondary,
      ),
      _SnapItem(
        label: 'Balance Left',
        value: balanceLeft != null
            ? CurrencyFormatter.format(balanceLeft!)
            : '—',
        icon: Icons.account_balance_wallet_rounded,
        color: context.primaryColor,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.5,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _SnapCard(item: items[i]),
    );
  }
}

class _SnapItem {
  const _SnapItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

class _SnapCard extends StatelessWidget {
  const _SnapCard({required this.item});
  final _SnapItem item;

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(item.icon, color: item.color, size: 16),
              ),
              const Spacer(),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.value,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                item.label,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
}

// ─── Smart Insight Cards ───────────────────────────────────────────────────

class _InsightCards extends StatelessWidget {
  const _InsightCards({required this.exp, required this.pay});
  final ExpenseStatsEntity? exp;
  final PaymentStatsEntity? pay;

  List<_InsightData> _buildInsights(BuildContext context) {
    final list = <_InsightData>[];

    if (exp != null) {
      final vel = exp!.spendingVelocityPercent;
      final isOver = vel > 100;
      list.add(_InsightData(
        icon:
            isOver ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
        color: isOver
            ? context.colorScheme.error
            : const Color(0xFF22C55E),
        headline: isOver
            ? 'Spending Over Budget'
            : 'Spending On Track',
        body: exp!.spendingVelocityMessage,
      ),);

      final streak = exp!.trackingStreak;
      if (streak > 0) {
        list.add(_InsightData(
          icon: Icons.local_fire_department_rounded,
          color: const Color(0xFFF97316),
          headline: '$streak-Day Tracking Streak 🔥',
          body:
              "You've been consistently logging expenses for $streak days. Keep it up!",
        ),);
      }

      if (exp!.categories.isNotEmpty) {
        final top = exp!.categories.reduce(
          (a, b) => a.amount > b.amount ? a : b,
        );
        list.add(_InsightData(
          icon: Icons.category_rounded,
          color: context.colorScheme.secondary,
          headline: 'Top Category: ${top.category}',
          body:
              '${CurrencyFormatter.format(top.amount)} spent on ${top.category} this period. Consider reviewing this category.',
        ),);
      }
    }

    if (pay != null) {
      final growth = pay!.periodGrowth;
      list.add(_InsightData(
        icon: growth >= 0
            ? Icons.trending_up_rounded
            : Icons.trending_down_rounded,
        color: growth >= 0
            ? const Color(0xFF22C55E)
            : context.colorScheme.error,
        headline: growth >= 0
            ? 'Income Up ${growth.toStringAsFixed(1)}%'
            : 'Income Down ${growth.abs().toStringAsFixed(1)}%',
        body: growth >= 0
            ? 'Your income grew compared to the previous period. Great progress!'
            : 'Income dipped compared to last period. Check payment sources.',
      ),);
    }

    if (list.isEmpty) {
      list.add(_InsightData(
        icon: Icons.hourglass_empty_rounded,
        color: context.colorScheme.onSurfaceVariant,
        headline: 'No Data Yet',
        body:
            'Start logging expenses and payments to receive personalised AI insights.',
      ),);
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final insights = _buildInsights(context);
    return Column(
      children: insights
          .map((i) => Padding(
                padding:
                    const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _InsightCard(data: i),
              ),)
          .toList(),
    );
  }
}

class _InsightData {
  const _InsightData({
    required this.icon,
    required this.color,
    required this.headline,
    required this.body,
  });
  final IconData icon;
  final Color color;
  final String headline;
  final String body;
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.data});
  final _InsightData data;

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: data.color.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: data.color.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(data.icon, color: data.color, size: 22),
          ),
          const SizedBox(width: AppSpacing.sm1),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.headline,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.body,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
}

// ─── Category Breakdown ────────────────────────────────────────────────────

class _CategoryBreakdown extends StatelessWidget {
  const _CategoryBreakdown({required this.exp});
  final ExpenseStatsEntity exp;

  static const _colors = [
    Color(0xFF6366F1),
    Color(0xFF22C55E),
    Color(0xFFF97316),
    Color(0xFFEC4899),
    Color(0xFF14B8A6),
    Color(0xFFF59E0B),
  ];

  @override
  Widget build(BuildContext context) {
    final cats = exp.categories.take(6).toList();
    final total = cats.fold<double>(0, (s, c) => s + c.amount);
    if (total == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Segmented bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 12,
              child: Row(
                children: cats.asMap().entries.map((e) {
                  final pct = e.value.amount / total;
                  return Flexible(
                    flex: (pct * 1000).round(),
                    child: Container(
                      color: _colors[e.key % _colors.length],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...cats.asMap().entries.map((e) {
            final cat = e.value;
            final pct = total > 0 ? (cat.amount / total * 100) : 0.0;
            final color = _colors[e.key % _colors.length];
            return Padding(
              padding:
                  const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      cat.category,
                      style: context.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(cat.amount),
                    style: context.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  SizedBox(
                    width: 38,
                    child: Text(
                      '${pct.toStringAsFixed(0)}%',
                      textAlign: TextAlign.end,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Payment Trend Card ────────────────────────────────────────────────────

class _PaymentTrendCard extends StatelessWidget {
  const _PaymentTrendCard({required this.pay});
  final PaymentStatsEntity pay;

  @override
  Widget build(BuildContext context) {
    final trend = pay.monthlyTrend;
    final max = trend.fold<double>(1, (m, t) => math.max(m, t.totalAmount));

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Monthly Income',
                style: context.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4,),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  pay.periodGrowth >= 0
                      ? '+${pay.periodGrowth.toStringAsFixed(1)}%'
                      : '${pay.periodGrowth.toStringAsFixed(1)}%',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: pay.periodGrowth >= 0
                        ? const Color(0xFF22C55E)
                        : context.colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: trend.map((t) {
                final frac = max > 0 ? t.totalAmount / max : 0.0;
                final isLast = t == trend.last;
                return Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOut,
                          height: (frac * 60).clamp(4, 60),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: isLast
                                  ? [
                                      context.primaryColor,
                                      context.colorScheme.tertiary,
                                    ]
                                  : [
                                      context.primaryColor
                                          .withValues(alpha: 0.3),
                                      context.primaryColor
                                          .withValues(alpha: 0.5),
                                    ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _monthLabel(t.month),
                          style: context.textTheme.labelSmall?.copyWith(
                            fontSize: 9,
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _monthLabel(int m) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    if (m < 1 || m > 12) return '';
    return months[m - 1];
  }
}

// ─── Quick Questions ───────────────────────────────────────────────────────

class _QuickQuestions extends StatelessWidget {
  const _QuickQuestions({
    required this.exp,
    required this.pay,
    required this.onQuestionTap,
  });
  final ExpenseStatsEntity? exp;
  final PaymentStatsEntity? pay;
  final void Function(String) onQuestionTap;

  @override
  Widget build(BuildContext context) {
    final questions = [
      'What is my top spending category?',
      'How does my income compare to expenses?',
      'Am I on track with my budget?',
      'What is my daily spending average?',
      'How can I reduce my expenses?',
      'When did I spend the most this week?',
    ];

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: questions
          .map(
            (q) => GestureDetector(
              onTap: () => onQuestionTap(q),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8,),
                decoration: BoxDecoration(
                  color: context.primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: context.primaryColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  q,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

// ─── Chat FAB ──────────────────────────────────────────────────────────────

class _ChatFab extends StatelessWidget {
  const _ChatFab({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: 12,),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              context.primaryColor,
              context.colorScheme.tertiary,
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: context.primaryColor.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Ask AI',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
}

// ─── Chat Panel ────────────────────────────────────────────────────────────

class _ChatPanel extends StatefulWidget {
  const _ChatPanel({required this.onClose, this.initialQuestion});
  final VoidCallback onClose;
  final String? initialQuestion;

  @override
  State<_ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<_ChatPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<Offset> _slide;
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isTyping = false;

  // Cubit snapshots resolved from context at init
  ExpenseStatsEntity? _exp;
  PaymentStatsEntity? _pay;
  double? _balance;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
    _anim.forward();

    _messages.add(
      const _ChatMessage(
        text:
            "Hi! I'm your AI financial assistant. Ask me anything about your expenses, income or budget.",
        isAi: true,
      ),
    );

    if (widget.initialQuestion != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _send(widget.initialQuestion!);
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _exp = context.read<ExpenseCubit>().state.expenseStats;
    _pay = context.read<PaymentCubit>().state.paymentStats;
    _balance =
        context.read<DashboardCubit>().state.weeklyStats?.balanceLeft;
  }

  @override
  void dispose() {
    _anim.dispose();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text: text.trim(), isAi: false));
      _isTyping = true;
    });
    _input.clear();
    _scrollToBottom();

    await Future.delayed(const Duration(milliseconds: 900));

    final reply = _generateReply(text.trim());
    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add(_ChatMessage(text: reply, isAi: true));
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _generateReply(String q) {
    final lower = q.toLowerCase();

    if (lower.contains('top') && lower.contains('categor')) {
      if (_exp != null && _exp!.categories.isNotEmpty) {
        final top = _exp!.categories
            .reduce((a, b) => a.amount > b.amount ? a : b);
        return '📊 Your top spending category is **${top.category}** with ${CurrencyFormatter.format(top.amount)} spent this period.';
      }
      return '📊 No category data available yet. Start logging expenses to see your top category!';
    }

    if (lower.contains('income') || lower.contains('payment')) {
      if (_pay != null) {
        return '💰 Your total income this period is ${CurrencyFormatter.format(_pay!.totalAmount)} across ${_pay!.totalPayments} transactions. Your average payment is ${CurrencyFormatter.format(_pay!.averagePayment)}.';
      }
      return '💰 No payment data found yet. Add payments to track your income.';
    }

    if (lower.contains('budget') || lower.contains('track')) {
      if (_exp != null) {
        final vel = _exp!.spendingVelocityPercent;
        if (vel <= 80) {
          return "✅ Great news! You're only at ${vel.toStringAsFixed(0)}% of your budget. You're well within your limits.";
        } else if (vel <= 100) {
          return "⚠️ You're at ${vel.toStringAsFixed(0)}% of your budget. You're close to your limit — try to slow down spending.";
        } else {
          return "🚨 You've exceeded your budget by ${(vel - 100).toStringAsFixed(0)}%. Consider reviewing your expenses immediately.";
        }
      }
      return '📋 No budget data available yet.';
    }

    if (lower.contains('daily') || lower.contains('average')) {
      if (_exp != null) {
        return '📅 Your daily spending average is ${CurrencyFormatter.format(_exp!.dailyAverage)}. This is calculated over your current tracking period.';
      }
      return '📅 No expense data available yet.';
    }

    if (lower.contains('balance') || lower.contains('remaining')) {
      if (_balance != null) {
        final msg = _balance! > 0
            ? 'You have ${CurrencyFormatter.format(_balance!)} remaining — keep it up!'
            : "You've exceeded your budget. Try to cut back.";
        return '💳 $msg';
      }
      return '💳 No balance data available yet.';
    }

    if (lower.contains('reduce') || lower.contains('save') ||
        lower.contains('tip')) {
      final tips = [
        '💡 Track all small purchases — coffee, subscriptions, and takeaways add up quickly.',
        '📉 Review your top spending category and set a monthly limit for it.',
        "🔄 Cancel unused subscriptions. They're the silent budget killers.",
        '🎯 Set a weekly spending goal and check in every Sunday.',
      ];
      return tips[math.Random().nextInt(tips.length)];
    }

    if (lower.contains('streak') || lower.contains('consistent')) {
      if (_exp != null) {
        final s = _exp!.trackingStreak;
        return s > 0
            ? "🔥 You're on a $s-day tracking streak! Consistency is the key to financial awareness."
            : '📝 Start logging your expenses daily to build a tracking streak!';
      }
    }

    if (lower.contains('total') && lower.contains('spent')) {
      if (_exp != null) {
        return "💸 You've spent ${CurrencyFormatter.format(_exp!.totalSpent)} in total this period.";
      }
    }

    // Fallback
    return "🤖 I'm analysing your financial data. Try asking about your spending categories, budget status, daily average, or tips to save money!";
  }

  @override
  Widget build(BuildContext context) => SlideTransition(
      position: _slide,
      child: ColoredBox(
        color: Colors.transparent,
        child: Column(
          children: [
            // Scrim tap to dismiss
            Expanded(
              child: GestureDetector(
                onTap: widget.onClose,
                behavior: HitTestBehavior.opaque,
                child: const ColoredBox(color: Colors.transparent),
              ),
            ),
            // Panel
            Container(
              height: MediaQuery.of(context).size.height * 0.72,
              decoration: BoxDecoration(
                color: context.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Handle bar
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                context.primaryColor,
                                context.colorScheme.tertiary,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI Assistant',
                                style: context.textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Powered by your financial data',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color:
                                      context.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: widget.onClose,
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Messages
                  Expanded(
                    child: ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount:
                          _messages.length + (_isTyping ? 1 : 0),
                      itemBuilder: (_, i) {
                        if (_isTyping && i == _messages.length) {
                          return const _TypingBubble();
                        }
                        return _MessageBubble(msg: _messages[i]);
                      },
                    ),
                  ),
                  // Input
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.md,
                      AppSpacing.md +
                          MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _input,
                            decoration: InputDecoration(
                              hintText: 'Ask about your finances…',
                              filled: true,
                              fillColor:
                                  context.colorScheme.surfaceContainerHighest,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12,),
                              hintStyle: TextStyle(
                                color:
                                    context.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            onSubmitted: _send,
                            textInputAction: TextInputAction.send,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _send(_input.text),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  context.primaryColor,
                                  context.colorScheme.tertiary,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
}

// ─── Chat Bubbles ──────────────────────────────────────────────────────────

class _ChatMessage {
  const _ChatMessage({required this.text, required this.isAi});
  final String text;
  final bool isAi;
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.msg});
  final _ChatMessage msg;

  @override
  Widget build(BuildContext context) => Align(
      alignment: msg.isAi ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 10,),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          gradient: msg.isAi
              ? null
              : LinearGradient(
                  colors: [
                    context.primaryColor,
                    context.colorScheme.tertiary,
                  ],
                ),
          color: msg.isAi
              ? context.colorScheme.surfaceContainerHighest
              : null,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(msg.isAi ? 4 : 16),
            bottomRight: Radius.circular(msg.isAi ? 16 : 4),
          ),
        ),
        child: Text(
          msg.text,
          style: context.textTheme.bodyMedium?.copyWith(
            color: msg.isAi
                ? context.colorScheme.onSurface
                : Colors.white,
            height: 1.5,
          ),
        ),
      ),
    );
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerHighest,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              final delay = i / 3.0;
              final val = math.sin((_ctrl.value - delay) * math.pi * 2);
              final opacity = ((val + 1) / 2).clamp(0.3, 1.0);
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.primaryColor.withValues(alpha: opacity),
                ),
              );
            }),
          ),
        ),
      ),
    );
}