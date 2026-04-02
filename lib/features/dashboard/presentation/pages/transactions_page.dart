import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/core/enums.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/state/transactions_tab_state.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/widget/app_bar_widget.dart';
import 'package:xpensemate/features/expense/presentation/cubit/expense_cubit.dart';
import 'package:xpensemate/features/expense/presentation/pages/expense_page.dart';
import 'package:xpensemate/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:xpensemate/features/payment/presentation/pages/payment_page.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Keep shared state in sync so the FAB handler knows the active tab.
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        TransactionsTabState.activeTabIndex = _tabController.index;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.colorScheme.surface,
        appBar: AppBar(
          backgroundColor: context.colorScheme.surface,
          elevation: 0,
          title: Text(
            context.l10n.transactions,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            BlocSelector<ExpenseCubit, ExpenseState, FilterValue>(
              selector: (state) => state.filterDefaultValue,
              builder: (context, filterValue) => Container(
                margin: EdgeInsetsDirectional.only(end: context.md),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.primaryColor,
                      context.colorScheme.tertiary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(context.md),
                  boxShadow: [
                    BoxShadow(
                      color: context.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(context.md),
                    onTap: () => showModalBottomSheet<void>(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (bottomSheetContext) => FilterDropdownSheetView(
                        defaultPeriod: filterValue,
                        title: _tabController.index == 0
                            ? context.l10n.expense
                            : context.l10n.payment,
                        onChanged: (value) {
                          if (_tabController.index == 0) {
                            context
                                .read<ExpenseCubit>()
                                .loadExpenseStats(period: value);
                          } else {
                            context
                                .read<PaymentCubit>()
                                .fetchPaymentStats(value);
                          }
                        },
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(context.sm1),
                      child: Icon(
                        Icons.tune_rounded,
                        color: context.onPrimaryColor,
                        size: context.iconMd,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: context.primaryColor,
            unselectedLabelColor: context.colorScheme.onSurfaceVariant,
            indicatorColor: context.primaryColor,
            indicatorWeight: 3,
            tabs: [
              Tab(text: context.l10n.expense),
              Tab(text: context.l10n.payment),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            ExpensePageContent(),
            PaymentPageContent(),
          ],
        ),
      );
}
