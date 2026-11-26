class ActiveRecovery {
  const ActiveRecovery(this.id, this.startDate);
  final int id;
  final DateTime startDate;
}

abstract interface class RecoveryStore {
  Stream<ActiveRecovery?> watchStart();
  Future<void> initialize(DateTime date, DateTime now);
  Future<void> correctStart(int id, DateTime date, DateTime now);
}
