import 'dart:async';
import 'package:flutter/foundation.dart';
import '../domain/survival_session.dart';
import 'panic_store.dart';

class SurvivalController extends ChangeNotifier {
  SurvivalController(this._store, this._now);
  final PanicStore _store;
  final DateTime Function() _now;
  SurvivalSession? _session;
  bool _loading = true;
  bool _resumed = false;
  bool _saving = false;
  Object? _error;
  SurvivalSession? get session => _session;
  bool get loading => _loading;
  bool get resumed => _resumed;
  bool get saving => _saving;
  Object? get error => _error;
  Timer? _timer;
  Future<void> _pending = Future.value();
  bool _disposed = false;

  Duration get remaining => _session?.remaining(_now()) ?? Duration.zero;
  int get stopRemaining =>
      (30 - _now().difference(_session!.stepStartedAt).inSeconds).clamp(0, 30);
  bool get complete => _session?.reassessment == Reassessment.complete;
  bool get stillHard => _session?.reassessment == Reassessment.stillHard;
  bool get stronger => _session?.reassessment == Reassessment.stronger;
  Future<void> get idle => _pending;
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> open() async {
    _loading = true;
    _error = null;
    _notify();
    try {
      _session = await _store.loadSession();
      if (_disposed) return;
      _resumed =
          _session != null && _session!.reassessment != Reassessment.complete;
      _session ??= SurvivalSession(startedAt: _now());
      if (!_resumed) {
        _session = SurvivalSession(startedAt: _now());
        _queue();
      }
      _timer ??= Timer.periodic(const Duration(seconds: 1), (_) => _notify());
    } catch (e) {
      _error = e;
    }
    _loading = false;
    _notify();
  }

  void _queue() {
    final value = _session!;
    _pending = _pending
        .then((_) async {
          await _store.saveSession(value);
          _error = null;
          _notify();
        })
        .catchError((Object e) {
          _error = e;
          _notify();
        });
  }

  void update(SurvivalSession value) {
    _session = value;
    _queue();
    _notify();
  }

  void next() => update(
    _session!.copyWith(
      step: (_session!.step + 1).clamp(0, 6),
      reassessment: Reassessment.none,
      breathingPaused: false,
      stepStartedAt: _now(),
    ),
  );
  void previous() => update(
    _session!.copyWith(
      step: (_session!.step - 1).clamp(0, 6),
      reassessment: Reassessment.none,
      stepStartedAt: _now(),
    ),
  );
  void chooseWater(String value) {
    update(_session!.copyWith(water: value));
    next();
  }

  void chooseEnvironment(String value) {
    update(_session!.copyWith(environment: value));
    next();
  }

  void assess(Reassessment value) => update(
    _session!.copyWith(
      reassessment: value == Reassessment.relieved
          ? Reassessment.complete
          : value,
    ),
  );
  void markRelieved() => assess(Reassessment.relieved);
  void markStillHard() => assess(Reassessment.stillHard);
  void markStronger() => assess(Reassessment.stronger);
  void toggleBreathing() =>
      update(_session!.copyWith(breathingPaused: !_session!.breathingPaused));
  void waitAgain() =>
      update(_session!.copyWith(step: 5, reassessment: Reassessment.none));
  void dismissResume() {
    _resumed = false;
    _notify();
  }

  void restart() {
    _resumed = false;
    update(SurvivalSession(startedAt: _now()));
  }

  void setNote(String value) => update(_session!.copyWith(note: value));
  void retrySave() {
    _error = null;
    _queue();
    _notify();
  }

  Future<bool> saveNote() async {
    if (_saving || _session!.note.trim().isEmpty || _error != null) {
      return false;
    }
    _saving = true;
    _error = null;
    _notify();
    try {
      await idle;
      if (_error != null) return false;
      await _store.saveNote(_session!.note.trim(), _now());
      return true;
    } catch (e) {
      _error = e;
      return false;
    } finally {
      _saving = false;
      _notify();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }
}
