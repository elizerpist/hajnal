import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/features/panic/application/panic_store.dart';
import 'package:hajnal/features/panic/application/survival_controller.dart';
import 'package:hajnal/features/panic/domain/survival_session.dart';

class MemoryPanicStore implements PanicStore {
  SurvivalSession? saved;
  final notes = <String>[];
  bool failSession = false;
  @override
  Future<String> motivation() async => 'A családom';
  @override
  Future<SurvivalSession?> loadSession() async => saved;
  @override
  Future<void> saveSession(SurvivalSession session) async {
    if (failSession) throw StateError('save failed');
    saved = session;
  }

  @override
  Future<void> saveNote(String body, DateTime now) async {
    notes.add(body);
  }
}

void main() {
  test('failed persistence is reported and can be retried', () async {
    final store = MemoryPanicStore();
    final flow = SurvivalController(store, () => DateTime.utc(2025));
    await flow.open();
    await flow.idle;
    store.failSession = true;
    flow.setNote('Megőrzendő');
    await flow.idle;
    expect(flow.error, isNotNull);
    expect(await flow.saveNote(), isFalse);
    expect(store.notes, isEmpty);
    store.failSession = false;
    flow.retrySave();
    await flow.idle;
    expect(flow.error, isNull);
    expect(await flow.saveNote(), isTrue);
    expect(store.notes, ['Megőrzendő']);
    flow.dispose();
  });
  test(
    'time is measured from the start even across background and resume',
    () async {
      final store = MemoryPanicStore();
      var now = DateTime.utc(2025, 1, 1, 12);
      var flow = SurvivalController(store, () => now);
      await flow.open();
      flow.next();
      flow.next();
      flow.chooseWater('drank');
      await flow.idle;
      flow.dispose();
      now = now.add(const Duration(minutes: 8));
      flow = SurvivalController(store, () => now);
      await flow.open();
      expect(flow.resumed, isTrue);
      expect(flow.session!.step, 3);
      expect(flow.remaining, const Duration(minutes: 7));
      now = now.add(const Duration(minutes: 9));
      expect(flow.remaining, Duration.zero);
      expect(flow.session!.step, 3);
      await flow.idle;
      flow.dispose();
    },
  );

  test('note persists and reassessment offers each branch', () async {
    final store = MemoryPanicStore();
    final flow = SurvivalController(store, () => DateTime.utc(2025));
    await flow.open();
    flow.setNote('Emlékeztető');
    expect(await flow.saveNote(), isTrue);
    expect(store.notes, ['Emlékeztető']);
    for (var i = 0; i < 6; i++) {
      flow.next();
    }
    flow.markStillHard();
    expect(flow.stillHard, isTrue);
    flow.waitAgain();
    expect(flow.session!.step, 5);
    flow.next();
    flow.markStronger();
    expect(flow.stronger, isTrue);
    flow.markRelieved();
    expect(flow.complete, isTrue);
    await flow.idle;
    flow.dispose();
  });
}
