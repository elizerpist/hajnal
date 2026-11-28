import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/app/bootstrap_controller.dart';
import 'package:hajnal/app/hajnal_app.dart';
import 'package:hajnal/core/artwork/practice_artwork.dart';
import 'package:hajnal/features/practice/application/practice_controller.dart';
import 'package:hajnal/features/practice/application/practice_store.dart';
import 'package:hajnal/features/recovery/application/recovery_store.dart';
import '../widget_test.dart' as app_fakes;
import 'practice_widget_test.dart' show MemoryPracticeStore;

void main() {
  testWidgets('capture practice manager and editor from actual widgets', (
    tester,
  ) async {
    final destination = Platform.environment['HAJNAL_CAPTURE_DIR'];
    if (destination != null) {
      await tester.runAsync(() async {
        final text = FontLoader('Roboto')
          ..addFont(rootBundle.load('assets/fonts/roboto/Roboto.ttf'));
        final icons = FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
        await text.load();
        await icons.load();
      });
    }
    tester.view.physicalSize = const Size(412, 892);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final recovery = app_fakes.MemoryStore();
    final bootstrap = BootstrapController(
      recovery,
      () => DateTime(2026, 11, 28),
    );
    final store = MemoryPracticeStore();
    final practice = PracticeController(store);
    for (final value in [
      'Kérhetek időt, mielőtt igent mondok.',
      'Megállok egy pillanatra.',
      'Hála a beszélgetésért.',
      'Mi segít reggel elindulni?',
      'Este időt hagyok magamra.',
      'Figyelek a határaimra.',
    ]) {
      await store.add(
        PracticeContent(text: value),
        activate: value.startsWith('Kérhetek'),
      );
    }
    final captureKey = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: captureKey,
        child: HajnalApp(
          controller: bootstrap,
          picker: app_fakes.CancelPicker(),
          practice: practice,
        ),
      ),
    );
    recovery.stream.add(ActiveRecovery(1, DateTime(2026, 11, 1)));
    await tester.pumpAndSettle();
    Future<void> shot(String name) async {
      if (destination == null) return;
      final context = tester.element(find.byType(Scaffold).last);
      await tester.runAsync(() async {
        await precacheImage(
          const AssetImage('assets/artwork/dashboard/placeholder.png'),
          context,
        );
        for (var id = 1; id <= 6; id++) {
          final artwork = PracticeArtwork.forId(id);
          await precacheImage(AssetImage(artwork.image), context);
          await precacheImage(AssetImage(artwork.decoration), context);
        }
      });
      await tester.pumpAndSettle();
      final boundary =
          captureKey.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 1);
        final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!;
        image.dispose();
        await Directory(destination).create(recursive: true);
        await File(
          '$destination/$name.png',
        ).writeAsBytes(bytes.buffer.asUint8List());
      });
    }

    await tester.tap(find.byKey(const Key('summary-card')));
    await tester.pumpAndSettle();
    await shot('practice-dashboard');
    await tester.tap(find.byKey(const Key('dashboard-practice')));
    await tester.pumpAndSettle();
    await shot('practice-manager');
    await tester.tap(find.text('Új kártya hozzáadása'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Segíts elindulni'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apró lépés'));
    await tester.pumpAndSettle();
    await shot('practice-editor');
    expect(find.text('Felismerés'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    bootstrap.dispose();
    practice.dispose();
    await recovery.stream.close();
    await store.events.close();
  });
}
