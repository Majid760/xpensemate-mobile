import 'package:flutter/material.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';

class AppButton extends StatefulWidget {
  const AppButton._({
    super.key,
    required this.text,
    required this.onPressed,
    required this.buttonBuilder,
    this.isLoading = false,
    this.isFullWidth = true,
    this.padding,
    this.height = 48,
    this.minWidth,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 12,
    this.leadingIcon,
    this.trailingIcon,
    this.hasShadow = true,
    this.borderColor,
    this.elevation,
    this.textStyle,
    this.enabled = true,
    this.animationDuration = const Duration(milliseconds: 200),
    this.scaleOnTap = true,
    this.hoverEffect = true,
  });

  // Static method for primary button
  static AppButton primary({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool isFullWidth = true,
    EdgeInsetsGeometry? padding,
    double height = 48,
    double? minWidth,
    Color? backgroundColor,
    Color? textColor,
    double borderRadius = 12,
    Widget? leadingIcon,
    Widget? trailingIcon,
    bool hasShadow = true,
    Color? borderColor,
    double? elevation,
    TextStyle? textStyle,
    bool enabled = true,
    Duration? animationDuration,
    bool scaleOnTap = true,
    bool hoverEffect = true,
  }) =>
      AppButton._(
        key: key,
        text: text,
        onPressed: onPressed,
        buttonBuilder: (context, child) => _buildPrimaryButton(
          context,
          child,
          onPressed,
          backgroundColor,
          textColor,
          hasShadow,
          borderRadius,
          padding,
          isFullWidth,
          minWidth,
          height,
          elevation,
          enabled,
          isLoading,
          animationDuration ?? const Duration(milliseconds: 200),
          scaleOnTap,
          hoverEffect,
        ),
        isLoading: isLoading,
        isFullWidth: isFullWidth,
        padding: padding,
        height: height,
        minWidth: minWidth,
        backgroundColor: backgroundColor,
        textColor: textColor,
        borderRadius: borderRadius,
        leadingIcon: leadingIcon,
        trailingIcon: trailingIcon,
        hasShadow: hasShadow,
        borderColor: borderColor,
        elevation: elevation,
        textStyle: textStyle,
        enabled: enabled,
        animationDuration: animationDuration ?? const Duration(milliseconds: 200),
        scaleOnTap: scaleOnTap,
        hoverEffect: hoverEffect,
      );

  // Static method for secondary button
  static AppButton secondary({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool isFullWidth = true,
    EdgeInsetsGeometry? padding,
    double height = 48,
    double? minWidth,
    Color? backgroundColor,
    Color? textColor,
    double borderRadius = 12,
    Widget? leadingIcon,
    Widget? trailingIcon,
    bool hasShadow = false,
    Color? borderColor,
    double? elevation,
    TextStyle? textStyle,
    bool enabled = true,
    Duration? animationDuration,
    bool scaleOnTap = true,
    bool hoverEffect = true,
  }) =>
      AppButton._(
        key: key,
        text: text,
        onPressed: onPressed,
        buttonBuilder: (context, child) => _buildSecondaryButton(
          context,
          child,
          onPressed,
          backgroundColor,
          textColor,
          hasShadow,
          borderRadius,
          padding,
          isFullWidth,
          minWidth,
          height,
          elevation,
          enabled,
          isLoading,
          animationDuration ?? const Duration(milliseconds: 200),
          scaleOnTap,
          hoverEffect,
        ),
        isLoading: isLoading,
        isFullWidth: isFullWidth,
        padding: padding,
        height: height,
        minWidth: minWidth,
        backgroundColor: backgroundColor,
        textColor: textColor,
        borderRadius: borderRadius,
        leadingIcon: leadingIcon,
        trailingIcon: trailingIcon,
        hasShadow: hasShadow,
        borderColor: borderColor,
        elevation: elevation,
        textStyle: textStyle,
        enabled: enabled,
        animationDuration: animationDuration ?? const Duration(milliseconds: 200),
        scaleOnTap: scaleOnTap,
        hoverEffect: hoverEffect,
      );

