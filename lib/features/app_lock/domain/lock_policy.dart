import 'lock_mode.dart';
export 'lock_mode.dart';

bool validPin(String value) => RegExp(r'^[0-9]{6,}$').hasMatch(value);

class UnlockSession {
  UnlockSession(this.mode) : unlocked = mode == LockMode.off;
  final LockMode mode;
  bool unlocked;
  bool _pinVerified = false;
  bool get pinVerified => _pinVerified;

  bool acceptPin(bool correct) {
    if (!correct || mode == LockMode.off) return unlocked;
    _pinVerified = true;
    if (mode != LockMode.pinAndBiometric) unlocked = true;
    return unlocked;
  }

  bool acceptBiometric(bool correct) {
    if (!correct) return unlocked;
    if (mode == LockMode.biometricOrPin ||
        (mode == LockMode.pinAndBiometric && _pinVerified)) {
      unlocked = true;
    }
    return unlocked;
  }

  void reset() {
    _pinVerified = false;
    unlocked = mode == LockMode.off;
  }
}

class RetryState {
  const RetryState({
    this.attempts = 0,
    this.deadlineUptime = 0,
    this.boot = '',
  });
  final int attempts;
  final int deadlineUptime;
  final String boot;

  int get delaySeconds {
    if (attempts < 3) return 0;
    final exponent = (attempts - 3).clamp(0, 6);
    return (5 * (1 << exponent)).clamp(0, 300);
  }

  RetryState failed({required int uptime, required String boot}) {
    final next = RetryState(attempts: attempts + 1);
    return RetryState(
      attempts: next.attempts,
      deadlineUptime: uptime + next.delaySeconds,
      boot: boot,
    );
  }

  int remaining({required int uptime, required String boot}) {
    if (delaySeconds == 0) return 0;
    if (boot != this.boot) return delaySeconds;
    return (deadlineUptime - uptime).clamp(0, delaySeconds);
  }
}
