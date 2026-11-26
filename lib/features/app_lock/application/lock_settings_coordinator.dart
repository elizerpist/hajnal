import '../domain/lock_mode.dart';
import 'biometrics.dart';
import 'lock_controller.dart';

enum SettingsResult { saved, unchanged, unavailable, cancelled, failed }

class LockSettingsCoordinator {
  const LockSettingsCoordinator(this.controller);
  final LockController controller;

  Future<SettingsResult> change(
    LockMode target, {
    required bool changePin,
    required Future<bool> Function() authenticate,
    required Future<String?> Function() choosePin,
    required Future<bool> Function() confirmCombined,
  }) async {
    final c = controller;
    if (!changePin && target == c.mode) return SettingsResult.unchanged;
    final biometric =
        target == LockMode.biometricOrPin || target == LockMode.pinAndBiometric;
    if (!changePin &&
        biometric &&
        await c.availability() != BiometricResult.success) {
      return SettingsResult.unavailable;
    }
    if (c.mode != LockMode.off) {
      c.beginReauthentication();
      if (!await authenticate() || !c.reauthenticated) {
        c.cancelReauthentication();
        return SettingsResult.cancelled;
      }
    }
    String? pin;
    if (changePin || (c.mode == LockMode.off && target != LockMode.off)) {
      pin = await choosePin();
      if (pin == null) {
        c.cancelReauthentication();
        return SettingsResult.cancelled;
      }
    }
    if (!changePin && biometric && target != c.mode) {
      if (target == LockMode.pinAndBiometric && !await confirmCombined()) {
        c.cancelReauthentication();
        return SettingsResult.cancelled;
      }
      if (!await c.submitBiometric(setup: true)) {
        c.cancelReauthentication();
        return SettingsResult.failed;
      }
    }
    if (!await c.changeMode(target, newPin: pin)) {
      c.cancelReauthentication();
      return SettingsResult.failed;
    }
    return SettingsResult.saved;
  }
}
