import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/core/brand/fingerprint_icon.dart';
import 'package:hajnal/features/app_lock/application/lock_controller.dart';
import 'package:hajnal/features/app_lock/domain/lock_mode.dart';
import 'package:hajnal/features/app_lock/presentation/lock_gate.dart';
import 'package:hajnal/features/app_lock/presentation/lock_settings.dart';
import 'package:hajnal/features/app_lock/presentation/pin_pad.dart';
import 'package:hajnal/features/app_lock/presentation/pin_setup.dart';
import 'lock_controller_test.dart' as fakes;

Future<void> enter(WidgetTester tester, String pin) async {
  for (final digit in pin.split('')) {
    await tester.tap(find.text(digit));
    await tester.pump();
  }
}

void main() {
  testWidgets('settings remain accessible on a narrow screen with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = LockController(
      fakes.Store(LockMode.pinAndBiometric),
      fakes.Finger(),
      fakes.Device(),
    );
    await controller.initialize();
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.6)),
          child: LockSettingsPage(controller: controller),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(find.text('PIN és biometria'), 200);
    expect(find.text('PIN és biometria'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });

  testWidgets('PIN screen supports small viewport and large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.6)),
          child: PinPad(
            title: 'Válassz PIN-kódot',
            subtitle: 'Legalább 6 számjegyet adj meg.',
            button: 'Tovább',
            onSubmit: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.widgetWithText(OutlinedButton, '1')).height,
      greaterThanOrEqualTo(48),
    );
  });
  testWidgets('PIN requires explicit submission and keeps a leading zero', (
    tester,
  ) async {
    String? submitted;
    await tester.pumpWidget(
      MaterialApp(
        home: PinPad(
          title: 'PIN',
          subtitle: '',
          button: 'Tovább',
          onSubmit: (pin) => submitted = pin,
        ),
      ),
    );
    await enter(tester, '001234');
    expect(submitted, isNull);
    await tester.ensureVisible(find.text('Tovább'));
    await tester.tap(find.text('Tovább'));
    expect(submitted, '001234');
  });

  testWidgets('confirmation mismatch does not return a PIN', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PinSetup()));
    await enter(tester, '001234');
    await tester.ensureVisible(find.text('Tovább'));
    await tester.tap(find.text('Tovább'));
    await tester.pump();
    await enter(tester, '999999');
    await tester.ensureVisible(find.text('Tovább'));
    await tester.tap(find.text('Tovább'));
    await tester.pump();
    expect(
      find.text('A két PIN-kód nem egyezik. Próbáld újra.'),
      findsOneWidget,
    );
    expect(find.text('Válassz PIN-kódot'), findsOneWidget);
  });

  testWidgets('lock gate hides personal content and rejects one factor', (
    tester,
  ) async {
    final controller = LockController(
      fakes.Store(LockMode.pinAndBiometric),
      fakes.Finger(),
      fakes.Device(),
    );
    await controller.initialize();
    await tester.pumpWidget(
      MaterialApp(
        home: LockGate(
          controller: controller,
          child: const Scaffold(body: Text('Személyes adat')),
        ),
      ),
    );
    expect(find.text('Személyes adat'), findsNothing);
    await enter(tester, '001234');
    await tester.ensureVisible(find.text('Feloldás'));
    await tester.tap(find.text('Feloldás'));
    await tester.pumpAndSettle();
    expect(find.text('Személyes adat'), findsNothing);
    expect(find.text('Azonosítás indítása'), findsOneWidget);
    expect(find.byType(HajnalFingerprint), findsOneWidget);
    await tester.tap(find.text('Azonosítás indítása'));
    await tester.pumpAndSettle();
    expect(find.text('Személyes adat'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });
}
