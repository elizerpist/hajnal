import 'onboarding_draft.dart';

abstract interface class OnboardingStore {
  Future<OnboardingDraft> load(DateTime now);
  Future<void> saveDraft(OnboardingDraft draft);
  Future<void> finish(OnboardingDraft draft, DateTime now);
}
