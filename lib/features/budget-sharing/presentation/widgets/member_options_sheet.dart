import 'package:flutter/material.dart';
import 'package:xpensemate/core/theme/app_spacing.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/widget/app_bottom_sheet.dart';
import 'package:xpensemate/features/budget-sharing/presentation/widgets/member_options_actions.dart';
import 'package:xpensemate/features/budget-sharing/presentation/widgets/member_options_header.dart';
import 'package:xpensemate/features/budget-sharing/presentation/widgets/role_selector_section.dart';

/// The content body for the member-options bottom sheet.
/// Compose it via [MemberOptionsSheet.show].
class MemberOptionsSheetContent extends StatefulWidget {
  const MemberOptionsSheetContent({
    super.key,
    required this.name,
    required this.email,
    required this.initials,
    required this.currentRole,
    required this.avatarColor,
    required this.avatarTextColor,
    required this.availableRoles,
    this.onSave,
    this.onRevoke,
  });

  final String name;
  final String email;
  final String initials;
  final String currentRole;
  final Color avatarColor;
  final Color avatarTextColor;
  final List<String> availableRoles;
  final void Function(String newRole)? onSave;
  final VoidCallback? onRevoke;

  @override
  State<MemberOptionsSheetContent> createState() =>
      _MemberOptionsSheetContentState();
}

class _MemberOptionsSheetContentState
    extends State<MemberOptionsSheetContent> {
  late String _selectedRole;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.currentRole;
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);

    // Simulate async save — replace with real cubit call
    await Future<void>.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;
    setState(() => _isSaving = false);
    widget.onSave?.call(_selectedRole);
    Navigator.of(context).pop();
  }

  Future<void> _handleRevoke() async {
    // Close the sheet first, then let caller handle confirmation
    Navigator.of(context).pop();
    widget.onRevoke?.call();
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Member header ──────────────────────────────────────────────
          MemberOptionsHeader(
            name: widget.name,
            email: widget.email,
            initials: widget.initials,
            avatarColor: widget.avatarColor,
            avatarTextColor: widget.avatarTextColor,
          ),
    
          const SizedBox(height: AppSpacing.md1),
    
          // ── Role selector ──────────────────────────────────────────────
          RoleSelectorSection(
            selectedRole: _selectedRole,
            availableRoles: widget.availableRoles,
            onRoleSelected: (role) => setState(() => _selectedRole = role),
          ),
    
          const SizedBox(height: AppSpacing.lg),
    
          // ── Action buttons ─────────────────────────────────────────────
          MemberOptionsActions(
            isSaving: _isSaving,
            onSave: _handleSave,
            onRevoke: _handleRevoke,
          ),
        ],
      ),
  );
}

/// Static helper to display the member-options bottom sheet.
class MemberOptionsSheet {
  const MemberOptionsSheet._();

  static Future<void> show({
    required BuildContext context,
    required String name,
    required String email,
    required String initials,
    required String currentRole,
    required Color avatarColor,
    required Color avatarTextColor,
    required List<String> availableRoles,
    void Function(String newRole)? onSave,
    VoidCallback? onRevoke,
  }) => AppBottomSheet.show<void>(
      context: context,
      config:  BottomSheetConfig(
        showCloseButton: false,
        height: context.screenHeight * 0.45,
        blurSigma: 6,
      ),
      child: MemberOptionsSheetContent(
        name: name,
        email: email,
        initials: initials,
        currentRole: currentRole,
        avatarColor: avatarColor,
        avatarTextColor: avatarTextColor,
        availableRoles: availableRoles,
        onSave: onSave,
        onRevoke: onRevoke,
      ),
    );
}
