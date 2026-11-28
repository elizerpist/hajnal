import 'practice_store.dart';

import 'practice_rules.dart';

/// Single coordinator for validated card changes; the store owns transactions.
class PracticeActions {
  const PracticeActions(this._store);
  final PracticeStore _store;
  void _validate(PracticeContent content) {
    if (!hasPersonalPracticeText(content.text)) {
      throw ArgumentError('Írj saját szöveget a kártyára.');
    }
  }

  Future<void> add(PracticeContent content, {required bool activate}) {
    _validate(content);
    return _store.add(content, activate: activate);
  }

  Future<void> saveChanges(int id, PracticeContent content) {
    _validate(content);
    return _store.saveChanges(id, content);
  }

  Future<void> activate(int id) => _store.activate(id);
  Future<void> remove(int id) => _store.remove(id);
}
