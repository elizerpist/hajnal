import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/features/practice/application/practice_controller.dart';
import 'package:hajnal/features/practice/application/practice_store.dart';
import 'practice_widget_test.dart' show MemoryPracticeStore;

class DelayedStore extends MemoryPracticeStore {
  final gate = Completer<void>();
  int writes = 0;
  @override
  Future<void> add(PracticeContent content, {required bool activate}) async {
    writes++;
    await gate.future;
    await super.add(content, activate: activate);
  }
}

void main() {
  test(
    'double save has one write and failures keep input available for retry',
    () async {
      final store = DelayedStore();
      final controller = PracticeController(store);
      expect(
        await controller.add(
          const PracticeContent(text: 'Észrevettem, hogy'),
          true,
        ),
        false,
      );
      expect(store.writes, 0);
      const content = PracticeContent(text: 'Saját gondolat');
      final first = controller.add(content, true);
      final second = controller.add(content, true);
      expect(await second, false);
      expect(store.writes, 1);
      store.gate.complete();
      expect(await first, true);
      expect(controller.active?.text, 'Saját gondolat');
      expect(
        await controller.saveChanges(
          -1,
          const PracticeContent(text: 'Megőrzött piszkozat'),
        ),
        false,
      );
      expect(controller.error, isNotNull);
      expect(controller.active?.text, 'Saját gondolat');
      controller.dispose();
      await store.events.close();
    },
  );
  test('portable practice snapshot validates and roundtrips independently', () {
    const snapshot = PracticeSnapshot(title: 'Cím', text: 'Eredeti gondolat');
    final restored = PracticeSnapshot.fromJson(snapshot.toJson());
    expect(restored.title, 'Cím');
    expect(restored.text, 'Eredeti gondolat');
    expect(
      () => PracticeSnapshot.fromJson({'text': 12}),
      throwsFormatException,
    );
  });
}
