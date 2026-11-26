import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/app/bootstrap_controller.dart';
import 'package:hajnal/features/recovery/application/recovery_store.dart';

class FakeStore implements RecoveryStore {
  final controller = StreamController<DateTime?>.broadcast();
  @override
  Stream<DateTime?> watchStart() => controller.stream;
  @override
  Future<void> initialize(DateTime date, DateTime now) async {
    controller.add(date);
  }
}

void main() {
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
}
