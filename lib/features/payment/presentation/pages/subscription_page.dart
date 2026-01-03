import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xpensemate/core/theme/colors/app_colors.dart';
import 'package:xpensemate/core/theme/widgets/app_buttons.dart';
import 'package:xpensemate/features/payment/presentation/widgets/feature_item.dart';
import 'package:xpensemate/features/payment/presentation/widgets/subscription_option.dart';
import 'package:xpensemate/l10n/app_localizations.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  int _selectedOption = 1; // 0 for monthly, 1 for yearly

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Mock features list
    final features = [
      l10n.featureUnlimitedBudgets,
      l10n.featureAdvancedAnalytics,
      l10n.featureDataExport,
      l10n.featureCloudSync,
    ];

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
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
                const SizedBox(height: 16),

                // Title & Subtitle
                Center(
                  child: Column(
                    children: [
                      Text(
                        l10n.premiumTitle,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.premiumSubtitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Features List
                ...features.map((feature) => FeatureItem(text: feature)),

                const SizedBox(height: 32),

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

                const SizedBox(height: 32),

                // Subscribe Button
                PrimaryButton(
                  text: l10n.subscribeNow,
                  onPressed: () {
                    // Implement subscription logic
                    context.go('/home');
                  },
                ),
                const SizedBox(height: 16),

                // Restore Purchase & Links
                Center(
                  child: TextButton(
                    onPressed: () {
                      // Implement restore logic
                    },
                    child: Text(l10n.restorePurchases),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        l10n.termsOfService,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                    const Text('•', style: TextStyle(color: Colors.grey)),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        l10n.privacyPolicy,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
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
