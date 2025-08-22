import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/utils/app_utils.dart';
import 'package:xpensemate/core/widget/app_dialogs.dart';

class ImagePickerBottomSheet extends StatelessWidget {
  const ImagePickerBottomSheet({super.key, required this.onImageSelected});
  final void Function(File?) onImageSelected;

  Future<void> _pick(ImageSource source, BuildContext ctx) async {
    try {
      // Show loading message
      if (!ctx.mounted) return;
      AppDialogs.showTopSnackBar(
        ctx,
        message: source == ImageSource.camera 
            ? ctx.l10n.openingCamera 
            : ctx.l10n.openingGallery,
        type: MessageType.info,
      );
      
      final picked = await ImagePicker().pickImage(source: source);
      
      if (picked != null) {
        final file = File(picked.path);
        
        // Show processing message
        if (!ctx.mounted) return;
        AppDialogs.showTopSnackBar(
          ctx,
          message: ctx.l10n.processingImage,
          type: MessageType.info,
        );
        
        // Validate file size using AppUtils
        final validation = AppUtils.validateImageFile(file);
        
        if (!validation.isValid) {
          if (ctx.mounted) {
            Navigator.pop(ctx); // Close the bottom sheet first
            
            // Show error dialog with localized message
            AppDialogs.showTopSnackBar(
              ctx,
              message: ctx.l10n.fileSizeExceeded(
                validation.formattedFileSize.replaceAll(' MB', ''),
              ),
              type: MessageType.error,
            );
          }
          return;
        }
        
        // Show success message
        if (!ctx.mounted) return;
        AppDialogs.showTopSnackBar(
          ctx,
          message: ctx.l10n.imageSelectedSuccessfully,
          type: MessageType.success,
        );
        
        // File size is acceptable, proceed
        onImageSelected(file);
      } else {
        // User cancelled image selection - show info message
        if (!ctx.mounted) return;
        AppDialogs.showTopSnackBar(
          ctx,
          message: ctx.l10n.imageSelectionCancelled,
          type: MessageType.info,
        );
        onImageSelected(null);
      }
      
      if (ctx.mounted) {
        Navigator.pop(ctx);
      }
    } on Exception catch (_) {
      // Handle any errors during image picking
      if (ctx.mounted) {
        Navigator.pop(ctx);
        AppDialogs.showTopSnackBar(
          ctx,
          message: ctx.l10n.imageSelectionFailed,
          type: MessageType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.fromLTRB(context.lg, context.md, context.lg, context.xl),
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Subtle handle
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: context.lg),
              decoration: BoxDecoration(
                color: context.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Text(
              context.l10n.selectImage,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: context.lg),
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(
                  icon: Icons.photo_library_outlined,
                  label: context.l10n.gallery,
                  onTap: () => _pick(ImageSource.gallery, context),
                ),
                _ActionButton(
                  icon: Icons.camera_alt_outlined,
                  label: context.l10n.camera,
                  onTap: () => _pick(ImageSource.camera, context),
                ),
              ],
            ),
          ],
        ),
      );
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(32),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(context.md),
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(32),
            // border: Border.all(
            //   color: context.colorScheme.outlineVariant,
            // ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 28,
                color: context.colorScheme.primary,
              ),
              SizedBox(height: context.sm),
              Text(
                label,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
}