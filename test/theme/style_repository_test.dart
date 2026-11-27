import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/core/database/hajnal_database.dart';
import 'package:hajnal/core/theme/data/style_repository.dart';
import 'package:hajnal/core/theme/domain/style_definitions.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('style write is durable and rejects a stale revision', () async {
    final db = HajnalDatabase(NativeDatabase.memory());
    final repository = StyleRepository(db);
    final initial = await repository.load();
    final changed = initial.definitions.copyWith(
      texts: {
        ...initial.definitions.texts,
        TextRole.title1: initial.definitions.texts[TextRole.title1]!.change(
          'size',
          36,
        ),
      },
    );
    expect(await repository.save(changed, initial.revision), 1);
    expect(
      (await repository.load()).definitions.texts[TextRole.title1]!.size,
      36,
    );
    await expectLater(
      repository.save(StyleDefinitions.defaults(), 0),
      throwsStateError,
    );
    expect(
      (await repository.load()).definitions.texts[TextRole.title1]!.size,
      36,
    );
    await db.close();
  });

  test('changed style survives a database reopen', () async {
    final directory = await Directory.systemTemp.createTemp(
      'hajnal-style-reopen-',
    );
    final file = File('${directory.path}/app.sqlite');
    var db = HajnalDatabase(NativeDatabase(file));
    var repository = StyleRepository(db);
    final initial = await repository.load();
    final changed = initial.definitions.copyWith(
      cards: {
        ...initial.definitions.cards,
        CardRole.large: initial.definitions.cards[CardRole.large]!.change(
          'radius',
          30.0,
        ),
      },
    );
    await repository.save(changed, initial.revision);
    await db.close();
    db = HajnalDatabase(NativeDatabase(file));
    repository = StyleRepository(db);
    expect(
      (await repository.load()).definitions.cards[CardRole.large]!.radius,
      30,
    );
    expect((await repository.load()).revision, 1);
    await db.close();
    await directory.delete(recursive: true);
  });

  test('v3 migration preserves existing data and corrupt style falls back', () async {
    final directory = await Directory.systemTemp.createTemp('hajnal-style-');
    final file = File('${directory.path}/app.sqlite');
    final old = sqlite3.open(file.path);
    old.execute(
      'CREATE TABLE recovery_periods (id INTEGER PRIMARY KEY, start_local_date TEXT NOT NULL, created_at_utc INTEGER NOT NULL, closed_at_utc INTEGER)',
    );
    old.execute(
      "INSERT INTO recovery_periods VALUES (7,'2024-01-03',1234,NULL)",
    );
    old.execute(
      'CREATE TABLE artwork_overrides (role TEXT PRIMARY KEY, filename TEXT NOT NULL, revision TEXT NOT NULL)',
    );
    old.execute(
      "INSERT INTO artwork_overrides VALUES ('dashboard.default','saved.img','1')",
    );
    old.execute(
      'CREATE TABLE lock_settings (id INTEGER PRIMARY KEY, mode INTEGER NOT NULL, credential_slot TEXT, failed_attempts INTEGER NOT NULL DEFAULT 0, retry_deadline INTEGER NOT NULL DEFAULT 0, retry_boot TEXT NOT NULL DEFAULT \'\')',
    );
    old.execute(
      "INSERT INTO lock_settings(id,mode,credential_slot) VALUES (1,2,'existing')",
    );
    old.execute(
      'CREATE TABLE onboarding_profiles (id INTEGER PRIMARY KEY, motivation TEXT NOT NULL, modules INTEGER NOT NULL, completed INTEGER NOT NULL)',
    );
    old.execute("INSERT INTO onboarding_profiles VALUES (1,'Emlék',7,1)");
    old.execute(
      'CREATE TABLE sponsor_contacts (id INTEGER PRIMARY KEY, name TEXT NOT NULL, phone TEXT NOT NULL)',
    );
    old.execute("INSERT INTO sponsor_contacts VALUES (1,'Anna','+361234')");
    old.execute(
      'CREATE TABLE onboarding_drafts (id INTEGER PRIMARY KEY, payload TEXT NOT NULL)',
    );
    old.execute('PRAGMA user_version = 3');
    old.dispose();
    var db = HajnalDatabase(NativeDatabase(file));
    var repo = StyleRepository(db);
    expect((await repo.load()).definitions.texts[TextRole.title1]!.size, 28);
    expect((await db.select(db.recoveryPeriods).getSingle()).id, 7);
    expect(
      (await db.select(db.artworkOverrides).getSingle()).filename,
      'saved.img',
    );
    expect(
      (await db.select(db.lockSettings).getSingle()).credentialSlot,
      'existing',
    );
    expect(
      (await db.select(db.onboardingProfiles).getSingle()).motivation,
      'Emlék',
    );
    expect((await db.select(db.sponsorContacts).getSingle()).name, 'Anna');
    await db.customStatement(
      "INSERT INTO style_settings VALUES (1,7,'broken')",
    );
    expect((await repo.load()).revision, 7);
    expect((await repo.load()).definitions.texts[TextRole.title1]!.size, 28);
    await repo.save(StyleDefinitions.defaults(), 7);
    await db.close();
    db = HajnalDatabase(NativeDatabase(file));
    repo = StyleRepository(db);
    expect((await repo.load()).revision, 8);
    expect(
      (await db.select(db.onboardingProfiles).getSingle()).motivation,
      'Emlék',
    );
    await db.close();
    await directory.delete(recursive: true);
  });
}
