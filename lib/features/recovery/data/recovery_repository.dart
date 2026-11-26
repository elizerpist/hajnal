import '../../../core/database/hajnal_database.dart';

class RecoveryRepository {
  RecoveryRepository(this._db);
  final HajnalDatabase _db;

  Stream<DateTime?> watchStart() =>
      (_db.select(
        _db.recoveryPeriods,
      )..where((p) => p.closedAtUtc.isNull())).watchSingleOrNull().map(
        (period) =>
            period == null ? null : DateTime.parse(period.startLocalDate),
      );

  Future<RecoveryPeriod> active() => (_db.select(
    _db.recoveryPeriods,
  )..where((p) => p.closedAtUtc.isNull())).getSingle();

  Future<int> countActive() async => (await (_db.select(
    _db.recoveryPeriods,
  )..where((p) => p.closedAtUtc.isNull())).get()).length;

  Future<RecoveryPeriod> initialize(DateTime start, DateTime now) async {
    final date = DateTime.utc(start.year, start.month, start.day);
    final today = DateTime.utc(now.year, now.month, now.day);
    if (date.isAfter(today)) throw ArgumentError('Future start date');
    final value =
        '${start.year.toString().padLeft(4, '0')}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';
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
