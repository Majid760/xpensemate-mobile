import 'package:flutter/material.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/app_spacing.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/widget/app_button.dart';

class InviteMemberButton extends StatelessWidget {
  const InviteMemberButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: AppButton.outline(
        text: '+ ${context.l10n.inviteMember}',
        onPressed: onPressed,
        height: 48,
        borderRadius: 12,
        borderColor: context.colorScheme.outline.withValues(alpha: 0.3),
        textColor: context.colorScheme.onPrimary,
        backgroundColor: context.colorScheme.primary,
      ),
    );
}
