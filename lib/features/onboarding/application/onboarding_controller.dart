import 'package:flutter/foundation.dart';
import '../../recovery/domain/calendar.dart';
import 'finish_onboarding.dart';
import 'onboarding_draft.dart';
import 'onboarding_store.dart';

class OnboardingController extends ChangeNotifier {
  OnboardingController(this._store, this._now, {Listenable? dayChanges})
    : _dayChanges = dayChanges {
    _dayChanges?.addListener(_notify);
  }
  final OnboardingStore _store;
  final DateTime Function() _now;
  final Listenable? _dayChanges;
  OnboardingDraft? _draft;
  Object? _error;
  bool _saving = false;
  int _page = 0;
  OnboardingDraft? get draft => _draft;
  Object? get error => _error;
  bool get saving => _saving;
  int get page => _page;
  bool _disposed = false;
  Future<void> _pending = Future.value();
  Future<void> get idle => _pending;

  int get cleanDayCount => cleanDays(_draft!.date, _now());
  DateTime get today => _now();

  Future<void> load() async {
    try {
      _draft = await _store.load(_now());
      _error = null;
      _change(_draft!);
    } catch (e) {
      _error = e;
    }
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  void _change(OnboardingDraft value) {
    if (_saving || _disposed) return;
    _draft = value;
    _error = null;
    _notify();
    _pending = _pending.then((_) async {
      try {
        await _store.saveDraft(value);
        _error = null;
      } catch (e) {
        _error = e;
      }
      _notify();
    });
  }

  void setDate(DateTime value) {
    validatedStartDate(value, _now());
    _change(_draft!.copyWith(date: value, dirty: {..._draft!.dirty, 'date'}));
  }

  void setMotivation(String value) => _change(
    _draft!.copyWith(
      motivation: value,
      dirty: {..._draft!.dirty, 'motivation'},
    ),
  );
  void skipMotivation() => _change(
    _draft!.copyWith(
      motivation: (_draft!.baseline['motivation'] as String?) ?? '',
      dirty: {..._draft!.dirty}..remove('motivation'),
    ),
  );
  void setModule(OnboardingModule module, bool enabled) {
    final modules = {..._draft!.modules};
    enabled ? modules.add(module) : modules.remove(module);
    _change(
      _draft!.copyWith(modules: modules, dirty: {..._draft!.dirty, 'modules'}),
    );
  }

  void setSponsorChoice(int value) =>
      _change(_draft!.copyWith(sponsorChoice: value));
  void setSponsorName(String value) => _change(
    _draft!.copyWith(sponsorName: value, dirty: {..._draft!.dirty, 'sponsor'}),
  );
  void setSponsorPhone(String value) => _change(
    _draft!.copyWith(sponsorPhone: value, dirty: {..._draft!.dirty, 'sponsor'}),
  );
  void next() {
    if (!_saving && _page < 6) {
      _page++;
      _notify();
    }
  }

  bool back() {
    if (_saving || _page == 0) return false;
    _page--;
    _notify();
    return true;
  }

  Future<void> _flush() async {
    await _pending;
    if (_error != null) {
      await _store.saveDraft(_draft!);
      _error = null;
    }
  }

  Future<bool> flushDraft() async {
    if (_saving || _draft == null) return false;
    _saving = true;
    _notify();
    try {
      await _flush();
      return true;
    } catch (e) {
      _error = e;
      return false;
    } finally {
      _saving = false;
      _notify();
    }
  }

  Future<bool> finish() async {
    if (_saving || _draft == null) return false;
    _saving = true;
    _notify();
    try {
      await _flush();
      await FinishOnboarding(_store)(_draft!, _now());
      _error = null;
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
    _dayChanges?.removeListener(_notify);
    super.dispose();
  }
}
