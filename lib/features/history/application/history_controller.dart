import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../recovery/domain/calendar.dart';
import 'history_store.dart';

class HistoryController extends ChangeNotifier {
  HistoryController(HistoryStore store, this.now) {
    _subscription = store.watch().listen(_receive, onError: _fail);
  }
  final DateTime Function() now;
  late final StreamSubscription<List<HistoryPeriod>> _subscription;
  List<HistoryPeriod> _periods = const [];
  int? _selectedId;
  bool _followActive = true;
  bool _loading = true;
  Object? _error;
  List<HistoryPeriod> get periods => _periods;
  int? get selectedId => _selectedId;
  bool get loading => _loading;
  Object? get error => _error;

  HistoryPeriod? get selected {
    for (final period in periods) {
      if (period.id == selectedId) return period;
    }
    return null;
  }

  void _receive(List<HistoryPeriod> value) {
    final selectedStillExists = value.any((p) => p.id == selectedId);
    HistoryPeriod? active;
    for (final period in value) {
      if (period.active) active = period;
    }
    _periods = List.unmodifiable(value);
    if (_followActive || !selectedStillExists) {
      _selectedId = active?.id ?? (value.isEmpty ? null : value.last.id);
    }
    _loading = false;
    _error = null;
    notifyListeners();
  }

  void _fail(Object value) {
    _error = value;
    _loading = false;
    notifyListeners();
  }

  void select(int id) {
    final matches = periods.where((p) => p.id == id);
    if (matches.isEmpty) return;
    _selectedId = id;
    _followActive = matches.single.active;
    notifyListeners();
  }

  int days(HistoryPeriod period) =>
      cleanDays(period.start, period.closedAt?.toLocal() ?? now());

  List<HistoryEvent> events(HistoryPeriod period) {
    final result = <HistoryEvent>[
      HistoryEvent(
        HistoryEventType.start,
        period.start,
        'A tiszta időszak kezdete.',
      ),
      for (final note in period.notes)
        HistoryEvent(
          HistoryEventType.note,
          note.createdAt.toLocal(),
          note.text,
          noteId: note.id,
        ),
      if (period.closedAt != null)
        HistoryEvent(
          HistoryEventType.close,
          period.closedAt!.toLocal(),
          'Az időszak lezárult.',
        ),
    ];
    result.sort((a, b) => a.date.compareTo(b.date));
    return result;
  }

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
