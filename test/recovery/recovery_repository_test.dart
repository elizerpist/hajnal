import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/core/database/hajnal_database.dart';
import 'package:hajnal/features/recovery/data/recovery_repository.dart';

void main() {
  test(
    'initialization survives reopening and never creates two active periods',
    () async {
      final directory = await Directory.systemTemp.createTemp('hajnal-db-');
      final file = File('${directory.path}/hajnal.sqlite');
      try {
        var db = HajnalDatabase(NativeDatabase(file));
        var repository = RecoveryRepository(db);
        final results = await Future.wait([
          repository.initialize(DateTime(2024, 2, 29), DateTime(2024, 3, 1)),
          repository.initialize(DateTime(2024, 2, 28), DateTime(2024, 3, 1)),
        ]);
        expect(results[0].id, results[1].id);
        await db.close();
        db = HajnalDatabase(NativeDatabase(file));
        repository = RecoveryRepository(db);
        expect((await repository.active()).id, results[0].id);
        expect(await repository.countActive(), 1);
        await db.close();
      } finally {
        await directory.delete(recursive: true);
      }
    },
  );
  test('future dates are rejected before writing', () async {
    final db = HajnalDatabase(NativeDatabase.memory());
    final repository = RecoveryRepository(db);
    await expectLater(
      repository.initialize(DateTime(2024, 4, 2), DateTime(2024, 4, 1)),
      throwsArgumentError,
    );
    expect(await repository.countActive(), 0);
    await db.close();
  });
  test('database enforces unique active period and integrity', () async {
    final db = HajnalDatabase(NativeDatabase.memory());
    await db.customStatement(
      "INSERT INTO recovery_periods (start_local_date, created_at_utc) VALUES ('2024-01-01', 0)",
    );
    await expectLater(
      db.customStatement(
        "INSERT INTO recovery_periods (start_local_date, created_at_utc) VALUES ('2024-01-02', 0)",
      ),
      throwsA(anything),
    );
    final check = await db.customSelect('PRAGMA integrity_check').getSingle();
    expect(check.data.values.single, 'ok');
    final foreignKeys = await db
        .customSelect('PRAGMA foreign_keys')
        .getSingle();
    expect(foreignKeys.data.values.single, 1);
    await db.close();
  });
  test(
    'failed insert rolls back and repeated initialization does not alter date',
    () async {
      final db = HajnalDatabase(NativeDatabase.memory());
      final repo = RecoveryRepository(db);
      await db.customStatement(
        "CREATE TRIGGER reject_period BEFORE INSERT ON recovery_periods BEGIN SELECT RAISE(ABORT, 'failure'); END",
      );
      await expectLater(
        repo.initialize(DateTime(2024, 1, 1), DateTime(2024, 1, 2)),
        throwsA(anything),
      );
      expect(await repo.countActive(), 0);
      await db.customStatement('DROP TRIGGER reject_period');
      final first = await repo.initialize(
        DateTime(2024, 1, 1),
        DateTime(2024, 1, 2),
      );
      final second = await repo.initialize(
        DateTime(2023, 1, 1),
        DateTime(2024, 1, 2),
      );
      expect(second.id, first.id);
      expect(second.startLocalDate, '2024-01-01');
      await db.close();
    },
  );
}
