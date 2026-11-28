import 'dart:async';
import 'package:flutter/foundation.dart';
import 'practice_store.dart';
import 'practice_actions.dart';
import 'practice_rules.dart';

class PracticeController extends ChangeNotifier {
  PracticeController(PracticeStore store) : _actions = PracticeActions(store) {
    _subscription = store.watch().listen(
      (value) {
        _cards = value;
        error = null;
        notifyListeners();
      },
      onError: (Object e) {
        error = e;
        notifyListeners();
      },
    );
  }
  final PracticeActions _actions;
  late final StreamSubscription<List<PracticeCard>> _subscription;
  List<PracticeCard> _cards = const [];
  List<PracticeCard> get cards => _cards;
  PracticeCard? get active =>
      _cards.where((c) => c.status == 'active').firstOrNull;
  bool canSave(String text) => hasPersonalPracticeText(text);
  String promptPrefix(String name) => practicePrompts[name]!;
  bool saving = false;
  Object? error;
  Future<bool> _run(Future<void> Function() operation) async {
    if (saving) return false;
    saving = true;
    error = null;
    notifyListeners();
    try {
      await operation();
      return true;
    } catch (e) {
      error = e;
      return false;
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  Future<bool> add(PracticeContent content, bool activate) =>
      _run(() => _actions.add(content, activate: activate));
  Future<bool> saveChanges(int id, PracticeContent content) =>
      _run(() => _actions.saveChanges(id, content));
  Future<bool> activate(int id) => _run(() => _actions.activate(id));
  Future<bool> remove(int id) => _run(() => _actions.remove(id));
  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
