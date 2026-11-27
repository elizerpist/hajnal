import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/app/bootstrap_controller.dart';
import 'package:hajnal/core/artwork/artwork_view.dart';
import 'package:hajnal/core/artwork/artwork_source.dart';
import 'package:hajnal/app/hajnal_app.dart';
import 'package:hajnal/features/onboarding/application/date_picker.dart';
import 'package:hajnal/features/recovery/application/recovery_store.dart';
import '../widget_test.dart' as app_fakes;

class Store implements RecoveryStore {
  final stream = StreamController<ActiveRecovery?>.broadcast();
  @override
  Stream<ActiveRecovery?> watchStart() => stream.stream;
  @override
  Future<void> correctStart(int id, DateTime date, DateTime now) async {
    if (id != 1) throw StateError("stale");
    stream.add(ActiveRecovery(id, date));
  }

  @override
  Future<void> initialize(DateTime date, DateTime now) async =>
      stream.add(ActiveRecovery(1, date));
}

class TrackingArtwork extends ChangeNotifier implements ArtworkSource {
  int loads = 0;
  final retained = <File>{};
  @override
  void retain(File file) => retained.add(file);
  @override
  Future<void> release(File file) async => retained.remove(file);
  @override
  Future<ArtworkDescriptor> resolve(String role) async {
    loads++;
    return const ArtworkDescriptor(revision: 'test');
  }
}

class Picker implements DatePicker {
  @override
  Future<DatePickerResult> pick(DateTime initial, DateTime today) async =>
      const DatePickCancelled();
}

