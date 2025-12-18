import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xpensemate/core/route/utils/router_extension.dart';
import 'package:xpensemate/core/utils/app_logger.dart';
import 'package:xpensemate/features/budget/presentation/pages/budget_page.dart';

import 'package:xpensemate/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:xpensemate/features/expense/presentation/pages/expense_page.dart';
import 'package:xpensemate/features/payment/presentation/pages/payment_page.dart';

// Define a typedef for the custom FAB action
typedef FabActionCallback = void Function(int index);

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.child, this.customFabAction});
  final Widget child;
  final FabActionCallback? customFabAction;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with TickerProviderStateMixin {
  /* ---------- controllers & animations ---------- */
  late final AnimationController _animationController = AnimationController(
    duration: const Duration(milliseconds: 200),
    vsync: this,
  );

  late final AnimationController _fabAnimationController = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  );

  late final Animation<double> _fabAnimation =
      Tween<double>(begin: 0, end: 1).animate(
    CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeOut),
  );

  bool _isFabExpanded = false;

  /* ---------- data ---------- */
  final _navItems = const [
    NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard', route: '/home'),
    NavItem(
      icon: Icons.account_balance_wallet_rounded,
      label: 'Expense',
      route: '/home/expense',
    ),
    NavItem(icon: Icons.add, label: 'Add', route: ''),
    NavItem(
      icon: Icons.payment_rounded,
      label: 'Budget',
      route: '/home/budget',
    ),
    NavItem(
      icon: Icons.currency_exchange_rounded,
      label: 'Payment',
      route: '/home/payment',
    ),
  ];

  final _fabActions = const [
    FabAction(
      icon: Icons.receipt_long_rounded,
      label: 'Add Expense',
      route: '/home/expense',
    ),
    FabAction(
      icon: Icons.account_balance_wallet_rounded,
      label: 'Add Budget',
      route: '/home/budget',
    ),
    FabAction(
      icon: Icons.payment_rounded,
      label: 'Add Payment',
      route: '/home/payment',
    ),
  ];

  /* ---------- helpers ---------- */
  int _calculateSelectedIndex(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    if (loc.startsWith('/home/budget')) return 3;
    if (loc.startsWith('/home/expense')) return 1;
    if (loc.startsWith('/home/payment')) return 4;
    // Default to dashboard for /home and /home/dashboard
    if (loc == '/home' || loc.startsWith('/home/dashboard')) return 0;
    return 0;
  }

  void _onFabTap() {
    // If custom action is provided, use it instead of default behavior
    final currentIndex = _calculateSelectedIndex(context);

    // If we're on dashboard (index 0), always show the arc menu
    if (currentIndex == 0) {
      _toggleFab();
      return;
    }
    if (widget.customFabAction != null) {
      // find out which action to trigger based on current route
      if (GoRouterState.of(context)
          .matchedLocation
          .startsWith('/home/expense')) {
        widget.customFabAction!(1);
        return;
      } else if (GoRouterState.of(context)
          .matchedLocation
          .startsWith('/home/budget')) {
        widget.customFabAction!(3);
        return;
      } else if (GoRouterState.of(context)
          .matchedLocation
          .startsWith('/home/payment')) {
        widget.customFabAction!(4);
        return;
      }
      // widget.customFabAction!(0);
      // return;
    }

    // Default behavior - toggle FAB
    _toggleFab();
  }

  void _onItemTapped(int index, BuildContext context) {
    if (index == 2) {
      // Only toggle FAB if no custom action is provided
      if (widget.customFabAction == null) {
        _toggleFab();
      } else {
        // Execute custom action directly
        widget.customFabAction!(index);
      }
      return;
    }
    if (_isFabExpanded) {
      _toggleFab();
    }

    final current = _calculateSelectedIndex(context);
    if (current != index) {
      _animationController
          .forward()
          .then((_) => _animationController.reverse());

      // Navigate to the correct route based on the tab index
      print('Index 2323: $index');
      switch (index) {
        case 0: // Dashboard
          context.go('/home');
          break;
        case 1: // expense
          context.go('/home/expense');
          break;
        case 3: // Budget
          context.go('/home/budget');
          break;
        case 4: // Payment
          context.go('/home/payment');
          break;
      }

      // Reset navigation flag after a delay
      Future.delayed(const Duration(milliseconds: 500), () {});
    }
  }

  void _toggleFab() {
    setState(() => _isFabExpanded = !_isFabExpanded);
    _isFabExpanded
        ? _fabAnimationController.forward()
        : _fabAnimationController.reverse();
  }

  void _onFabAction(FabAction action, int index) {
    logI('FAB Action clicked - Index: $index');
    logI('FAB Action route: ${action.route}');

    // Close the FAB menu
    _toggleFab();

    // Navigate to the correct route based on the FAB action
    switch (index) {
      case 0:
        addPayment(
          context: context,
          onSave: (payment) async {
            await context.dashboardCubit.createPayment(payment: payment);
            if (context.mounted) {
              Navigator.of(context).pop();
              if (_isFabExpanded) {
                _toggleFab();
              }
            }
          },
        );
        break;
      case 1:
        addExpense(
          context: context,
          onSave: (expense) async {
            await context.dashboardCubit.createExpense(expense: expense);
            if (context.mounted) {
              Navigator.of(context).pop();
              if (_isFabExpanded) {
                _toggleFab();
              }
            }
          },
        );
        break;
      case 2:
        addBudget(
          context: context,
          onSave: (budget) async {
            await context.dashboardCubit.createBudget(budget: budget);
            if (context.mounted) {
              Navigator.of(context).pop();
              if (_isFabExpanded) {
                _toggleFab();
              }
            }
          },
        );
        break;
      default:
        context.goToProfile(); // fallback
    }

    _toggleFab();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  /* ---------- build ---------- */
  /* ---------- build ---------- */
  @override
  Widget build(BuildContext context) {
    final currentIndex = _calculateSelectedIndex(context);
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Content with padding for bottom bar
          Padding(
            padding: const EdgeInsets.only(bottom: 90),
            child: widget.child,
          ),

          // Dimmer Overlay
          if (_isFabExpanded)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleFab,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.3),
                ),
              ),
            ),

          // Bottom Bar Background & Nav Items
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildNavBar(currentIndex),
          ),

          // Arc Action Buttons (Menu)
          if (widget.customFabAction == null || currentIndex == 0)
            ..._fabActions.asMap().entries.map((e) {
              final idx = e.key;
              final action = e.value;
              return _ArcActionButton(
                action: action,
                animation: _fabAnimation,
                index: idx,
                total: _fabActions.length,
                onTap: () => _onFabAction(action, idx),
              );
            }),

          // Main FAB
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: _buildFab(),
            ),
          ),
        ],
      ),
    );
  }

  /* ---------- sub-widgets ---------- */

  Widget _buildNavBar(int currentIndex) => SizedBox(
        height: 100,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // curved background
            Positioned(
              top: 4,
              child: CustomPaint(
                size: Size(MediaQuery.of(context).size.width, 80),
                painter: CurvedBottomBarPainter(),
              ),
            ),

            // navigation items
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _navItems.asMap().entries.map((e) {
                final idx = e.key;
                final item = e.value;
                final selected = currentIndex == idx;
                if (idx == 2) return const SizedBox(width: 56);
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _onItemTapped(idx, context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.icon,
                            size: 24,
                            color: selected
                                ? const Color(0xFF6366F1)
                                : Colors.grey.shade600,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight:
                                  selected ? FontWeight.w600 : FontWeight.w500,
                              color: selected
                                  ? const Color(0xFF6366F1)
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );

  Widget _buildFab() => AnimatedBuilder(
        animation: _fabAnimation,
        builder: (_, __) => Transform.scale(
          scale: 1.0 + (_fabAnimation.value * 0.05),
          child: Transform.rotate(
            angle: _fabAnimation.value * (math.pi / 4),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF6366F1),
                    Color(0xFF8B5CF6),
                    Color(0xFFA855F7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(28),
                child: InkWell(
                  borderRadius: BorderRadius.circular(28),
                  onTap: _onFabTap,
                  child: Center(
                    child: Icon(
                      _isFabExpanded ? Icons.close : Icons.add,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

/* ---------- arc action button ---------- */
class _ArcActionButton extends StatelessWidget {
  const _ArcActionButton({
    required this.action,
    required this.animation,
    required this.index,
    required this.total,
    required this.onTap,
  });

  final FabAction action;
  final Animation<double> animation;
  final int index;
  final int total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mid = (total - 1) / 2;
    final angle = (index - mid) * (math.pi / 3);
    const radius = 100.0;
    final dx = radius * math.sin(angle);
    final dy = radius * math.cos(angle);

    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) {
        final t = Curves.easeOut.transform(animation.value);
        return Positioned(
          left: (MediaQuery.of(context).size.width / 2) + dx * t - 22,
          bottom: 48 + dy * t,
          child: Transform.scale(
            scale: t,
            child: Opacity(
              opacity: t,
              child: GestureDetector(
                onTap: onTap,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF6366F1),
                        Color(0xFF8B5CF6),
                        Color(0xFFA855F7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(action.icon, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/* ---------- curved painter ---------- */
class CurvedBottomBarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final path = Path()
      ..moveTo(0, 20)
      ..quadraticBezierTo(size.width * 0.35, 20, size.width * 0.4, 0)
      ..quadraticBezierTo(size.width * 0.45, -20, size.width * 0.5, -20)
      ..quadraticBezierTo(size.width * 0.55, -20, size.width * 0.6, 0)
      ..quadraticBezierTo(size.width * 0.65, 20, size.width, 20)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/* ---------- data classes ---------- */
class NavItem {
  const NavItem({required this.icon, required this.label, required this.route});
  final IconData icon;
  final String label;
  final String route;
}

class FabAction {
  const FabAction({
    required this.icon,
    required this.label,
    required this.route,
  });
  final IconData icon;
  final String label;
  final String route;
}
