import '../../../core/database/hajnal_database.dart';
import 'package:drift/drift.dart';
import '../domain/calendar.dart';
import '../application/recovery_store.dart';

class RecoveryRepository {
  RecoveryRepository(this._db);
  final HajnalDatabase _db;

  Stream<ActiveRecovery?> watchStart() =>
      (_db.select(
        _db.recoveryPeriods,
      )..where((p) => p.closedAtUtc.isNull())).watchSingleOrNull().map(
        (period) => period == null
            ? null
            : ActiveRecovery(period.id, DateTime.parse(period.startLocalDate)),
      );

  Future<RecoveryPeriod> active() => (_db.select(
    _db.recoveryPeriods,
  )..where((p) => p.closedAtUtc.isNull())).getSingle();

  Future<int> countActive() async => (await (_db.select(
    _db.recoveryPeriods,
  )..where((p) => p.closedAtUtc.isNull())).get()).length;

  Future<void> correctStart(int id, DateTime start, DateTime now) async {
    final value = validatedStartDate(start, now);
    final count =
        await (_db.update(_db.recoveryPeriods)
              ..where((p) => p.id.equals(id) & p.closedAtUtc.isNull()))
            .write(RecoveryPeriodsCompanion(startLocalDate: Value(value)));
    if (count != 1) throw StateError('Active period changed');
  }

  Future<RecoveryPeriod> initialize(DateTime start, DateTime now) async {
    final value = validatedStartDate(start, now);
    return _db.transaction(() async {
      final existing = await (_db.select(
        _db.recoveryPeriods,
      )..where((p) => p.closedAtUtc.isNull())).getSingleOrNull();
      if (existing != null) return existing;
      final id = await _db
          .into(_db.recoveryPeriods)
          .insert(
            RecoveryPeriodsCompanion.insert(
              startLocalDate: value,
              createdAtUtc: now.toUtc(),
            ),
          );
      return (_db.select(
        _db.recoveryPeriods,
      )..where((p) => p.id.equals(id))).getSingle();
    });
  }
}
