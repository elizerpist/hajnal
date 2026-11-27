import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/app/bootstrap_controller.dart';
import 'package:hajnal/app/hajnal_app.dart';
import 'package:hajnal/features/panic/application/panic_controller.dart';
import 'package:hajnal/features/recovery/application/recovery_store.dart';
import 'package:hajnal/features/recovery/application/restart_recovery.dart';
import '../widget_test.dart' as fakes;
import 'panic_flow_test.dart' show FakeDialer, FakeRestart;
import 'survival_controller_test.dart' show MemoryPanicStore;

void main() {
  testWidgets('capture dashboard, panic and survival from actual widgets', (
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
    final recovery = fakes.MemoryStore();
    final bootstrap = BootstrapController(recovery, () => DateTime(2025, 4, 8));
    final panic = PanicController(
      MemoryPanicStore(),
      RestartRecovery(FakeRestart(), () => DateTime(2025, 4, 8)),
      FakeDialer(),
      () => 1,
      () => DateTime(2025, 4, 8),
    );
    final captureKey = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: captureKey,
        child: HajnalApp(
          controller: bootstrap,
          picker: fakes.CancelPicker(),
          panic: panic,
        ),
      ),
    );
    recovery.stream.add(ActiveRecovery(1, DateTime(2025, 4, 8)));
    await tester.pumpAndSettle();
    Future<void> shot(String name, String? asset) async {
      if (asset != null) {
        final context = tester.element(find.byType(Scaffold).last);
        await tester.runAsync(() => precacheImage(AssetImage(asset), context));
      }
      await tester.pumpAndSettle();
      if (destination == null) return;
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

    await shot('dashboard-closed', 'assets/artwork/dashboard/placeholder.png');
    await tester.tap(find.byKey(const Key('summary-card')));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byKey(const Key('dashboard-help'))).height, 48);
    expect(
      tester.getSize(find.byKey(const Key('dashboard-help-surface'))).height,
      42,
    );
    await shot('dashboard-open', 'assets/artwork/dashboard/placeholder.png');
    await tester.tap(find.byKey(const Key('dashboard-help')));
    await tester.pumpAndSettle();
    await shot('panic', 'assets/artwork/panic/panik1.png');
    await tester.tap(find.text('15 perces\ntúlélőcsomag'));
    await tester.pumpAndSettle();
    await shot('survival-stop', 'assets/artwork/survival/survival_stop_bg.png');
    await tester.tap(find.text('Tovább'));
    await tester.pumpAndSettle();
    await shot(
      'survival-breathe',
      'assets/artwork/survival/survival_breathe_bg.png',
    );
    Future<void> advance(String label) async {
      await tester.ensureVisible(find.text(label));
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }

    await advance('Tovább');
    await shot(
      'survival-water',
      'assets/artwork/survival/survival_water_bg.png',
    );
    await advance('Ittam egy kortyot');
    await shot(
      'survival-environment',
      'assets/artwork/survival/survival_environment_bg.png',
    );
    await advance('Helyet váltottam');
    await shot(
      'survival-connect',
      'assets/artwork/survival/survival_contact_bg.png',
    );
    await advance('Most még nem szeretnék beszélni');
    await shot('survival-wait', 'assets/artwork/survival/survival_wait_bg.png');
    await advance('Most értékelem újra');
    await shot(
      'survival-reassess',
      'assets/artwork/survival/survival_reassess_bg.png',
    );
    await advance('Előző állomás');
    await advance('Most értékelem újra');
    await advance('Erősebb lett – Most még nagyobb támogatásra van szükségem.');
    await shot(
      'survival-stronger',
      'assets/artwork/survival/survival_reassess_bg.png',
    );
    await advance('Vissza a Pánik módba');
    await advance('Visszaestem');
    await shot('relapse', null);
    await tester.pumpWidget(const SizedBox());
    bootstrap.dispose();
    panic.dispose();
    await recovery.stream.close();
  });
}
