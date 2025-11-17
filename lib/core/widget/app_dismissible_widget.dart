// Dismissible Wrapper Widget with fade-out effect
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';

class AppDismissible extends StatefulWidget {
  const AppDismissible({
    super.key,
    required this.child,
    required this.objectKey,
    required this.onDeleteConfirm,
    required this.onEdit,
  });

  final Widget child;
  final String objectKey;
  final Future<bool> Function() onDeleteConfirm;
  final VoidCallback onEdit;

  @override
  State<AppDismissible> createState() => _AppDismissibleState();
}

class _AppDismissibleState extends State<AppDismissible> {
  bool _isDismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_isDismissed) {
      return const SizedBox.shrink();
    }

    return Dismissible(
      key: Key('dismissible_${widget.objectKey}'),
      background: DismissBackground(
        alignment: Alignment.centerLeft,
        color: context.colorScheme.error,
        icon: Icons.delete,
        label: context.l10n.delete,
      ),
      secondaryBackground: DismissBackground(
        alignment: Alignment.centerRight,
        color: context.colorScheme.primary,
        icon: Icons.edit,
        label: context.l10n.edit,
      ),
      confirmDismiss: (direction) async {
        await HapticFeedback.mediumImpact();
        if (direction == DismissDirection.startToEnd) {
          final result = await widget.onDeleteConfirm();
          if (result == true) {
            setState(() {
              _isDismissed = true;
            });
          }
          return result;
        } else if (direction == DismissDirection.endToStart) {
          widget.onEdit();
          return false; // Don't actually dismiss for edit
        }
        return false;
      },
      onDismissed: (direction) {
        // This handler is required to properly remove the widget from the tree
        if (direction == DismissDirection.startToEnd) {
          setState(() {
            _isDismissed = true;
          });
        }
      },
      dismissThresholds: const {
        DismissDirection.startToEnd: 0.4,
        DismissDirection.endToStart: 0.4,
      },
      child: widget.child,
    );
  }
}

// Static Dismiss Background Widget
class DismissBackground extends StatelessWidget {
  const DismissBackground({
    super.key,
    required this.alignment,
    required this.color,
    required this.icon,
    required this.label,
  });

  final Alignment alignment;
  final Color color;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: alignment,
        padding: EdgeInsets.only(
          left: alignment == Alignment.centerLeft ? 20 : 0,
          right: alignment == Alignment.centerRight ? 20 : 0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
}
