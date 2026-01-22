import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/app_spacing.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';
import 'package:xpensemate/core/theme/widgets/app_buttons.dart';
import 'package:xpensemate/features/payment/presentation/widgets/feature_item.dart';
import 'package:xpensemate/features/payment/presentation/widgets/subscription_option.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  int _selectedOption = 1; // 0 for monthly, 1 for yearly

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    // Mock features list
    final features = [
      l10n.featureUnlimitedBudgets,
      l10n.featureAdvancedAnalytics,
      l10n.featureDataExport,
      l10n.featureCloudSync,
    ];

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Close button)
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      context.go('/home'); // Or whatever the home route is
                    },
                  ),
                ),
                SizedBox(height: AppSpacing.md),

                // Title & Subtitle
                Center(
                  child: Column(
                    children: [
                      Text(
                        l10n.premiumTitle,
                        style: context.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.primaryColor,
                        ),
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        l10n.premiumSubtitle,
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.xl),

                // Features List
                ...features.map((feature) => FeatureItem(text: feature)),

                SizedBox(height: AppSpacing.xl),

                // Subscription Options
                SubscriptionOption(
                  title: l10n.monthly,
                  price: '\$4.99/${l10n.monthly.toLowerCase()}', // Mock price
                  isSelected: _selectedOption == 0,
                  onTap: () => setState(() => _selectedOption = 0),
                  isBestValue: false,
                ),
                SubscriptionOption(
                  title: l10n.yearly,
                  price: '\$39.99/${l10n.yearly.toLowerCase()}', // Mock price
                  isSelected: _selectedOption == 1,
                  onTap: () => setState(() => _selectedOption = 1),
                  isBestValue: true,
                  subtitle: l10n.bestValue,
                ),

                SizedBox(height: AppSpacing.xl),

                // Subscribe Button
                PrimaryButton(
                  text: l10n.subscribeNow,
                  onPressed: () {
                    // Implement subscription logic
                    context.go('/home');
                  },
                ),
                SizedBox(height: AppSpacing.md),

                // Restore Purchase & Links
                Center(
                  child: TextButton(
                    onPressed: () {
                      // Implement restore logic
                    },
                    child: Text(l10n.restorePurchases),
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        l10n.termsOfService,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Text('•',
                        style: TextStyle(
                            color: context.colorScheme.onSurfaceVariant)),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        l10n.privacyPolicy,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