void main() {
  for (final size in [
    const Size(412, 892),
    const Size(390, 844),
    const Size(360, 800),
    const Size(220, 320),
  ]) {
    testWidgets(
      'dashboard fits $size with large text and supports drag and back',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final store = Store();
        final controller = BootstrapController(
          store,
          () => DateTime(2024, 4, 1),
        );
        await tester.pumpWidget(
          MediaQuery(
            data: MediaQueryData(
              size: size,
              textScaler: const TextScaler.linear(1.5),
            ),
            child: HajnalApp(controller: controller, picker: Picker()),
          ),
        );
        store.stream.add(ActiveRecovery(1, DateTime(2024, 4, 1)));
        await tester.pumpAndSettle();
        final card = find.byKey(const Key('summary-card'));
        expect(card, findsOneWidget);

        final closed = tester.getTopLeft(card).dy;
        await tester.drag(card, const Offset(0, -90));
        await tester.pumpAndSettle();
        expect(tester.getTopLeft(card).dy, lessThan(closed));
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(tester.getTopLeft(card).dy, closeTo(closed, .1));

        await tester.pumpWidget(const SizedBox());
        controller.dispose();
        await store.stream.close();
      },
    );
  }
  testWidgets('cancelled drag settles and subsequent tap works', (
    tester,
  ) async {
    final store = Store();
    final controller = BootstrapController(store, () => DateTime(2024, 4, 1));
    await tester.pumpWidget(
      HajnalApp(controller: controller, picker: Picker()),
    );
    store.stream.add(ActiveRecovery(1, DateTime(2024, 4, 1)));
    await tester.pumpAndSettle();
    final card = find.byKey(const Key('summary-card'));
    final closed = tester.getTopLeft(card).dy;
    final gesture = await tester.startGesture(tester.getCenter(card));
    await gesture.moveBy(const Offset(0, -20));
    await tester.pump();
    await gesture.moveBy(const Offset(0, -70));
    await tester.pump();
    await gesture.cancel();
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(card).dy, lessThan(closed - 80));
    await tester.tap(card);
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(card).dy, closeTo(closed, .1));
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
    await store.stream.close();
  });
  testWidgets('semantic action opens the panel with reduced motion', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final semantics = tester.ensureSemantics();
    final store = Store();
    final controller = BootstrapController(store, () => DateTime(2024, 4, 1));
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: HajnalApp(controller: controller, picker: Picker()),
      ),
    );
    store.stream.add(ActiveRecovery(1, DateTime(2024, 4, 1)));
    await tester.pumpAndSettle();
    final card = find.byKey(const Key('summary-card'));
    final initial = tester.getTopLeft(card).dy;
    final node = tester.getSemantics(
      find.bySemanticsLabel(RegExp('Napi összegzés')),
    );
    node.owner!.performAction(node.id, SemanticsAction.tap);
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(card).dy, lessThan(initial));
    await tester.pumpWidget(const SizedBox());
    semantics.dispose();
    controller.dispose();
    await store.stream.close();
  });
  testWidgets('onboarding starts without overflow on a small screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = app_fakes.MemoryStore();
    final controller = BootstrapController(store, () => DateTime(2024, 4, 1));
    final onboarding = app_fakes.MemoryOnboarding(controller, store);
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
        child: HajnalApp(
          controller: controller,
          picker: Picker(),
          onboardingStore: onboarding,
        ),
      ),
    );
    store.stream.add(null);
    await tester.pumpAndSettle();
    expect(find.text('Kezdjük el'), findsOneWidget);
    await tester.ensureVisible(find.text('Kezdjük el'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kezdjük el'));
    await tester.pumpAndSettle();
    expect(find.text('Üdv a Hajnalban!'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
    await store.stream.close();
  });
  testWidgets('panel fades in 180ms while card still moves for 300ms', (
    tester,
  ) async {
    final store = Store();
    final controller = BootstrapController(store, () => DateTime(2024, 4, 1));
    await tester.pumpWidget(
      HajnalApp(controller: controller, picker: Picker()),
    );
    store.stream.add(ActiveRecovery(1, DateTime(2024, 4, 1)));
    await tester.pumpAndSettle();
    final card = find.byKey(const Key('summary-card'));
    final start = tester.getTopLeft(card).dy;
    await tester.tap(card);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 180));
    expect(
      tester.widget<Opacity>(find.byKey(const Key('sheet-opacity'))).opacity,
      1,
    );
    final mid = tester.getTopLeft(card).dy;
    expect(mid, lessThan(start));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(card).dy, lessThan(mid));
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
    await store.stream.close();
  });
  testWidgets('card and panel share position progress during drag', (
    tester,
  ) async {
    final store = Store();
    final controller = BootstrapController(store, () => DateTime(2024, 4, 1));
    await tester.pumpWidget(
      HajnalApp(controller: controller, picker: Picker()),
    );
    store.stream.add(ActiveRecovery(1, DateTime(2024, 4, 1)));
    await tester.pumpAndSettle();
    final card = find.byKey(const Key('summary-card'));
    final sheet = find.byKey(const Key('empty-sheet'));
    final initialCard = tester.getTopLeft(card).dy;
    final initialSheet = tester.getTopLeft(sheet).dy;
    final gesture = await tester.startGesture(tester.getCenter(card));
    await gesture.moveBy(const Offset(0, -20));
    await tester.pump();
    await gesture.moveBy(const Offset(0, -40));
    await tester.pump();
    expect(
      initialCard - tester.getTopLeft(card).dy,
      closeTo(initialSheet - tester.getTopLeft(sheet).dy, .01),
    );
    await gesture.cancel();
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
    await store.stream.close();
  });
  testWidgets('sheet animation keeps the static dashboard and artwork intact', (
    tester,
  ) async {
    final store = Store();
    final controller = BootstrapController(store, () => DateTime(2024, 4, 1));
    final source = TrackingArtwork();
    await tester.pumpWidget(
      HajnalApp(controller: controller, picker: Picker(), artwork: source),
    );
    store.stream.add(ActiveRecovery(1, DateTime(2024, 4, 1)));
    await tester.pumpAndSettle();
    final initialLoads = source.loads;
    final artwork = tester.widget(find.byType(ArtworkView));
    final scaffold = tester.widget(find.byType(Scaffold).first);
    await tester.tap(find.byKey(const Key('summary-card')));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 30));
      expect(source.loads, initialLoads);
      expect(tester.widget(find.byType(ArtworkView)), same(artwork));
      expect(tester.widget(find.byType(Scaffold).first), same(scaffold));
    }
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
    source.dispose();
    await store.stream.close();
  });
  testWidgets('back interrupts opening animation and returns to closed state', (
    tester,
  ) async {
    final store = Store();
    final controller = BootstrapController(store, () => DateTime(2024, 4, 1));
    await tester.pumpWidget(
      HajnalApp(controller: controller, picker: Picker()),
    );
    store.stream.add(ActiveRecovery(1, DateTime(2024, 4, 1)));
    await tester.pumpAndSettle();
    final card = find.byKey(const Key('summary-card'));
    final closed = tester.getTopLeft(card).dy;
    await tester.tap(card);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    expect(tester.getTopLeft(card).dy, lessThan(closed));
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(card).dy, closeTo(closed, .1));
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
    await store.stream.close();
  });

  testWidgets('large text and bottom system inset keep the card visible', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(220, 320);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 24, bottom: 48);
    tester.platformDispatcher.textScaleFactorTestValue = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final store = Store();
    final controller = BootstrapController(store, () => DateTime(2024, 4, 1));
    await tester.pumpWidget(
      HajnalApp(controller: controller, picker: Picker()),
    );
    store.stream.add(ActiveRecovery(1, DateTime(2024, 4, 1)));
    await tester.pumpAndSettle();
    final card = find.byKey(const Key('summary-card'));
    expect(tester.getTopLeft(card).dy, greaterThanOrEqualTo(24));
    expect(tester.getBottomRight(card).dy, lessThanOrEqualTo(272));
    final closed = tester.getTopLeft(card).dy;
    await tester.drag(card, const Offset(0, -80));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(card).dy, lessThan(closed));
    expect(tester.getTopLeft(card).dy, greaterThanOrEqualTo(24));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
    await store.stream.close();
  });
}
