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
        ])..orderBy([
          OrderingTerm.asc(_db.recoveryPeriods.id),
          OrderingTerm.asc(_db.survivalNotes.id),
        ]);
    return query.watch().map((rows) {
      final periods = <int, RecoveryPeriod>{};
      final notes = <int, List<HistoryNote>>{};
      for (final row in rows) {
        final period = row.readTable(_db.recoveryPeriods);
        periods[period.id] = period;
        final note = row.readTableOrNull(_db.survivalNotes);
        if (note != null) {
          (notes[period.id] ??= []).add(
            HistoryNote(note.id, note.body, note.createdAtUtc),
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
            notes: List.unmodifiable(notes[p.id] ?? const <HistoryNote>[]),
          ),
        ),
      );
    });
  }
}
