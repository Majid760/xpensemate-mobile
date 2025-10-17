// Search and Filter Bar with shadow
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:xpensemate/features/auth/presentation/widgets/custom_text_form_field.dart';

class SearchAndFilterBar extends StatefulWidget {
  const SearchAndFilterBar({super.key});

  @override
  State<SearchAndFilterBar> createState() => _SearchAndFilterBarState();
}

class _SearchAndFilterBarState extends State<SearchAndFilterBar>
    with SingleTickerProviderStateMixin {
  bool _isFilterVisible = false;
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;
  late Animation<double> _fadeAnimation;
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

    _heightAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
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
      }
    });
  }

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ReactiveForm(
                  formGroup: _form,
                  child: ReactiveAppField(
                    formControlName: 'search',
                    radius: BorderRadius.circular(36),
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
                        ? const Color(0xFF6C63FF)
                        : Colors.grey[200]!,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _isFilterVisible
                          ? const Color(0xFF6C63FF)
                          : Colors.grey[200]!,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _isFilterVisible
                            ? const Color(0xFF6C63FF).withOpacity(0.3)
                            : Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.filter_list,
                    color: _isFilterVisible ? Colors.white : Colors.grey[600],
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          SizeTransition(
            sizeFactor: _heightAnimation,
            axisAlignment: -1,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                margin: const EdgeInsets.only(top: 16),
                child: const PaymentMethodFilter(),
              ),
            ),
          ),
        ],
      );
}

// Payment Method Filter
class PaymentMethodFilter extends StatefulWidget {
  const PaymentMethodFilter({super.key});

  @override
  State<PaymentMethodFilter> createState() => _PaymentMethodFilterState();
}

class _PaymentMethodFilterState extends State<PaymentMethodFilter> {
  String selected = 'All';

  void _selectFilter(String filter) {
    setState(() {
      selected = filter;
    });
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
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
            color: isSelected ? const Color(0xFF6C63FF) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? const Color(0xFF6C63FF) : Colors.grey[200]!,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? const Color(0xFF6C63FF).withOpacity(0.3)
                    : Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      );
}
