// lib/widgets/common/universal_image.dart
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:xpensemate/core/theme/app_spacing.dart';

enum ImageType {
  network,
  asset,
  file,
  svg,
}

enum ImageShape {
  rectangle,
  circle,
  roundedRectangle,
}

class AppImage extends StatelessWidget {
  // Auto-detect factory constructor (original behavior)
  factory AppImage(
    String imagePath, {
    Key? key,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    ImageShape shape = ImageShape.rectangle,
    double borderRadius = AppSpacing.baseUnit,
    Color? color,
    String? placeholder,
    String? errorImage,
    Widget? customPlaceholder,
    Widget? customErrorWidget,
    Color? backgroundColor,
    Duration fadeDuration = const Duration(milliseconds: 300),
    bool enableMemoryCache = true,
    VoidCallback? onTap,
    String? heroTag,
    Border? border,
    List<BoxShadow>? shadows,
  }) {
    final imageType = _determineImageTypeStatic(imagePath);

    return AppImage._(
      key: key,
      imagePath: imagePath,
      imageType: imageType,
      width: width,
      height: height,
      fit: fit,
      shape: shape,
      borderRadius: borderRadius,
      color: color,
      placeholder: placeholder,
      errorImage: errorImage,
      customPlaceholder: customPlaceholder,
      customErrorWidget: customErrorWidget,
      backgroundColor: backgroundColor,
      fadeDuration: fadeDuration,
      enableMemoryCache: enableMemoryCache,
      onTap: onTap,
      heroTag: heroTag,
      border: border,
      shadows: shadows,
    );
  }
  const AppImage._({
    super.key,
    required this.imagePath,
    required this.imageType,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.shape = ImageShape.rectangle,
    this.borderRadius = AppSpacing.baseUnit,
    this.color,
    this.placeholder,
    this.errorImage,
    this.customPlaceholder,
    this.customErrorWidget,
    this.backgroundColor,
    this.fadeDuration = const Duration(milliseconds: 300),
    this.enableMemoryCache = true,
    this.onTap,
    this.heroTag,
    this.border,
    this.shadows,
  });

  // Factory constructor for network images
  factory AppImage.network(
    String url, {
    Key? key,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    ImageShape shape = ImageShape.rectangle,
    double borderRadius = AppSpacing.baseUnit,
    Color? color,
    String? placeholder,
    String? errorImage,
    Widget? customPlaceholder,
    Widget? customErrorWidget,
    Color? backgroundColor,
    Duration fadeDuration = const Duration(milliseconds: 300),
    bool enableMemoryCache = true,
    VoidCallback? onTap,
    String? heroTag,
    Border? border,
    List<BoxShadow>? shadows,
  }) =>
      AppImage._(
        key: key,
        imagePath: url,
        imageType: ImageType.network,
        width: width,
        height: height,
        fit: fit,
        shape: shape,
        borderRadius: borderRadius,
        color: color,
        placeholder: placeholder,
        errorImage: errorImage,
        customPlaceholder: customPlaceholder,
        customErrorWidget: customErrorWidget,
        backgroundColor: backgroundColor,
        fadeDuration: fadeDuration,
        enableMemoryCache: enableMemoryCache,
        onTap: onTap,
        heroTag: heroTag,
        border: border,
        shadows: shadows,
      );

  // Factory constructor for asset images
  factory AppImage.asset(
    String assetPath, {
    Key? key,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    ImageShape shape = ImageShape.rectangle,
    double borderRadius = AppSpacing.baseUnit,
    Color? color,
    String? placeholder,
    String? errorImage,
    Widget? customPlaceholder,
    Widget? customErrorWidget,
    Color? backgroundColor,
    Duration fadeDuration = const Duration(milliseconds: 300),
    bool enableMemoryCache = true,
    VoidCallback? onTap,
    String? heroTag,
    Border? border,
    List<BoxShadow>? shadows,
  }) =>
      AppImage._(
        key: key,
        imagePath: assetPath,
        imageType: ImageType.asset,
        width: width,
        height: height,
        fit: fit,
        shape: shape,
        borderRadius: borderRadius,
        color: color,
        placeholder: placeholder,
        errorImage: errorImage,
        customPlaceholder: customPlaceholder,
        customErrorWidget: customErrorWidget,
        backgroundColor: backgroundColor,
        fadeDuration: fadeDuration,
        enableMemoryCache: enableMemoryCache,
        onTap: onTap,
        heroTag: heroTag,
        border: border,
        shadows: shadows,
      );

