import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/app_spacing.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/utils/app_utils.dart';
import 'package:xpensemate/core/widget/app_bottom_sheet.dart';
import 'package:xpensemate/core/widget/app_button.dart';
import 'package:xpensemate/core/widget/custom_app_loader.dart';
import 'package:xpensemate/core/widget/error_state_widget.dart';
import 'package:xpensemate/features/auth/presentation/widgets/custom_text_form_field.dart';
import 'package:xpensemate/features/budget-sharing/domain/entities/user_search_entity.dart';
import 'package:xpensemate/features/budget-sharing/presentation/cubit/invite_access_budget_cubit.dart';
import 'package:xpensemate/features/budget-sharing/presentation/cubit/invite_access_budget_state.dart';

class ShareBudgetSheet {
  const ShareBudgetSheet._();

  static Future<void> show({
    required BuildContext context,
    required String budgetId,
  }) =>
      AppBottomSheet.show<void>(
        context: context,
        title: context.l10n.shareBudget,
        config: BottomSheetConfig(
          height: context.screenHeight * 0.70,
          blurSigma: 6,
        ),
        child: _ShareBudgetSheetContent(budgetId: budgetId),
      );
}

class _ShareBudgetSheetContent extends StatefulWidget {
  const _ShareBudgetSheetContent({required this.budgetId});

  final String budgetId;

  @override
  State<_ShareBudgetSheetContent> createState() =>
      _ShareBudgetSheetContentState();
}

class _ShareBudgetSheetContentState extends State<_ShareBudgetSheetContent> {
  String _selectedRole = 'Editor';

  late final FormGroup _form;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _form = FormGroup({
      'search': FormControl<String>(),
    });

    _form.control('search').valueChanges.listen((value) {
      AppUtils.debounce(() {
        if (mounted) {
          final query = value as String? ?? '';
          
          if (query.isEmpty || query.length > 2) {
            context.inviteAccessBudgetCubit.searchUsers(query);
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _form.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return BlocBuilder<InviteAccessBudgetCubit, InviteAccessBudgetCubitState>(
      builder: (context, state) => Column(
        children: [
          // FIXED HEADER SECTION
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.sm),
                // TextField
                ReactiveForm(
                  formGroup: _form,
                  child: ReactiveAppField(
                    formControlName: 'search',
                    fieldType: FieldType.search,
                    hintText: context.l10n.searchNameOrEmail,
                    prefixIcon: Icon(
                      Icons.search,
                      size: 18,
                      color: scheme.primary.withValues(
                        alpha: 0.7,
                      ),
                    ),
                    // suffixIcon:_form.control('search'). GestureDetector(
                    //   onTap: {
                        
                    //   },
                    //   child: const Icon(Icons.close),
                    // ) ,
                  ),
                ),
                const SizedBox(height: AppSpacing.md1),

                // ROLE Label
                Text(
                  context.l10n.roleTitleLabel,
                  style: context.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Roles Filter Chips inside a Row
                Row(
                  children: [
                    _RoleChip(
                      label: context.l10n.editor,
                      isSelected: _selectedRole == context.l10n.editor,
                      onTap: () =>
                          setState(() => _selectedRole = context.l10n.editor),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _RoleChip(
                      label: context.l10n.viewer,
                      isSelected: _selectedRole == context.l10n.viewer,
                      onTap: () =>
                          setState(() => _selectedRole = context.l10n.viewer),
                    ),
                  ],
                ),
                const SizedBox(height:AppSpacing.sm),
              ],
            ),
          ),
          
          // SCROLLABLE LIST SECTION
          Expanded(
            child: CustomScrollView(
              slivers: [
                PagingListener<int, UserSearchEntity>(
                  controller: context.inviteAccessBudgetCubit.pagingController,
                  builder: (context, pagingState, fetchNextPage) =>
                      PagedSliverList<int, UserSearchEntity>(
                    state: pagingState,
                    fetchNextPage: fetchNextPage,
                    builderDelegate: PagedChildBuilderDelegate<UserSearchEntity>(
                      animateTransitions: true,
                      transitionDuration: const Duration(milliseconds: 400),
                      itemBuilder: (context, user, index) {
                        final isInviting = state.invitingUserIds.contains(user.id);
                        final isInvited = state.invitedUserIds.contains(user.id);

                        return UserSearchItem(
                          initials: user.firstName.isNotEmpty
                              ? user.firstName[0].toUpperCase()
                              : 'U',
                          email: user.email,
                          name: user.fullName,
                          imageUrl: user.profilePhotoUrl,
                          isSelected: false,
                          isInvited: isInvited,
                          isInviting: isInviting,
                          onTap: () {
                            if (!isInvited && !isInviting) {
                              context.inviteAccessBudgetCubit.inviteUser(
                                budgetId: widget.budgetId,
                                inviteeId: user.id,
                                role: _selectedRole,
                                monthlyLimit: 0, // Default or selected limit
                              );
                            }
                          },
                        );
                      },
                  noItemsFoundIndicatorBuilder: (context) {
                    final query = context.inviteAccessBudgetCubit.filterQuery;
                    if (query.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.all(context.lg),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.search,
                                  size: 48,
                                  color: context.colorScheme.onSurface
                                      .withValues(alpha: 0.3),),
                              const SizedBox(height: 16),
                              Text(context.l10n.startTypingToSearch),
                            ],
                          ),
                        ),
                      );
                    }
                    if (query.trim().length < 2) {
                      return Padding(
                        padding: EdgeInsets.all(context.lg),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.info_outline,
                                  size: 48,
                                  color: context.colorScheme.onSurface
                                      .withValues(alpha: 0.3),),
                              const SizedBox(height: 16),
                              Text(context.l10n.searchQueryTooShort),
                            ],
                          ),
                        ),
                      );
                    }
                    return ErrorStateSectionWidget(
                      onRetry: () => context
                          .inviteAccessBudgetCubit.pagingController
                          .refresh(),
                      errorMsg: context.l10n.noUsersFound,
                    );
                  },
                  firstPageProgressIndicatorBuilder: (_) => Padding(
                    padding: EdgeInsets.all(context.md),
                    child: const Center(child: CustomAppLoader()),
                  ),
                  newPageProgressIndicatorBuilder: (_) => Center(
                    child: Padding(
                      padding: EdgeInsets.all(context.md),
                      child: const CustomAppLoader(),
                    ),
                  ),
                  firstPageErrorIndicatorBuilder: (_) => Container(
                    padding: EdgeInsets.all(context.md),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.error_outline,
                              size: 48, color: context.colorScheme.error,),
                          const SizedBox(height: 16),
                          Text(
                            context.l10n.errorLoadingUsers,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.error,
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppButton.primary(
                            text: context.l10n.retry,
                            onPressed: () => context
                                .inviteAccessBudgetCubit.pagingController
                                .refresh(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  newPageErrorIndicatorBuilder: (_) => Container(
                    padding: EdgeInsets.all(context.md),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.error_outline,
                              size: 48, color: context.colorScheme.error,),
                          const SizedBox(height: 16),
                          Text(
                            context.l10n.errorLoadingUsers,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.error,
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppButton.primary(
                            text: context.l10n.retry,
                            onPressed: () => context
                                .inviteAccessBudgetCubit.pagingController
                                .fetchNextPage(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  noMoreItemsIndicatorBuilder: (_) => Padding(
                    padding: EdgeInsets.only(top: context.xl),
                    child: Center(
                      child:Container(
                        padding: EdgeInsets.symmetric(horizontal:context.md,vertical: context.sm),
                        decoration: BoxDecoration(
                          color: context.colorScheme.primary,
                          borderRadius: BorderRadius.circular(32),
                        ),  
                        child: Text(
                        context.l10n.noMoreUsers,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                  ),
                ),
                ),),
            ],
            ),
          ),
        ],
      ), 
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final isDark = context.theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? scheme.primary.withValues(alpha: 0.2)
                  : scheme.primaryContainer)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? scheme.primary
                : scheme.outlineVariant.withValues(alpha: 0.5),
            width: isSelected ? 1 : 1,
          ),
        ),
        child: Text(
          label,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isSelected ? scheme.primary : scheme.onSurface,
          ),
        ),
      ),
    );
  }
}
class UserSearchItem extends StatelessWidget {
  const UserSearchItem({
    super.key,
    required this.initials,
    required this.email,
    required this.name,
    required this.imageUrl,
    required this.isSelected,
    this.isInvited = false,
    this.isInviting = false,
    required this.onTap,
  });

