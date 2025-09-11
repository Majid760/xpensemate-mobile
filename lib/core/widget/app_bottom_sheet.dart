import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:xpensemate/core/theme/colors/app_colors.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/widget/morphic_button.dart';

/// Enhanced configuration class for bottom sheet behavior and appearance
@immutable
class BottomSheetConfig {
  const BottomSheetConfig({
    this.height,
    this.minHeight,
    this.maxHeight,
    this.borderRadius = 28.0,
    this.padding,
    this.backgroundColor,
    this.barrierColor,
    this.showHandle = true,
    this.showCloseButton = true,
    this.enableDrag = true,
    this.isDismissible = true,
    this.isScrollControlled = true,
    this.expand = false,
    this.useRootNavigator = false,
    this.animationCurve = Curves.easeOutCubic,
    this.duration = const Duration(milliseconds: 300),
    this.dragSensitivity = 200.0,
    this.dismissThreshold = 0.25,
    this.enableBlur = true,
    this.blurSigma = 10.0,
    this.elevation = 0.0,
    this.clipBehavior = Clip.antiAlias,
    this.enableHapticFeedback = true,
    this.maintainState = false,
    this.persistentFooterButtons,
    this.scrollController,
    this.transitionAnimationController,
    this.anchorPoint,
    // Wolt specific properties
    this.heroTag,
    this.modalTypeBuilder,
    this.onModalDismissedWithBarrierTap,
    this.onModalDismissedWithDrag,
    this.shadowColor,
    this.surfaceTintColor,
    this.barrierDismissible,
    this.useSafeArea = true,
    this.pageListBuilder,
  });

  // Dimensions
  final double? height;
  final double? minHeight;
  final double? maxHeight;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  // Colors and styling
  final Color? backgroundColor;
  final Color? barrierColor;
  final double elevation;
  final Clip clipBehavior;
  final Color? shadowColor;
  final Color? surfaceTintColor;

  // UI elements
  final bool showHandle;
  final bool showCloseButton;
  final List<Widget>? persistentFooterButtons;

  // Behavior
  final bool enableDrag;
  final bool isDismissible;
  final bool isScrollControlled;
  final bool expand;
  final bool useRootNavigator;
  final bool maintainState;
  final bool enableHapticFeedback;
  final bool? barrierDismissible;
  final bool useSafeArea;

  // Animation
  final Curve animationCurve;
  final Duration duration;
  final double dragSensitivity;
  final double dismissThreshold;

  // Effects
  final bool enableBlur;
  final double blurSigma;

  // Controllers
  final ScrollController? scrollController;
  final AnimationController? transitionAnimationController;
  final Offset? anchorPoint;

  // Wolt specific properties
  final String? heroTag;
  final WoltModalType Function(BuildContext)? modalTypeBuilder;
  final VoidCallback? onModalDismissedWithBarrierTap;
  final VoidCallback? onModalDismissedWithDrag;
  final List<SliverWoltModalSheetPage> Function(BuildContext)? pageListBuilder;

