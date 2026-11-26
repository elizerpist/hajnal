import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/app/hajnal_app.dart';
import 'package:hajnal/app/bootstrap_controller.dart';
import 'package:hajnal/features/onboarding/application/date_picker.dart';
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

void main() {
  testWidgets(
    'onboarding saves and dashboard panel opens without demo features',
    (tester) async {
      final store = MemoryStore();
      final controller = BootstrapController(store, () => DateTime(2024, 4, 1));
      await tester.pumpWidget(
        HajnalApp(controller: controller, picker: FakePicker()),
      );
      store.stream.add(null);
      await tester.pumpAndSettle();
      expect(find.text('Kezdődátum'), findsOneWidget);
      await tester.tap(find.text('Dátum kiválasztása'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mentés'));
      await tester.pumpAndSettle();
      expect(find.text('Tiszta napok'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('24'), findsNothing);
      expect(find.byType(BottomNavigationBar), findsNothing);
      expect(tester.getSize(find.byTooltip('Menü')), const Size(54, 54));
      await tester.tap(find.byKey(const Key('summary-card')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('empty-sheet')), findsOneWidget);
      await tester.tap(find.byTooltip('Menü'));
      await tester.pumpAndSettle();
      expect(find.text('Onboarding'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
      await store.stream.close();
    },
  );
  testWidgets(
    'leaving onboarding without save shows empty counter and can reopen it',
    (tester) async {
      final store = MemoryStore();
      final controller = BootstrapController(store, () => DateTime(2024, 4, 1));
      await tester.pumpWidget(
        HajnalApp(controller: controller, picker: FakePicker()),
      );
      store.stream.add(null);
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('—'), findsOneWidget);
      await tester.tap(find.byTooltip('Menü'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Onboarding'));
      await tester.pumpAndSettle();
      expect(find.text('Dátum kiválasztása'), findsOneWidget);
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
    final picker = FakePicker();
    await tester.pumpWidget(HajnalApp(controller: controller, picker: picker));
    store.stream.add(ActiveRecovery(1, DateTime(2024, 3, 30)));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Menü'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Onboarding'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dátum kiválasztása'));
    await tester.pumpAndSettle();
    expect(picker.initialDate, DateTime(2024, 3, 30));
    expect(controller.startDate, DateTime(2024, 3, 30));
    await tester.tap(find.text('Mentés'));
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
    await store.stream.close();
  });
  testWidgets('failed save remains on onboarding', (tester) async {
    final store = FailingStore();
    final controller = BootstrapController(store, DateTime.now);
    await tester.pumpWidget(
      HajnalApp(controller: controller, picker: FakePicker()),
    );
    store.stream.add(null);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mentés'));
    await tester.pumpAndSettle();
    expect(find.text('A mentés nem sikerült. Próbáld újra.'), findsOneWidget);
    expect(find.text('Kezdődátum'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
    await store.stream.close();
  });
  testWidgets('cancel and back preserve the saved date', (tester) async {
    final store = MemoryStore();
    final controller = BootstrapController(store, () => DateTime(2024, 4, 1));
    await tester.pumpWidget(
      HajnalApp(controller: controller, picker: CancelPicker()),
    );
    store.stream.add(ActiveRecovery(1, DateTime(2024, 3, 30)));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Menü'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Onboarding'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dátum kiválasztása'));
    await tester.pumpAndSettle();
    expect(controller.startDate, DateTime(2024, 3, 30));
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('2'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
    await store.stream.close();
  });
  testWidgets('correction failure leaves onboarding open', (tester) async {
    final store = FailingStore();
    final controller = BootstrapController(store, () => DateTime(2024, 4, 1));
    await tester.pumpWidget(
      HajnalApp(controller: controller, picker: FakePicker()),
    );
    store.stream.add(ActiveRecovery(1, DateTime(2024, 3, 30)));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Menü'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Onboarding'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mentés'));
    await tester.pumpAndSettle();
    expect(find.text('A mentés nem sikerült. Próbáld újra.'), findsOneWidget);
    expect(find.text('Kezdődátum'), findsOneWidget);
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
    await tester.pumpWidget(
      HajnalApp(controller: controller, picker: FakePicker()),
    );
    store.stream.add(ActiveRecovery(1, DateTime(2024, 3, 30)));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Menü'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Onboarding'));
    await tester.pumpAndSettle();
    store.activeId = 2;
    store.stream.add(ActiveRecovery(2, DateTime(2024, 3, 29)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mentés'));
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
