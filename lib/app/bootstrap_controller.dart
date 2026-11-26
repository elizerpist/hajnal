import 'dart:async';
import 'package:flutter/foundation.dart';
import '../features/dashboard/application/day_tracker.dart';
import '../features/recovery/application/recovery_store.dart';
import '../features/recovery/application/initialize_recovery.dart';

class BootstrapController extends ChangeNotifier {
  BootstrapController(this._store, this._now) : tracker = DayTracker(_now) {
    retry();
  }
  final RecoveryStore _store;
  final DateTime Function() _now;
  final DayTracker tracker;
  StreamSubscription<DateTime?>? _subscription;
  DateTime? startDate;
  Object? error;
  Object? saveError;
  bool loading = true;
  bool saving = false;

  void retry() {
    _subscription?.cancel();
    loading = true;
    error = null;
    notifyListeners();
    _subscription = _store.watchStart().listen(
      (date) {
        startDate = date;
        tracker.setStart(date);
        loading = false;
        error = null;
        notifyListeners();
      },
      onError: (Object e) {
        loading = false;
        error = e;
        notifyListeners();
      },
    );
  }

  Future<bool> initialize(DateTime date) async {
    if (saving) return false;
    saving = true;
    saveError = null;
    notifyListeners();
    try {
      await InitializeRecovery(_store)(date, _now());
      return true;
    } catch (e) {
      saveError = e;
      notifyListeners();
      return false;
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    tracker.dispose();
    super.dispose();
  }
}