  // Static method for outline button
  static AppButton outline({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool isFullWidth = true,
    EdgeInsetsGeometry? padding,
    double height = 48,
    double? minWidth,
    Color? backgroundColor,
    Color? textColor,
    double borderRadius = 12,
    Widget? leadingIcon,
    Widget? trailingIcon,
    Color? borderColor,
    double? elevation,
    TextStyle? textStyle,
    bool enabled = true,
    Duration? animationDuration,
    bool scaleOnTap = true,
    bool hoverEffect = true,
  }) =>
      AppButton._(
        key: key,
        text: text,
        onPressed: onPressed,
        buttonBuilder: (context, child) => _buildOutlineButton(
          context,
          child,
          onPressed,
          backgroundColor,
          textColor,
          borderRadius,
          padding,
          isFullWidth,
          minWidth,
          height,
          borderColor,
          enabled,
          isLoading,
          animationDuration ?? const Duration(milliseconds: 200),
          scaleOnTap,
          hoverEffect,
        ),
        isLoading: isLoading,
        isFullWidth: isFullWidth,
        padding: padding,
        height: height,
        minWidth: minWidth,
        backgroundColor: backgroundColor,
        textColor: textColor,
        borderRadius: borderRadius,
        leadingIcon: leadingIcon,
        trailingIcon: trailingIcon,
        hasShadow: false,
        borderColor: borderColor,
        elevation: elevation,
        textStyle: textStyle,
        enabled: enabled,
        animationDuration: animationDuration ?? const Duration(milliseconds: 200),
        scaleOnTap: scaleOnTap,
        hoverEffect: hoverEffect,
      );

  // Static method for text button
  static AppButton textButton({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool isFullWidth = false,
    EdgeInsetsGeometry? padding,
    double height = 48,
    double? minWidth,
    Color? backgroundColor,
    Color? textColor,
    double borderRadius = 12,
    Widget? leadingIcon,
    Widget? trailingIcon,
    Color? borderColor,
    double? elevation,
    TextStyle? textStyle,
    bool enabled = true,
    Duration? animationDuration,
    bool scaleOnTap = true,
    bool hoverEffect = true,
  }) =>
      AppButton._(
        key: key,
        text: text,
        onPressed: onPressed,
        buttonBuilder: (context, child) => _buildTextButton(
          context,
          child,
          onPressed,
          backgroundColor,
          textColor,
          borderRadius,
          padding,
          isFullWidth,
          minWidth,
          height,
          enabled,
          isLoading,
          animationDuration ?? const Duration(milliseconds: 200),
          scaleOnTap,
          hoverEffect,
        ),
        isLoading: isLoading,
        isFullWidth: isFullWidth,
        padding: padding,
        height: height,
        minWidth: minWidth,
        backgroundColor: backgroundColor,
        textColor: textColor,
        borderRadius: borderRadius,
        leadingIcon: leadingIcon,
        trailingIcon: trailingIcon,
        hasShadow: false,
        borderColor: borderColor,
        elevation: elevation,
        textStyle: textStyle,
        enabled: enabled,
        animationDuration: animationDuration ?? const Duration(milliseconds: 200),
        scaleOnTap: scaleOnTap,
        hoverEffect: hoverEffect,
      );

  // Static method for icon button
  static AppButton icon({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    required Widget leadingIcon,
    bool isLoading = false,
    bool isFullWidth = false,
    EdgeInsetsGeometry? padding,
    double height = 48,
    double? minWidth,
    Color? backgroundColor,
    Color? textColor,
    double borderRadius = 12,
    Widget? trailingIcon,
    bool hasShadow = true,
    Color? borderColor,
    double? elevation,
    TextStyle? textStyle,
    bool enabled = true,
    Duration? animationDuration,
    bool scaleOnTap = true,
    bool hoverEffect = true,
  }) =>
      AppButton._(
        key: key,
        text: text,
        onPressed: onPressed,
        buttonBuilder: (context, child) => _buildIconButton(
          context,
          text,
          leadingIcon,
          onPressed,
          backgroundColor,
          textColor,
          hasShadow,
          borderRadius,
          padding,
          isFullWidth,
          minWidth,
          height,
          elevation,
          textStyle,
          enabled,
          isLoading,
          animationDuration ?? const Duration(milliseconds: 200),
          scaleOnTap,
          hoverEffect,
        ),
        isLoading: isLoading,
        isFullWidth: isFullWidth,
        padding: padding,
        height: height,
        minWidth: minWidth,
        backgroundColor: backgroundColor,
        textColor: textColor,
        borderRadius: borderRadius,
        leadingIcon: leadingIcon,
        trailingIcon: trailingIcon,
        hasShadow: hasShadow,
        borderColor: borderColor,
        elevation: elevation,
        textStyle: textStyle,
        enabled: enabled,
        animationDuration: animationDuration ?? const Duration(milliseconds: 200),
        scaleOnTap: scaleOnTap,
        hoverEffect: hoverEffect,
      );

