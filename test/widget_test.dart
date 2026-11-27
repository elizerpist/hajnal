import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/app/hajnal_app.dart';
import 'package:hajnal/app/bootstrap_controller.dart';
import 'package:hajnal/features/onboarding/application/date_picker.dart';
import 'package:hajnal/features/onboarding/application/onboarding_draft.dart';
import 'package:hajnal/features/onboarding/application/onboarding_store.dart';
import 'package:hajnal/features/recovery/application/recovery_store.dart';

class MemoryStore implements RecoveryStore {
  final stream = StreamController<ActiveRecovery?>.broadcast();
  @override
  Stream<ActiveRecovery?> watchStart() => stream.stream;
  @override
  Future<void> correctStart(int id, DateTime date, DateTime now) async {
    if (id != 1) throw StateError("stale");
    stream.add(ActiveRecovery(id, date));
  }

  @override
  Future<void> initialize(DateTime date, DateTime now) async {
    stream.add(ActiveRecovery(1, date));
  }
}

class FailingStore extends MemoryStore {
  @override
  Future<void> correctStart(int id, DateTime date, DateTime now) async =>
      throw StateError('write failed');
  @override
  Future<void> initialize(DateTime date, DateTime now) async =>
      throw StateError('write failed');
}

class ChangedPeriodStore extends MemoryStore {
  int activeId = 1;
  int? attemptedId;
  @override
  Future<void> correctStart(int id, DateTime date, DateTime now) async {
    attemptedId = id;
    if (id != activeId) throw StateError('period changed');
    await super.correctStart(id, date, now);
  }
}

class FakePicker implements DatePicker {
  DateTime? initialDate;
  @override
  Future<DatePickerResult> pick(DateTime initial, DateTime today) async {
    initialDate = initial;
    return DatePicked(DateTime(2024, 3, 31));
  }
}

class CancelPicker implements DatePicker {
  @override
  Future<DatePickerResult> pick(DateTime initial, DateTime today) async =>
      const DatePickCancelled();
}

class MemoryOnboarding implements OnboardingStore {
  MemoryOnboarding(this.bootstrap, this.recovery);
  final BootstrapController bootstrap;
  final MemoryStore recovery;
  OnboardingDraft? saved;
  @override
  Future<OnboardingDraft> load(DateTime now) async {
    if (saved != null) return saved!;
    final period = bootstrap.activePeriod;
    return OnboardingDraft(
      periodId: period?.id,
      date: period?.startDate ?? DateTime(now.year, now.month, now.day),
      motivation: '',
      modules: {},
      sponsorName: '',
      sponsorPhone: '',
      completed: period != null,
      baseline: const {},
    );
  }

  @override
  Future<void> saveDraft(OnboardingDraft draft) async {
    saved = draft;
  }

  @override
  Future<void> finish(OnboardingDraft draft, DateTime now) async {
    if (draft.periodId == null) {
      await recovery.initialize(draft.date, now);
    } else {
      await recovery.correctStart(draft.periodId!, draft.date, now);
    }
    saved = null;
  }
}

Future<void> toDate(WidgetTester tester, {bool existing = false}) async {
  await tester.tap(
    find.text(existing ? 'Beállítások áttekintése' : 'Kezdjük el'),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Tovább'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Értem, tovább'));
  await tester.pumpAndSettle();
}

Future<void> toFinish(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Tovább'));
  await tester.tap(find.text('Tovább'));
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text('Később írom meg'));
  await tester.tap(find.text('Később írom meg'));
  await tester.pumpAndSettle();
}

