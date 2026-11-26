import 'dart:async';
import 'package:flutter/foundation.dart';
import '../domain/lock_policy.dart';
import 'biometrics.dart';
import 'device_guard.dart';
import 'lock_store.dart';

class LockController extends ChangeNotifier {
  LockController(this._store, this._biometrics, this._device);
  final LockStore _store;
  final Biometrics _biometrics;
  final DeviceGuard _device;
  UnlockSession? _session;
  UnlockSession? _reauth;
  LockMode _mode = LockMode.off;
  bool _loading = true;
  bool _error = false;
  bool _obscured = false;
  bool _busy = false;
  bool _grant = false;
  bool _setupBiometricVerified = false;
  int _generation = 0;
  String? _message;
  Timer? _retryTimer;
  bool _disposed = false;

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  LockMode get mode => _mode;
  bool get loading => _loading;
  bool get error => _error;
  bool get obscured => _obscured;
  bool get locked => _loading || _error || !(_session?.unlocked ?? false);
  bool get busy => _busy;
  bool get reauthenticated => _grant;
  String? get message => _message;
  bool get pinVerified => _session?.pinVerified ?? false;
  bool get reauthPinVerified => _reauth?.pinVerified ?? false;

  Future<void> initialize() async {
    _loading = true;
    notifyListeners();
    try {
      final state = await _store.read();
      _mode = state.mode;
      _session = UnlockSession(_mode);
      _error = false;
    } catch (_) {
      _error = true;
      _session = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void inactive() {
    _obscured = true;
    notifyListeners();
  }

  void background() {
    _generation++;
    _obscured = true;
    _session?.reset();
    _reauth = null;
    _grant = false;
    _setupBiometricVerified = false;
    _message = null;
    unawaited(_biometrics.cancel().catchError((Object _) {}));
    notifyListeners();
  }

  void resumed() {
    _obscured = false;
    notifyListeners();
  }

  Future<void> revealAfterFrame() => _device.revealAfterFrame();

  void beginReauthentication() {
    _reauth = UnlockSession(_mode);
    _grant = _mode == LockMode.off;
    _message = null;
    notifyListeners();
  }

  void cancelReauthentication() {
    _reauth = null;
    _grant = false;
    _setupBiometricVerified = false;
    notifyListeners();
  }

  Future<bool> submitPin(String pin, {bool reauthentication = false}) async {
    final session = reauthentication ? _reauth : _session;
    if (_busy || session == null || !validPin(pin)) return false;
    _busy = true;
    _message = null;
    final ticket = _generation;
    notifyListeners();
    try {
      final time = await _device.time();
      final remaining = await _store.retryRemaining(
        uptime: time.uptime,
        boot: time.boot,
      );
      if (remaining > 0) {
        _message = 'Próbáld újra $remaining másodperc múlva.';
        _retryTimer?.cancel();
        _retryTimer = Timer(Duration(seconds: remaining), () {
          _message = null;
          notifyListeners();
        });
        return false;
      }
      final correct = await _store.verifyPin(
        pin,
        uptime: time.uptime,
        boot: time.boot,
      );
      if (ticket != _generation) return false;
      if (!correct) {
        _message = 'Hibás PIN-kód.';
        return false;
      }
      final success = session.acceptPin(true);
      if (reauthentication && success) _grant = true;
      return success;
    } catch (_) {
      if (ticket == _generation) {
        _message = 'Az ellenőrzés nem sikerült. Próbáld újra.';
      }
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<BiometricResult> availability() => _biometrics.availability();

  Future<bool> submitBiometric({
    bool reauthentication = false,
    bool setup = false,
  }) async {
    final session = reauthentication ? _reauth : _session;
    if (_busy || (!setup && session == null)) return false;
    _busy = true;
    _message = null;
    final ticket = _generation;
    notifyListeners();
    try {
      final available = await _biometrics.availability();
      final outcome = available == BiometricResult.success
          ? await _biometrics.authenticate()
          : available;
      if (ticket != _generation) return false;
      if (outcome != BiometricResult.success) {
        _message = switch (outcome) {
          BiometricResult.unavailable => 'Biometrikus hardver nem érhető el.',
          BiometricResult.notEnrolled =>
            'Nincs beállított biometrikus azonosítás.',
          BiometricResult.cancelled => 'Az azonosítás megszakadt.',
          BiometricResult.failed => 'Az azonosítás sikertelen.',
          BiometricResult.temporaryLockout =>
            'A biometria átmenetileg zárolva van.',
          BiometricResult.permanentLockout =>
            'A biometria zárolva van; ellenőrizd a telefon beállításait.',
          _ => 'A biometria jelenleg nem használható.',
        };
        return false;
      }
      if (setup) {
        _setupBiometricVerified = true;
        return true;
      }
      final success = session!.acceptBiometric(true);
      if (reauthentication && success) _grant = true;
      return success;
    } catch (_) {
      if (ticket == _generation) {
        _message = 'A biometria jelenleg nem használható.';
      }
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<bool> changeMode(LockMode target, {String? newPin}) async {
    if (_busy || locked || (_mode != LockMode.off && !_grant)) return false;
    if ((target == LockMode.biometricOrPin ||
            target == LockMode.pinAndBiometric) &&
        target != _mode &&
        !_setupBiometricVerified) {
      return false;
    }
    final ticket = _generation;
    _busy = true;
    notifyListeners();
    try {
      await _store.setMode(target, newPin: newPin);
      if (ticket != _generation) {
        await initialize();
        return false;
      }
      _mode = target;
      _session = UnlockSession(target);
      if (target != LockMode.off) {
        _session!.acceptPin(true);
        if (target == LockMode.pinAndBiometric) _session!.acceptBiometric(true);
      }
      _grant = false;
      _setupBiometricVerified = false;
      _reauth = null;
      return true;
    } catch (_) {
      _message = 'A beállítást nem sikerült menteni.';
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _generation++;
    _disposed = true;
    _retryTimer?.cancel();
    super.dispose();
  }
}
