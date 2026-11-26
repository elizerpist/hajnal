import 'dart:convert';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/core/database/hajnal_database.dart';
import 'package:hajnal/features/app_lock/application/lock_store.dart';
import 'package:hajnal/features/app_lock/data/lock_repository.dart';
import 'package:hajnal/features/app_lock/data/pin_hasher.dart';
import 'package:hajnal/features/app_lock/domain/lock_policy.dart';

class MemorySecrets implements SecretStore {
  final values = <String, String>{};
  bool failWrite = false;
  @override
  Future<String?> read(String key) async => values[key];
  @override
  Future<void> write(String key, String value) async {
    if (failWrite) throw StateError('secure storage unavailable');
    values[key] = value;
  }

  @override
  Future<void> delete(String key) async => values.remove(key);
}

class FastHasher extends PinHasher {
  @override
  Future<String> create(String pin) async => jsonEncode({
    'version': 1,
    'salt': base64Encode(List.filled(16, 1)),
    'hash': base64Encode(List.filled(32, pin == '001234' ? 1 : 2)),
  });
  @override
  Future<bool> verify(String pin, String record) async =>
      (jsonDecode(await create(pin)) as Map)['hash'] ==
      (jsonDecode(record) as Map)['hash'];
}

void main() {
  test('PIN change invalidates the old PIN and rejects short input', () async {
    final db = HajnalDatabase(NativeDatabase.memory());
    final repo = LockRepository(db, MemorySecrets(), FastHasher());
    await expectLater(
      repo.setMode(LockMode.pin, newPin: '12345'),
      throwsArgumentError,
    );
    expect((await repo.read()).mode, LockMode.off);
    await repo.setMode(LockMode.pin, newPin: '001234');
    await repo.setMode(LockMode.pin, newPin: '999999');
    expect(await repo.verifyPin('001234', uptime: 1, boot: 'a'), isFalse);
    expect(await repo.verifyPin('999999', uptime: 1, boot: 'a'), isTrue);
    await db.close();
  });
  test('interrupted DB switch keeps the original verified credential', () async {
    final db = HajnalDatabase(NativeDatabase.memory());
    final secrets = MemorySecrets();
    final repo = LockRepository(db, secrets, FastHasher());
    await repo.setMode(LockMode.pin, newPin: '001234');
    await db.customStatement(
      "CREATE TRIGGER fail_lock BEFORE UPDATE ON lock_settings BEGIN SELECT RAISE(ABORT, 'write failed'); END",
    );
    await expectLater(
      repo.setMode(LockMode.pin, newPin: '999999'),
      throwsA(anything),
    );
    expect((await repo.read()).mode, LockMode.pin);
    await db.customStatement('DROP TRIGGER fail_lock');
    expect(await repo.verifyPin('001234', uptime: 1, boot: 'a'), isTrue);
    await db.close();
  });
  test('secure write failure preserves old active setting and PIN', () async {
    final db = HajnalDatabase(NativeDatabase.memory());
    final secrets = MemorySecrets();
    final repo = LockRepository(db, secrets, FastHasher());
    expect((await repo.read()).mode, LockMode.off);
    await repo.setMode(LockMode.pin, newPin: '001234');
    secrets.failWrite = true;
    await expectLater(
      repo.setMode(LockMode.pin, newPin: '999999'),
      throwsStateError,
    );
    expect((await repo.read()).mode, LockMode.pin);
    expect(await repo.verifyPin('001234', uptime: 1, boot: 'boot'), isTrue);
    await db.close();
  });
  test(
    'switching active policies keeps the same PIN and protected mode',
    () async {
      final db = HajnalDatabase(NativeDatabase.memory());
      final repo = LockRepository(db, MemorySecrets(), FastHasher());
      await repo.setMode(LockMode.pin, newPin: '001234');
      for (final mode in [
        LockMode.biometricOrPin,
        LockMode.pinAndBiometric,
        LockMode.pin,
      ]) {
        await repo.setMode(mode);
        expect((await repo.read()).mode, mode);
        expect(await repo.verifyPin('001234', uptime: 1, boot: 'a'), isTrue);
      }
      await db.close();
    },
  );
  test('corrupt active mode cannot weaken an existing policy', () async {
    final db = HajnalDatabase(NativeDatabase.memory());
    final repo = LockRepository(db, MemorySecrets(), FastHasher());
    await repo.setMode(LockMode.pinAndBiometric, newPin: '001234');
    await db.customStatement('UPDATE lock_settings SET mode = 1');
    await expectLater(repo.read(), throwsFormatException);
    await db.close();
  });
  test('corrupt mode cannot silently switch an active lock off', () async {
    final db = HajnalDatabase(NativeDatabase.memory());
    final repo = LockRepository(db, MemorySecrets(), FastHasher());
    await repo.setMode(LockMode.pin, newPin: '001234');
    await db.customStatement('UPDATE lock_settings SET mode = 0');
    await expectLater(repo.read(), throwsStateError);
    await db.close();
  });
  test('authorized disable clears the credential pointer', () async {
    final db = HajnalDatabase(NativeDatabase.memory());
    final secrets = MemorySecrets();
    final repo = LockRepository(db, secrets, FastHasher());
    await repo.setMode(LockMode.pin, newPin: '001234');
    await repo.setMode(LockMode.off);
    expect((await repo.read()).mode, LockMode.off);
    expect(secrets.values, isEmpty);
    await db.close();
  });
  test('missing or corrupt active secret fails closed', () async {
    final db = HajnalDatabase(NativeDatabase.memory());
    final secrets = MemorySecrets();
    final repo = LockRepository(db, secrets, FastHasher());
    await repo.setMode(LockMode.pin, newPin: '001234');
    final slot = (await repo.read()).slot!;
    secrets.values[slot] = 'invalid';
    await expectLater(repo.read(), throwsFormatException);
    secrets.values.remove(slot);
    await expectLater(repo.read(), throwsStateError);
    await db.close();
  });
  test(
    'failed attempt delay persists when the database is closed and reopened',
    () async {
      final dir = await Directory.systemTemp.createTemp('hajnal-lock-restart-');
      final path = File('${dir.path}/hajnal.sqlite');
      final secrets = MemorySecrets();
      var db = HajnalDatabase(NativeDatabase(path));
      var repo = LockRepository(db, secrets, FastHasher());
      await repo.setMode(LockMode.pin, newPin: '001234');
      for (var i = 0; i < 3; i++) {
        expect(
          await repo.verifyPin('999999', uptime: 100, boot: 'boot'),
          isFalse,
        );
      }
      await db.close();
      db = HajnalDatabase(NativeDatabase(path));
      repo = LockRepository(db, secrets, FastHasher());
      expect(await repo.retryRemaining(uptime: 101, boot: 'boot'), 4);
      expect(await repo.retryRemaining(uptime: 0, boot: 'reboot'), 5);
      await db.close();
      await dir.delete(recursive: true);
    },
  );
  test('rate limiting survives controller recreation and reboot', () async {
    final db = HajnalDatabase(NativeDatabase.memory());
    final secrets = MemorySecrets();
    var repo = LockRepository(db, secrets, FastHasher());
    await repo.setMode(LockMode.pin, newPin: '001234');
    for (var i = 0; i < 3; i++) {
      expect(await repo.verifyPin('999999', uptime: 100, boot: 'a'), isFalse);
    }
    repo = LockRepository(db, secrets, FastHasher());
    expect(await repo.retryRemaining(uptime: 101, boot: 'a'), 4);
    expect(await repo.retryRemaining(uptime: 2, boot: 'b'), 5);
    expect(await repo.retryRemaining(uptime: 8, boot: 'b'), 0);
    expect(await repo.verifyPin('001234', uptime: 8, boot: 'b'), isTrue);
    await db.close();
  });
}
