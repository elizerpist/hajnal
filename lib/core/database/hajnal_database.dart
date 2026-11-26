import 'package:drift/drift.dart';

part 'hajnal_database.g.dart';

class RecoveryPeriods extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get startLocalDate => text()();
  DateTimeColumn get createdAtUtc => dateTime()();
  DateTimeColumn get closedAtUtc => dateTime().nullable()();
}

class ArtworkOverrides extends Table {
  TextColumn get role => text()();
  TextColumn get filename => text()();
  TextColumn get revision => text()();
  @override
  Set<Column> get primaryKey => {role};
}

@DriftDatabase(tables: [RecoveryPeriods, ArtworkOverrides])
class HajnalDatabase extends _$HajnalDatabase {
  HajnalDatabase(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await customStatement(
        'CREATE UNIQUE INDEX one_active_period ON recovery_periods ((1)) WHERE closed_at_utc IS NULL',
      );
    },
  );
}
