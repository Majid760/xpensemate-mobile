import 'package:flutter/material.dart';
import 'package:xpensemate/core/service/service_locator.dart';
import 'package:xpensemate/core/theme/app_spacing.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/widget/app_image.dart';
import 'package:xpensemate/features/dashboard/presentation/widgets/notification_button_widget.dart';

class AppBarWidget extends StatelessWidget {
  const AppBarWidget({super.key, this.onProfileTap});
  final void Function()? onProfileTap;

  @override
  Widget build(BuildContext context) => SliverAppBar(
        pinned: true,
        elevation: 0,
        leadingWidth: 70,
        leading: Builder(
          builder: (BuildContext builderContext) => UnconstrainedBox(
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: InkWell(
                onTap: () {
                  onProfileTap?.call();
                },
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
                      color: const Color(0xFF6366F1).withValues(alpha: 0.3),
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
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.3),
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
