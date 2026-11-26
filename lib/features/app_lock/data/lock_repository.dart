import 'dart:convert';
import 'dart:math';
import 'package:drift/drift.dart';
import '../../../core/database/hajnal_database.dart';
import '../application/lock_store.dart';
import '../domain/lock_policy.dart';
import 'pin_hasher.dart';

class LockRepository implements LockStore {
  LockRepository(this._db, this._secrets, this._hasher);
  final HajnalDatabase _db;
  final SecretStore _secrets;
  final PinHasher _hasher;
  Future<void> _pending = Future.value();

  Future<T> _serial<T>(Future<T> Function() action) {
    final next = _pending.then((_) => action());
    _pending = next.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return next;
  }

  Future<LockSetting> _row() async {
    final rows = await _db.select(_db.lockSettings).get();
    if (rows.length != 1 ||
        rows.single.id != 1 ||
        rows.single.mode < 0 ||
        rows.single.mode >= LockMode.values.length ||
        rows.single.failedAttempts < 0 ||
        rows.single.retryDeadline < 0) {
      throw StateError('Invalid lock settings');
    }
    return rows.single;
  }

  Future<String> _credential(LockSetting row) async {
    final slot = row.credentialSlot;
    if (slot == null || !RegExp(r'^lock-[a-f0-9]{32}$').hasMatch(slot)) {
      throw StateError('Missing lock credential');
    }
    final credential = await _secrets.read(slot);
    if (credential == null) throw StateError('Missing lock credential');
    final decoded = jsonDecode(credential);
    if (decoded is! Map ||
        decoded['version'] != 1 ||
        decoded['mode'] != row.mode ||
        decoded['salt'] is! String ||
        decoded['hash'] is! String ||
        base64Decode(decoded['salt'] as String).length != 16 ||
        base64Decode(decoded['hash'] as String).length != 32) {
      throw const FormatException('Invalid lock credential');
    }
    return credential;
  }

  RetryState _retry(LockSetting row) => RetryState(
    attempts: row.failedAttempts,
    deadlineUptime: row.retryDeadline,
    boot: row.retryBoot,
  );

  @override
  Future<StoredLock> read() => _serial(() async {
    final row = await _row();
    final mode = LockMode.values[row.mode];
    if (mode != LockMode.off) {
      await _credential(row);
    } else if (row.credentialSlot != null) {
      throw StateError('Invalid off state');
    }
    return StoredLock(mode: mode, slot: row.credentialSlot, retry: _retry(row));
  });

  @override
  Future<void> setMode(LockMode mode, {String? newPin}) => _serial(() async {
    final before = await _row();
    if (mode == LockMode.off && newPin != null) {
      throw ArgumentError('PIN cannot be set while lock is off');
    }
    String? slot;
    if (mode != LockMode.off) {
      final String base;
      if (newPin != null) {
        if (!validPin(newPin)) throw ArgumentError('Invalid PIN');
        base = await _hasher.create(newPin);
      } else {
        base = await _credential(before);
      }
      final data = Map<String, dynamic>.from(jsonDecode(base) as Map);
      data['mode'] = mode.index;
      final encoded = jsonEncode(data);
      final random = Random.secure();
      slot =
          'lock-${List.generate(16, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0')).join()}';
      await _secrets.write(slot, encoded);
      if (await _secrets.read(slot) != encoded) {
        throw StateError('Credential write failed');
      }
    }
    await _db.transaction(() async {
      final current = await _row();
      if (current.mode != before.mode ||
          current.credentialSlot != before.credentialSlot) {
        throw StateError('Lock settings changed');
      }
      final count =
          await (_db.update(
            _db.lockSettings,
          )..where((x) => x.id.equals(1))).write(
            LockSettingsCompanion(
              mode: Value(mode.index),
              credentialSlot: Value(slot),
              failedAttempts: const Value(0),
              retryDeadline: const Value(0),
              retryBoot: const Value(''),
            ),
          );
      if (count != 1) throw StateError('Lock settings missing');
    });
    if (before.credentialSlot != null && before.credentialSlot != slot) {
      try {
        await _secrets.delete(before.credentialSlot!);
      } catch (_) {
        /* old slot is not authoritative */
      }
    }
  });

  Future<int> _remaining(LockSetting row, int uptime, String boot) async {
    var retry = _retry(row);
    if (retry.attempts >= 3 && retry.boot != boot) {
      retry = RetryState(
        attempts: retry.attempts,
        deadlineUptime: uptime + retry.delaySeconds,
        boot: boot,
      );
      await (_db.update(_db.lockSettings)..where((x) => x.id.equals(1))).write(
        LockSettingsCompanion(
          retryDeadline: Value(retry.deadlineUptime),
          retryBoot: Value(boot),
        ),
      );
    }
    return retry.remaining(uptime: uptime, boot: boot);
  }

  @override
  Future<int> retryRemaining({required int uptime, required String boot}) =>
      _serial(() async => _remaining(await _row(), uptime, boot));

  @override
  Future<bool> verifyPin(
    String pin, {
    required int uptime,
    required String boot,
  }) => _serial(() async {
    final row = await _row();
    if (LockMode.values[row.mode] == LockMode.off) {
      throw StateError('Lock is off');
    }
    if (await _remaining(row, uptime, boot) > 0) return false;
    final correct = await _hasher.verify(pin, await _credential(row));
    final retry = correct
        ? const RetryState()
        : _retry(row).failed(uptime: uptime, boot: boot);
    await (_db.update(_db.lockSettings)..where((x) => x.id.equals(1))).write(
      LockSettingsCompanion(
        failedAttempts: Value(retry.attempts),
        retryDeadline: Value(retry.deadlineUptime),
        retryBoot: Value(retry.boot),
      ),
    );
    return correct;
  });
}
