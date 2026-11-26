import 'dart:async';
import 'package:flutter/foundation.dart';
import '../features/dashboard/application/day_tracker.dart';
import '../features/recovery/application/recovery_store.dart';
import '../features/recovery/application/initialize_recovery.dart';
import '../features/recovery/application/correct_recovery_start.dart';

class BootstrapController extends ChangeNotifier {
  BootstrapController(this._store, this._now) : tracker = DayTracker(_now) {
    retry();
  }
  final RecoveryStore _store;
  final DateTime Function() _now;
  final DayTracker tracker;
  StreamSubscription<ActiveRecovery?>? _subscription;
  ActiveRecovery? _active;
  Object? _error;
  Object? _saveError;
  bool _loading = true;
  bool _saving = false;
  DateTime? get startDate => _active?.startDate;
  ActiveRecovery? get activePeriod => _active;
  Object? get error => _error;
  Object? get saveError => _saveError;
  bool get loading => _loading;
  bool get saving => _saving;

  void retry() {
    _subscription?.cancel();
    _loading = true;
    _error = null;
    notifyListeners();
    _subscription = _store.watchStart().listen(
      (period) {
        _active = period;
        tracker.setStart(period?.startDate);
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (Object e) {
        _loading = false;
        _error = e;
        notifyListeners();
      },
    );
  }

  Future<bool> initialize(DateTime date) =>
      _save(() => InitializeRecovery(_store)(date, _now()));

  Future<bool> correctStart(int id, DateTime date) =>
      _save(() => CorrectRecoveryStart(_store)(id, date, _now()));

  Future<bool> _save(Future<void> Function() action) async {
    if (_saving) return false;
    _saving = true;
    _saveError = null;
    notifyListeners();
    try {
      await action();
      return true;
    } catch (e) {
      _saveError = e;
      notifyListeners();
      return false;
    } finally {
      _saving = false;
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
