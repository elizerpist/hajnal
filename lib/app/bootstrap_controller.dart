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
  DateTime? _startDate;
  Object? _error;
  Object? _saveError;
  bool _loading = true;
  bool _saving = false;
  DateTime? get startDate => _startDate;
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
      (date) {
        _startDate = date;
        tracker.setStart(date);
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

  Future<bool> initialize(DateTime date) async {
    if (_saving) return false;
    _saving = true;
    _saveError = null;
    notifyListeners();
    try {
      await InitializeRecovery(_store)(date, _now());
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
