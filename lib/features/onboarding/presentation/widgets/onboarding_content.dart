import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:xpensemate/core/theme/colors/app_colors.dart';

class OnboardingContent extends StatelessWidget {

  const OnboardingContent({
    super.key,
    required this.title,
    required this.description,
    this.lottieAsset,
  });
  final String title;
  final String description;
  final String? lottieAsset;

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (lottieAsset != null)
            Expanded(
              flex: 3,
              child: Lottie.asset(
                lottieAsset!,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.image_not_supported,
                  size: 100,
                  color: AppColors.primary,
                ),
              ),
            )
          else
            const Spacer(flex: 3),
          const SizedBox(height: 40),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withValues(alpha: 0.7),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
}
