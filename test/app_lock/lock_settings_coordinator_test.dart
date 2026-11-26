import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/features/app_lock/application/biometrics.dart';
import 'package:hajnal/features/app_lock/application/lock_controller.dart';
import 'package:hajnal/features/app_lock/application/lock_settings_coordinator.dart';
import 'package:hajnal/features/app_lock/domain/lock_mode.dart';
import 'lock_controller_test.dart' as fakes;

void main() {
  test('cancel and unavailable biometric never change settings', () async {
    final store = fakes.Store(LockMode.off);
    final finger = fakes.Finger()..available = BiometricResult.notEnrolled;
    final controller = LockController(store, finger, fakes.Device());
    await controller.initialize();
    final flow = LockSettingsCoordinator(controller);
    expect(
      await flow.change(
        LockMode.pinAndBiometric,
        changePin: false,
        authenticate: () async => true,
        choosePin: () async => '001234',
        confirmCombined: () async => true,
      ),
      SettingsResult.unavailable,
    );
    expect(
      await flow.change(
        LockMode.pin,
        changePin: false,
        authenticate: () async => true,
        choosePin: () async => null,
        confirmCombined: () async => true,
      ),
      SettingsResult.cancelled,
    );
    expect(store.mode, LockMode.off);
    controller.dispose();
  });
  test(
    'combined activation requires warning and successful biometric',
    () async {
      final store = fakes.Store(LockMode.off);
      final controller = LockController(store, fakes.Finger(), fakes.Device());
      await controller.initialize();
      final flow = LockSettingsCoordinator(controller);
      Future<SettingsResult> attempt(bool confirm) => flow.change(
        LockMode.pinAndBiometric,
        changePin: false,
        authenticate: () async => true,
        choosePin: () async => '001234',
        confirmCombined: () async => confirm,
      );
      expect(await attempt(false), SettingsResult.cancelled);
      expect(store.mode, LockMode.off);
      expect(await attempt(true), SettingsResult.saved);
      expect(store.mode, LockMode.pinAndBiometric);
      controller.dispose();
    },
  );
}
