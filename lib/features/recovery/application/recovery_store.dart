abstract interface class RecoveryStore {
  Stream<DateTime?> watchStart();
  Future<void> initialize(DateTime date, DateTime now);
}