  BottomSheetConfig copyWith({
    double? height,
    double? minHeight,
    double? maxHeight,
    double? borderRadius,
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
    Color? barrierColor,
    bool? showHandle,
    bool? showCloseButton,
    List<Widget>? persistentFooterButtons,
    bool? enableDrag,
    bool? isDismissible,
    bool? isScrollControlled,
    bool? expand,
    bool? useRootNavigator,
    bool? maintainState,
    bool? enableHapticFeedback,
    Curve? animationCurve,
    Duration? duration,
    double? dragSensitivity,
    double? dismissThreshold,
    bool? enableBlur,
    double? blurSigma,
    double? elevation,
    Clip? clipBehavior,
    ScrollController? scrollController,
    AnimationController? transitionAnimationController,
    Offset? anchorPoint,
    Color? shadowColor,
    Color? surfaceTintColor,
    bool? barrierDismissible,
    bool? useSafeArea,
    String? heroTag,
    WoltModalType Function(BuildContext)? modalTypeBuilder,
    VoidCallback? onModalDismissedWithBarrierTap,
    VoidCallback? onModalDismissedWithDrag,
    List<SliverWoltModalSheetPage> Function(BuildContext)? pageListBuilder,
  }) =>
      BottomSheetConfig(
        height: height ?? this.height,
        minHeight: minHeight ?? this.minHeight,
        maxHeight: maxHeight ?? this.maxHeight,
        borderRadius: borderRadius ?? this.borderRadius,
        padding: padding ?? this.padding,
        backgroundColor: backgroundColor ?? this.backgroundColor,
        barrierColor: barrierColor ?? this.barrierColor,
        showHandle: showHandle ?? this.showHandle,
        showCloseButton: showCloseButton ?? this.showCloseButton,
        persistentFooterButtons:
            persistentFooterButtons ?? this.persistentFooterButtons,
        enableDrag: enableDrag ?? this.enableDrag,
        isDismissible: isDismissible ?? this.isDismissible,
        isScrollControlled: isScrollControlled ?? this.isScrollControlled,
        expand: expand ?? this.expand,
        useRootNavigator: useRootNavigator ?? this.useRootNavigator,
        maintainState: maintainState ?? this.maintainState,
        enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
        animationCurve: animationCurve ?? this.animationCurve,
        duration: duration ?? this.duration,
        dragSensitivity: dragSensitivity ?? this.dragSensitivity,
        dismissThreshold: dismissThreshold ?? this.dismissThreshold,
        enableBlur: enableBlur ?? this.enableBlur,
        blurSigma: blurSigma ?? this.blurSigma,
        elevation: elevation ?? this.elevation,
        clipBehavior: clipBehavior ?? this.clipBehavior,
        scrollController: scrollController ?? this.scrollController,
        transitionAnimationController:
            transitionAnimationController ?? this.transitionAnimationController,
        anchorPoint: anchorPoint ?? this.anchorPoint,
        shadowColor: shadowColor ?? this.shadowColor,
        surfaceTintColor: surfaceTintColor ?? this.surfaceTintColor,
        barrierDismissible: barrierDismissible ?? this.barrierDismissible,
        useSafeArea: useSafeArea ?? this.useSafeArea,
        heroTag: heroTag ?? this.heroTag,
        modalTypeBuilder: modalTypeBuilder ?? this.modalTypeBuilder,
        onModalDismissedWithBarrierTap: onModalDismissedWithBarrierTap ??
            this.onModalDismissedWithBarrierTap,
        onModalDismissedWithDrag:
            onModalDismissedWithDrag ?? this.onModalDismissedWithDrag,
        pageListBuilder: pageListBuilder ?? this.pageListBuilder,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BottomSheetConfig &&
        other.height == height &&
        other.minHeight == minHeight &&
        other.maxHeight == maxHeight &&
        other.borderRadius == borderRadius &&
        other.backgroundColor == backgroundColor &&
        other.showHandle == showHandle &&
        other.showCloseButton == showCloseButton &&
        other.enableDrag == enableDrag &&
        other.isDismissible == isDismissible &&
        other.isScrollControlled == isScrollControlled &&
        other.expand == expand;
  }

  @override
  int get hashCode => Object.hash(
        height,
        minHeight,
        maxHeight,
        borderRadius,
        backgroundColor,
        showHandle,
        showCloseButton,
        enableDrag,
        isDismissible,
        isScrollControlled,
        expand,
      );
}

/// Enum for different bottom sheet presentation styles
enum BottomSheetStyle {
  material,
  cupertino,
  floating,
  bar,
  avatar,
  custom,
  // Wolt styles
  woltSideSheet,
  woltBottomSheet,
  woltDialog,
  woltAlertDialog,
  woltMultiPage,
  woltDynamic,
}

/// Result class for bottom sheet operations
@immutable
class BottomSheetResult<T> {
  const BottomSheetResult._({
    required this.isSuccess,
    this.data,
    this.error,
  });

  const BottomSheetResult.success(T data) : this._(isSuccess: true, data: data);
  const BottomSheetResult.dismissed() : this._(isSuccess: false);
  const BottomSheetResult.error(Object error)
      : this._(isSuccess: false, error: error);

  final bool isSuccess;
  final T? data;
  final Object? error;

  bool get isDismissed => !isSuccess && error == null;
  bool get hasError => error != null;
}

/// Main service class for handling bottom sheets
class AppBottomSheetService {
  AppBottomSheetService._();

  static final AppBottomSheetService _instance = AppBottomSheetService._();
  static AppBottomSheetService get instance => _instance;

  /// Currently active bottom sheets count
  int _activeSheets = 0;
  int get activeSheets => _activeSheets;

