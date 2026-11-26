import 'recovery_store.dart';

class InitializeRecovery {
  const InitializeRecovery(this.store);
  final RecoveryStore store;

  Future<void> call(DateTime start, DateTime now) {
    final startDay = DateTime.utc(start.year, start.month, start.day);
    final today = DateTime.utc(now.year, now.month, now.day);
    if (startDay.isAfter(today)) throw ArgumentError('Future start date');
    return store.initialize(start, now);
  }
}
