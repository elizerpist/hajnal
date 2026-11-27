import 'package:flutter/foundation.dart';

import '../domain/style_definitions.dart';
import 'save_style.dart';
import 'style_store.dart';

class StyleOwner extends ChangeNotifier {
  StyleOwner(this._store);
  final StyleStore _store;
  StyleSnapshot _current = StyleSnapshot(StyleDefinitions.defaults(), 0);
  StyleSnapshot get current => _current;

  Future<void> load() async {
    _current = await _store.load();
    notifyListeners();
  }

  Future<void> save(StyleDefinitions draft, int revision) async {
    final result = await SaveStyle(_store)(draft, revision);
    _current = result;
    notifyListeners();
  }
}

class StyleEditorController extends ChangeNotifier {
  StyleEditorController(this._owner)
    : _draft = _owner.current.definitions,
      revision = _owner.current.revision,
      _original = _owner.current.definitions.encode();
  final StyleOwner _owner;
  final int revision;
  final String _original;
  StyleDefinitions _draft;
  StyleDefinitions get draft => _draft;
  bool _saving = false;
  bool get saving => _saving;
  Object? _error;
  Object? get error => _error;
  bool get dirty => draft.encode() != _original;

  void setText(TextRole role, String key, Object value) {
    _draft = draft.copyWith(
      texts: {...draft.texts, role: draft.texts[role]!.change(key, value)},
    );
    notifyListeners();
  }

  void setCard(CardRole role, String key, Object value) {
    _draft = draft.copyWith(
      cards: {...draft.cards, role: draft.cards[role]!.change(key, value)},
    );
    notifyListeners();
  }

  void setButton(ButtonRole role, String key, Object value) {
    _draft = draft.copyWith(
      buttons: {
        ...draft.buttons,
        role: draft.buttons[role]!.change(key, value),
      },
    );
    notifyListeners();
  }

  void setPalette(String key, int value) {
    _draft = draft.copyWith(palette: {...draft.palette, key: value});
    notifyListeners();
  }

  void setSpacing(String key, double value) {
    final candidate = draft.copyWith(spacing: {...draft.spacing, key: value});
    _draft = StyleDefinitions.decode(candidate.encode());
    notifyListeners();
  }

  void resetText(TextRole role) {
    _draft = draft.copyWith(
      texts: {...draft.texts, role: StyleDefinitions.defaults().texts[role]!},
    );
    notifyListeners();
  }

  void resetCard(CardRole role) {
    _draft = draft.copyWith(
      cards: {...draft.cards, role: StyleDefinitions.defaults().cards[role]!},
    );
    notifyListeners();
  }

  void resetButton(ButtonRole role) {
    _draft = draft.copyWith(
      buttons: {
        ...draft.buttons,
        role: StyleDefinitions.defaults().buttons[role]!,
      },
    );
    notifyListeners();
  }

  void resetAll() {
    _draft = StyleDefinitions.defaults();
    notifyListeners();
  }

  void resetPalette() {
    _draft = draft.copyWith(palette: StyleDefinitions.defaults().palette);
    notifyListeners();
  }

  void resetPaletteColor(String role) {
    _draft = draft.copyWith(
      palette: {
        ...draft.palette,
        role: StyleDefinitions.defaults().palette[role]!,
      },
    );
    notifyListeners();
  }

  void resetSpacing() {
    _draft = draft.copyWith(spacing: StyleDefinitions.defaults().spacing);
    notifyListeners();
  }

  Future<bool> apply() async {
    if (saving) return false;
    _saving = true;
    _error = null;
    notifyListeners();
    try {
      await _owner.save(draft, revision);
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
