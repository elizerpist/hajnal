import 'dart:async';
import 'package:flutter/foundation.dart';
import 'reflection_store.dart';

class ReflectionController extends ChangeNotifier {
  ReflectionController(this._store);
  final ReflectionStore _store;
  ReflectionEntry? _entry;
  Object? _error;
  int _step = 0;
  bool _saving = false;
  ReflectionEntry? get entry => _entry;
  Object? get error => _error;
  int get step => _step;
  bool get saving => _saving;
  Future<void> _pending = Future.value();
  Future<void> get idle => _pending;
  Future<void> open(int periodId, DateTime date) async {
    try {
      _entry = await _store.open(periodId, date);
    } catch (e) {
      _error = e;
    }
    notifyListeners();
  }

  Future<void> openById(int id) async {
    try {
      _entry = await _store.openById(id);
    } catch (e) {
      _error = e;
    }
    notifyListeners();
  }

  void update(ReflectionEntry value) {
    if (saving) return;
    _entry = value;
    _pending = _pending.then((_) => _store.saveDraft(value)).catchError((
      Object e,
    ) {
      _error = e;
      notifyListeners();
    });
    notifyListeners();
  }

  void move(int delta) {
    final maxStep = entry?.snapshot == null ? 1 : 2;
    _step = (step + delta).clamp(0, maxStep);
    notifyListeners();
  }

  Future<bool> finish() async {
    if (saving || entry == null) return false;
    _saving = true;
    _error = null;
    notifyListeners();
    await _pending;
    try {
      if (error != null) return false;
      await _store.finish(entry!);
      return true;
    } catch (e) {
      _error = e;
      return false;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }
}
