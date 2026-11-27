import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/core/database/hajnal_database.dart';
import 'package:hajnal/features/onboarding/data/onboarding_repository.dart';
import 'package:hajnal/features/recovery/data/recovery_repository.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:hajnal/features/sponsor/data/sponsor_repository.dart';

void main() {
  final now = DateTime(2026, 11, 27);

  test('all four extras are independent and persist after reopening', () async {
    final dir = await Directory.systemTemp.createTemp('hajnal-modules-');
    final file = File('${dir.path}/app.sqlite');
    var db = HajnalDatabase(NativeDatabase(file));
    var repository = OnboardingRepository(
      db,
      RecoveryRepository(db),
      SponsorRepository(db),
    );
    var draft = await repository.load(now);
    draft = draft.copyWith(
      modules: OnboardingModule.values.toSet(),
      dirty: {'modules'},
    );
    await repository.finish(draft, now);
    await db.close();
    db = HajnalDatabase(NativeDatabase(file));
    repository = OnboardingRepository(
      db,
      RecoveryRepository(db),
      SponsorRepository(db),
    );
    final saved = await repository.load(now);
    expect(saved.modules, OnboardingModule.values.toSet());
    final next = {...saved.modules}..remove(OnboardingModule.reflection);
    await repository.finish(
      saved.copyWith(modules: next, dirty: {'modules'}),
      now,
    );
    expect((await repository.load(now)).modules, next);
    await db.close();
    await dir.delete(recursive: true);
  });

  test(
    'draft persists separately; finalization corrects period atomically',
    () async {
      final dir = await Directory.systemTemp.createTemp('hajnal-onboarding-');
      final path = '${dir.path}/app.sqlite';
      var db = HajnalDatabase(NativeDatabase(File(path)));
      var repository = OnboardingRepository(
        db,
        RecoveryRepository(db),
        SponsorRepository(db),
      );
      final period = await RecoveryRepository(
        db,
      ).initialize(DateTime(2026, 11, 20), now);
      var draft = await repository.load(now);
      draft = draft.copyWith(
        date: DateTime(2026, 11, 21),
        motivation: 'Fontos',
        modules: {OnboardingModule.sponsor},
        sponsorName: 'Anna',
        sponsorPhone: '+361234',
        sponsorChoice: 0,
        dirty: {'date', 'motivation', 'modules', 'sponsor'},
      );
      await repository.saveDraft(draft);
      expect(
        (await RecoveryRepository(db).active()).startLocalDate,
        '2026-11-20',
      );
      await db.close();
      db = HajnalDatabase(NativeDatabase(File(path)));
      repository = OnboardingRepository(
        db,
        RecoveryRepository(db),
        SponsorRepository(db),
      );
      expect((await repository.load(now)).motivation, 'Fontos');
      await repository.finish(draft, now);
      final updated = await RecoveryRepository(db).active();
      expect(updated.id, period.id);
      expect(updated.createdAtUtc, period.createdAtUtc);
      expect(updated.startLocalDate, '2026-11-21');
      final saved = await repository.load(now);
      expect(saved.motivation, 'Fontos');
      expect(saved.modules, contains(OnboardingModule.sponsor));
      expect(saved.sponsorName, 'Anna');
      expect(saved.completed, isTrue);
      await db.close();
      await dir.delete(recursive: true);
    },
  );

  test(
    'stale period and failed write leave every committed field intact',
    () async {
      final db = HajnalDatabase(NativeDatabase.memory());
      final recovery = RecoveryRepository(db);
      final repository = OnboardingRepository(
        db,
        recovery,
        SponsorRepository(db),
      );
      final original = await recovery.initialize(DateTime(2026, 11, 20), now);
      var draft = await repository.load(now);
      draft = draft.copyWith(
        date: DateTime(2026, 11, 21),
        motivation: 'Új',
        modules: {OnboardingModule.sponsor},
        sponsorName: 'Nem menthető',
        sponsorChoice: 0,
        dirty: {'date', 'motivation', 'modules', 'sponsor'},
      );
      await repository.saveDraft(draft);
      await db.customStatement(
        "CREATE TRIGGER reject_onboarding BEFORE UPDATE ON recovery_periods BEGIN SELECT RAISE(ABORT, 'failure'); END",
      );
      await expectLater(repository.finish(draft, now), throwsA(anything));
      expect((await recovery.active()).startLocalDate, '2026-11-20');
      expect((await repository.load(now)).motivation, 'Új');
      expect(await db.select(db.sponsorContacts).get(), isEmpty);
      expect(await db.select(db.onboardingProfiles).get(), isEmpty);
      await db.customStatement('DROP TRIGGER reject_onboarding');
      await db.customStatement(
        'UPDATE recovery_periods SET closed_at_utc = 1 WHERE id = ?',
        [original.id],
      );
      await recovery.initialize(DateTime(2026, 11, 22), now);
      await expectLater(repository.finish(draft, now), throwsStateError);
      expect((await recovery.active()).startLocalDate, '2026-11-22');
      await db.close();
    },
  );

  test(
    'unchanged draft fields do not overwrite newer data and skip preserves sponsor',
    () async {
      final db = HajnalDatabase(NativeDatabase.memory());
      final repository = OnboardingRepository(
        db,
        RecoveryRepository(db),
        SponsorRepository(db),
      );
      await RecoveryRepository(db).initialize(DateTime(2026, 11, 1), now);
      await db.customStatement(
        "INSERT INTO sponsor_contacts (id,name,phone) VALUES (1,'Anna','+36')",
      );
      var draft = await repository.load(now);
      await db.customStatement(
        "INSERT INTO onboarding_profiles (id,motivation,modules,completed) VALUES (1,'Friss',4,1)",
      );
      draft = draft.copyWith(
        modules: {OnboardingModule.sponsor},
        sponsorChoice: 1,
        dirty: {'modules'},
      );
      await repository.finish(draft, now);
      final saved = await repository.load(now);
      expect(saved.motivation, 'Friss');
      expect(saved.modules, {
        OnboardingModule.sponsor,
        OnboardingModule.meetings,
      });
      expect(saved.sponsorName, 'Anna');
      expect(saved.sponsorPhone, '+36');
      final disabled = saved.copyWith(
        modules: {OnboardingModule.meetings},
        dirty: {'modules'},
      );
      await repository.finish(disabled, now);
      final afterDisable = await repository.load(now);
      expect(afterDisable.modules, {OnboardingModule.meetings});
      expect(afterDisable.sponsorName, 'Anna');
      expect(afterDisable.sponsorPhone, '+36');
      await db.close();
    },
  );

  test(
    'version 2 migration preserves existing data and does not force onboarding',
    () async {
      final dir = await Directory.systemTemp.createTemp('hajnal-v2-');
      final file = File('${dir.path}/hajnal.sqlite');
      final old = sqlite3.open(file.path);
      old.execute(
        'CREATE TABLE recovery_periods (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, start_local_date TEXT NOT NULL, created_at_utc INTEGER NOT NULL, closed_at_utc INTEGER)',
      );
      old.execute(
        'CREATE UNIQUE INDEX one_active_period ON recovery_periods ((1)) WHERE closed_at_utc IS NULL',
      );
      old.execute(
        'CREATE TABLE artwork_overrides (role TEXT NOT NULL PRIMARY KEY, filename TEXT NOT NULL, revision TEXT NOT NULL)',
      );
      old.execute(
        "CREATE TABLE lock_settings (id INTEGER NOT NULL PRIMARY KEY, mode INTEGER NOT NULL, credential_slot TEXT, failed_attempts INTEGER NOT NULL DEFAULT 0, retry_deadline INTEGER NOT NULL DEFAULT 0, retry_boot TEXT NOT NULL DEFAULT '')",
      );
      old.execute(
        "INSERT INTO recovery_periods VALUES (41,'2026-10-01',1234,NULL)",
      );
      old.execute(
        "INSERT INTO artwork_overrides VALUES ('dashboard.default','custom.img','revision')",
      );
      old.execute(
        "INSERT INTO lock_settings (id, mode, credential_slot, failed_attempts) VALUES (1,2,'slot-a',3)",
      );
      old.execute('PRAGMA user_version = 2');
      old.dispose();
      final db = HajnalDatabase(NativeDatabase(file));
      final draft = await OnboardingRepository(
        db,
        RecoveryRepository(db),
        SponsorRepository(db),
      ).load(now);
      expect(draft.completed, isTrue);
      expect(draft.periodId, 41);
      expect(
        (await db.select(db.artworkOverrides).getSingle()).filename,
        'custom.img',
      );
      final lock = await db.select(db.lockSettings).getSingle();
      expect(lock.mode, 2);
      expect(lock.credentialSlot, 'slot-a');
      expect(lock.failedAttempts, 3);
      await db.close();
      await dir.delete(recursive: true);
    },
  );

  test(
    'future date and a second finalization cannot modify the period',
    () async {
      final db = HajnalDatabase(NativeDatabase.memory());
      final recovery = RecoveryRepository(db);
      final repository = OnboardingRepository(
        db,
        recovery,
        SponsorRepository(db),
      );
      var draft = await repository.load(now);
      await expectLater(
        repository.finish(
          draft.copyWith(date: now.add(const Duration(days: 1))),
          now,
        ),
        throwsArgumentError,
      );
      expect(await recovery.countActive(), 0);
      await repository.finish(draft, now);
      await expectLater(repository.finish(draft, now), throwsStateError);
      expect(await recovery.countActive(), 1);
      await db.close();
    },
  );
}
