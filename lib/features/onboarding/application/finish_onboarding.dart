import '../../recovery/domain/calendar.dart';
import 'onboarding_draft.dart';
import 'onboarding_store.dart';

class FinishOnboarding {
  const FinishOnboarding(this.store);
  final OnboardingStore store;

  Future<void> call(OnboardingDraft draft, DateTime now) {
    validatedStartDate(draft.date, now);
    if (draft.modules.contains(OnboardingModule.sponsor) &&
        draft.sponsorChoice == 0 &&
        draft.sponsorName.trim().isEmpty) {
      throw ArgumentError('A szponzor neve kötelező.');
    }
    return store.finish(draft, now);
  }
}