  // Factory constructor for file images
  factory AppImage.file(
    String filePath, {
    Key? key,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    ImageShape shape = ImageShape.rectangle,
    double borderRadius = AppSpacing.baseUnit,
    Color? color,
    String? placeholder,
    String? errorImage,
    Widget? customPlaceholder,
    Widget? customErrorWidget,
    Color? backgroundColor,
    Duration fadeDuration = const Duration(milliseconds: 300),
    bool enableMemoryCache = true,
    VoidCallback? onTap,
    String? heroTag,
    Border? border,
    List<BoxShadow>? shadows,
  }) =>
      AppImage._(
        key: key,
        imagePath: filePath,
        imageType: ImageType.file,
        width: width,
        height: height,
        fit: fit,
        shape: shape,
        borderRadius: borderRadius,
        color: color,
        placeholder: placeholder,
        errorImage: errorImage,
        customPlaceholder: customPlaceholder,
        customErrorWidget: customErrorWidget,
        backgroundColor: backgroundColor,
        fadeDuration: fadeDuration,
        enableMemoryCache: enableMemoryCache,
        onTap: onTap,
        heroTag: heroTag,
        border: border,
        shadows: shadows,
      );

  // Factory constructor for SVG images
  factory AppImage.svg(
    String svgPath, {
    Key? key,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    ImageShape shape = ImageShape.rectangle,
    double borderRadius = AppSpacing.baseUnit,
    Color? color,
    String? placeholder,
    String? errorImage,
    Widget? customPlaceholder,
    Widget? customErrorWidget,
    Color? backgroundColor,
    Duration fadeDuration = const Duration(milliseconds: 300),
    bool enableMemoryCache = true,
    VoidCallback? onTap,
    String? heroTag,
    Border? border,
    List<BoxShadow>? shadows,
  }) =>
      AppImage._(
        key: key,
        imagePath: svgPath,
        imageType: ImageType.svg,
        width: width,
        height: height,
        fit: fit,
        shape: shape,
        borderRadius: borderRadius,
        color: color,
        placeholder: placeholder,
        errorImage: errorImage,
        customPlaceholder: customPlaceholder,
        customErrorWidget: customErrorWidget,
        backgroundColor: backgroundColor,
        fadeDuration: fadeDuration,
        enableMemoryCache: enableMemoryCache,
        onTap: onTap,
        heroTag: heroTag,
        border: border,
        shadows: shadows,
      );

  final String imagePath;
  final ImageType imageType;
  final double? width;
  final double? height;
  final BoxFit fit;
  final ImageShape shape;
  final double borderRadius;
  final Color? color;
  final String? placeholder;
  final String? errorImage;
  final Widget? customPlaceholder;
  final Widget? customErrorWidget;
  final Color? backgroundColor;
  final Duration fadeDuration;
  final bool enableMemoryCache;
  final VoidCallback? onTap;
  final String? heroTag;
  final Border? border;
  final List<BoxShadow>? shadows;

