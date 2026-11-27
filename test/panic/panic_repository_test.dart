import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/core/database/hajnal_database.dart' hide SurvivalSession;
import 'package:hajnal/features/panic/data/panic_repository.dart';
import 'package:hajnal/features/panic/domain/survival_session.dart';

void main() {
  test('v4 migration preserves existing profile and recovery data', () async {
    final dir = await Directory.systemTemp.createTemp('hajnal-v4-survival-');
    final file = File('${dir.path}/hajnal.sqlite');
    var db = HajnalDatabase(NativeDatabase(file));
    await db.customStatement(
      "INSERT INTO recovery_periods (start_local_date,created_at_utc) VALUES ('2024-01-02',1)",
    );
    await db.customStatement(
      "INSERT INTO onboarding_profiles (id,motivation,modules,completed) VALUES (1,'Megmarad',3,1)",
    );
    await db.customStatement('DROP TABLE survival_sessions');
    await db.customStatement('DROP TABLE survival_notes');
    await db.customStatement('PRAGMA user_version=4');
    await db.close();
    db = HajnalDatabase(NativeDatabase(file));
    final repo = PanicRepository(db);
    expect(await repo.motivation(), 'Megmarad');
    expect(
      (await db.select(db.recoveryPeriods).getSingle()).startLocalDate,
      '2024-01-02',
    );
    expect(await repo.loadSession(), isNull);
    await repo.saveNote('Működik', DateTime.utc(2025));
    expect((await db.select(db.survivalNotes).getSingle()).body, 'Működik');
    await db.close();
    await dir.delete(recursive: true);
  });
  test(
    'session and note survive reopening; motivation uses saved profile',
    () async {
      final dir = await Directory.systemTemp.createTemp('hajnal-survival-');
      final file = File('${dir.path}/hajnal.sqlite');
      var db = HajnalDatabase(NativeDatabase(file));
      await db.customStatement(
        "INSERT INTO onboarding_profiles (id,motivation,modules,completed) VALUES (1,'Saját szó',0,1)",
      );
      var repository = PanicRepository(db);
      final session = SurvivalSession(
        startedAt: DateTime.utc(2025),
        step: 4,
        note: 'piszkozat',
      );
      await repository.saveSession(session);
      await repository.saveNote('Saját jegyzet', DateTime.utc(2025));
      await db.close();
      db = HajnalDatabase(NativeDatabase(file));
      repository = PanicRepository(db);
      expect(await repository.motivation(), 'Saját szó');
      expect((await repository.loadSession())!.step, 4);
      expect((await repository.loadSession())!.note, 'piszkozat');
      expect(
        (await db.select(db.survivalNotes).getSingle()).body,
        'Saját jegyzet',
      );
      await db.close();
      await dir.delete(recursive: true);
    },
  );
}
