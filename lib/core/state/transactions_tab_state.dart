/// Shared state to track the active tab index inside [TransactionsPage].
///
/// 0 = Expense tab, 1 = Payment tab.
/// Updated by [TransactionsPage] whenever the tab changes; read by
/// [MainShell]'s FAB handler (via app_router.dart) to decide which
/// add-form to open.
class TransactionsTabState {
  TransactionsTabState._();

  static int activeTabIndex = 0;
}
