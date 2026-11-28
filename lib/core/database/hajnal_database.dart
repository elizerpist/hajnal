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

class OnboardingProfiles extends Table {
  IntColumn get id => integer()();
  TextColumn get motivation => text().withDefault(const Constant(''))();
  IntColumn get modules => integer().withDefault(const Constant(0))();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {id};
}

class SponsorContacts extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get phone => text().withDefault(const Constant(''))();
  @override
  Set<Column> get primaryKey => {id};
}

class OnboardingDrafts extends Table {
  IntColumn get id => integer()();
  TextColumn get payload => text()();
  @override
  Set<Column> get primaryKey => {id};
}

class StyleSettings extends Table {
  IntColumn get id => integer()();
  IntColumn get revision => integer()();
  TextColumn get payload => text()();
  @override
  Set<Column> get primaryKey => {id};
}

class SurvivalSessions extends Table {
  IntColumn get id => integer()();
  TextColumn get payload => text()();
  @override
  Set<Column> get primaryKey => {id};
}

class SurvivalNotes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get body => text()();
  Column<DateTime> get createdAtUtc => dateTime().map(const UtcInstant())();
  IntColumn get periodId =>
      integer().nullable().references(RecoveryPeriods, #id)();
}

@TableIndex.sql(
  "CREATE UNIQUE INDEX one_active_practice ON practice_cards(status) WHERE status = 'active'",
)
@DataClassName('PracticeCardData')
class PracticeCards extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get cardText => text()();
  TextColumn get title => text().nullable()();
  TextColumn get promptKind => text().nullable()();
  TextColumn get status => text()();
  TextColumn get sourceReference => text().nullable()();
  TextColumn get sourceName => text().nullable()();
  TextColumn get sourceText => text().nullable()();
  Column<DateTime> get createdAtUtc => dateTime().map(const UtcInstant())();
  Column<DateTime> get updatedAtUtc => dateTime().map(const UtcInstant())();
  Column<DateTime> get activatedAtUtc =>
      dateTime().map(const UtcInstant()).nullable()();
}

@TableIndex.sql(
  'CREATE UNIQUE INDEX reflection_period_day ON daily_reflections(period_id, local_date)',
)
class DailyReflections extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get periodId => integer().references(RecoveryPeriods, #id)();
  TextColumn get localDate => text()();
  IntColumn get mood => integer().nullable()();
  TextColumn get prompt => text().withDefault(const Constant('best'))();
  TextColumn get body => text().withDefault(const Constant(''))();
  TextColumn get practiceSnapshot => text().nullable()();
  TextColumn get observation => text().nullable()();
  TextColumn get note => text().withDefault(const Constant(''))();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(
  tables: [
    RecoveryPeriods,
    ArtworkOverrides,
    LockSettings,
    OnboardingProfiles,
    SponsorContacts,
    OnboardingDrafts,
    StyleSettings,
    SurvivalSessions,
    SurvivalNotes,
    PracticeCards,
    DailyReflections,
  ],
)
class HajnalDatabase extends _$HajnalDatabase {
  HajnalDatabase(super.executor);

  @override
  int get schemaVersion => 8;

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
      if (from < 3) {
        await m.createTable(onboardingProfiles);
        await m.createTable(sponsorContacts);
        await m.createTable(onboardingDrafts);
      }
      if (from < 4) {
        await m.createTable(styleSettings);
      }
      if (from < 5) {
        await m.createTable(survivalSessions);
        await m.createTable(survivalNotes);
      }
      if (from < 7) {
        await m.createTable(practiceCards);
        await customStatement(
          "CREATE UNIQUE INDEX one_active_practice ON practice_cards(status) WHERE status = 'active'",
        );
      }
      if (from >= 5 && from < 6) {
        await m.addColumn(survivalNotes, survivalNotes.periodId);
      }
      if (from < 8) {
        await m.createTable(dailyReflections);
        await customStatement(
          'CREATE UNIQUE INDEX reflection_period_day ON daily_reflections(period_id, local_date)',
        );
      }
    },
    beforeOpen: (_) async => customStatement('PRAGMA foreign_keys = ON'),
  );
}
