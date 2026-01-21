import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
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
                    Text(
                      context.l10n.filterByPaymentMethod,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: _toggleFilter,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: context.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: context.onPrimaryColor,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.md),
                PaymentMethodFilter(
                  onFilterChanged: (method) {
                    if (context.mounted) {
                      // Convert display names to database format
                      // final dbFormat = _convertToDatabaseFormat(method);
                      context.budgetExpensesCubit
                          .updatePaymentMethodFilter(method);
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      );
}

class PaymentMethodFilter extends StatefulWidget {
  const PaymentMethodFilter({super.key, this.onFilterChanged});

  final void Function(String)? onFilterChanged;

  @override
  State<PaymentMethodFilter> createState() => _PaymentMethodFilterState();
}

class _PaymentMethodFilterState extends State<PaymentMethodFilter> {
  String selected = 'all';

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
                label: context.l10n.all,
                isSelected: selected == 'all',
                onTap: () => _selectFilter('all'),
              ),
              SizedBox(width: context.sm),
              FilterChip(
                label: context.l10n.cash,
                isSelected: selected == 'cash',
                onTap: () => _selectFilter('cash'),
              ),
              SizedBox(width: context.sm),
              FilterChip(
                label: context.l10n.creditCard,
                isSelected: selected == 'credit_card',
                onTap: () => _selectFilter('credit_card'),
              ),
              SizedBox(width: context.sm),
              FilterChip(
                label: context.l10n.debitCard,
                isSelected: selected == 'debit_card',
                onTap: () => _selectFilter('debit_card'),
              ),
              SizedBox(width: context.sm),
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
            color:
                isSelected ? context.primaryColor : context.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? context.primaryColor
                  : context.colorScheme.outlineVariant,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? context.primaryColor.withValues(alpha: 0.3)
                    : context.colorScheme.shadow.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              color: isSelected
                  ? context.onPrimaryColor
                  : context.colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      );
}