  final String initials;
  final String email;
  final String name;
  final String? imageUrl;
  final bool isSelected;
  final bool isInvited;
  final bool isInviting;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final isDark = context.theme.brightness == Brightness.dark;

    return Card(
      elevation: isSelected ? 4 : 1,
      shadowColor: isSelected
          ? context.primaryColor.withValues(alpha: 0.25)
          : Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelected
            ? BorderSide(
                color: context.primaryColor.withValues(alpha: 0.5),
                width: 1.5,
              )
            : BorderSide(
                color: scheme.outlineVariant.withValues(alpha: 0.4),
                width: 0.8,
              ),
      ),
      color: isSelected
          ? context.primaryColor.withValues(alpha: isDark ? 0.12 : 0.06)
          : scheme.surface,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: context.primaryColor.withValues(alpha: 0.08),
        highlightColor: context.primaryColor.withValues(alpha: 0.04),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              // Avatar
              Stack(
                children: [
                  if (imageUrl != null)
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(imageUrl!),
                    )
                  else
                    CircleAvatar(
                      backgroundColor:
                          context.primaryColor.withValues(alpha: isDark ? 0.25 : 0.12),
                      radius: 24,
                      child: Text(
                        initials,
                        style: context.textTheme.titleSmall?.copyWith(
                          color: context.primaryColor,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  if (isSelected)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: context.primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: scheme.surface,
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 8,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
    
              const SizedBox(width: AppSpacing.sm1),
    
              // Name + Email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                        letterSpacing: 0.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.55),
                        letterSpacing: 0.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
    
              const SizedBox(width: AppSpacing.md),
    
              // Pending badge
              AppButton.icon(
                text: isInviting
                    ? context.l10n.invitingLabel
                    : (isInvited ? context.l10n.invitedLabel : context.l10n.share),
                onPressed: (isInvited || isInviting) ? null : onTap,
                leadingIcon: Icon(
                  isInvited ? Icons.check : (isInviting ? Icons.hourglass_empty : Icons.share),
                ),
                backgroundColor: isInvited
                    ? Colors.green
                    : (isInviting ? context.primaryColor.withValues(alpha: 0.5) : context.primaryColor),
                textColor: context.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm1,
                  vertical: AppSpacing.sm1,
                ),
                borderRadius: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}