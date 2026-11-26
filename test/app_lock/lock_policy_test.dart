import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/features/app_lock/domain/lock_policy.dart';

void main() {
  test('off, pin and biometric alternatives obey the selected policy', () {
    expect(UnlockSession(LockMode.off).unlocked, isTrue);
    final pin = UnlockSession(LockMode.pin);
    expect(pin.acceptBiometric(true), isFalse);
    expect(pin.acceptPin(false), isFalse);
    expect(pin.acceptPin(true), isTrue);
    final either = UnlockSession(LockMode.biometricOrPin);
    expect(either.acceptBiometric(false), isFalse);
    expect(either.acceptPin(true), isTrue);
    expect(
      UnlockSession(LockMode.biometricOrPin).acceptBiometric(true),
      isTrue,
    );
  });

  test('combined mode requires correct PIN first and biometric second', () {
    final both = UnlockSession(LockMode.pinAndBiometric);
    expect(both.acceptBiometric(true), isFalse);
    expect(both.acceptPin(true), isFalse);
    expect(both.acceptBiometric(false), isFalse);
    expect(both.acceptBiometric(true), isTrue);
    both.reset();
    expect(both.unlocked, isFalse);
    expect(both.acceptBiometric(true), isFalse);
  });

  test('PIN validation preserves leading zeros and accepts long PINs', () {
    expect(validPin('001234'), isTrue);
    expect(validPin('001234567890'), isTrue);
    expect(validPin('01234'), isFalse);
    expect(validPin('00123a'), isFalse);
  });

  test('retry delay grows, is capped, and does not trust wall clock', () {
    var retry = const RetryState();
    for (var i = 0; i < 15; i++) {
      retry = retry.failed(uptime: 1000, boot: 'boot-a');
    }
    expect(retry.delaySeconds, 300);
    expect(retry.remaining(uptime: 1005, boot: 'boot-a'), 295);
    expect(retry.remaining(uptime: 10, boot: 'boot-b'), 300);
    expect(retry.remaining(uptime: 1301, boot: 'boot-a'), 0);
  });
}
