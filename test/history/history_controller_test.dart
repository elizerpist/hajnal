import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/features/history/application/history_controller.dart';
import 'package:hajnal/features/history/application/history_store.dart';

class FakeHistory implements HistoryStore {
  final changes = StreamController<List<HistoryPeriod>>.broadcast(sync: true);
  @override
  Stream<List<HistoryPeriod>> watch() => changes.stream;
}

HistoryPeriod period(
  int id, {
  bool active = true,
  List<HistoryNote> notes = const [],
}) => HistoryPeriod(
  id: id,
  start: DateTime(2024, 1, 1),
  createdAt: DateTime.utc(2024),
  closedAt: active ? null : DateTime.utc(2024, 1, 4),
  notes: notes,
);

void main() {
  test('follows restart only while following the current period', () async {
    final store = FakeHistory();
    final controller = HistoryController(store, () => DateTime(2024, 1, 5));
    store.changes.add([period(1)]);
    expect(controller.selectedId, 1);
    store.changes.add([period(1, active: false), period(2)]);
    expect(controller.selectedId, 2);
    controller.select(1);
    store.changes.add([
      period(1, active: false),
      period(2, active: false),
      period(3),
    ]);
    expect(controller.selectedId, 1);
    controller.select(3);
    store.changes.add([
      period(1, active: false),
      period(2, active: false),
      period(3, active: false),
      period(4),
    ]);
    expect(controller.selectedId, 4);
    controller.dispose();
    await store.changes.close();
  });
  test('events and note count share the same underlying period', () async {
    final store = FakeHistory();
    final controller = HistoryController(store, () => DateTime(2024, 1, 5));
    store.changes.add([
      period(1, notes: [HistoryNote(12, 'szöveg', DateTime.utc(2024, 1, 3))]),
    ]);
    expect(controller.days(controller.selected!), 4);
    expect(
      controller.events(controller.selected!).map((e) => e.type),
      containsAll([HistoryEventType.start, HistoryEventType.note]),
    );
    expect(
      controller
          .events(controller.selected!)
          .singleWhere((e) => e.type == HistoryEventType.note)
          .noteId,
      12,
    );
    controller.dispose();
    await store.changes.close();
  });
}