  /// Show a bottom sheet with the specified configuration
  Future<BottomSheetResult<T>> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    BottomSheetStyle style = BottomSheetStyle.material,
    BottomSheetConfig? config,
    VoidCallback? onShow,
    VoidCallback? onDismiss,
  }) async {
    try {
      _activeSheets++;
      onShow?.call();

      final effectiveConfig = config ?? const BottomSheetConfig();
      final result = await _showWithStyle<T>(
        context: context,
        child: child,
        title: title,
        style: style,
        config: effectiveConfig,
      );

      return result != null
          ? BottomSheetResult<T>.success(result)
          : const BottomSheetResult.dismissed();
    } on Exception catch (e) {
      return BottomSheetResult<T>.error(e);
    } finally {
      _activeSheets--;
      onDismiss?.call();
    }
  }

  /// Show Wolt side sheet (for wide screens)
  Future<BottomSheetResult<T>> showWoltSideSheet<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    BottomSheetConfig? config,
  }) =>
      show<T>(
        context: context,
        child: child,
        title: title,
        style: BottomSheetStyle.woltSideSheet,
        config: config?.copyWith(
              modalTypeBuilder: (context) => WoltModalType.sideSheet(),
            ) ??
            BottomSheetConfig(
              modalTypeBuilder: (context) => WoltModalType.sideSheet(),
            ),
      );

  /// Show Wolt dialog style
  Future<BottomSheetResult<T>> showWoltDialog<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    BottomSheetConfig? config,
  }) =>
      show<T>(
        context: context,
        child: child,
        title: title,
        style: BottomSheetStyle.woltDialog,
        config: config?.copyWith(
              modalTypeBuilder: (context) => WoltModalType.dialog(),
              borderRadius: 16,
              showHandle: false,
            ) ??
            BottomSheetConfig(
              modalTypeBuilder: (context) => WoltModalType.dialog(),
              borderRadius: 16,
              showHandle: false,
            ),
      );

  /// Show Wolt alert dialog
  Future<BottomSheetResult<T>> showWoltAlertDialog<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    BottomSheetConfig? config,
  }) =>
      show<T>(
        context: context,
        child: child,
        title: title,
        style: BottomSheetStyle.woltAlertDialog,
        config: config?.copyWith(
              modalTypeBuilder: (context) => WoltModalType.alertDialog(),
              borderRadius: 12,
              showHandle: false,
              showCloseButton: false,
            ) ??
            BottomSheetConfig(
              modalTypeBuilder: (context) => WoltModalType.alertDialog(),
              borderRadius: 12,
              showHandle: false,
              showCloseButton: false,
            ),
      );

  /// Show Wolt multi-page modal
  Future<BottomSheetResult<T>> showWoltMultiPage<T>({
    required BuildContext context,
    required List<SliverWoltModalSheetPage> pages,
    String? title,
    BottomSheetConfig? config,
  }) =>
      show<T>(
        context: context,
        child: const SizedBox(), // Not used for multi-page
        title: title,
        style: BottomSheetStyle.woltMultiPage,
        config: config?.copyWith(
              pageListBuilder: (_) => pages,
            ) ??
            BottomSheetConfig(
              pageListBuilder: (_) => pages,
            ),
      );

  /// Show expandable bottom sheet
  Future<BottomSheetResult<T>> showExpandable<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    BottomSheetStyle style = BottomSheetStyle.material,
    BottomSheetConfig? config,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    final expandableConfig = (config ?? const BottomSheetConfig()).copyWith(
      minHeight: config?.minHeight ?? screenHeight * 0.4,
      maxHeight: config?.maxHeight ?? screenHeight * 0.95,
      expand: false,
      isScrollControlled: true,
    );

    return show<T>(
      context: context,
      child: child,
      title: title,
      style: style,
      config: expandableConfig,
    );
  }

  /// Show scrollable bottom sheet
  Future<BottomSheetResult<T>> showScrollable<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    BottomSheetStyle style = BottomSheetStyle.material,
    BottomSheetConfig? config,
    ScrollController? scrollController,
  }) =>
      show<T>(
        context: context,
        child: child,
        title: title,
        style: style,
        config: config?.copyWith(
              isScrollControlled: true,
              scrollController: scrollController,
            ) ??
            BottomSheetConfig(
              scrollController: scrollController,
            ),
      );

  /// Show full screen bottom sheet
  Future<BottomSheetResult<T>> showFullScreen<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    BottomSheetStyle style = BottomSheetStyle.material,
    BottomSheetConfig? config,
  }) =>
      show<T>(
        context: context,
        child: child,
        title: title,
        style: style,
        config: config?.copyWith(expand: true) ??
            const BottomSheetConfig(expand: true),
      );

  Future<T?> _showWithStyle<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    required BottomSheetStyle style,
    required BottomSheetConfig config,
  }) {
    switch (style) {
      case BottomSheetStyle.woltSideSheet:
      case BottomSheetStyle.woltBottomSheet:
      case BottomSheetStyle.woltDialog:
      case BottomSheetStyle.woltAlertDialog:
      case BottomSheetStyle.woltDynamic:
        return _showWoltModal<T>(
          context: context,
          child: child,
          title: title,
          config: config,
          style: style,
        );

      case BottomSheetStyle.woltMultiPage:
        return _showWoltMultiPageModal<T>(
          context: context,
          config: config,
        );

      case BottomSheetStyle.material:
        return showMaterialModalBottomSheet<T>(
          context: context,
          builder: (_) => AppBottomSheetContent(
            title: title,
            config: config,
            child: child,
          ),
          backgroundColor: Colors.transparent,
          barrierColor: config.barrierColor,
          expand: config.expand,
          isDismissible: config.isDismissible,
          enableDrag: config.enableDrag,
          useRootNavigator: config.useRootNavigator,
          clipBehavior: config.clipBehavior,
          elevation: config.elevation,
          animationCurve: config.animationCurve,
          duration: config.duration,
          settings: RouteSettings(name: '/bottom_sheet_${style.name}'),
        );

      case BottomSheetStyle.cupertino:
        return showCupertinoModalBottomSheet<T>(
          context: context,
          builder: (_) => AppBottomSheetContent(
            title: title,
            config: config,
            child: child,
          ),
          backgroundColor: Colors.transparent,
          barrierColor: config.barrierColor,
          expand: config.expand,
          isDismissible: config.isDismissible,
          enableDrag: config.enableDrag,
          topRadius: Radius.circular(config.borderRadius),
          useRootNavigator: config.useRootNavigator,
          animationCurve: config.animationCurve,
          duration: config.duration,
          settings: RouteSettings(name: '/bottom_sheet_${style.name}'),
        );

      case BottomSheetStyle.bar:
        return showBarModalBottomSheet<T>(
          context: context,
          builder: (_) => AppBottomSheetContent(
            title: title,
            config: config,
            child: child,
          ),
          backgroundColor: Colors.transparent,
          expand: config.expand,
          isDismissible: config.isDismissible,
          enableDrag: config.enableDrag,
          useRootNavigator: config.useRootNavigator,
          animationCurve: config.animationCurve,
          duration: config.duration,
          settings: RouteSettings(name: '/bottom_sheet_${style.name}'),
        );

      case BottomSheetStyle.floating:
      case BottomSheetStyle.avatar:
      case BottomSheetStyle.custom:
      default:
        return showModalBottomSheet<T>(
          context: context,
          builder: (_) => AppBottomSheetContent(
            title: title,
            config: config,
            child: child,
          ),
          backgroundColor: Colors.transparent,
          barrierColor: config.barrierColor,
          isScrollControlled: config.isScrollControlled,
          isDismissible: config.isDismissible,
          enableDrag: config.enableDrag,
          useRootNavigator: config.useRootNavigator,
          elevation: config.elevation,
          clipBehavior: config.clipBehavior,
          anchorPoint: config.anchorPoint,
          useSafeArea: config.useSafeArea,
        );
    }
  }

  Future<T?> _showWoltModal<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    required BottomSheetConfig config,
    required BottomSheetStyle style,
  }) =>
      WoltModalSheet.show<T>(
        context: context,
        pageListBuilder: config.pageListBuilder ??
            (context) => [
                  WoltModalSheetPage(
                    child: AppBottomSheetContent(
                      title: title,
                      config: config,
                      child: child,
                    ),
                    backgroundColor: config.backgroundColor,
                    surfaceTintColor: config.surfaceTintColor,
                    navBarHeight: 36,
                    isTopBarLayerAlwaysVisible: title != null,
                    topBar: title != null
                        ? _buildWoltTopBar(context, title, config)
                        : null,
                    stickyActionBar: config.persistentFooterButtons != null
                        ? _buildWoltActionBar(context, config)
                        : null,
                  ),
                ],
        modalTypeBuilder: config.modalTypeBuilder ??
            (context) {
              switch (style) {
                case BottomSheetStyle.woltSideSheet:
                  return WoltModalType.sideSheet();
                case BottomSheetStyle.woltDialog:
                  return WoltModalType.dialog();
                case BottomSheetStyle.woltAlertDialog:
                  return WoltModalType.alertDialog();
                case BottomSheetStyle.woltDynamic:
                default:
                  return WoltModalType.bottomSheet();
              }
            },
        onModalDismissedWithBarrierTap: config.onModalDismissedWithBarrierTap,
        onModalDismissedWithDrag: config.onModalDismissedWithDrag,
        barrierDismissible: config.barrierDismissible ?? config.isDismissible,
        useSafeArea: config.useSafeArea,
      );

  Future<T?> _showWoltMultiPageModal<T>({
    required BuildContext context,
    required BottomSheetConfig config,
  }) {
    if (config.pageListBuilder == null) {
      throw ArgumentError('pageListBuilder is required for multi-page modals');
    }

    return WoltModalSheet.show<T>(
      context: context,
      pageListBuilder: config.pageListBuilder!,
      modalTypeBuilder:
          config.modalTypeBuilder ?? (context) => WoltModalType.bottomSheet(),
      onModalDismissedWithBarrierTap: config.onModalDismissedWithBarrierTap,
      onModalDismissedWithDrag: config.onModalDismissedWithDrag,
      barrierDismissible: config.barrierDismissible ?? config.isDismissible,
      useSafeArea: config.useSafeArea,
    );
  }

  Widget _buildWoltTopBar(
          BuildContext context, String title, BottomSheetConfig config) =>
      Container(
        padding: EdgeInsets.symmetric(horizontal: context.lg),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (config.showCloseButton)
              GlassmorphicButton(
                icon: Icons.close_rounded,
                onTap: () => Navigator.of(context).pop(),
                isGradientBg: true,
              ),
          ],
        ),
      );

  Widget _buildWoltActionBar(BuildContext context, BottomSheetConfig config) =>
      Container(
        padding: EdgeInsets.all(context.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: config.persistentFooterButtons ?? [],
        ),
      );

  Gradient? _buildGradient(BuildContext context, BottomSheetStyle style) {
    switch (style) {
      case BottomSheetStyle.woltSideSheet:
        return LinearGradient(
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
          ],
        );
      default:
        return null;
    }
  }
}

