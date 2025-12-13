import 'package:flutter/material.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';

class NotificationButtonWidget extends StatelessWidget {
  const NotificationButtonWidget({super.key});

  @override
  Widget build(BuildContext context) => Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: context.colorScheme.onPrimary,
              size: 28,
            ),
            onPressed: () {},
          ),
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: context.colorScheme.tertiary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: context.colorScheme.onPrimary,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: context.colorScheme.tertiary.withValues(alpha: 0.5),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
}
