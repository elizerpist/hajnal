import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../recovery/domain/calendar.dart';

/// Owns all foreground timers; the clock always supplies device-local time.
class DayTracker extends ChangeNotifier {
  DayTracker(this._now);
  final DateTime Function() _now;
  DateTime? _start;
  int? _days;
  int? get days => _days;
  Timer? _midnight;
  Timer? _check;
  bool _foreground = false;

  void setStart(DateTime? start) {
    _start = start;
    _update();
  }

  void resume() {
    if (_foreground) return;
    _foreground = true;
    _refresh();
    _check = Timer.periodic(const Duration(seconds: 30), (_) => _refresh());
  }

  void pause() {
    _foreground = false;
    _midnight?.cancel();
    _check?.cancel();
    _midnight = null;
    _check = null;
  }

  void _update([DateTime? current]) {
    final next = _start == null ? null : cleanDays(_start!, current ?? _now());
    if (_days != next) {
      _days = next;
      notifyListeners();
    }
  }

  void _refresh() {
    if (!_foreground) return;
    final now = _now();
    _update(now);
    _midnight?.cancel();
    final next = DateTime(now.year, now.month, now.day + 1);
    _midnight = Timer(next.difference(now), _refresh);
  }

  @override
  void dispose() {
    pause();
    super.dispose();
  }
}