/// Internal content widget for the bottom sheet
class AppBottomSheetContent extends StatefulWidget {
  const AppBottomSheetContent({
    super.key,
    required this.child,
    required this.config,
    this.title,
  });

  final Widget child;
  final String? title;
  final BottomSheetConfig config;

  @override
  State<AppBottomSheetContent> createState() => _AppBottomSheetContentState();
}

class _AppBottomSheetContentState extends State<AppBottomSheetContent>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  double? _currentHeight;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeHeight();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: widget.config.duration,
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: widget.config.animationCurve,
    );

    // Start animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  void _initializeHeight() {
    if (widget.config.minHeight != null) {
      _currentHeight = widget.config.minHeight;
    } else if (widget.config.height != null) {
      _currentHeight = widget.config.height;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleClose() async {
    if (widget.config.enableHapticFeedback) {
      await HapticFeedback.lightImpact();
    }

    if (mounted) {
      await _animationController.reverse();
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _handleExpansion() {
    if (!_canExpand) return;

    if (widget.config.enableHapticFeedback) {
      HapticFeedback.selectionClick();
    }

    setState(() {
      _isExpanded = !_isExpanded;
      _currentHeight =
          _isExpanded ? widget.config.maxHeight : widget.config.minHeight;
    });
  }

  bool get _canExpand =>
      widget.config.minHeight != null &&
      widget.config.maxHeight != null &&
      widget.config.enableDrag;

  double _calculateHeight(BuildContext context) {
    if (_currentHeight != null) return _currentHeight!;

    final screenHeight = MediaQuery.of(context).size.height;

    if (widget.config.expand) {
      return screenHeight;
    }

    if (widget.config.height != null) {
      return widget.config.height!;
    }

    return screenHeight * 0.7;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = _calculateHeight(context);
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => _buildBottomSheetStructure(
        context: context,
        theme: theme,
        height: effectiveHeight,
      ),
    );
  }

  Widget _buildBottomSheetStructure({
    required BuildContext context,
    required ThemeData theme,
    required double height,
  }) =>
      Stack(
        children: [
          // Background with blur effect
          if (widget.config.enableBlur)
            _buildBlurredBackground()
          else
            _buildSimpleBackground(),

          // Main bottom sheet container
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedContainer(
              duration: widget.config.duration,
              curve: widget.config.animationCurve,
              height: height,
              decoration: _buildSheetDecoration(theme),
              child: _buildSheetContent(),
            ),
          ),
        ],
      );

  Widget _buildBlurredBackground() => GestureDetector(
        onTap: widget.config.isDismissible ? _handleClose : null,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: widget.config.barrierColor ??
                Colors.black.withValues(alpha: 0.4 * _animation.value),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: widget.config.blurSigma * _animation.value,
              sigmaY: widget.config.blurSigma * _animation.value,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      );

  Widget _buildSimpleBackground() => GestureDetector(
        onTap: widget.config.isDismissible ? _handleClose : null,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: widget.config.barrierColor ??
              Colors.black.withValues(alpha: 0.4 * _animation.value),
        ),
      );

  BoxDecoration _buildSheetDecoration(ThemeData theme) => BoxDecoration(
        color: widget.config.backgroundColor ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(widget.config.borderRadius),
          topRight: Radius.circular(widget.config.borderRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
          if (widget.config.elevation > 0)
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: widget.config.elevation,
              offset: Offset(0, -widget.config.elevation / 2),
            ),
        ],
      );

  Widget _buildSheetContent() => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(),

            // Main content
            Expanded(
              child: widget.config.scrollController != null
                  ? SingleChildScrollView(
                      controller: widget.config.scrollController,
                      child: _buildContentWithPadding(),
                    )
                  : _buildContentWithPadding(),
            ),

            // Footer buttons
            if (widget.config.persistentFooterButtons != null) _buildFooter(),
          ],
        ),
      );

  Widget _buildHeader() {
    if (!widget.config.showHandle &&
        widget.title == null &&
        !widget.config.showCloseButton) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.fromLTRB(
        context.lg,
        context.md,
        context.lg,
        widget.title != null ? context.sm : context.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          if (widget.config.showHandle)
            GestureDetector(
              onTap: _canExpand ? _handleExpansion : null,
              child: Container(
                width: 36,
                height: 4,
                margin: EdgeInsets.only(
                  bottom: widget.title != null || widget.config.showCloseButton
                      ? context.sm
                      : 0,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: _canExpand ? 0.6 : 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

          // Title and close button row
          if (widget.title != null || widget.config.showCloseButton)
            Row(
              children: [
                // Title
                if (widget.title != null)
                  Expanded(
                    child: Text(
                      widget.title!,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                              ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),

                // Spacer
                if (widget.title != null && widget.config.showCloseButton)
                  SizedBox(width: context.sm),

                // Close button
                if (widget.config.showCloseButton)
                  GlassmorphicButton(
                    icon: Icons.close_rounded,
                    onTap: _handleClose,
                    isGradientBg: true,
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildContentWithPadding() => Padding(
        padding: widget.config.padding ??
            EdgeInsets.fromLTRB(context.lg, 0, context.lg, context.lg),
        child: widget.child,
      );

  Widget _buildFooter() {
    if (widget.config.persistentFooterButtons?.isEmpty ?? true) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(context.md),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: widget.config.persistentFooterButtons!,
      ),
    );
  }
}

/// Custom Wolt Modal Sheet Pages for different use cases
class WoltModalPages {
  /// Create a simple content page
  static SliverWoltModalSheetPage simplePage({
    required Widget child,
    String? title,
    List<Widget>? actionButtons,
    Color? backgroundColor,
    bool showTopBar = true,
    VoidCallback? onClose,
  }) =>
      WoltModalSheetPage(
        child: child,
        backgroundColor: backgroundColor,
        // topBarHeight: showTopBar ? 56.0 : 0,
        isTopBarLayerAlwaysVisible: showTopBar,
        topBar: showTopBar
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    if (title != null)
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    IconButton(
                      onPressed: onClose,
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              )
            : null,
        stickyActionBar: actionButtons != null
            ? Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: actionButtons,
                ),
              )
            : null,
      );

  /// Create a form page with validation
  static SliverWoltModalSheetPage formPage({
    required Widget form,
    String? title,
    required VoidCallback onSubmit,
    required VoidCallback onCancel,
    String submitLabel = 'Submit',
    String cancelLabel = 'Cancel',
    bool isSubmitEnabled = true,
  }) =>
      WoltModalSheetPage(
        child: form,
        isTopBarLayerAlwaysVisible: true,
        topBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              if (title != null)
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        stickyActionBar: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancel,
                  child: Text(cancelLabel),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: isSubmitEnabled ? onSubmit : null,
                  child: Text(submitLabel),
                ),
              ),
            ],
          ),
        ),
      );

  /// Create a list page with search functionality
  static SliverWoltModalSheetPage listPage({
    required List<Widget> items,
    String? title,
    Widget? searchField,
    bool showSearch = false,
  }) =>
      WoltModalSheetPage(
        child: Column(
          children: [
            if (showSearch && searchField != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                child: searchField,
              ),
              const Divider(height: 1),
            ],
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) => items[index],
              ),
            ),
          ],
        ),
        // topBarHeight: title != null ? 56.0 : 0,
        isTopBarLayerAlwaysVisible: title != null,
        topBar: title != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              )
            : null,
      );

  /// Create a confirmation dialog page
  static SliverWoltModalSheetPage confirmationPage({
    required String title,
    required String message,
    required VoidCallback onConfirm,
    required VoidCallback onCancel,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    IconData? icon,
    Color? iconColor,
  }) =>
      WoltModalSheetPage(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 48,
                  color: iconColor,
                ),
                const SizedBox(height: 16),
              ],
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancel,
                      child: Text(cancelLabel),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onConfirm,
                      child: Text(confirmLabel),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}

