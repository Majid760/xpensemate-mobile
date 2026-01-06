import 'package:flutter/material.dart';
import 'package:xpensemate/core/service/service_locator.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/widget/app_image.dart';
import 'package:xpensemate/features/dashboard/presentation/widgets/notification_button_widget.dart';

class AppBarWidget extends StatelessWidget {
  const AppBarWidget({super.key, this.onProfileTap});
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) => SliverAppBar(
        pinned: true,
        elevation: 0,
        leadingWidth: 70,
        leading: Builder(
          builder: (BuildContext builderContext) => UnconstrainedBox(
            child: Padding(
              padding: EdgeInsets.only(left: context.sm),
              child: InkWell(
                onTap: onProfileTap,
                child: AppImage.network(
                  sl.authService.currentUser?.profilePhotoUrl ?? '',
                  height: 50,
                  width: 50,
                  border: Border.all(
                    width: 2,
                    color: context.colorScheme.primary,
                  ),
                  shadows: [
                    BoxShadow(
                      color: context.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 9,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  shape: ImageShape.circle,
                  heroTag: 'profilelDP',
                ),
              ),
            ),
          ),
        ),
        backgroundColor: context.colorScheme.surface,
        automaticallyImplyLeading: false,
        toolbarHeight: 60,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: context.md),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.colorScheme.primary,
                    context.colorScheme.tertiary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: context.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const NotificationButtonWidget(),
            ),
          ),
        ],
      );
}
