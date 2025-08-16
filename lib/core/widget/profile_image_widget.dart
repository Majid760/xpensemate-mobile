import 'dart:io';

import 'package:flutter/material.dart';
import 'package:xpensemate/core/theme/colors/app_colors.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/widget/app_image.dart';

class ProfileImageWidget extends StatelessWidget {
  const ProfileImageWidget({
    super.key,
    required this.imageUrl,
    this.file,
    this.size = 120,
    this.onImageTap,
    this.showEditButton = true,
    this.editButtonSize = 18,
    this.borderWidth = 3,
    this.gradientColors,

    this.backgroundColor = Colors.white,
    this.shadowColor,
    this.borderColor = Colors.white,
  });

  final String? imageUrl;
  final double size;
  final VoidCallback? onImageTap;
  final bool showEditButton;
  final double editButtonSize;
  final double borderWidth;
  final List<Color>? gradientColors;
  final Color backgroundColor;
  final Color? shadowColor;
  final Color borderColor;
  final File? file;

  @override
  Widget build(BuildContext context) {
    final defaultGradientColors = gradientColors ??
        [
          AppColors.primary,
          AppColors.secondary,
          AppColors.tertiary,
        ];

    return Center(
      child: Stack(
        children: [
          // Main profile image container
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: defaultGradientColors,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      (shadowColor ?? AppColors.primary).withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(context.xs),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: backgroundColor,
                ),
                child: ClipOval(
                  child: file !=null ? AppImage.file(file!.path): AppImage.network(imageUrl!),
                ),
              ),
            ),
          ),

          // Edit button overlay
          if (showEditButton && onImageTap != null)
            Positioned(
              bottom: size * 0.010, // 8px for 120px size
              right: size * 0.010,
              child: GestureDetector(
                onTap: onImageTap,
                child: Container(
                  padding: EdgeInsets.all(context.sm),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.secondary,
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: borderColor,
                      width: borderWidth,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: editButtonSize,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