/// Extension for preset configurations with Wolt styles
extension BottomSheetPresets on BottomSheetConfig {
  /// Small bottom sheet (300px height)
  static const BottomSheetConfig small = BottomSheetConfig(
    height: 300,
    borderRadius: 20,
    enableBlur: false,
  );

  /// Medium bottom sheet (50% screen height)
  static BottomSheetConfig medium(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return BottomSheetConfig(
      height: screenHeight * 0.5,
      borderRadius: 24,
    );
  }

  /// Large bottom sheet (80% screen height)
  static BottomSheetConfig large(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return BottomSheetConfig(
      height: screenHeight * 0.8,
    );
  }

  /// Expandable configuration
  static BottomSheetConfig expandable(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return BottomSheetConfig(
      minHeight: screenHeight * 0.3,
      maxHeight: screenHeight * 0.95,
    );
  }

  /// Wolt side sheet configuration
  static BottomSheetConfig get woltSideSheet => BottomSheetConfig(
        borderRadius: 16,
        showHandle: false,
        modalTypeBuilder: (context) => WoltModalType.sideSheet(),
      );

  /// Wolt dialog configuration
  static BottomSheetConfig get woltDialog => BottomSheetConfig(
        borderRadius: 16,
        showHandle: false,
        showCloseButton: true,
        modalTypeBuilder: (context) => WoltModalType.dialog(),
        height: 400,
      );

