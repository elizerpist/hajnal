import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/features/onboarding/application/onboarding_controller.dart';
import 'package:hajnal/features/onboarding/application/onboarding_draft.dart';
import 'package:hajnal/features/onboarding/application/onboarding_store.dart';

class DelayedStore implements OnboardingStore {
  final gate = Completer<void>();
  int finished = 0;
  final writes = <String>[];
  late OnboardingDraft current;
  @override
  Future<OnboardingDraft> load(DateTime now) async => current;
  @override
  Future<void> saveDraft(OnboardingDraft draft) async {
    await gate.future;
    writes.add(draft.motivation);
  }

  @override
  Future<void> finish(OnboardingDraft draft, DateTime now) async {
    finished++;
  }
}

class RetryStore extends DelayedStore {
  bool fail = true;
  @override
  Future<void> finish(OnboardingDraft draft, DateTime now) async {
    if (fail) throw StateError('write failed');
    finished++;
  }
}

class DraftFailureStore extends DelayedStore {
  bool failDraft = true;
  @override
  Future<void> saveDraft(OnboardingDraft draft) async {
    if (failDraft) throw StateError('draft write failed');
    writes.add(draft.motivation);
  }
}

void main() {
  test(
    'the existing day tracker updates the open preview after midnight',
    () async {
      final store = DelayedStore();
      store.current = OnboardingDraft(
        periodId: null,
        date: DateTime(2026, 1, 1),
        motivation: '',
        modules: {},
        sponsorName: '',
        sponsorPhone: '',
        completed: false,
        baseline: const {},
      );
      store.gate.complete();
      var now = DateTime(2026, 1, 1);
      final dayChanges = ValueNotifier(0);
      final controller = OnboardingController(
        store,
        () => now,
        dayChanges: dayChanges,
      );
      await controller.load();
      expect(controller.cleanDayCount, 0);
      now = DateTime(2026, 1, 2);
      var notified = false;
      controller.addListener(() => notified = true);
      dayChanges.value++;
      expect(notified, isTrue);
      expect(controller.cleanDayCount, 1);
      await controller.idle;
      controller.dispose();
      dayChanges.dispose();
    },
  );
  test(
    'closing waits for a durable draft and offers retry after a write failure',
    () async {
      final store = DraftFailureStore();
      store.current = OnboardingDraft(
        periodId: null,
        date: DateTime(2026, 1, 1),
        motivation: '',
        modules: {},
        sponsorName: '',
        sponsorPhone: '',
        completed: false,
        baseline: const {},
      );
      final controller = OnboardingController(
        store,
        () => DateTime(2026, 1, 1),
      );
      await controller.load();
      controller.setMotivation('Megőrzendő');
      expect(await controller.flushDraft(), isFalse);
      expect(controller.draft!.motivation, 'Megőrzendő');
      store.failDraft = false;
      expect(await controller.flushDraft(), isTrue);
      expect(store.writes.last, 'Megőrzendő');
      controller.dispose();
    },
  );
  test('failed finalization keeps the draft for retry', () async {
    final store = RetryStore();
    store.current = OnboardingDraft(
      periodId: null,
      date: DateTime(2026, 1, 1),
      motivation: 'Érték',
      modules: {},
      sponsorName: '',
      sponsorPhone: '',
      completed: false,
      baseline: const {},
    );
    store.gate.complete();
    final controller = OnboardingController(store, () => DateTime(2026, 1, 1));
    await controller.load();
    expect(await controller.finish(), isFalse);
    expect(controller.draft!.motivation, 'Érték');
    expect(store.finished, 0);
    store.fail = false;
    expect(await controller.finish(), isTrue);
    expect(store.finished, 1);
    controller.dispose();
  });
  test(
    'sponsor selection requires a name without partially finalizing',
    () async {
      final store = DelayedStore();
      store.current = OnboardingDraft(
        periodId: null,
        date: DateTime(2026, 1, 1),
        motivation: '',
        modules: {OnboardingModule.sponsor},
        sponsorName: '',
        sponsorPhone: '',
        sponsorChoice: 0,
        completed: false,
        baseline: const {},
      );
      store.gate.complete();
      final controller = OnboardingController(
        store,
        () => DateTime(2026, 1, 1),
      );
      await controller.load();
      expect(await controller.finish(), isFalse);
      expect(store.finished, 0);
      expect(controller.error, isA<ArgumentError>());
      controller.dispose();
    },
  );
  test(
    'skipping motivation restores the saved value instead of clearing it',
    () async {
      final store = DelayedStore();
      store.current = OnboardingDraft(
        periodId: 1,
        date: DateTime(2026, 1, 1),
        motivation: 'Régi',
        modules: {},
        sponsorName: '',
        sponsorPhone: '',
        completed: true,
        baseline: const {'motivation': 'Régi'},
      );
      final controller = OnboardingController(
        store,
        () => DateTime(2026, 1, 1),
      );
      await controller.load();
      controller.setMotivation('');
      controller.skipMotivation();
      expect(controller.draft!.motivation, 'Régi');
      expect(controller.draft!.dirty, isNot(contains('motivation')));
      store.gate.complete();
      await controller.idle;
      controller.dispose();
    },
  );
  test(
    'pending draft writes finish in order before one finalization',
    () async {
      final store = DelayedStore();
      store.current = OnboardingDraft(
        periodId: null,
        date: DateTime(2026, 1, 1),
        motivation: '',
        modules: {},
        sponsorName: '',
        sponsorPhone: '',
        completed: false,
        baseline: const {},
      );
      final controller = OnboardingController(
        store,
        () => DateTime(2026, 1, 1),
      );
      await controller.load();
      controller.setMotivation('első');
      controller.setMotivation('második');
      final finish = controller.finish();
      expect(await controller.finish(), isFalse);
      expect(store.finished, 0);
      store.gate.complete();
      expect(await finish, isTrue);
      expect(store.writes, ['', 'első', 'második']);
      expect(store.finished, 1);
      controller.dispose();
    },
  );
}
