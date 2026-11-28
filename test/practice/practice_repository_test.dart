import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:hajnal/core/database/hajnal_database.dart';
import 'package:hajnal/features/practice/application/practice_store.dart';
import 'package:hajnal/features/practice/data/practice_repository.dart';
import 'package:hajnal/features/recovery/data/recovery_repository.dart';
import 'package:hajnal/features/history/data/history_repository.dart';

void main() {
  test(
    'period restart and disabling extras preserve cards without history notes',
    () async {
      final db = HajnalDatabase(NativeDatabase.memory());
      final recovery = RecoveryRepository(db);
      final first = await recovery.initialize(
        DateTime(2026, 1, 1),
        DateTime(2026, 1, 2),
      );
      final practice = PracticeRepository(db);
      await practice.add(
        const PracticeContent(text: 'Megmaradó gyakorlat'),
        activate: true,
      );
      final id = (await practice.watch().first).single.id;
      await db.customStatement(
        "INSERT INTO onboarding_profiles (id, motivation, modules, completed) VALUES (1, '', 15, 1)",
      );
      await db.customStatement(
        'UPDATE onboarding_profiles SET modules = 0 WHERE id = 1',
      );
      await recovery.restart(first.id, DateTime(2026, 2, 1));
      final saved = (await practice.watch().first).single;
      expect(saved.id, id);
      expect(saved.text, 'Megmaradó gyakorlat');
      expect(saved.status, 'active');
      final periods = await HistoryRepository(db).watch().first;
      expect(periods, hasLength(2));
      expect(periods.every((period) => period.notes.isEmpty), isTrue);
      await db.close();
    },
  );
  test(
    'v6 migration, one active, atomic switch, edit and restart persistence',
    () async {
      final dir = await Directory.systemTemp.createTemp('practice-v6-');
      final file = File('${dir.path}/hajnal.sqlite');
      final old = sqlite.sqlite3.open(file.path);
      old.execute(
        'CREATE TABLE recovery_periods (id INTEGER PRIMARY KEY AUTOINCREMENT, start_local_date TEXT NOT NULL, created_at_utc INTEGER NOT NULL, closed_at_utc INTEGER)',
      );
      old.execute(
        "INSERT INTO recovery_periods VALUES (1, '2024-01-01', 1704067200, NULL)",
      );
      old.execute('PRAGMA user_version = 6');
      old.dispose();
      var db = HajnalDatabase(NativeDatabase(file));
      var repository = PracticeRepository(db, clock: () => DateTime.utc(2026));
      expect(await repository.watch().first, isEmpty);
      expect(
        (await db.select(db.recoveryPeriods).get()).single.startLocalDate,
        '2024-01-01',
      );
      await repository.add(
        const PracticeContent(
          text: 'Első',
          sourceReference: 'step-4',
          sourceName: '4. lépés',
          sourceText: 'Forrás',
        ),
        activate: true,
      );
      await repository.add(
        const PracticeContent(text: 'Második'),
        activate: false,
      );
      var cards = await repository.watch().first;
      final active = cards.singleWhere((p) => p.status == 'active');
      final paused = cards.singleWhere((p) => p.status == 'paused');
      final snapshot = active.snapshot();
      await repository.saveChanges(
        paused.id,
        const PracticeContent(text: 'Átírt inaktív'),
      );
      cards = await repository.watch().first;
      expect(cards.singleWhere((p) => p.id == paused.id).status, 'paused');
      expect(cards.singleWhere((p) => p.status == 'active').id, active.id);
      await expectLater(repository.activate(99999), throwsStateError);
      expect(
        (await repository.watch().first)
            .singleWhere((p) => p.status == 'active')
            .id,
        active.id,
      );
      await expectLater(
        db.customStatement(
          "INSERT INTO practice_cards (card_text,status,created_at_utc,updated_at_utc) VALUES ('x','active',0,0)",
        ),
        throwsA(anything),
      );
      await repository.activate(paused.id);
      cards = await repository.watch().first;
      expect(cards.singleWhere((p) => p.status == 'active').id, paused.id);
      expect(cards.singleWhere((p) => p.id == active.id).status, 'paused');
      await repository.saveChanges(
        active.id,
        const PracticeContent(text: 'Új szöveg'),
      );
      expect(snapshot.text, 'Első');
      await db.close();
      db = HajnalDatabase(NativeDatabase(file));
      repository = PracticeRepository(db);
      cards = await repository.watch().first;
      expect(
        cards.singleWhere((p) => p.status == 'active').text,
        'Átírt inaktív',
      );
      final original = cards.singleWhere((p) => p.id == active.id);
      expect(original.sourceReference, 'step-4');
      expect(original.sourceText, 'Forrás');
      await repository.remove(paused.id);
      expect(
        (await repository.watch().first).where((p) => p.status == 'active'),
        isEmpty,
      );
      await repository.activate(active.id);
      expect((await repository.watch().first).single.status, 'active');
      await db.close();
      await dir.delete(recursive: true);
    },
  );
}
