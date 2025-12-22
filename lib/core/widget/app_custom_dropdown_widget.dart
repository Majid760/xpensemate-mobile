import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';

class CustomDropDown extends StatefulWidget {
  const CustomDropDown({
    super.key,
    this.initialValue,
    required this.items,
    required this.onChanged,
  });

  final String? initialValue;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  State<CustomDropDown> createState() => _CustomDropDownState();
}

class _CustomDropDownState extends State<CustomDropDown>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  late String _selectedItem;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.initialValue ??
        (widget.items.isNotEmpty ? widget.items.first : '');

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void didUpdateWidget(CustomDropDown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != null) {
      _selectedItem = widget.initialValue!;
    }
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
    HapticFeedback.lightImpact();
  }

  void _openDropdown() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _animationController.forward();
    setState(() {
      _isOpen = true;
    });
  }

  Future<void> _closeDropdown() async {
    await _animationController.reverse();
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() {
        _isOpen = false;
      });
    }
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return OverlayEntry(builder: (_) => const SizedBox());
    }

    final size = renderBox.size;
    // final offset = renderBox.localToGlobal(Offset.zero);

    // Determine position (default to bottom, flip if close to bottom edge?)
    // For simplicity, just anchor to bottom right of target for now.

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Transparent dismiss barrier
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _closeDropdown,
              child: Container(color: Colors.transparent),
            ),
          ),
          // Dropdown content
          Positioned(
            width:
                200, // Or dynamic? Fixed width for the menu looks cleaner typically
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset:
                  Offset(size.width - 200, size.height + 8), // Align right edge
              child: Material(
                color: Colors.transparent,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    alignment: Alignment.topRight,
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 250),
                      decoration: BoxDecoration(
                        color: context.colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: context.colorScheme.outline
                              .withValues(alpha: 0.1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: context.colorScheme.shadow
                                .withValues(alpha: 0.15),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: SingleChildScrollView(
                                padding: EdgeInsets.zero,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: widget.items.map((item) {
                                    final isSelected = item == _selectedItem;
                                    return Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          _selectItem(item);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? context.colorScheme.primary
                                                    .withValues(alpha: 0.1)
                                                : Colors.transparent,
                                          ),
                                          child: Row(
                                            children: [
                                              if (isSelected)
                                                Container(
                                                  width: 6,
                                                  height: 6,
                                                  margin: const EdgeInsets.only(
                                                      right: 12),
                                                  decoration: BoxDecoration(
                                                    color: context
                                                        .colorScheme.primary,
                                                    shape: BoxShape.circle,
                                                  ),
                                                )
                                              else
                                                const SizedBox(width: 18),
                                              Expanded(
                                                child: Text(
                                                  item,
                                                  style: context
                                                      .textTheme.bodyMedium
                                                      ?.copyWith(
                                                    color: isSelected
                                                        ? context
                                                            .colorScheme.primary
                                                        : context.colorScheme
                                                            .onSurface,
                                                    fontWeight: isSelected
                                                        ? FontWeight.w600
                                                        : FontWeight.w500,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectItem(String item) {
    widget.onChanged(item);
    setState(() {
      _selectedItem = item;
    });
    _closeDropdown();
    HapticFeedback.selectionClick();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _isOpen
                ? context.colorScheme.primary.withValues(alpha: 0.1)
                : context.colorScheme.surfaceContainerHigh
                    .withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isOpen
                  ? context.colorScheme.primary.withValues(alpha: 0.2)
                  : context.colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _selectedItem,
                style: context.textTheme.labelLarge?.copyWith(
                  color: _isOpen
                      ? context.colorScheme.primary
                      : context.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              AnimatedRotation(
                turns: _isOpen ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: _isOpen
                      ? context.colorScheme.primary
                      : context.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