  // Static method for icon outline button
  static AppButton iconOutline({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    required Widget leadingIcon,
    bool isLoading = false,
    bool isFullWidth = false,
    EdgeInsetsGeometry? padding,
    double height = 48,
    double? minWidth,
    Color? backgroundColor,
    Color? textColor,
    double borderRadius = 12,
    Widget? trailingIcon,
    Color? borderColor,
    double? elevation,
    TextStyle? textStyle,
    bool enabled = true,
    Duration? animationDuration,
    bool scaleOnTap = true,
    bool hoverEffect = true,
  }) =>
      AppButton._(
        key: key,
        text: text,
        onPressed: onPressed,
        buttonBuilder: (context, child) => _buildIconOutlineButton(
          context,
          text,
          leadingIcon,
          onPressed,
          backgroundColor,
          textColor,
          borderRadius,
          padding,
          isFullWidth,
          minWidth,
          height,
          borderColor,
          textStyle,
          enabled,
          isLoading,
          animationDuration ?? const Duration(milliseconds: 200),
          scaleOnTap,
          hoverEffect,
        ),
        isLoading: isLoading,
        isFullWidth: isFullWidth,
        padding: padding,
        height: height,
        minWidth: minWidth,
        backgroundColor: backgroundColor,
        textColor: textColor,
        borderRadius: borderRadius,
        leadingIcon: leadingIcon,
        trailingIcon: trailingIcon,
        hasShadow: false,
        borderColor: borderColor,
        elevation: elevation,
        textStyle: textStyle,
        enabled: enabled,
        animationDuration: animationDuration ?? const Duration(milliseconds: 200),
        scaleOnTap: scaleOnTap,
        hoverEffect: hoverEffect,
      );

  final String text;
  final VoidCallback? onPressed;
  final Widget Function(BuildContext, Widget) buttonBuilder;
  final bool isLoading;
  final bool isFullWidth;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final double? minWidth;
  final Color? backgroundColor;
  final Color? textColor;
  final double borderRadius;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final bool hasShadow;
  final Color? borderColor;
  final double? elevation;
  final TextStyle? textStyle;
  final bool enabled;
  final Duration animationDuration;
  final bool scaleOnTap;
  final bool hoverEffect;

  @override
  State<AppButton> createState() => _AppButtonState();

