import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/features/app_lock/application/biometrics.dart';
import 'package:hajnal/features/app_lock/application/device_guard.dart';
import 'package:hajnal/features/app_lock/application/lock_controller.dart';
import 'package:hajnal/features/app_lock/application/lock_store.dart';
import 'package:hajnal/features/app_lock/domain/lock_policy.dart';

class Store implements LockStore {
  Store(this.mode);
  LockMode mode;
  bool failRead = false;
  bool failWrite = false;
  @override
  Future<StoredLock> read() async {
    if (failRead) throw StateError('unavailable');
    return StoredLock(mode: mode, slot: 'stored', retry: const RetryState());
  }

  @override
  Future<void> setMode(LockMode value, {String? newPin}) async {
    if (failWrite) throw StateError('storage unavailable');
    mode = value;
  }

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
  }) async => pin == '001234';
}

class Finger implements Biometrics {
  Completer<BiometricResult>? pending;
  BiometricResult available = BiometricResult.success;
  @override
  Future<BiometricResult> availability() async => available;
  @override
  Future<BiometricResult> authenticate() async =>
      pending == null ? BiometricResult.success : pending!.future;
  @override
  Future<void> cancel() async {}
}

class Device implements DeviceGuard {
  @override
  Future<DeviceTime> time() async => const DeviceTime(1, 'boot');
  @override
  Future<void> revealAfterFrame() async {}
}

void main() {
  test(
    'changing active settings requires full current authentication',
    () async {
      final store = Store(LockMode.pinAndBiometric);
      final c = LockController(store, Finger(), Device());
      await c.initialize();
      await c.submitPin('001234');
      await c.submitBiometric();
      expect(await c.changeMode(LockMode.off), isFalse);
      c.beginReauthentication();
      expect(await c.submitPin('001234', reauthentication: true), isFalse);
      expect(await c.changeMode(LockMode.off), isFalse);
      expect(await c.submitBiometric(reauthentication: true), isTrue);
      store.failWrite = true;
      expect(await c.changeMode(LockMode.off), isFalse);
      expect(store.mode, LockMode.pinAndBiometric);
      store.failWrite = false;
      expect(await c.changeMode(LockMode.off), isTrue);
      expect(store.mode, LockMode.off);
      c.dispose();
    },
  );
  test('cancelled and locked biometrics cannot unlock', () async {
    final finger = Finger()..available = BiometricResult.temporaryLockout;
    final c = LockController(Store(LockMode.biometricOrPin), finger, Device());
    await c.initialize();
    expect(await c.submitBiometric(), isFalse);
    expect(c.locked, isTrue);
    finger.available = BiometricResult.cancelled;
    expect(await c.submitBiometric(), isFalse);
    expect(c.locked, isTrue);
    expect(await c.submitPin('001234'), isTrue);
    c.dispose();
  });
  test('failed secure read never permits dashboard', () async {
    final c = LockController(
      Store(LockMode.pin)..failRead = true,
      Finger(),
      Device(),
    );
    await c.initialize();
    expect(c.error, isTrue);
    expect(c.locked, isTrue);
    c.dispose();
  });
  test(
    'combined mode requires both factors and transient inactive does not relock',
    () async {
      final c = LockController(
        Store(LockMode.pinAndBiometric),
        Finger(),
        Device(),
      );
      await c.initialize();
      expect(await c.submitBiometric(), isFalse);
      expect(c.locked, isTrue);
      expect(await c.submitPin('001234'), isFalse);
      expect(c.pinVerified, isTrue);
      c.inactive();
      c.resumed();
      expect(c.pinVerified, isTrue);
      expect(await c.submitBiometric(), isTrue);
      expect(c.locked, isFalse);
      c.background();
      c.resumed();
      expect(c.locked, isTrue);
      c.dispose();
    },
  );
  test(
    'late biometric success after background cannot unlock new session',
    () async {
      final finger = Finger()..pending = Completer<BiometricResult>();
      final c = LockController(
        Store(LockMode.biometricOrPin),
        finger,
        Device(),
      );
      await c.initialize();
      final pending = c.submitBiometric();
      await Future<void>.delayed(Duration.zero);
      c.background();
      c.resumed();
      finger.pending!.complete(BiometricResult.success);
      expect(await pending, isFalse);
      expect(c.locked, isTrue);
      c.dispose();
    },
  );
  test('unavailable biometrics never enables the combined mode', () async {
    final finger = Finger()..available = BiometricResult.notEnrolled;
    final store = Store(LockMode.off);
    final c = LockController(store, finger, Device());
    await c.initialize();
    expect(await c.submitBiometric(setup: true), isFalse);
    expect(
      await c.changeMode(LockMode.pinAndBiometric, newPin: '001234'),
      isFalse,
    );
    expect(store.mode, LockMode.off);
    c.dispose();
  });
}
