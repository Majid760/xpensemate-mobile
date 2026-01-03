import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:xpensemate/core/service/storage_service.dart';

part 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final StorageService _storageService;
  static const String _keyOnboardingCompleted = 'onboarding_completed';

  OnboardingCubit(this._storageService) : super(OnboardingInitial());

  void pageChanged(int index) {
    emit(OnboardingPageChanged(index));
  }

  Future<void> completeOnboarding() async {
    await _storageService.put(key: _keyOnboardingCompleted, value: true);
    emit(OnboardingCompleted());
  }
}
