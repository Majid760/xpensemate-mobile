import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/core/enums.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/app_spacing.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/utils/app_utils.dart';
import 'package:xpensemate/core/widget/animated_section_header.dart';
import 'package:xpensemate/core/widget/app_bottom_sheet.dart';
import 'package:xpensemate/core/widget/app_snackbar.dart';
import 'package:xpensemate/features/payment/domain/entities/payment_entity.dart';
import 'package:xpensemate/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:xpensemate/features/payment/presentation/widgets/payment_form_widget.dart';
import 'package:xpensemate/features/payment/presentation/widgets/payment_list_widget.dart';
import 'package:xpensemate/features/payment/presentation/widgets/payment_stats_widget.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.colorScheme.surface,
        body: const PaymentPageContent(),
      );
}

class PaymentPageContent extends StatefulWidget {
  const PaymentPageContent({super.key});

  @override
  State<PaymentPageContent> createState() => _PaymentPageContentState();
}

class _PaymentPageContentState extends State<PaymentPageContent>
    with AutomaticKeepAliveClientMixin {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadPaymentData(FilterValue filterValue) {
    context.paymentCubit.fetchPaymentStats(filterValue);
    context.read<PaymentCubit>().pagingController.refresh();
  }

  void _editPayment(PaymentEntity entity, BuildContext context) {
    AppBottomSheet.show<void>(
      context: context,
      title: context.l10n.editPayment,
      config: const BottomSheetConfig(
        padding: EdgeInsets.zero,
        blurSigma: 5,
        barrierColor: Colors.transparent,
      ),
      child: PaymentFormWidget(
        payment: entity,
        onSave: (payment) async {
          await context.paymentCubit.updatePayment(payment: payment);
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        },
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocListener<PaymentCubit, PaymentState>(
      listenWhen: (previous, current) =>
          (previous.message != current.message && current.message != null) ||
          (previous != current),
      listener: (context, state) {
        if (state.message != null && state.message!.isNotEmpty) {
          AppSnackBar.show(
            context: context,
            message: state.message ?? "",
            type: state.status == PaymentStatus.error
                ? SnackBarType.error
                : SnackBarType.success,
          );
        }
      },
      child: RefreshIndicator(
        onRefresh: () async => _loadPaymentData(FilterValue.monthly),
        color: context.primaryColor,
        child: CustomScrollView(
          controller: _scrollController,
          // ✅ OPTIMIZATION: Add cacheExtent for smoother scrolling
          cacheExtent: 500,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [


            // Stats Section
            const _StatsSection(),

            // Search Header Section
            const _SearchHeaderSection(),

            // Payment List Section
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              sliver: PaymentListWidget(
                onEdit: (updatedEntity) {
                  _editPayment(updatedEntity, context);
                },
                onDelete: (paymentId) {
                  context.paymentCubit.deletePayment(paymentId: paymentId);
                },
                scrollController: _scrollController,
              ),
            ),
            // Bottom padding for FAB
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.xxxl + AppSpacing.xl),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}



// ✅ OPTIMIZATION: Extracted Stats Section with RepaintBoundary
class _StatsSection extends StatelessWidget {
  const _StatsSection();

  @override
  Widget build(BuildContext context) => BlocBuilder<PaymentCubit, PaymentState>(
        buildWhen: (previous, current) =>
            previous.paymentStats != current.paymentStats ||
            previous.filterValue != current.filterValue,
        builder: (context, state) => SliverToBoxAdapter(
          child: RepaintBoundary(
            child: PaymentStatsWidget(
              stats: state.paymentStats,
              defaultPeriod: state.filterValue,
            ),
          ),
        ),
      );
}

// ✅ OPTIMIZATION: Extracted Search Header Section
class _SearchHeaderSection extends StatelessWidget {
  const _SearchHeaderSection();

  @override
  Widget build(BuildContext context) => SliverPadding(
        padding: const EdgeInsets.all(AppSpacing.md),
        sliver: SliverToBoxAdapter(
          child: AnimatedSectionHeader(
            title: context.l10n.payments,
            icon: Icon(
              Icons.payment_rounded,
              color: context.primaryColor,
              size: AppSpacing.iconLg,
            ),
            onSearchChanged: (value) {
              if (value.trim().isEmpty) return;
              AppUtils.debounce(
                () => context.paymentCubit.updateSearchTerm(value),
                delay: const Duration(milliseconds: 800),
              );
            },
            onSearchCleared: () => context.paymentCubit.refreshPayments(),
          ),
        ),
      );
}

void addPayment({
  required BuildContext context,
  void Function(PaymentEntity)? onSave,
}) {
  final screenHeight = context.screenHeight;

  AppBottomSheet.show<void>(
    context: context,
    title: context.l10n.addPayment,
    config: BottomSheetConfig(
      minHeight: screenHeight * 0.8,
      maxHeight: screenHeight * 0.95,
      padding: EdgeInsets.zero,
      blurSigma: 5,
      barrierColor: Colors.transparent,
    ),
    child: PaymentFormWidget(
      onSave: onSave ??
          (payment) async {
            await context.paymentCubit.createPayment(payment: payment);
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
      onCancel: () => Navigator.of(context).pop(),
    ),
  );
}
