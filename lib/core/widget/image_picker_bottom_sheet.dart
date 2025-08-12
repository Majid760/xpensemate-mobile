import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';

class ImagePickerBottomSheet extends StatelessWidget {
  const ImagePickerBottomSheet({super.key, required this.onImageSelected});
  final Function(File?) onImageSelected;

  Future<void> _pick(ImageSource source, BuildContext ctx) async {
    final picked = await ImagePicker().pickImage(source: source);
    onImageSelected(picked != null ? File(picked.path) : null);
    if (ctx.mounted) Navigator.pop(ctx);
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