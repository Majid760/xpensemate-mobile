import 'package:flutter/material.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';

class CustomAppLoader extends StatelessWidget {
  const CustomAppLoader({
    super.key,
    this.color,
    this.size = 24.0,
    this.strokeWidth = 3.0,
  });

  final Color? color;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) => Center(
        child: SizedBox(
          height: size,
          width: size,
          child: CircularProgressIndicator.adaptive(
            strokeWidth: strokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? context.colorScheme.primary,
            ),
            backgroundColor:
                Theme.of(context).platform == TargetPlatform.iOS ? null : null,
          ),
        ),
      );
}
