import 'package:drift/drift.dart';

part 'hajnal_database.g.dart';

class UtcInstant extends TypeConverter<DateTime, DateTime> {
  const UtcInstant();
  @override
  DateTime fromSql(DateTime fromDb) => fromDb.toUtc();
  @override
  DateTime toSql(DateTime value) => value.toUtc();
}

@TableIndex.sql(
  'CREATE UNIQUE INDEX one_active_period ON recovery_periods ((1)) WHERE closed_at_utc IS NULL',
)
class RecoveryPeriods extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get startLocalDate => text()();
  Column<DateTime> get createdAtUtc => dateTime().map(const UtcInstant())();
  Column<DateTime> get closedAtUtc =>
      dateTime().map(const UtcInstant()).nullable()();
}

class ArtworkOverrides extends Table {
  TextColumn get role => text()();
  TextColumn get filename => text()();
  TextColumn get revision => text()();
  @override
  Set<Column> get primaryKey => {role};
}

class LockSettings extends Table {
  IntColumn get id => integer()();
  IntColumn get mode => integer()();
  TextColumn get credentialSlot => text().nullable()();
  IntColumn get failedAttempts => integer().withDefault(const Constant(0))();
  IntColumn get retryDeadline => integer().withDefault(const Constant(0))();
  TextColumn get retryBoot => text().withDefault(const Constant(''))();
  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [RecoveryPeriods, ArtworkOverrides, LockSettings])
class HajnalDatabase extends _$HajnalDatabase {
  HajnalDatabase(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await customStatement(
        'INSERT INTO lock_settings (id, mode) VALUES (1, 0)',
      );
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(lockSettings);
        await customStatement(
          'INSERT INTO lock_settings (id, mode) VALUES (1, 0)',
        );
      }
    },
    beforeOpen: (_) async => customStatement('PRAGMA foreign_keys = ON'),
  );
}
