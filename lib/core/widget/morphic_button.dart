import 'package:flutter/material.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';

class GlassmorphicButton extends StatelessWidget {
  const GlassmorphicButton(
      {super.key, required this.icon, required this.onTap, this.isGradientBg = false,});

  final IconData icon;
  final VoidCallback onTap;
  final bool isGradientBg;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(context.sm),
          decoration: BoxDecoration(
            // color: context.colorScheme.onPrimary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: context.colorScheme.onPrimary.withValues(alpha: 0.3),
              width: 1.5,
            ),
            gradient: isGradientBg ? const LinearGradient(
              colors: [
                Color(0xFF6366F1),
                Color(0xFF8B5CF6),
                Color(0xFFA855F7),
              ],
            ) :  LinearGradient(
              colors: [
                context.colorScheme.onPrimary.withValues(alpha: 0.2),
                context.colorScheme.onPrimary.withValues(alpha: 0.2),
              ],
            ) ,
            boxShadow: [
              
              BoxShadow(
                color: context.colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: context.colorScheme.onPrimary,
            size: 20,
          ),
        ),
      );
}
