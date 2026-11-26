import 'recovery_store.dart';
import '../domain/calendar.dart';

class InitializeRecovery {
  const InitializeRecovery(this.store);
  final RecoveryStore store;

  Future<void> call(DateTime start, DateTime now) {
    validatedStartDate(start, now);
    return store.initialize(start, now);
  }
}
