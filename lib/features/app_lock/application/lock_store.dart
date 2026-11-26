import '../domain/lock_policy.dart';

class StoredLock {
  const StoredLock({
    required this.mode,
    required this.slot,
    required this.retry,
  });
  final LockMode mode;
  final String? slot;
  final RetryState retry;
}

abstract interface class LockStore {
  Future<StoredLock> read();
  Future<void> setMode(LockMode mode, {String? newPin});
  Future<bool> verifyPin(
    String pin, {
    required int uptime,
    required String boot,
  });
  Future<int> retryRemaining({required int uptime, required String boot});
}

abstract interface class SecretStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}