Future<void> openOnboarding(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Menü'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Onboarding'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'onboarding saves and dashboard panel opens without demo features',
    (tester) async {
      final store = MemoryStore();
      final controller = BootstrapController(store, () => DateTime(2024, 4, 1));
      final onboarding = MemoryOnboarding(controller, store);
      await tester.pumpWidget(
        HajnalApp(
          controller: controller,
          picker: FakePicker(),
          onboardingStore: onboarding,
        ),
      );
      store.stream.add(null);
      await tester.pumpAndSettle();
      await toDate(tester);
      tester
          .widget<CalendarDatePicker>(find.byType(CalendarDatePicker))
          .onDateChanged(DateTime(2024, 3, 31));
      await tester.pumpAndSettle();
      await toFinish(tester);
      await tester.ensureVisible(find.text('Mentés és indulás'));
      await tester.tap(find.text('Mentés és indulás'));
      await tester.pumpAndSettle();
      expect(find.text('Tiszta napok'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsNothing);
      await tester.tap(find.byKey(const Key('summary-card')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('empty-sheet')), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
      await store.stream.close();
    },
  );

  testWidgets(
    'leaving onboarding without save shows empty counter and can reopen it',
    (tester) async {
      final store = MemoryStore();
      final controller = BootstrapController(store, DateTime.now);
      final onboarding = MemoryOnboarding(controller, store);
      await tester.pumpWidget(
        HajnalApp(
          controller: controller,
          picker: FakePicker(),
          onboardingStore: onboarding,
        ),
      );
      store.stream.add(null);
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('—'), findsOneWidget);
      await openOnboarding(tester);
      expect(find.text('Jó, hogy itt vagy.'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
      await store.stream.close();
    },
  );

  testWidgets('saved date is editable and immediately updates dashboard', (
    tester,
  ) async {
    final store = MemoryStore();
    final controller = BootstrapController(store, () => DateTime(2024, 4, 1));
    final onboarding = MemoryOnboarding(controller, store);
    await tester.pumpWidget(
      HajnalApp(
        controller: controller,
        picker: FakePicker(),
        onboardingStore: onboarding,
      ),
    );
    store.stream.add(ActiveRecovery(1, DateTime(2024, 3, 30)));
    await tester.pumpAndSettle();
    await openOnboarding(tester);
    await toDate(tester, existing: true);
    expect(
      tester
          .widget<CalendarDatePicker>(find.byType(CalendarDatePicker))
          .initialDate,
      DateTime(2024, 3, 30),
    );
    tester
        .widget<CalendarDatePicker>(find.byType(CalendarDatePicker))
        .onDateChanged(DateTime(2024, 3, 31));
    expect(controller.startDate, DateTime(2024, 3, 30));
    await tester.pumpAndSettle();
    await toFinish(tester);
    await tester.ensureVisible(find.text('Módosítások mentése'));
    await tester.tap(find.text('Módosítások mentése'));
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
    await store.stream.close();
  });

  testWidgets('failed save remains on onboarding', (tester) async {
    final store = FailingStore();
    final controller = BootstrapController(store, DateTime.now);
    final onboarding = MemoryOnboarding(controller, store);
    await tester.pumpWidget(
      HajnalApp(
        controller: controller,
        picker: FakePicker(),
        onboardingStore: onboarding,
      ),
    );
    store.stream.add(null);
    await tester.pumpAndSettle();
    await toDate(tester);
    await toFinish(tester);
    await tester.ensureVisible(find.text('Mentés és indulás'));
    await tester.tap(find.text('Mentés és indulás'));
    await tester.pumpAndSettle();
    expect(find.text('A mentés nem sikerült. Próbáld újra.'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
    await store.stream.close();
  });

  testWidgets('back and close preserve the saved date', (tester) async {
    final store = MemoryStore();
    final controller = BootstrapController(store, () => DateTime(2024, 4, 1));
    final onboarding = MemoryOnboarding(controller, store);
    await tester.pumpWidget(
      HajnalApp(
        controller: controller,
        picker: FakePicker(),
        onboardingStore: onboarding,
      ),
    );
    store.stream.add(ActiveRecovery(1, DateTime(2024, 3, 30)));
    await tester.pumpAndSettle();
    await openOnboarding(tester);
    await toDate(tester, existing: true);
    tester
        .widget<CalendarDatePicker>(find.byType(CalendarDatePicker))
        .onDateChanged(DateTime(2024, 3, 31));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Bezárás'));
    await tester.pumpAndSettle();
    expect(controller.startDate, DateTime(2024, 3, 30));
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
    await store.stream.close();
  });

  testWidgets('correction failure leaves onboarding open', (tester) async {
    final store = FailingStore();
    final controller = BootstrapController(store, () => DateTime(2024, 4, 1));
    final onboarding = MemoryOnboarding(controller, store);
    await tester.pumpWidget(
      HajnalApp(
        controller: controller,
        picker: FakePicker(),
        onboardingStore: onboarding,
      ),
    );
    store.stream.add(ActiveRecovery(1, DateTime(2024, 3, 30)));
    await tester.pumpAndSettle();
    await openOnboarding(tester);
    await toDate(tester, existing: true);
    await toFinish(tester);
    await tester.ensureVisible(find.text('Módosítások mentése'));
    await tester.tap(find.text('Módosítások mentése'));
    await tester.pumpAndSettle();
    expect(find.text('A mentés nem sikerült. Próbáld újra.'), findsOneWidget);
    expect(controller.startDate, DateTime(2024, 3, 30));
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
    await store.stream.close();
  });

  testWidgets('an open edit retains its original period identity', (
    tester,
  ) async {
    final store = ChangedPeriodStore();
    final controller = BootstrapController(store, () => DateTime(2024, 4, 1));
    final onboarding = MemoryOnboarding(controller, store);
    await tester.pumpWidget(
      HajnalApp(
        controller: controller,
        picker: FakePicker(),
        onboardingStore: onboarding,
      ),
    );
    store.stream.add(ActiveRecovery(1, DateTime(2024, 3, 30)));
    await tester.pumpAndSettle();
    await openOnboarding(tester);
    await toDate(tester, existing: true);
    store.activeId = 2;
    store.stream.add(ActiveRecovery(2, DateTime(2024, 3, 29)));
    await tester.pumpAndSettle();
    await toFinish(tester);
    await tester.ensureVisible(find.text('Módosítások mentése'));
    await tester.tap(find.text('Módosítások mentése'));
    await tester.pumpAndSettle();
    expect(store.attemptedId, 1);
    expect(controller.startDate, DateTime(2024, 3, 29));
    expect(find.text('A mentés nem sikerült. Próbáld újra.'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
    await store.stream.close();
  });
  testWidgets('back closes the open menu before the expanded panel', (
    tester,
  ) async {
    final store = MemoryStore();
    final controller = BootstrapController(store, () => DateTime(2024, 4, 1));
    await tester.pumpWidget(
      HajnalApp(controller: controller, picker: FakePicker()),
    );
    store.stream.add(ActiveRecovery(1, DateTime(2024, 4, 1)));
    await tester.pumpAndSettle();
    final card = find.byKey(const Key('summary-card'));
    final initial = tester.getTopLeft(card).dy;
    await tester.tap(card);
    await tester.pumpAndSettle();
    final expanded = tester.getTopLeft(card).dy;
    expect(expanded, lessThan(initial));
    await tester.tap(find.byTooltip('Menü'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Onboarding'), findsNothing);
    expect(tester.getTopLeft(card).dy, closeTo(expanded, .1));
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(card).dy, closeTo(initial, .1));
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
    await store.stream.close();
  });
  testWidgets('storage error shows retry instead of onboarding', (
    tester,
  ) async {
    final store = MemoryStore();
    final controller = BootstrapController(store, DateTime.now);
    var retries = 0;
    await tester.pumpWidget(
      HajnalApp(
        controller: controller,
        picker: FakePicker(),
        onRetry: () => retries++,
      ),
    );
    store.stream.addError(StateError('unreadable database'));
    await tester.pumpAndSettle();
    expect(find.text('Az adatok nem tölthetők be.'), findsOneWidget);
    expect(find.text('Kezdődátum'), findsNothing);
    await tester.tap(find.text('Újrapróbálás'));
    expect(retries, 1);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
    await store.stream.close();
  });
  testWidgets('lifecycle resume updates the visible day count', (tester) async {
    final store = MemoryStore();
    var now = DateTime(2024, 3, 31, 12);
    final controller = BootstrapController(store, () => now);
    await tester.pumpWidget(
      HajnalApp(controller: controller, picker: FakePicker()),
    );
    store.stream.add(ActiveRecovery(1, DateTime(2024, 3, 30)));
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    now = DateTime(2024, 4, 2, 12);
    expect(controller.tracker.days, 1);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(find.text('3'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
    await store.stream.close();
  });
  testWidgets('tapping the scrim closes the menu', (tester) async {
    final store = MemoryStore();
    final controller = BootstrapController(store, DateTime.now);
    await tester.pumpWidget(
      HajnalApp(controller: controller, picker: FakePicker()),
    );
    store.stream.add(ActiveRecovery(1, DateTime.now()));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Menü'));
    await tester.pumpAndSettle();
    expect(find.text('Onboarding'), findsOneWidget);
    final size = tester.getSize(find.byType(Scaffold).first);
    await tester.tapAt(Offset(size.width - 10, size.height / 2));
    await tester.pumpAndSettle();
    expect(find.text('Onboarding'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
    await store.stream.close();
  });
}
