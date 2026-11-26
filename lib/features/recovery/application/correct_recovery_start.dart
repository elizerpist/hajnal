import '../domain/calendar.dart';
import 'recovery_store.dart';

class CorrectRecoveryStart {
  const CorrectRecoveryStart(this.store);
  final RecoveryStore store;

  Future<void> call(int id, DateTime date, DateTime now) {
    validatedStartDate(date, now);
    return store.correctStart(id, date, now);
  }
}
