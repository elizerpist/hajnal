import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/app/bootstrap_controller.dart';
import 'package:hajnal/features/recovery/application/recovery_store.dart';

class FakeStore implements RecoveryStore {
  bool failSave = false;
  Completer<void>? correctionPending;
  final controller = StreamController<ActiveRecovery?>.broadcast();
  @override
  Stream<ActiveRecovery?> watchStart() => controller.stream;
  @override
  Future<void> correctStart(int id, DateTime date, DateTime now) async {
    if (correctionPending != null) await correctionPending!.future;
    if (id != 1) throw StateError("stale");
    controller.add(ActiveRecovery(id, date));
  }

  @override
  Future<void> initialize(DateTime date, DateTime now) async {
    if (failSave) throw StateError('failed write');
    controller.add(ActiveRecovery(1, date));
  }
}

void main() {
  test('duplicate correction is refused while one save is pending', () async {
    final store = FakeStore()..correctionPending = Completer<void>();
    final controller = BootstrapController(store, () => DateTime(2024, 4, 1));
    store.controller.add(ActiveRecovery(1, DateTime(2024, 3, 1)));
    await Future<void>.delayed(Duration.zero);
    final first = controller.correctStart(1, DateTime(2024, 3, 2));
    expect(await controller.correctStart(1, DateTime(2024, 3, 3)), false);
    store.correctionPending!.complete();
    expect(await first, true);
    controller.dispose();
    await store.controller.close();
  });
  test(
    'bootstrap waits for storage and preserves errors instead of empty data',
    () async {
      final store = FakeStore();
      final controller = BootstrapController(store, () => DateTime(2024, 4, 1));
      expect(controller.loading, true);
      store.controller.addError(StateError('db failure'));
      await Future<void>.delayed(Duration.zero);
      expect(controller.loading, false);
      expect(controller.error, isNotNull);
      expect(controller.startDate, isNull);
      controller.dispose();
      await store.controller.close();
    },
  );
  test('an empty store and saved date are distinct', () async {
    final store = FakeStore();
    final controller = BootstrapController(store, () => DateTime(2024, 4, 1));
    store.controller.add(null);
    await Future<void>.delayed(Duration.zero);
    expect(controller.loading, false);
    expect(controller.startDate, isNull);
    await controller.initialize(DateTime(2024, 3, 31));
    await Future<void>.delayed(Duration.zero);
    expect(controller.startDate, DateTime(2024, 3, 31));
    expect(controller.tracker.days, 1);
    controller.dispose();
    await store.controller.close();
  });
  test('save failure stays distinct from database loading error', () async {
    final store = FakeStore()..failSave = true;
    final controller = BootstrapController(store, () => DateTime(2024, 4, 1));
    store.controller.add(null);
    await Future<void>.delayed(Duration.zero);
    expect(await controller.initialize(DateTime(2024, 4, 1)), false);
    expect(controller.startDate, isNull);
    expect(controller.error, isNull);
    expect(controller.saveError, isNotNull);
    controller.dispose();
    await store.controller.close();
  });
}
