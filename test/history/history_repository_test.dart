import 'dart:io';
import 'dart:async';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/core/database/hajnal_database.dart';
import 'package:hajnal/features/history/data/history_repository.dart';
import 'package:hajnal/features/panic/data/panic_repository.dart';
import 'package:hajnal/features/recovery/data/recovery_repository.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  test(
    'v5 migration retains unlinked notes and links new notes to the active period',
    () async {
      final dir = await Directory.systemTemp.createTemp('hajnal-history-v5');
      final file = File('${dir.path}/data.sqlite');
      final old = sqlite.sqlite3.open(file.path);
      old.execute(
        'CREATE TABLE recovery_periods (id INTEGER PRIMARY KEY AUTOINCREMENT, start_local_date TEXT NOT NULL, created_at_utc INTEGER NOT NULL, closed_at_utc INTEGER)',
      );
      old.execute(
        'CREATE TABLE survival_notes (id INTEGER PRIMARY KEY AUTOINCREMENT, body TEXT NOT NULL, created_at_utc INTEGER NOT NULL)',
      );
      old.execute(
        'CREATE TABLE onboarding_profiles (id INTEGER PRIMARY KEY, motivation TEXT NOT NULL, modules INTEGER NOT NULL, completed INTEGER NOT NULL)',
      );
      old.execute(
        "INSERT INTO onboarding_profiles VALUES (1, 'Megőrzött szöveg', 3, 1)",
      );
      old.execute(
        "INSERT INTO recovery_periods VALUES (1, '2024-01-01', 1704067200, NULL)",
      );
      old.execute("INSERT INTO survival_notes VALUES (1, 'régi', 1704067200)");
      old.execute('PRAGMA user_version = 5');
      old.dispose();
      final db = HajnalDatabase(NativeDatabase(file));
      final notes = await db.select(db.survivalNotes).get();
      expect(notes.single.body, 'régi');
      expect(notes.single.periodId, isNull);
      expect(await PanicRepository(db).motivation(), 'Megőrzött szöveg');
      await PanicRepository(db).saveNote('új', DateTime.utc(2024, 2));
      final updated = await db.select(db.survivalNotes).get();
      expect(updated.last.periodId, 1);
      expect(updated.first.body, 'régi');
      await db.close();
      await dir.delete(recursive: true);
    },
  );

  test('one live snapshot observes notes and the atomic restart', () async {
    final db = HajnalDatabase(NativeDatabase.memory());
    final recovery = RecoveryRepository(db);
    final initial = await recovery.initialize(
      DateTime(2024, 1, 1),
      DateTime(2024, 1, 3),
    );
    final stream = HistoryRepository(db).watch();
    final iterator = StreamIterator(stream);
    expect(await iterator.moveNext(), isTrue);
    expect(iterator.current.single.id, initial.id);
    await PanicRepository(
      db,
    ).saveNote('teljes jegyzet', DateTime.utc(2024, 1, 3));
    expect(await iterator.moveNext(), isTrue);
    expect(iterator.current.single.notes.single.text, 'teljes jegyzet');
    final next = await recovery.restart(initial.id, DateTime(2024, 1, 4));
    expect(await iterator.moveNext(), isTrue);
    expect(iterator.current.length, 2);
    expect(iterator.current.first.closedAt, isNotNull);
    expect(iterator.current.last.id, next.id);
    expect(iterator.current.first.notes.single.text, 'teljes jegyzet');
    await expectLater(
      recovery.restart(initial.id, DateTime(2024, 1, 4)),
      throwsStateError,
    );
    await iterator.cancel();
    await db.close();
  });

  test('no period means note save fails without inserting an orphan', () async {
    final db = HajnalDatabase(NativeDatabase.memory());
    await expectLater(
      PanicRepository(db).saveNote('x', DateTime.now()),
      throwsStateError,
    );
    expect(await db.select(db.survivalNotes).get(), isEmpty);
    await db.close();
  });
}
