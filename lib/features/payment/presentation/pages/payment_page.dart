import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/core/utils/app_utils.dart';
import 'package:xpensemate/core/widget/animated_section_header.dart';
import 'package:xpensemate/core/widget/app_bar_widget.dart';
import 'package:xpensemate/core/widget/app_bottom_sheet.dart';
import 'package:xpensemate/core/widget/app_snackbar.dart';
import 'package:xpensemate/features/expense/presentation/cubit/expense_cubit.dart';
import 'package:xpensemate/features/payment/domain/entities/payment_entity.dart';
import 'package:xpensemate/features/payment/domain/entities/payment_stats_entity.dart';
import 'package:xpensemate/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:xpensemate/features/payment/presentation/widgets/payment_form_widget.dart';
import 'package:xpensemate/features/payment/presentation/widgets/payment_list_widget.dart';
import 'package:xpensemate/features/payment/presentation/widgets/payment_stats_widget.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const PaymentPageBody(),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _addPayment(context),
          child: const Icon(Icons.add),
        ),
      );

  void _addPayment(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    AppBottomSheet.show<void>(
      context: context,
      title: 'Add Payment',
      config: BottomSheetConfig(
        minHeight: screenHeight * 0.8,
        maxHeight: screenHeight * 0.95,
        padding: EdgeInsets.zero,
        blurSigma: 5,
        barrierColor: Colors.transparent,
      ),
      child: PaymentFormWidget(
        onSave: (payment) async {
          await context.paymentCubit.createPayment(payment: payment);
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        },
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }
}

class PaymentPageBody extends StatelessWidget {
  const PaymentPageBody({super.key});

  @override
  Widget build(BuildContext context) => const PaymentPageContent();
}

class PaymentPageContent extends StatefulWidget {
  const PaymentPageContent({super.key});

  @override
  State<PaymentPageContent> createState() => _PaymentPageContentState();
}

class _PaymentPageContentState extends State<PaymentPageContent>
    with TickerProviderStateMixin {
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

  void _loadPaymentData() {
    BlocProvider.of<PaymentCubit>(context).loadPaymentData();
  }

  void _editPayment(PaymentEntity entity, BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    AppBottomSheet.show<void>(
      context: context,
      title: "Edit Payment",
      config: BottomSheetConfig(
        minHeight: screenHeight * 0.8,
        maxHeight: screenHeight * 0.95,
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
  Widget build(BuildContext context) =>
      BlocListener<PaymentCubit, PaymentState>(
        listenWhen: (previous, current) =>
            previous.message != current.message && current.message != null,
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
          onRefresh: () async => _loadPaymentData(),
          color: Theme.of(context).primaryColor,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              const CustomAppBar(
                defaultPeriod:
                    FilterDefaultValue.monthly, // Default value for now
              ),
              BlocSelector<PaymentCubit, PaymentState, PaymentStatsEntity?>(
                selector: (state) => state.paymentStats,
                builder: (context, paymentStats) =>
                    PaymentStatsWidget(stats: paymentStats),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: AnimatedSectionHeader(
                    title: "Payments",
                    icon: Icon(
                      Icons.payment_rounded,
                      color: Theme.of(context).primaryColor,
                      size: 28,
                    ),
                    onSearchChanged: (value) {
                      if (value.trim().isEmpty) return;
                      AppUtils.debounce(
                        () => context.paymentCubit.updateSearchTerm(value),
                        delay: const Duration(milliseconds: 700),
                      );
                    },
                    onSearchCleared: () =>
                        context.paymentCubit.refreshPayments(),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
      );
}
