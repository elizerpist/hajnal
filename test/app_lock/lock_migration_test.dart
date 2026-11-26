import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/core/database/hajnal_database.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('v1 upgrade preserves period and artwork and starts lock off', () async {
    final dir = await Directory.systemTemp.createTemp('hajnal-lock-migration-');
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
      "INSERT INTO recovery_periods VALUES (41, '2024-01-02', 1704240000, NULL)",
    );
    old.execute(
      "INSERT INTO artwork_overrides VALUES ('dashboard.default', 'artwork-example.img', 'rev')",
    );
    old.execute('PRAGMA user_version = 1');
    old.dispose();
    final db = HajnalDatabase(NativeDatabase(file));
    final period = await db.select(db.recoveryPeriods).getSingle();
    final artwork = await db.select(db.artworkOverrides).getSingle();
    final lock = await db.select(db.lockSettings).getSingle();
    expect(period.id, 41);
    expect(period.startLocalDate, '2024-01-02');
    expect(artwork.filename, 'artwork-example.img');
    expect(lock.mode, 0);
    expect(lock.credentialSlot, isNull);
    await db.close();
    await dir.delete(recursive: true);
  });
}
