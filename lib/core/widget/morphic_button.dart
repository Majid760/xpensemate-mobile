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
              color: context.colorScheme.onPrimary.withValues(alpha: 0.6),
              width: 1.5,
            ),
            color: context.colorScheme.primary.withValues(alpha: 0.9),
            // gradient: isGradientBg ?  LinearGradient(
            //   colors: [
            //     context.colorScheme.onPrimary.withValues(alpha: 0.9),
            //     context.primaryColor.withValues(alpha: 0.9),
            //   ],
            // ) :  LinearGradient(
            //   colors: [
            //     context.colorScheme.tertiary.withValues(alpha: 0.9),
            //     context.colorScheme.tertiary.withValues(alpha: 0.9),
            //   ],
            // ) ,
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