  static ImageType _determineImageTypeStatic(String imagePath) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return ImageType.network;
    } else if (imagePath.startsWith('assets/') || !imagePath.contains('/')) {
      if (imagePath.toLowerCase().endsWith('.svg')) {
        return ImageType.svg;
      }
      return ImageType.asset;
    } else if (imagePath.startsWith('/') || imagePath.contains(r'\')) {
      if (imagePath.toLowerCase().endsWith('.svg')) {
        return ImageType.svg;
      }
      return ImageType.file;
    } else {
      return ImageType.asset;
    }
  }

  @override
  Widget build(BuildContext context) {
    var imageWidget = _buildImageWidget();

    // Apply shape and styling
    imageWidget = _applyShapeAndStyling(imageWidget);

    // Add tap functionality
    if (onTap != null) {
      imageWidget = GestureDetector(
        onTap: onTap,
        child: imageWidget,
      );
    }

    // Add hero animation if specified
    if (heroTag != null) {
      imageWidget = Hero(
        tag: heroTag!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildImageWidget() {
    switch (imageType) {
      case ImageType.network:
        return _buildNetworkImage();
      case ImageType.asset:
        return _buildAssetImage();
      case ImageType.file:
        return _buildFileImage();
      case ImageType.svg:
        return _buildSvgImage();
    }
  }

  Widget _buildNetworkImage() => CachedNetworkImage(
        imageUrl: imagePath,
        width: width,
        height: height,
        fit: fit,
        color: color,
        fadeInDuration: fadeDuration,
        memCacheWidth: enableMemoryCache ? width?.round() : null,
        memCacheHeight: enableMemoryCache ? height?.round() : null,
        maxWidthDiskCache: width?.round(),
        maxHeightDiskCache: height?.round(),
        httpHeaders: {'User-Agent': 'xpensemate App', 'Accept': 'image/*'},
        placeholder: (context, url) => _buildPlaceholderWidget(),
        errorWidget: (context, url, error) {
          print('this is error while showing image ${error.toString()}');
          print('this image url ${url}');
          return _buildErrorWidget();
        },
      );

  Widget _buildAssetImage() {
    if (imagePath.toLowerCase().endsWith('.svg')) {
      return _buildSvgImage();
    }

    return Image.asset(
      imagePath,
      width: width,
      height: height,
      fit: fit,
      color: color,
      errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
    );
  }

  Widget _buildFileImage() {
    if (imagePath.toLowerCase().endsWith('.svg')) {
      return _buildSvgImage();
    }

    return Image.file(
      File(imagePath),
      width: width,
      height: height,
      fit: fit,
      color: color,
      errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
    );
  }

  Widget _buildSvgImage() {
    if (imageType == ImageType.network) {
      return SvgPicture.network(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        colorFilter:
            color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
        placeholderBuilder: (context) => _buildPlaceholderWidget(),
      );
    } else if (imageType == ImageType.asset) {
      return SvgPicture.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        colorFilter:
            color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
      );
    } else {
      return SvgPicture.file(
        File(imagePath),
        width: width,
        height: height,
        fit: fit,
        colorFilter:
            color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
      );
    }
  }

  Widget _buildPlaceholderWidget() {
    if (customPlaceholder != null) {
      return customPlaceholder!;
    }

    if (placeholder != null) {
      return AppImage(
        placeholder!,
        width: width,
        height: height,
        fit: fit,
        shape: shape,
        borderRadius: borderRadius,
      );
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey[200],
        borderRadius: shape == ImageShape.circle
            ? null
            : BorderRadius.circular(
                shape == ImageShape.roundedRectangle ? borderRadius : 0,
              ),
        shape:
            shape == ImageShape.circle ? BoxShape.circle : BoxShape.rectangle,
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    if (customErrorWidget != null) {
      return customErrorWidget!;
    }

    if (errorImage != null) {
      return AppImage(
        errorImage!,
        width: width,
        height: height,
        fit: fit,
        shape: shape,
        borderRadius: borderRadius,
      );
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white30,
        borderRadius: shape == ImageShape.circle
            ? null
            : BorderRadius.circular(
                shape == ImageShape.roundedRectangle ? borderRadius : 0,
              ),
        shape:
            shape == ImageShape.circle ? BoxShape.circle : BoxShape.rectangle,
      ),
      child: Icon(
        Icons.broken_image_outlined,
        size: (width != null && height != null)
            ? (width! < height! ? width! * 0.4 : height! * 0.4)
            : 24,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _applyShapeAndStyling(Widget imageWidget) {
    var styledWidget = imageWidget;

    // Apply clipping based on shape
    switch (shape) {
      case ImageShape.circle:
        styledWidget = ClipOval(child: styledWidget);
        break;
      case ImageShape.roundedRectangle:
        styledWidget = ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: styledWidget,
        );
        break;
      case ImageShape.rectangle:
        // No clipping needed
        break;
    }

    // Apply container with decoration if needed
    if (backgroundColor != null || border != null || shadows != null) {
      styledWidget = Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: border,
          boxShadow: shadows,
          borderRadius: shape == ImageShape.circle
              ? null
              : BorderRadius.circular(
                  shape == ImageShape.roundedRectangle ? borderRadius : 0,
                ),
          shape:
              shape == ImageShape.circle ? BoxShape.circle : BoxShape.rectangle,
        ),
        child: styledWidget,
      );
    }

    return styledWidget;
  }
}

// Extension for easy usage (now uses the auto-detect constructor)
extension AppImageExtension on String {
  Widget toImage({
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    ImageShape shape = ImageShape.rectangle,
    double borderRadius = 8.0,
    Color? color,
    String? placeholder,
    String? errorImage,
    VoidCallback? onTap,
  }) =>
      AppImage(
        this,
        width: width,
        height: height,
        fit: fit,
        shape: shape,
        borderRadius: borderRadius,
        color: color,
        placeholder: placeholder,
        errorImage: errorImage,
        onTap: onTap,
      );
}

// Predefined image widgets for common use cases
class ProfileImage extends StatelessWidget {
  const ProfileImage({
    super.key,
    required this.imagePath,
    this.size = 50,
    this.onTap,
  });

  final String imagePath;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => AppImage(
        imagePath,
        width: size,
        height: size,
        shape: ImageShape.circle,
        onTap: onTap,
        border: Border.all(
          color: Colors.grey[300]!,
        ),
      );
}

class IconImage extends StatelessWidget {
  const IconImage({
    super.key,
    required this.imagePath,
    this.size = 24,
    this.color,
    this.onTap,
  });

  final String imagePath;
  final double size;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => AppImage(
        imagePath,
        width: size,
        height: size,
        color: color ?? Theme.of(context).iconTheme.color,
        fit: BoxFit.contain,
        onTap: onTap,
      );
}
