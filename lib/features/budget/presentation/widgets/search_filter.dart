// Search and Filter Bar with shadow
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:xpensemate/features/auth/presentation/widgets/custom_text_form_field.dart';
import 'package:xpensemate/features/budget/presentation/cubit/budget_expense_cubit.dart';

class SearchAndFilterBar extends StatefulWidget {
  const SearchAndFilterBar({
    super.key,
    this.onFilterToggle,
  });

  final void Function(bool)? onFilterToggle;

  @override
  State<SearchAndFilterBar> createState() => _SearchAndFilterBarState();
}

class _SearchAndFilterBarState extends State<SearchAndFilterBar>
    with SingleTickerProviderStateMixin {
  bool _isFilterVisible = false;
  late AnimationController _animationController;
  late final FormGroup _form;

  @override
  void initState() {
    _form = FormGroup(
      {
        'search': FormControl<String>(
          validators: [],
        ),
      },
    );
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Listen to form changes for search
    _form.control('search').valueChanges.listen((value) {
      if (context.mounted) {
        context.budgetExpensesCubit.updateSearchQuery(value as String? ?? '');
      }
    });
  }

  @override
  void dispose() {
    _form.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleFilter() {
    setState(() {
      _isFilterVisible = !_isFilterVisible;
      if (_isFilterVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
        // Reset payment method filter to 'all' when switching back to search view
        if (context.mounted) {
          context.budgetExpensesCubit.updatePaymentMethodFilter('all');
        }
      }
    });

    // Notify parent about filter state change
    widget.onFilterToggle?.call(_isFilterVisible);
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Show either search bar or filter options based on _isFilterVisible state
              if (!_isFilterVisible) ...[
                Row(
                  children: [
                    Expanded(
                      child: ReactiveForm(
                        formGroup: _form,
                        child: ReactiveAppField(
                          formControlName: 'search',
                          radius: BorderRadius.circular(36),
                          fieldType: FieldType.search,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _toggleFilter,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: _isFilterVisible
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _isFilterVisible
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outlineVariant,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _isFilterVisible
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.3)
                                  : Theme.of(context)
                                      .colorScheme
                                      .shadow
                                      .withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.filter_list,
                          color: _isFilterVisible
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Show filter options when filter is active
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filter by Payment Method',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: _toggleFilter,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                PaymentMethodFilter(
                  onFilterChanged: (method) {
                    if (context.mounted) {
                      // Convert display names to database format
                      final dbFormat = _convertToDatabaseFormat(method);
                      context.budgetExpensesCubit
                          .updatePaymentMethodFilter(dbFormat);
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      );

  // Convert display names to database format
  String _convertToDatabaseFormat(String displayName) {
    switch (displayName) {
      case 'Cash':
        return 'cash';
      case 'Credit Card':
        return 'credit_card';
      case 'Debit Card':
        return 'debit_card';
      default:
        return 'all'; // For 'All' option
    }
  }
}

// Payment Method Filter
class PaymentMethodFilter extends StatefulWidget {
  const PaymentMethodFilter({super.key, this.onFilterChanged});

  final Function(String)? onFilterChanged;

  @override
  State<PaymentMethodFilter> createState() => _PaymentMethodFilterState();
}

class _PaymentMethodFilterState extends State<PaymentMethodFilter> {
  String selected = 'All';

  void _selectFilter(String filter) {
    setState(() {
      selected = filter;
      widget.onFilterChanged?.call(filter);
    });
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 40, // Fixed height to prevent overflow
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilterChip(
                label: 'All',
                isSelected: selected == 'All',
                onTap: () => _selectFilter('All'),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: 'Cash',
                isSelected: selected == 'Cash',
                onTap: () => _selectFilter('Cash'),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: 'Credit Card',
                isSelected: selected == 'Credit Card',
                onTap: () => _selectFilter('Credit Card'),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: 'Debit Card',
                isSelected: selected == 'Debit Card',
                onTap: () => _selectFilter('Debit Card'),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      );
}

// Filter Chip Widget with shadow
class FilterChip extends StatelessWidget {
  const FilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outlineVariant,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.3)
                    : Theme.of(context)
                        .colorScheme
                        .shadow
                        .withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      );
}
