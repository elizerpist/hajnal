import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hajnal/app/bootstrap_controller.dart';
import 'package:hajnal/app/hajnal_app.dart';
import 'package:hajnal/features/onboarding/application/date_picker.dart';
import 'package:hajnal/features/recovery/application/recovery_store.dart';
import 'package:hajnal/features/app_lock/application/biometrics.dart';
import 'package:hajnal/features/app_lock/application/device_guard.dart';
import 'package:hajnal/features/app_lock/application/lock_controller.dart';
import 'package:hajnal/features/app_lock/application/lock_store.dart';
import 'package:hajnal/features/app_lock/domain/lock_policy.dart';
import 'package:hajnal/features/app_lock/presentation/pin_setup.dart';

// Visual evidence uses the real widgets and session rules; simulated platform
// responses make the biometric state reproducible without claiming hardware coverage.
class VisualStore implements LockStore {
  @override
  Future<StoredLock> read() async => const StoredLock(
    mode: LockMode.pinAndBiometric,
    slot: 'visual',
    retry: RetryState(),
  );
  @override
  Future<int> retryRemaining({
    required int uptime,
    required String boot,
  }) async => 0;
  @override
  Future<bool> verifyPin(
    String pin, {
    required int uptime,
    required String boot,
  }) async => pin == '123456';
  @override
  Future<void> setMode(LockMode mode, {String? newPin}) async =>
      throw UnsupportedError('visual evidence only');
}

class VisualBiometrics implements Biometrics {
  @override
  Future<BiometricResult> availability() async => BiometricResult.success;
  @override
  Future<BiometricResult> authenticate() async => BiometricResult.success;
  @override
  Future<void> cancel() async {}
}

class VisualDevice implements DeviceGuard {
  @override
  Future<DeviceTime> time() async => const DeviceTime(1, 'visual');
  @override
  Future<void> revealAfterFrame() async {}
}

class VisualRecovery implements RecoveryStore {
  @override
  Stream<ActiveRecovery?> watchStart() =>
      Stream.value(ActiveRecovery(1, DateTime(2024, 1, 1)));
  @override
  Future<void> correctStart(int id, DateTime date, DateTime now) async =>
      throw UnsupportedError('visual evidence only');
  @override
  Future<void> initialize(DateTime date, DateTime now) async =>
      throw UnsupportedError('visual evidence only');
}

class VisualPicker implements DatePicker {
  @override
  Future<DatePickerResult> pick(DateTime initial, DateTime today) async =>
      const DatePickCancelled();
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('capture real lock screens with simulated platform responses', (
    tester,
  ) async {
    final controller = LockController(
      VisualStore(),
      VisualBiometrics(),
      VisualDevice(),
    );
    await controller.initialize();
    final directory = await getApplicationSupportDirectory();
    await binding.convertFlutterSurfaceToImage();
    Future<void> capture(String name) async {
      await tester.pumpAndSettle();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(seconds: 1)),
      );
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 500)),
      );
      final bytes = await binding.takeScreenshot(name);
      expect(bytes, isNotEmpty);
      await File(
        '${directory.path}/$name.png',
      ).writeAsBytes(bytes, flush: true);
    }

    await controller.submitPin('123456');
    await controller.submitBiometric();
    final bootstrap = BootstrapController(VisualRecovery(), DateTime.now);
    await tester.pumpWidget(
      HajnalApp(
        controller: bootstrap,
        picker: VisualPicker(),
        lock: controller,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Menü'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Alkalmazászár'));
    await tester.pumpAndSettle();
    expect(find.text('Te döntöd el, hogyan lépsz be.'), findsOneWidget);
    await capture('lock-settings');
    final navigator = Navigator.of(
      tester.element(find.text('Alkalmazászár').last),
    );
    unawaited(
      navigator.push<void>(MaterialPageRoute(builder: (_) => const PinSetup())),
    );
    await tester.pumpAndSettle();
    for (final digit in '123456'.split('')) {
      await tester.tap(find.text(digit));
      await tester.pump();
    }
    await capture('lock-pin-setup');
    controller.background();
    controller.resumed();
    await controller.submitPin('123456');
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('Jó, hogy itt vagy.'), findsOneWidget);
    await tester.runAsync(() => vg.waitForPendingDecodes());
    await tester.pumpAndSettle();
    await capture('lock-biometric-step');
    await File(
      '${directory.path}/lock-visual-ready',
    ).writeAsString('ready', flush: true);
    await tester.runAsync(() async {
      final copied = File('${directory.path}/lock-visual-copied');
      final deadline = DateTime.now().add(const Duration(minutes: 5));
      while (!await copied.exists()) {
        if (DateTime.now().isAfter(deadline)) {
          throw TimeoutException('Screenshots were not collected');
        }
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }
    });
    await tester.pumpWidget(const SizedBox());
    bootstrap.dispose();
    controller.dispose();
  });
}
