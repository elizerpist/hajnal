import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/app/hajnal_app.dart';
import 'package:hajnal/app/bootstrap_controller.dart';
import 'package:hajnal/core/platform/date_picker.dart';
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
}
