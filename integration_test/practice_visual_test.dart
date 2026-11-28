import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hajnal/app/bootstrap_controller.dart';
import 'package:hajnal/app/hajnal_app.dart';
import 'package:hajnal/features/practice/application/practice_controller.dart';
import 'package:hajnal/features/practice/application/practice_store.dart';
import 'lock_visual_test.dart' show VisualPicker, VisualRecovery;

class _VisualStore implements PracticeStore {
  final cards = [
    for (var i = 0; i < 6; i++)
      PracticeCard(
        id: i + 1,
        text: [
          'Kérhetek időt, mielőtt igent mondok.',
          'Megállok egy pillanatra.',
          'Hála a beszélgetésért.',
          'Mi segít reggel elindulni?',
          'Este időt hagyok magamra.',
          'Figyelek a határaimra.',
        ][i],
        status: i == 0 ? 'active' : 'paused',
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      ),
  ];
  @override
  Stream<List<PracticeCard>> watch() => Stream.value(cards);
  @override
  Future<void> activate(int id) async => throw UnsupportedError('visual only');
  @override
  Future<void> add(PracticeContent content, {required bool activate}) async =>
      throw UnsupportedError('visual only');
  @override
  Future<void> remove(int id) async => throw UnsupportedError('visual only');
  @override
  Future<void> saveChanges(int id, PracticeContent content) async =>
      throw UnsupportedError('visual only');
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('capture practice manager and expanded editor in the real app', (
    tester,
  ) async {
    final practice = PracticeController(_VisualStore());
    final bootstrap = BootstrapController(VisualRecovery(), DateTime.now);
    final directory = await getApplicationSupportDirectory();
    try {
      await binding.convertFlutterSurfaceToImage();
      await tester.pumpWidget(
        HajnalApp(
          controller: bootstrap,
          picker: VisualPicker(),
          practice: practice,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('summary-card')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('dashboard-practice')));
      await tester.pumpAndSettle();
      Future<void> capture(String name) async {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(seconds: 1)),
        );
        await tester.pump();
        final bytes = await binding.takeScreenshot(name);
        expect(bytes, isNotEmpty);
        await File(
          '${directory.path}/$name.png',
        ).writeAsBytes(bytes, flush: true);
      }

      await capture('practice-manager');
      await tester.tap(find.text('＋ Új kártya hozzáadása'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Segíts elindulni'));
      await tester.pumpAndSettle();
      await capture('practice-editor');
    } finally {
      await tester.pumpWidget(const SizedBox());
      bootstrap.dispose();
      practice.dispose();
    }
  });
}
