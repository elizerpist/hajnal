import 'package:drift/drift.dart';
import '../../../core/database/hajnal_database.dart';
import '../application/history_store.dart';

class HistoryRepository implements HistoryStore {
  HistoryRepository(this._db);
  final HajnalDatabase _db;

  @override
  Stream<List<HistoryPeriod>> watch() {
    final query =
        _db.select(_db.recoveryPeriods).join([
          leftOuterJoin(
            _db.survivalNotes,
            _db.survivalNotes.periodId.equalsExp(_db.recoveryPeriods.id),
          ),
          leftOuterJoin(
            _db.dailyReflections,
            _db.dailyReflections.periodId.equalsExp(_db.recoveryPeriods.id) &
                _db.dailyReflections.completed.equals(true),
          ),
        ])..orderBy([
          OrderingTerm.asc(_db.recoveryPeriods.id),
          OrderingTerm.asc(_db.survivalNotes.id),
        ]);
    return query.watch().map((rows) {
      final periods = <int, RecoveryPeriod>{};
      final notes = <int, Map<int, HistoryNote>>{};
      final reflections = <int, Map<int, HistoryReflection>>{};
      for (final row in rows) {
        final period = row.readTable(_db.recoveryPeriods);
        periods[period.id] = period;
        final note = row.readTableOrNull(_db.survivalNotes);
        if (note != null) {
          (notes[period.id] ??= {})[note.id] = HistoryNote(
            note.id,
            note.body,
            note.createdAtUtc,
          );
        }
        final reflection = row.readTableOrNull(_db.dailyReflections);
        if (reflection != null) {
          (reflections[period.id] ??= {})[reflection.id] = HistoryReflection(
            reflection.id,
            DateTime.parse(reflection.localDate),
            reflection.body,
          );
        }
      }
      return List.unmodifiable(
        periods.values.map(
          (p) => HistoryPeriod(
            id: p.id,
            start: DateTime.parse(p.startLocalDate),
            createdAt: p.createdAtUtc,
            closedAt: p.closedAtUtc,
            notes: (notes[p.id]?.values ?? const <HistoryNote>[]).toList(),
            reflections:
                (reflections[p.id]?.values ?? const <HistoryReflection>[])
                    .toList(),
          ),
        ),
      );
    });
  }
}