  /// Wolt alert dialog configuration
  static BottomSheetConfig get woltAlertDialog => BottomSheetConfig(
        borderRadius: 12,
        showHandle: false,
        showCloseButton: false,
        modalTypeBuilder: (context) => WoltModalType.alertDialog(),
        height: 200,
      );

  /// No interaction configuration
  BottomSheetConfig get noInteraction => copyWith(
        enableDrag: false,
        showCloseButton: false,
        showHandle: false,
        isDismissible: false,
      );

  /// Quick access modifiers
  BottomSheetConfig get noDrag => copyWith(enableDrag: false);
  BottomSheetConfig get noClose => copyWith(showCloseButton: false);
  BottomSheetConfig get noHandle => copyWith(showHandle: false);
  BottomSheetConfig get noDismiss => copyWith(isDismissible: false);
  BottomSheetConfig get noBlur => copyWith(enableBlur: false);
  BottomSheetConfig get fullScreen => copyWith(expand: true);

  /// Height modifiers
  BottomSheetConfig withHeight(double height) => copyWith(height: height);
  BottomSheetConfig withMinHeight(double minHeight) =>
      copyWith(minHeight: minHeight);
  BottomSheetConfig withMaxHeight(double maxHeight) =>
      copyWith(maxHeight: maxHeight);
}