  // Static button builders - Using ElevatedButton for primary/secondary
  static Widget _buildPrimaryButton(
    BuildContext context,
    Widget child,
    VoidCallback? onPressed,
    Color? backgroundColor,
    Color? textColor,
    bool hasShadow,
    double borderRadius,
    EdgeInsetsGeometry? padding,
    bool isFullWidth,
    double? minWidth,
    double height,
    double? elevation,
    bool enabled,
    bool isLoading,
    Duration animationDuration,
    bool scaleOnTap,
    bool hoverEffect,
  ) {
    final colorScheme = context.colorScheme;

    // Use system theme colors for gradient
    final gradient = LinearGradient(
      colors: [
        colorScheme.primary,
        colorScheme.secondary,
      ],
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
    );

    // If gradient is disabled or button is disabled, use solid color
    final bgColor = !enabled || isLoading
        ? (backgroundColor ?? colorScheme.primary)
        : null;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: isFullWidth ? double.infinity : null,
        constraints: minWidth != null ? BoxConstraints(minWidth: minWidth) : null,
        height: height,
        decoration: enabled && !isLoading
            ? BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: hasShadow && enabled
                    ? [
                        BoxShadow(
                          color: colorScheme.shadow.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              )
            : BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(borderRadius),
              ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          child: InkWell(
            onTap: (enabled && !isLoading) ? onPressed : null,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: context.lg, vertical: context.md),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildSecondaryButton(
    BuildContext context,
    Widget child,
    VoidCallback? onPressed,
    Color? backgroundColor,
    Color? textColor,
    bool hasShadow,
    double borderRadius,
    EdgeInsetsGeometry? padding,
    bool isFullWidth,
    double? minWidth,
    double height,
    double? elevation,
    bool enabled,
    bool isLoading,
    Duration animationDuration,
    bool scaleOnTap,
    bool hoverEffect,
  ) {
    final colorScheme = context.colorScheme;

    return ElevatedButton(
      onPressed: (enabled && !isLoading) ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? colorScheme.secondary,
        foregroundColor: textColor ?? colorScheme.onSecondary,
        disabledBackgroundColor: colorScheme.surfaceContainerHighest,
        disabledForegroundColor: colorScheme.onSurfaceVariant,
        elevation: hasShadow ? (elevation ?? 2) : 0,
        shadowColor: hasShadow ? colorScheme.shadow.withValues(alpha: 0.15) : null,
        overlayColor: colorScheme.onSecondary.withValues(alpha: 0.1),
        animationDuration: animationDuration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: padding ?? EdgeInsets.symmetric(horizontal: context.lg, vertical: context.md),
        minimumSize: Size(
          isFullWidth ? double.infinity : (minWidth ?? 0),
          height,
        ),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: child,
    );
  }

  // Using OutlinedButton for outline buttons
  static Widget _buildOutlineButton(
    BuildContext context,
    Widget child,
    VoidCallback? onPressed,
    Color? backgroundColor,
    Color? textColor,
    double borderRadius,
    EdgeInsetsGeometry? padding,
    bool isFullWidth,
    double? minWidth,
    double height,
    Color? borderColor,
    bool enabled,
    bool isLoading,
    Duration animationDuration,
    bool scaleOnTap,
    bool hoverEffect,
  ) {
    final colorScheme = context.colorScheme;

    return OutlinedButton(
      onPressed: (enabled && !isLoading) ? onPressed : null,
      style: OutlinedButton.styleFrom(
        backgroundColor: backgroundColor ?? colorScheme.surfaceContainer,
        foregroundColor: textColor ?? colorScheme.onSurface,
        disabledForegroundColor: colorScheme.onSurfaceVariant,
        overlayColor: colorScheme.primary.withValues(alpha: 0.08),
        animationDuration: animationDuration,
        side: BorderSide(
          color: borderColor ?? colorScheme.outlineVariant,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: padding ?? EdgeInsets.symmetric(horizontal: context.lg, vertical: context.md),
        minimumSize: Size(
          isFullWidth ? double.infinity : (minWidth ?? 0),
          height,
        ),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: child,
    );
  }

  // Using TextButton for text buttons
  static Widget _buildTextButton(
    BuildContext context,
    Widget child,
    VoidCallback? onPressed,
    Color? backgroundColor,
    Color? textColor,
    double borderRadius,
    EdgeInsetsGeometry? padding,
    bool isFullWidth,
    double? minWidth,
    double height,
    bool enabled,
    bool isLoading,
    Duration animationDuration,
    bool scaleOnTap,
    bool hoverEffect,
  ) {
    final colorScheme = context.colorScheme;

    return TextButton(
      onPressed: (enabled && !isLoading) ? onPressed : null,
      style: TextButton.styleFrom(
        backgroundColor: backgroundColor ?? Colors.transparent,
        foregroundColor: textColor ?? colorScheme.primary,
        disabledForegroundColor: colorScheme.onSurfaceVariant,
        overlayColor: colorScheme.primary.withValues(alpha: 0.08),
        animationDuration: animationDuration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: padding ?? EdgeInsets.symmetric(horizontal: context.md, vertical: context.sm),
        minimumSize: Size(
          isFullWidth ? double.infinity : (minWidth ?? 0),
          height,
        ),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: child,
    );
  }

  // Using ElevatedButton.icon for icon buttons
  static Widget _buildIconButton(
    BuildContext context,
    String text,
    Widget leadingIcon,
    VoidCallback? onPressed,
    Color? backgroundColor,
    Color? textColor,
    bool hasShadow,
    double borderRadius,
    EdgeInsetsGeometry? padding,
    bool isFullWidth,
    double? minWidth,
    double height,
    double? elevation,
    TextStyle? textStyle,
    bool enabled,
    bool isLoading,
    Duration animationDuration,
    bool scaleOnTap,
    bool hoverEffect,
  ) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return ElevatedButton.icon(
      onPressed: (enabled && !isLoading) ? onPressed : null,
      icon: isLoading
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator.adaptive(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  colorScheme.onPrimary,
                ),
              ),
            )
          : leadingIcon,
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? colorScheme.primary,
        foregroundColor: textColor ?? colorScheme.onPrimary,
        disabledBackgroundColor: colorScheme.surfaceContainerHighest,
        disabledForegroundColor: colorScheme.onSurfaceVariant,
        elevation: hasShadow ? (elevation ?? 2) : 0,
        shadowColor: hasShadow ? colorScheme.shadow.withValues(alpha: 0.15) : null,
        overlayColor: colorScheme.onPrimary.withValues(alpha: 0.1),
        animationDuration: animationDuration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: padding ?? EdgeInsets.symmetric(horizontal: context.lg, vertical: context.md),
        minimumSize: Size(
          isFullWidth ? double.infinity : (minWidth ?? 0),
          height,
        ),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: textStyle ??
            textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
      ),
    );
  }

  // Using OutlinedButton.icon for icon outline buttons
  static Widget _buildIconOutlineButton(
    BuildContext context,
    String text,
    Widget leadingIcon,
    VoidCallback? onPressed,
    Color? backgroundColor,
    Color? textColor,
    double borderRadius,
    EdgeInsetsGeometry? padding,
    bool isFullWidth,
    double? minWidth,
    double height,
    Color? borderColor,
    TextStyle? textStyle,
    bool enabled,
    bool isLoading,
    Duration animationDuration,
    bool scaleOnTap,
    bool hoverEffect,
  ) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return OutlinedButton.icon(
      onPressed: (enabled && !isLoading) ? onPressed : null,
      icon: isLoading
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator.adaptive(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  colorScheme.primary,
                ),
              ),
            )
          : leadingIcon,
      label: Text(text),
      style: OutlinedButton.styleFrom(
        backgroundColor: backgroundColor ?? colorScheme.surfaceContainer,
        foregroundColor: textColor ?? colorScheme.onSurface,
        disabledForegroundColor: colorScheme.onSurfaceVariant,
        overlayColor: colorScheme.primary.withValues(alpha: 0.08),
        animationDuration: animationDuration,
        side: BorderSide(
          color: borderColor ?? colorScheme.outlineVariant,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: padding ?? EdgeInsets.symmetric(horizontal: context.lg, vertical: context.md),
        minimumSize: Size(
          isFullWidth ? double.infinity : (minWidth ?? 0),
          height,
        ),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: textStyle ??
            textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}

class _AppButtonState extends State<AppButton>
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
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ),);

    _elevationAnimation = Tween<double>(
      begin: 1,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ),);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.enabled && !widget.isLoading && widget.scaleOnTap) {
      setState(() => _isPressed = true);
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.enabled && !widget.isLoading && widget.scaleOnTap) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.enabled && !widget.isLoading && widget.scaleOnTap) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  void _onHover(bool isHovered) {
    if (widget.enabled && !widget.isLoading && widget.hoverEffect) {
      setState(() => _isHovered = isHovered);
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = _buildButtonChild(context);
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, childWidget) => Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: MouseRegion(
              onEnter: (_) => _onHover(true),
              onExit: (_) => _onHover(false),
              child: widget.buttonBuilder(context, childWidget!),
            ),
          ),
        ),
      child: child,
    );
  }

  Widget _buildButtonChild(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    if (widget.isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator.adaptive(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                colorScheme.onPrimary,
              ),
            ),
          ),
          SizedBox(width: context.sm),
          Opacity(
            opacity: 0.7,
            child: Text(
              widget.text,
              style: widget.textStyle ??
                  textTheme.labelLarge?.copyWith(
                    color: widget.textColor ?? colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ), 
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.leadingIcon != null) ...[
          widget.leadingIcon!,
          SizedBox(width: context.xs),
        ],
        Text(
          widget.text,
          style: widget.textStyle ??
              textTheme.labelLarge?.copyWith(
                color: widget.textColor,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
        ),
        if (widget.trailingIcon != null) ...[
          SizedBox(width: context.xs),
          widget.trailingIcon!,
        ],
      ],
    );
  }
}
