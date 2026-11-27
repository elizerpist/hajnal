import 'package:flutter/foundation.dart';
import '../../recovery/application/restart_recovery.dart';
import 'emergency_dialer.dart';
import 'panic_store.dart';
import 'survival_controller.dart';

class PanicController extends ChangeNotifier {
  PanicController(
    this.store,
    this.restartRecovery,
    this.dialer,
    this.activeId,
    this.now,
  );
  final PanicStore store;
  final RestartRecovery restartRecovery;
  final EmergencyDialer dialer;
  final int? Function() activeId;
  final DateTime Function() now;
  String _motivation = '';
  bool _motivationLoading = false;
  bool _motivationFailed = false;
  bool _disposed = false;
  Object? _error;
  bool _busy = false;
  String get motivation => _motivation;
  bool get motivationLoading => _motivationLoading;
  bool get motivationFailed => _motivationFailed;
  Object? get error => _error;
  bool get busy => _busy;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  SurvivalController createSurvival() => SurvivalController(store, now);

  Future<void> load() async {
    _motivationLoading = true;
    _motivationFailed = false;
    _notify();
    try {
      _motivation = await store.motivation();
    } catch (_) {
      _motivationFailed = true;
    } finally {
      _motivationLoading = false;
      _notify();
    }
  }

  Future<bool> restart(int? expectedId) async {
    if (_busy || expectedId == null) return false;
    _busy = true;
    _error = null;
    _notify();
    try {
      await restartRecovery(expectedId);
      return true;
    } catch (e) {
      _error = e;
      return false;
    } finally {
      _busy = false;
      _notify();
    }
  }

  Future<bool> callEmergency() async {
    try {
      return await dialer.open112();
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