/// Convenience class for easy access
class AppBottomSheet {
  static AppBottomSheetService get _service => AppBottomSheetService.instance;

  // Traditional bottom sheet methods
  static Future<BottomSheetResult<T>> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    BottomSheetStyle style = BottomSheetStyle.material,
    BottomSheetConfig? config,
    VoidCallback? onShow,
    VoidCallback? onDismiss,
  }) =>
      _service.show<T>(
        context: context,
        child: child,
        title: title,
        style: style,
        config: config,
        onShow: onShow,
        onDismiss: onDismiss,
      );

  static Future<BottomSheetResult<T>> showExpandable<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    BottomSheetStyle style = BottomSheetStyle.material,
    BottomSheetConfig? config,
  }) =>
      _service.showExpandable<T>(
        context: context,
        child: child,
        title: title,
        style: style,
        config: config,
      );

  static Future<BottomSheetResult<T>> showScrollable<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    BottomSheetStyle style = BottomSheetStyle.material,
    BottomSheetConfig? config,
    ScrollController? scrollController,
  }) =>
      _service.showScrollable<T>(
        context: context,
        child: child,
        title: title,
        style: style,
        config: config,
        scrollController: scrollController,
      );

  static Future<BottomSheetResult<T>> showFullScreen<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    BottomSheetStyle style = BottomSheetStyle.material,
    BottomSheetConfig? config,
  }) =>
      _service.showFullScreen<T>(
        context: context,
        child: child,
        title: title,
        style: style,
        config: config,
      );

  // Wolt specific methods
  static Future<BottomSheetResult<T>> showWoltSideSheet<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    BottomSheetConfig? config,
  }) =>
      _service.showWoltSideSheet<T>(
        context: context,
        child: child,
        title: title,
        config: config,
      );

  static Future<BottomSheetResult<T>> showWoltDialog<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    BottomSheetConfig? config,
  }) =>
      _service.showWoltDialog<T>(
        context: context,
        child: child,
        title: title,
        config: config,
      );

  static Future<BottomSheetResult<T>> showWoltAlertDialog<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    BottomSheetConfig? config,
  }) =>
      _service.showWoltAlertDialog<T>(
        context: context,
        child: child,
        title: title,
        config: config,
      );

  static Future<BottomSheetResult<T>> showWoltMultiPage<T>({
    required BuildContext context,
    required List<SliverWoltModalSheetPage> pages,
    String? title,
    BottomSheetConfig? config,
  }) =>
      _service.showWoltMultiPage<T>(
        context: context,
        pages: pages,
        title: title,
        config: config,
      );

  // Quick confirmation dialog
  static Future<BottomSheetResult<bool>> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    IconData? icon,
    Color? iconColor,
  }) =>
      showWoltMultiPage<bool>(
        context: context,
        pages: [
          WoltModalPages.confirmationPage(
            title: title,
            message: message,
            onConfirm: () => Navigator.of(context).pop(true),
            onCancel: () => Navigator.of(context).pop(false),
            confirmLabel: confirmLabel,
            cancelLabel: cancelLabel,
            icon: icon,
            iconColor: iconColor,
          ),
        ],
      );

  // Quick form dialog
  static Future<BottomSheetResult<T>> showForm<T>({
    required BuildContext context,
    required Widget form,
    String? title,
    required VoidCallback onSubmit,
    String submitLabel = 'Submit',
    String cancelLabel = 'Cancel',
    bool isSubmitEnabled = true,
  }) =>
      showWoltMultiPage<T>(
        context: context,
        pages: [
          WoltModalPages.formPage(
            form: form,
            title: title,
            onSubmit: onSubmit,
            onCancel: () => Navigator.of(context).pop(),
            submitLabel: submitLabel,
            cancelLabel: cancelLabel,
            isSubmitEnabled: isSubmitEnabled,
          ),
        ],
      );

  // Quick list dialog
  static Future<BottomSheetResult<T>> showList<T>({
    required BuildContext context,
    required List<Widget> items,
    String? title,
    Widget? searchField,
    bool showSearch = false,
  }) =>
      showWoltMultiPage<T>(
        context: context,
        pages: [
          WoltModalPages.listPage(
            items: items,
            title: title,
            searchField: searchField,
            showSearch: showSearch,
          ),
        ],
      );

  /// Get current active bottom sheets count
  static int get activeSheets => _service.activeSheets;
}
