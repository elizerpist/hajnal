import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/app/hajnal_app.dart';
import 'package:hajnal/app/bootstrap_controller.dart';
import 'package:hajnal/features/onboarding/application/date_picker.dart';
import 'package:hajnal/features/recovery/application/recovery_store.dart';

class MemoryStore implements RecoveryStore {
  final stream = StreamController<DateTime?>.broadcast();
  @override
  Stream<DateTime?> watchStart() => stream.stream;
  @override
  Future<void> initialize(DateTime date, DateTime now) async {
    stream.add(date);
  }
}

class FailingStore extends MemoryStore {
  @override
  Future<void> initialize(DateTime date, DateTime now) async =>
      throw StateError('write failed');
}

class FakePicker implements DatePicker {
  @override
  Future<DatePickerResult> pick(DateTime initial, DateTime today) async =>
      DatePicked(DateTime(2024, 3, 31));
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
  testWidgets('saved date is shown locked when onboarding reopened', (
    tester,
  ) async {
    final store = MemoryStore();
    final controller = BootstrapController(store, () => DateTime(2024, 4, 1));
    await tester.pumpWidget(
      HajnalApp(controller: controller, picker: FakePicker()),
    );
    store.stream.add(DateTime(2024, 3, 31));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Menü'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Onboarding'));
    await tester.pumpAndSettle();
    expect(find.text('A mentett kezdőnap nem módosítható.'), findsOneWidget);
    expect(find.text('Mentés'), findsNothing);
    expect(find.text('Dátum kiválasztása'), findsNothing);
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
  testWidgets('back closes the open menu before the expanded panel', (
    tester,
  ) async {
    final store = MemoryStore();
    final controller = BootstrapController(store, () => DateTime(2024, 4, 1));
    await tester.pumpWidget(
      HajnalApp(controller: controller, picker: FakePicker()),
    );
    store.stream.add(DateTime(2024, 4, 1));
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
    store.stream.add(DateTime(2024, 3, 30));
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
}
