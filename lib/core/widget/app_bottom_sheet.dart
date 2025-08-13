import 'package:flutter/material.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/theme/colors/app_colors.dart';
import 'dart:ui';

class ModernBottomSheet extends StatefulWidget {
  const ModernBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.height,
    this.showHandle = true,
    this.enableDrag = true,
    this.showCloseButton = true,
    this.backgroundColor,
    this.borderRadius = 28.0,
    this.padding,
    this.isExpandable = false,
    this.initialHeight,
    this.maxHeight,
  });

  final Widget child;
  final String? title;
  final double? height;
  final bool showHandle;
  final bool enableDrag;
  final bool showCloseButton;
  final Color? backgroundColor;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool isExpandable;
  final double? initialHeight;
  final double? maxHeight;

  @override
  State<ModernBottomSheet> createState() => _ModernBottomSheetState();

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    double? height,
    bool showHandle = true,
    bool enableDrag = true,
    bool showCloseButton = true,
    Color? backgroundColor,
    double borderRadius = 28.0,
    EdgeInsetsGeometry? padding,
    bool isScrollControlled = true,
    bool useRootNavigator = false,
    bool isDismissible = true,
    bool isExpandable = false,
    double? initialHeight,
    double? maxHeight,
  }) => showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      useRootNavigator: useRootNavigator,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (context) => ModernBottomSheet(
        title: title,
        height: height,
        showHandle: showHandle,
        enableDrag: enableDrag,
        showCloseButton: showCloseButton,
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
        padding: padding,
        isExpandable: isExpandable,
        initialHeight: initialHeight,
        maxHeight: maxHeight,
        child: child,
      ),
    );
}

class _ModernBottomSheetState extends State<ModernBottomSheet>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  late AnimationController _dragController;
  late Animation<double> _dragAnimation;
  
  double _currentHeight = 0;
  double _dragStartHeight = 0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeDragController();
  }

  void _initializeAnimations() {
    // Fast slide animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Quick fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    // Smooth scale animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // Start animations
    _slideController.forward();
    _fadeController.forward();
    _scaleController.forward();
  }

  void _initializeDragController() {
    _dragController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _dragAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _dragController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _dragController.dispose();
    super.dispose();
  }

  Future<void> _closeBottomSheet() async {
    await Future.wait([
      _slideController.reverse(),
      _fadeController.reverse(),
      _scaleController.reverse(),
    ]);
    
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _onDragStart(DragStartDetails details) {
    if (!widget.isExpandable) return;
    
    setState(() {
      _isDragging = true;
      _dragStartHeight = _currentHeight;
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!widget.isExpandable) return;
    
    final newHeight = _dragStartHeight - details.primaryDelta!;
    final screenHeight = MediaQuery.of(context).size.height;
    final minHeight = widget.initialHeight ?? screenHeight * 0.3;
    final maxHeight = widget.maxHeight ?? screenHeight * 0.9;
    
    setState(() {
      _currentHeight = newHeight.clamp(minHeight, maxHeight);
    });
    
    _dragController.value = (_currentHeight - minHeight) / (maxHeight - minHeight);
  }

  void _onDragEnd(DragEndDetails details) {
    if (!widget.isExpandable) return;
    
    setState(() {
      _isDragging = false;
    });
    
    final screenHeight = MediaQuery.of(context).size.height;
    final minHeight = widget.initialHeight ?? screenHeight * 0.3;
    final maxHeight = widget.maxHeight ?? screenHeight * 0.9;
    
    // Snap to nearest position
    if (_currentHeight < (minHeight + maxHeight) / 2) {
      _animateToHeight(minHeight);
    } else {
      _animateToHeight(maxHeight);
    }
  }

  void _animateToHeight(double targetHeight) {
    _dragController.animateTo(
      (targetHeight - (widget.initialHeight ?? MediaQuery.of(context).size.height * 0.3)) / 
      ((widget.maxHeight ?? MediaQuery.of(context).size.height * 0.9) - (widget.initialHeight ?? MediaQuery.of(context).size.height * 0.3)),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
    
    setState(() {
      _currentHeight = targetHeight;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomSheetHeight = widget.height ?? screenHeight * 0.7;
    
    if (_currentHeight == 0) {
      _currentHeight = widget.initialHeight ?? bottomSheetHeight;
    }

    return AnimatedBuilder(
      animation: Listenable.merge([
        _slideController,
        _fadeController,
        _scaleController,
        _dragController,
      ]),
      builder: (context, child) => Stack(
        children: [
          // Background overlay with blur effect
          GestureDetector(
            onTap: _closeBottomSheet,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              color: Colors.black.withValues(alpha: 0.4 * _fadeAnimation.value),
              width: double.infinity,
              height: double.infinity,
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 8 * _fadeAnimation.value,
                  sigmaY: 8 * _fadeAnimation.value,
                ),
              ),
            ),
          ),
          
          // Bottom sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Transform.translate(
              offset: Offset(0, bottomSheetHeight * _slideAnimation.value),
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: GestureDetector(
                  onPanStart: _onDragStart,
                  onPanUpdate: _onDragUpdate,
                  onPanEnd: _onDragEnd,
                  child: Container(
                    height: widget.isExpandable ? _currentHeight : bottomSheetHeight,
                    decoration: BoxDecoration(
                      color: widget.backgroundColor ?? context.colorScheme.surface,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(widget.borderRadius),
                        topRight: Radius.circular(widget.borderRadius),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: context.colorScheme.shadow.withValues(alpha: 0.15),
                          blurRadius: 30,
                          offset: const Offset(0, -10),
                          spreadRadius: 5,
                        ),
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header with handle and title
                        _buildHeader(),
                        // Content
                        Expanded(
                          child: Padding(
                            padding: widget.padding ?? EdgeInsets.all(context.lg),
                            child: widget.child,
                          ),
                        ),
                      ],
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

  Widget _buildHeader() => Container(
    padding: EdgeInsets.symmetric(
      horizontal: context.lg,
      vertical: context.md,
    ),
    child: Column(
      children: [
        if (widget.showHandle)
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.only(bottom: context.sm),
            decoration: BoxDecoration(
              color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        if (widget.title != null || widget.showCloseButton)
          Row(
            children: [
              if (widget.title != null)
                Expanded(
                  child: Text(
                    widget.title!,
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: context.colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              if (widget.showCloseButton)
                GestureDetector(
                  onTap: _closeBottomSheet,
                  child: Container(
                    padding: EdgeInsets.all(context.sm),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          context.colorScheme.surfaceContainerHighest,
                          context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: context.colorScheme.outline.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
      ],
    ),
  );
}