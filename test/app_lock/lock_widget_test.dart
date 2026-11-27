import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/core/brand/fingerprint_icon.dart';
import 'package:hajnal/core/brand/security_icons.dart';
import 'package:hajnal/features/app_lock/application/lock_controller.dart';
import 'package:hajnal/features/app_lock/domain/lock_mode.dart';
import 'package:hajnal/features/app_lock/presentation/lock_gate.dart';
import 'package:hajnal/features/app_lock/presentation/lock_auth_page.dart';
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
  testWidgets('PIN reference geometry keeps the keyboard and action visible', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(412, 892);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(412, 892),
            padding: EdgeInsets.only(top: 24, bottom: 48),
          ),
          child: PinSetup(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.widget<Chip>(find.byType(Chip)).shape, isA<StadiumBorder>());
    final header = tester.getRect(find.text('PIN beállítása'));
    final lock = tester.getRect(find.byType(HajnalLockIcon));
    final firstKey = tester.getRect(find.widgetWithText(OutlinedButton, '1'));
    expect(header.top, inInclusiveRange(40, 60));
    expect(lock.top, inInclusiveRange(105, 145));
    expect(header.bottom, lessThan(lock.top));
    expect(lock.bottom, lessThan(firstKey.top));
    await tester.ensureVisible(find.text('A következő lépésben ismételd meg.'));
    await tester.pumpAndSettle();
    final action = tester.getRect(find.widgetWithText(FilledButton, 'Tovább'));
    final footer = tester.getRect(
      find.text('A következő lépésben ismételd meg.'),
    );
    expect(action.bottom, lessThan(footer.top));
    expect(footer.bottom, lessThanOrEqualTo(844));
    expect(tester.takeException(), isNull);
  });

  testWidgets('PIN lock paints a visible keyhole', (tester) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: RepaintBoundary(key: key, child: const HajnalLockIcon()),
        ),
      ),
    );
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = (await tester.runAsync(() => boundary.toImage()))!;
    final pixels = (await tester.runAsync(
      () => image.toByteData(format: ui.ImageByteFormat.rawRgba),
    ))!;
    int alpha(int x, int y) => pixels.getUint8((y * image.width + x) * 4 + 3);
    expect(alpha(27, 35), greaterThan(200));
    expect(alpha(27, 42), greaterThan(200));
    expect(alpha(18, 35), 0);
    image.dispose();
  });

  testWidgets('biometric screen remains scrollable with enlarged text', (
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
    await controller.submitPin('001234');
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.6)),
          child: LockAuthPage(controller: controller),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Azonosítás indítása'));
    expect(tester.takeException(), isNull);
    expect(find.byType(HajnalFingerprint), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });

  testWidgets('reference sized settings and PIN retain their controls', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(412, 892);
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
      MaterialApp(home: LockSettingsPage(controller: controller)),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('PIN módosítása'), 100);
    expect(find.byType(HajnalKeyIcon), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Az azonosítás a készülékeden történik.'),
      100,
    );
    expect(
      tester
          .getBottomLeft(find.text('Az azonosítás a készülékeden történik.'))
          .dy,
      lessThanOrEqualTo(892),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute<void>(builder: (_) => const PinSetup())),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(HajnalLockIcon), findsOneWidget);
    expect(find.byTooltip('Back'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Válassz PIN-kódot')).dy,
      lessThan(tester.getTopLeft(find.text('1')).dy),
    );
    expect(
      tester.getBottomLeft(find.text('A következő lépésben ismételd meg.')).dy,
      lessThanOrEqualTo(892),
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });

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
