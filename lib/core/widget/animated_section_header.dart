import 'package:flutter/material.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/utils/app_utils.dart';

class AnimatedSectionHeader extends StatefulWidget {
  const AnimatedSectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.onSearchChanged,
    this.onSearchCleared,
    this.searchHint,
  });

  final String title;
  final Widget? icon;
  final ValueChanged<String>? onSearchChanged;
  final String? searchHint;
  final VoidCallback? onSearchCleared;

  @override
  State<AnimatedSectionHeader> createState() => _AnimatedSectionHeaderState();
}

class _AnimatedSectionHeaderState extends State<AnimatedSectionHeader>
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

    _widthAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );

    _fadeOutAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.3, curve: Curves.easeOut),
      ),
    );

    _fadeInAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1, curve: Curves.easeIn),
      ),
    );

    _searchController.addListener(() {
      setState(() {});
      if (_searchController.text.length >= 2 ||
          _searchController.text.isEmpty) {
        widget.onSearchChanged?.call(_searchController.text);
      }
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
          const Duration(milliseconds: 300),
          _focusNode.requestFocus,
        );
      } else {
        _animationController.reverse();
        widget.onSearchCleared?.call();

        _searchController.clear();
        _focusNode.unfocus();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _focusNode.requestFocus();
    widget.onSearchCleared?.call();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final screenWidth = context.screenWidth;
          final buttonWidth = context.xxl;
          final maxSearchWidth =
              screenWidth - buttonWidth - (context.md * 2 + context.sm1);
          final currentSearchWidth = maxSearchWidth * _widthAnimation.value;

          return SizedBox(
            height: 50, // Standard header height
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
                                if (hasSpaceForIcon) context.sm.widthBox,
                                Flexible(
                                  child: Text(
                                    widget.title,
                                    style: context.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: context.onSurfaceColor,
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
                  curve: Curves.ease,
                  width: currentSearchWidth,
                  height: 48,
                  child: currentSearchWidth > 50
                      ? Opacity(
                          opacity: _fadeInAnimation.value,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: context.colorScheme.surfaceContainer
                                  .withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(context.md),
                              border: Border.all(
                                color:
                                    context.primaryColor.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: context.primaryColor
                                      .withValues(alpha: 0.15),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              focusNode: _focusNode,
                              style: context.bodyMedium,
                              decoration: InputDecoration(
                                fillColor: context
                                    .colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.4),
                                hintText: widget.searchHint ??
                                    context.l10n.searchHint,
                                hintStyle: TextStyle(
                                  color: context.onSurfaceColor
                                      .withValues(alpha: 0.5),
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: context.primaryColor,
                                  size: context.iconSm,
                                ),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(
                                          Icons.clear,
                                          color: context.onSurfaceColor
                                              .withValues(alpha: 0.6),
                                          size: context.iconSm,
                                        ),
                                        onPressed: _clearSearch,
                                        splashRadius: 20,
                                      )
                                    : null,
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(context.sm1),
                                  borderSide: BorderSide(
                                    color: context.colorScheme.primary
                                        .withValues(alpha: 0.4),
                                    width: 1.5,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(context.sm1),
                                  borderSide: BorderSide(
                                    color: context.colorScheme.primary
                                        .withValues(alpha: 0.4),
                                    width: 1.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(context.sm1),
                                  borderSide: BorderSide(
                                    color: context.colorScheme.primary
                                        .withValues(alpha: 0.4),
                                    width: 2,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: context.md,
                                  vertical: context.sm1,
                                ),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                context.sm.widthBox,

                // Search/Close Button (always on the right)
                Container(
                  width: buttonWidth,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _isSearchExpanded
                        ? context.colorScheme.errorContainer
                        : context.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(context.sm1),
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
                            ? context.colorScheme.error
                            : context.primaryColor,
                        size: 22,
                      ),
                    ),
                    onPressed: _toggleSearch,
                    tooltip: _isSearchExpanded
                        ? context.l10n.closeSearch
                        : context.l10n.search,
                    splashRadius: context.lg,
                  ),
                ),
              ],
            ),
          );
        },
      );
}
