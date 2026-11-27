import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/features/onboarding/application/onboarding_draft.dart';

void main() {
  test(
    'legacy later and none choices become skip without losing draft fields',
    () {
      final draft = OnboardingDraft(
        periodId: 4,
        date: DateTime(2026, 1, 2),
        motivation: 'Megmarad',
        modules: {OnboardingModule.sponsor},
        sponsorName: 'Anna',
        sponsorPhone: '+361234',
        completed: true,
        baseline: const {},
        dirty: const {'sponsor'},
      );
      for (final legacy in [0, 1, 2]) {
        final data = jsonDecode(draft.encode()) as Map<String, dynamic>;
        data['sponsorChoice'] = legacy;
        final restored = OnboardingDraft.decode(jsonEncode(data));
        expect(
          restored.sponsorChoice,
          legacy == 0 ? SponsorChoice.add : SponsorChoice.skip,
        );
        expect(restored.motivation, 'Megmarad');
        expect(restored.sponsorName, 'Anna');
        expect(restored.modules, contains(OnboardingModule.sponsor));
      }
    },
  );
}
