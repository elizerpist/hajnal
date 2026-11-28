import 'dart:io';
import 'dart:async';
import 'package:drift/drift.dart' show Value;

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/core/database/hajnal_database.dart';
import 'package:hajnal/features/reflection/data/reflection_repository.dart';
import 'package:hajnal/features/recovery/data/recovery_repository.dart';
import 'package:hajnal/features/history/data/history_repository.dart';
import 'package:hajnal/features/practice/application/practice_store.dart';
import 'package:hajnal/features/practice/data/practice_repository.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  test(
    'module changes do not discard a draft and empty finish is not an event',
    () async {
      final db = HajnalDatabase(NativeDatabase.memory());
      final period = await RecoveryRepository(
        db,
      ).initialize(DateTime(2026, 1, 1), DateTime(2026, 1, 2));
      final repo = ReflectionRepository(db, PracticeRepository(db));
      await db
          .into(db.onboardingProfiles)
          .insert(
            OnboardingProfilesCompanion.insert(
              id: const Value(1),
              modules: const Value(1),
            ),
          );
      final enabled = StreamIterator(repo.watchEnabled());
      expect(await enabled.moveNext(), isTrue);
      expect(enabled.current, isTrue);
      final entry = await repo.open(period.id, DateTime(2026, 1, 2));
      await repo.finish(entry);
      expect(
        (await HistoryRepository(db).watch().first).single.reflections,
        isEmpty,
      );
      await repo.saveDraft(entry.copyWith(text: 'Piszkozat'));
      final disabling = enabled.moveNext();
      await (db.update(db.onboardingProfiles)..where((p) => p.id.equals(1)))
          .write(const OnboardingProfilesCompanion(modules: Value(0)));
      expect(await disabling, isTrue);
      expect(enabled.current, isFalse);
      final enabling = enabled.moveNext();
      await (db.update(db.onboardingProfiles)..where((p) => p.id.equals(1)))
          .write(const OnboardingProfilesCompanion(modules: Value(1)));
      expect(await enabling, isTrue);
      expect(enabled.current, isTrue);
      expect(
        (await repo.open(period.id, DateTime(2026, 1, 2))).text,
        'Piszkozat',
      );
      await expectLater(
        db.customStatement(
          "INSERT INTO daily_reflections (period_id, local_date) VALUES (?, ?)",
          [period.id, '2026-01-02'],
        ),
        throwsA(anything),
      );
      await enabled.cancel();
      await db.close();
    },
  );
  test(
    'draft survives reopening and one period/day keeps a stable id',
    () async {
      final dir = await Directory.systemTemp.createTemp('reflection-');
      final file = File('${dir.path}/db.sqlite');
      var db = HajnalDatabase(NativeDatabase(file));
      final period = await RecoveryRepository(
        db,
      ).initialize(DateTime(2026, 1, 1), DateTime(2026, 1, 2));
      var repository = ReflectionRepository(db, PracticeRepository(db));
      var draft = await repository.open(period.id, DateTime(2026, 1, 2));
      draft = draft.copyWith(mood: 3, text: 'Megmarad');
      await repository.saveDraft(draft);
      await db.close();
      db = HajnalDatabase(NativeDatabase(file));
      repository = ReflectionRepository(db, PracticeRepository(db));
      final reopened = await repository.open(period.id, DateTime(2026, 1, 2));
      expect(reopened.id, draft.id);
      expect(reopened.text, 'Megmarad');
      expect(reopened.mood, 3);
      expect(reopened.completed, isFalse);
      await repository.finish(reopened);
      expect(
        (await repository.open(period.id, DateTime(2026, 1, 2))).completed,
        isTrue,
      );
      expect((await db.select(db.dailyReflections).get()), hasLength(1));
      await db.close();
      await dir.delete(recursive: true);
    },
  );
  test(
    'v7 upgrade preserves period, snapshot and history completion',
    () async {
      final dir = await Directory.systemTemp.createTemp('reflection-v7-');
      final file = File('${dir.path}/db.sqlite');
      var db = HajnalDatabase(NativeDatabase(file));
      final period = await RecoveryRepository(
        db,
      ).initialize(DateTime(2026, 1, 1), DateTime(2026, 1, 2));
      final cards = PracticeRepository(db);
      await cards.add(
        const PracticeContent(title: 'Cím', text: 'Eredeti'),
        activate: true,
      );
      final card = (await cards.watch().first).single;
      await db.close();
      final old = sqlite.sqlite3.open(file.path);
      old.execute('DROP TABLE daily_reflections');
      old.execute('PRAGMA user_version = 7');
      old.dispose();
      db = HajnalDatabase(NativeDatabase(file));
      final repository = ReflectionRepository(db, PracticeRepository(db));
      final draft = await repository.open(period.id, DateTime(2026, 1, 2));
      expect(draft.snapshot?.text, 'Eredeti');
      final changedCards = PracticeRepository(db);
      await changedCards.add(
        const PracticeContent(text: 'Másik aktív'),
        activate: true,
      );
      await changedCards.saveChanges(
        card.id,
        const PracticeContent(text: 'Átírt'),
      );
      expect((await repository.openById(draft.id)).snapshot?.text, 'Eredeti');
      await changedCards.remove(card.id);
      expect((await repository.openById(draft.id)).snapshot?.text, 'Eredeti');
      expect(
        (await HistoryRepository(db).watch().first).single.reflections,
        isEmpty,
      );
      await repository.finish(draft.copyWith(mood: 4));
      var history = (await HistoryRepository(
        db,
      ).watch().first).single.reflections;
      expect(history, hasLength(1));
      expect(history.single.id, draft.id);
      await repository.finish(
        (await repository.openById(draft.id)).copyWith(text: 'Új szöveg'),
      );
      history = (await HistoryRepository(db).watch().first).single.reflections;
      expect(history, hasLength(1));
      expect(history.single.text, 'Új szöveg');
      await db.close();
      db = HajnalDatabase(NativeDatabase(file));
      expect(
        (await ReflectionRepository(
          db,
          PracticeRepository(db),
        ).openById(draft.id)).snapshot?.text,
        'Eredeti',
      );
      await db.close();
      await dir.delete(recursive: true);
    },
  );
  test(
    'history watches completed reflection live without duplication',
    () async {
      final db = HajnalDatabase(NativeDatabase.memory());
      final period = await RecoveryRepository(
        db,
      ).initialize(DateTime(2026, 1, 1), DateTime(2026, 1, 2));
      final repository = ReflectionRepository(db, PracticeRepository(db));
      final draft = await repository.open(period.id, DateTime(2026, 1, 2));
      final stream = StreamIterator(HistoryRepository(db).watch());
      await stream.moveNext();
      expect(stream.current.single.reflections, isEmpty);
      final next = stream.moveNext();
      await repository.finish(draft.copyWith(mood: 2));
      expect(await next, isTrue);
      expect(stream.current.single.reflections.single.id, draft.id);
      final changed = stream.moveNext();
      await repository.finish(
        (await repository.openById(draft.id)).copyWith(text: 'Itt van'),
      );
      expect(await changed, isTrue);
      expect(stream.current.single.reflections.single.text, 'Itt van');
      await stream.cancel();
      await db.close();
    },
  );
}
