import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xpensemate/core/widget/custom_app_loader.dart';

class SocialButton extends StatefulWidget {
  const SocialButton({
    super.key,
    required this.onPressed,
    required this.iconAsset,
    this.tooltip,
    this.size = 24,
    this.backgroundColor,
    this.borderColor,
    this.hoverColor,
    this.borderRadius = 12,
    this.padding,
    this.isLoading = false,
  });
  final VoidCallback? onPressed;
  final String iconAsset;
  final String? tooltip;
  final double size;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? hoverColor;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool isLoading;

  // Pre-configured social buttons
  static SocialButton google({
    Key? key,
    required VoidCallback? onPressed,
    double size = 24,
    String? tooltip = 'Continue with Google',
    bool isLoading = false,
  }) =>
      SocialButton(
        key: key,
        onPressed: onPressed,
        iconAsset: 'assets/images/google.png',
        tooltip: tooltip,
        size: size,
        isLoading: isLoading,
      );

  static SocialButton facebook({
    Key? key,
    required VoidCallback? onPressed,
    double size = 24,
    String? tooltip = 'Continue with Facebook',
    bool isLoading = false,
  }) =>
      SocialButton(
        key: key,
        onPressed: onPressed,
        iconAsset: 'assets/images/facebook.png',
        tooltip: tooltip,
        size: size,
        hoverColor: const Color(0xFF1877F2).withValues(alpha: 0.08),
        isLoading: isLoading,
      );

  static SocialButton apple({
    Key? key,
    required VoidCallback? onPressed,
    double size = 24,
    String? tooltip = 'Continue with Apple',
    bool isLoading = false,
  }) =>
      SocialButton(
        key: key,
        onPressed: onPressed,
        iconAsset: 'assets/images/apple.png',
        tooltip: tooltip,
        size: size,
        hoverColor: Colors.black.withValues(alpha: 0.06),
        isLoading: isLoading,
      );

  static SocialButton github({
    Key? key,
    required VoidCallback? onPressed,
    double size = 24,
    String? tooltip = 'Continue with GitHub',
    bool isLoading = false,
  }) =>
      SocialButton(
        key: key,
        onPressed: onPressed,
        iconAsset: 'assets/images/github.png',
        tooltip: tooltip,
        size: size,
        hoverColor: Colors.black.withValues(alpha: 0.06),
        isLoading: isLoading,
      );

  @override
  State<SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<SocialButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 0.95,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _elevationAnimation = Tween<double>(
      begin: 0,
      end: 4,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = true);
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  void _handleHoverEnter(PointerEnterEvent event) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isHovered = true);
    }
  }

  void _handleHoverExit(PointerExitEvent event) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isHovered = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final backgroundColor = widget.backgroundColor ?? colorScheme.surface;
    final borderColor = widget.borderColor ?? colorScheme.outlineVariant;
    final hoverColor =
        widget.hoverColor ?? colorScheme.primary.withValues(alpha: 0.08);

    return MouseRegion(
      onEnter: _handleHoverEnter,
      onExit: _handleHoverExit,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onPressed,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: widget.padding ?? const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isHovered
                    ? Color.lerp(backgroundColor, hoverColor, 0.8)
                    : backgroundColor,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(
                  color: _isHovered
                      ? borderColor.withValues(alpha: 0.6)
                      : borderColor,
                ),
                boxShadow: [
                  if (_isHovered && !widget.isLoading)
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  if (_isPressed && !widget.isLoading)
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: _buildButtonContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (widget.isLoading) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomAppLoader(
          size: widget.size,
          strokeWidth: 2,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    final iconWidget = AnimatedOpacity(
      opacity: widget.onPressed != null ? 1.0 : 0.5,
      duration: const Duration(milliseconds: 200),
      child: Image.asset(
        widget.iconAsset,
        height: widget.size,
        width: widget.size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.login,
          size: widget.size,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(
        message: widget.tooltip,
        child: iconWidget,
      );
    }

    return iconWidget;
  }
}
