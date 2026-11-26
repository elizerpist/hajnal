import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/app/bootstrap_controller.dart';
import 'package:hajnal/app/hajnal_app.dart';
import 'package:hajnal/core/platform/date_picker.dart';
import 'package:hajnal/features/recovery/application/recovery_store.dart';

class Store implements RecoveryStore {
  final stream = StreamController<DateTime?>.broadcast();
  @override
  Stream<DateTime?> watchStart() => stream.stream;
  @override
  Future<void> initialize(DateTime date, DateTime now) async =>
      stream.add(date);
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
        store.stream.add(DateTime(2024, 4, 1));
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
}
