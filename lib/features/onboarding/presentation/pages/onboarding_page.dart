import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:xpensemate/core/theme/colors/app_colors.dart';
import 'package:xpensemate/core/theme/widgets/app_buttons.dart';
import 'package:xpensemate/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:xpensemate/features/onboarding/presentation/widgets/onboarding_content.dart';
import 'package:xpensemate/l10n/app_localizations.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Define onboarding data here or move to a separate data source
    final onboardingData = <Map<String, String>>[
      {
        "title": l10n.onboardingTitle1,
        "desc": l10n.onboardingDesc1,
        "lottie": 'assets/lottie/onboarding_1.json', // Placeholder path
      },
      {
        "title": l10n.onboardingTitle2,
        "desc": l10n.onboardingDesc2,
        "lottie": 'assets/lottie/onboarding_2.json', // Placeholder path
      },
      {
        "title": l10n.onboardingTitle3,
        "desc": l10n.onboardingDesc3,
        "lottie": 'assets/lottie/onboarding_3.json', // Placeholder path
      },
    ];

    return Scaffold(
      body: BlocConsumer<OnboardingCubit, OnboardingState>(
        listener: (context, state) {
          if (state is OnboardingCompleted) {
            // Navigate to Subscription page (Paywall)
            // context.go('/subscription');
            // For now, let's assume /subscription route exists or will be created.
            // If not, we might fail. I'll use a named route or path.
            context.go('/subscription');
          }
        },
        builder: (context, state) {
          var currentIndex = 0;
          if (state is OnboardingPageChanged) {
            currentIndex = state.pageIndex;
          }
          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      context.read<OnboardingCubit>().pageChanged(index);
                    },
                    itemCount: onboardingData.length,
                    itemBuilder: (context, index) {
                      final data = onboardingData[index];
                      return OnboardingContent(
                        title: data['title']!,
                        description: data['desc']!,
                        lottieAsset: data['lottie'],
                      );
                    },
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    children: [
                      // Page Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          onboardingData.length,
                          (index) => Container(
                            margin: const EdgeInsets.only(right: 6),
                            height: 8,
                            width: currentIndex == index ? 24 : 8,
                            decoration: BoxDecoration(
                              color: currentIndex == index
                                  ? AppColors.primary
                                  : AppColors.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Buttons
                      PrimaryButton(
                        text: currentIndex == onboardingData.length - 1
                            ? l10n.getStarted
                            : l10n.next,
                        onPressed: () {
                          if (currentIndex == onboardingData.length - 1) {
                            context
                                .read<OnboardingCubit>()
                                .completeOnboarding();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      if (currentIndex != onboardingData.length - 1)
                        TextButton(
                          onPressed: () {
                            context
                                .read<OnboardingCubit>()
                                .completeOnboarding();
                          },
                          child: Text(
                            l10n.skip,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withValues(alpha: 0.5),
                            ),
                          ),
                        )
                      else
                        const SizedBox(
                          height: 48,
                        ), // Spacer to keep layout stable
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
