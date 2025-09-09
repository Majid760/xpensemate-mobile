import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomDropDown extends StatefulWidget {
  const CustomDropDown(
      {super.key, this.defaultValue, this.value, required this.onChanged});
  final String? defaultValue;
  final List<String>? value;
  final Function(String?) onChanged;

  @override
  State<CustomDropDown> createState() => _CustomDropDownState();
}

class _CustomDropDownState extends State<CustomDropDown>
    with SingleTickerProviderStateMixin {
  late AnimationController _dropdownAnimationController;
  late Animation<double> _dropdownOpacityAnimation;

  late Animation<double> _dropdownAnimation;

  String _selectedPeriod = 'weekly';
  bool _isDropdownOpen = false;
  final List<String> _periods = ['Weekly', 'Monthly', 'Yearly'];

  @override
  void initState() {
    super.initState();
    _selectedPeriod = widget.defaultValue ?? _periods.first;
    _dropdownAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _dropdownAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _dropdownAnimationController,
        curve: Curves.easeOutBack,
      ),
    );

    _dropdownOpacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _dropdownAnimationController,
        curve: const Interval(0, 0.7, curve: Curves.easeOut),
      ),
    );
  }

  void _toggleDropdown() {
    setState(() {
      _isDropdownOpen = !_isDropdownOpen;
    });

    if (_isDropdownOpen) {
      _dropdownAnimationController.forward();
    } else {
      _dropdownAnimationController.reverse();
    }

    HapticFeedback.lightImpact();
  }

  void _selectPeriod(String period) {
    widget.onChanged(period);
    setState(() {
      _selectedPeriod = period;
      _isDropdownOpen = false;
    });
    _dropdownAnimationController.reverse();

    HapticFeedback.selectionClick();
  }

  @override
  void dispose() {
    _dropdownAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Dropdown button
          GestureDetector(
            onTap: _toggleDropdown,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedPeriod,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: _isDropdownOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Dropdown menu
          AnimatedBuilder(
            animation: _dropdownAnimation,
            builder: (context, child) {
              if (_dropdownAnimation.value == 0) {
                return const SizedBox.shrink();
              }

              return Transform.scale(
                scale: _dropdownAnimation.value,
                alignment: Alignment.topRight,
                child: Transform.translate(
                  offset: Offset(0, 10 * (1 - _dropdownAnimation.value)),
                  child: Opacity(
                    opacity: _dropdownOpacityAnimation.value,
                    child: Container(
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: _periods.map((period) {
                            final isSelected = period == _selectedPeriod;
                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _selectPeriod(period),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Theme.of(context)
                                            .primaryColor
                                            .withValues(alpha: 0.1)
                                        : Colors.transparent,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (isSelected)
                                        Container(
                                          width: 6,
                                          height: 6,
                                          margin:
                                              const EdgeInsets.only(right: 8),
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).primaryColor,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      Text(
                                        period,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Theme.of(context).primaryColor
                                              : Colors.grey[700],
                                          fontSize: 14,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      );
}
