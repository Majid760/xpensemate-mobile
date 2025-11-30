import 'package:flutter/material.dart';

class SectionHeader extends StatefulWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.onSearchChanged,
    this.searchHint = 'Search...',
  });

  final String title;
  final ValueChanged<String>? onSearchChanged;
  final String searchHint;

  @override
  State<SectionHeader> createState() => _SectionHeaderState();
}

class _SectionHeaderState extends State<SectionHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _widthAnimation;
  late Animation<double> _fadeOutAnimation;
  late Animation<double> _fadeInAnimation;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSearchExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Width expands smoothly from 0 to 1
    _widthAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );

    // Title fades out quickly at the start
    _fadeOutAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.3, curve: Curves.easeOut),
      ),
    );

    // Search field content fades in after expansion starts
    _fadeInAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1, curve: Curves.easeIn),
      ),
    );

    _searchController.addListener(() {
      setState(() {});
      widget.onSearchChanged?.call(_searchController.text);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
      if (_isSearchExpanded) {
        _animationController.forward();
        Future.delayed(
          const Duration(milliseconds: 400),
          _focusNode.requestFocus,
        );
      } else {
        _animationController.reverse();
        _searchController.clear();
        _focusNode.unfocus();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final screenWidth = MediaQuery.of(context).size.width;
          const buttonWidth = 48.0;
          final maxSearchWidth =
              screenWidth - buttonWidth - 45; // 32 for padding
          final currentSearchWidth = maxSearchWidth * _widthAnimation.value;

          return SizedBox(
            height: 50,
            child: Row(
              children: [
                // Left side - Icon and Title (fades out when search expands)
                Expanded(
                  child: IgnorePointer(
                    ignoring: _isSearchExpanded,
                    child: Opacity(
                      opacity: _fadeOutAnimation.value,
                      child: ClipRect(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final hasSpaceForIcon = constraints.maxWidth >= 40;
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (hasSpaceForIcon)
                                  Icon(
                                    Icons.receipt_long_rounded,
                                    color: Theme.of(context).primaryColor,
                                    size: 24,
                                  ),
                                if (hasSpaceForIcon) const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    widget.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                        ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                // Search Field Container (expands from right)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  width: currentSearchWidth,
                  height: 48,
                  child: currentSearchWidth > 50
                      ? Opacity(
                          opacity: _fadeInAnimation.value,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.3),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.15),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              focusNode: _focusNode,
                              style: Theme.of(context).textTheme.bodyMedium,
                              decoration: InputDecoration(
                                hintText: widget.searchHint,
                                hintStyle: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.5),
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Theme.of(context).primaryColor,
                                  size: 20,
                                ),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(
                                          Icons.clear,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.6),
                                          size: 20,
                                        ),
                                        onPressed: _clearSearch,
                                        splashRadius: 20,
                                      )
                                    : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                const SizedBox(width: 8),

                // Search/Close Button (always on the right)
                Container(
                  width: buttonWidth,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _isSearchExpanded
                        ? Theme.of(context).colorScheme.errorContainer
                        : Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, animation) =>
                          RotationTransition(
                        turns: Tween<double>(begin: 0.5, end: 1)
                            .animate(animation),
                        child: ScaleTransition(
                          scale: animation,
                          child: child,
                        ),
                      ),
                      child: Icon(
                        _isSearchExpanded ? Icons.close : Icons.search,
                        key: ValueKey<bool>(_isSearchExpanded),
                        color: _isSearchExpanded
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).primaryColor,
                        size: 22,
                      ),
                    ),
                    onPressed: _toggleSearch,
                    tooltip: _isSearchExpanded ? 'Close search' : 'Search',
                    splashRadius: 24,
                  ),
                ),
              ],
            ),
          );
        },
      );
}
