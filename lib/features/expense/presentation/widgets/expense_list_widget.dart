import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/widget/error_state_widget.dart';
import 'package:xpensemate/features/expense/domain/entities/expense_entity.dart';
import 'package:xpensemate/features/expense/presentation/cubit/expense_cubit.dart';
import 'package:xpensemate/features/expense/presentation/widgets/expense_item_widget.dart';

class ExpenseListWidget extends StatefulWidget {
  const ExpenseListWidget({
    super.key,
    this.onDelete,
    this.onEdit,
    this.scrollThreshold = 5,
    this.scrollController, // Add scroll controller parameter
  });

  final void Function(String expenseId)? onDelete;
  final void Function(ExpenseEntity expenseEntity)? onEdit;
  final int scrollThreshold; // Items before end to trigger loading
  final ScrollController? scrollController; // Optional scroll controller

  @override
  State<ExpenseListWidget> createState() => _ExpenseListWidgetState();
}

class _ExpenseListWidgetState extends State<ExpenseListWidget>
    with SingleTickerProviderStateMixin {
  late ExpenseCubit _expenseCubit;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 1.2,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _bounceAnimation = Tween<double>(
      begin: 0,
      end: -8,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _expenseCubit = context.read<ExpenseCubit>();
  }

  void _scrollToTop() {
    if (widget.scrollController != null) {
      widget.scrollController!.animateTo(
        0,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  void _startAnimation() {
    _animationController.repeat(reverse: true);
  }

  void _stopAnimation() {
    _animationController.stop();
    _animationController.reset();
  }

  Widget _buildInitialLoading() => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: CircularProgressIndicator.adaptive(),
          ),
        ),
      );

  Widget _buildInitialError(ExpenseState state) => SliverToBoxAdapter(
        child: ErrorStateSectionWidget(
          errorMsg: state.errorMessage,
          onRetry: () => _expenseCubit.refreshExpenses(),
        ),
      );

  Widget _buildEmptyState() => SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 64,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  context.l10n.noDataAvailable,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.emptyListMessage,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildLoadingMoreIndicator() => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Text(
                  '${context.l10n.loading}...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildPaginationError(ExpenseState state) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                state.paginationError ?? context.l10n.errorGeneric,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => _expenseCubit.retryPaginationRequest(),
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(context.l10n.retry),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  textStyle: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildScrollToTopButton() {
    // Start animation when button is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAnimation();
    });

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
        child: Align(
          alignment: Alignment.bottomRight,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) => Transform.translate(
              offset: Offset(0, _bounceAnimation.value),
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: FloatingActionButton(
                    onPressed: _scrollToTop,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    child: const Icon(Icons.keyboard_arrow_up, size: 24),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEndOfListIndicator() => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        context.l10n.expenseLoaded,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<ExpenseCubit, ExpenseState>(
        listener: (context, state) {
          // Handle pagination errors with snackbar
          if (state.hasPaginationError && state.hasData) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(state.paginationError ?? context.l10n.errorGeneric),
                action: SnackBarAction(
                  label: context.l10n.retry,
                  onPressed: () => _expenseCubit.retryPaginationRequest(),
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }

          // Stop animation when state changes away from end of list
          if (!state.hasReachedMax) {
            _stopAnimation();
          }
        },
        builder: (context, state) {
          // Initial loading state
          if (state.isInitialLoading) {
            return _buildInitialLoading();
          }

          // Error state with no data
          if (state.hasError) {
            return _buildInitialError(state);
          }

          // No data state
          if (!state.hasData) {
            return _buildEmptyState();
          }

          // Build the expenses list with additional states
          final expenses = state.expenses!.expenses;

          return SliverMainAxisGroup(
            slivers: [
              // Main expenses list
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      // Check if we should trigger loading more
                      _expenseCubit.checkAndLoadMore(
                        index,
                        threshold: widget.scrollThreshold,
                      );

                      final expense = expenses[index];
                      return ExpenseListItem(
                        expense: expense,
                        isLast: index == expenses.length - 1,
                        onDelete: widget.onDelete,
                        onEdit: widget.onEdit,
                      );
                    },
                    childCount: expenses.length,
                  ),
                ),
              ),

              // Loading more indicator
              if (state.isLoadingMore) _buildLoadingMoreIndicator(),

              // Pagination error indicator
              if (state.hasPaginationError && !state.isLoadingMore)
                _buildPaginationError(state),

              // Scroll to top button when reached end
              if (state.hasReachedMax &&
                  !state.hasPaginationError &&
                  expenses.isNotEmpty) ...[
                _buildEndOfListIndicator(),
                _buildScrollToTopButton(),
              ],
            ],
          );
        },
      );
}
