import '../application/recovery_store.dart';
import 'recovery_repository.dart';

class DriftRecoveryStore implements RecoveryStore {
  DriftRecoveryStore(this.repository);
  final RecoveryRepository repository;

  @override
  Stream<ActiveRecovery?> watchStart() => repository.watchStart();

  @override
  Future<void> initialize(DateTime date, DateTime now) async {
    await repository.initialize(date, now);
  }

  @override
  Future<void> correctStart(int id, DateTime date, DateTime now) =>
      repository.correctStart(id, date, now);
}
