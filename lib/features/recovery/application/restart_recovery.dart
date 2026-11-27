abstract interface class RestartRecoveryStore {
  Future<void> restart(int activePeriodId, DateTime now);
}

class RestartRecovery {
  const RestartRecovery(this.store, this.now);
  final RestartRecoveryStore store;
  final DateTime Function() now;
  Future<void> call(int activePeriodId) => store.restart(activePeriodId, now());
}
