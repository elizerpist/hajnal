import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/app/bootstrap_controller.dart';
import 'package:hajnal/app/hajnal_app.dart';
import 'package:hajnal/core/database/hajnal_database.dart';
import 'package:hajnal/features/panic/application/panic_controller.dart';
import 'package:hajnal/features/panic/data/panic_repository.dart';
import 'package:hajnal/features/recovery/application/restart_recovery.dart';
import 'package:hajnal/features/recovery/data/drift_recovery_store.dart';
import 'package:hajnal/features/recovery/data/recovery_repository.dart';
import '../widget_test.dart' show CancelPicker;
import 'panic_flow_test.dart' show FakeDialer;

void main() {
  testWidgets(
    'relapse restart updates the real dashboard and keeps the old period',
    (tester) async {
      tester.view.physicalSize = const Size(412, 892);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      final db = HajnalDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repository = RecoveryRepository(db);
      final now = DateTime(2025, 4, 8, 12);
      final old = await tester.runAsync(
        () => repository.initialize(DateTime(2025, 4, 5), now),
      );
      final store = DriftRecoveryStore(repository);
      final bootstrap = BootstrapController(store, () => now);
      final panic = PanicController(
        PanicRepository(db),
        RestartRecovery(store, () => now),
        FakeDialer(),
        () => bootstrap.activePeriod?.id,
        () => now,
      );
      await tester.pumpWidget(
        HajnalApp(controller: bootstrap, picker: CancelPicker(), panic: panic),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(bootstrap.activePeriod?.id, old!.id);
      expect(find.text('3'), findsOneWidget);
      await tester.tap(find.byKey(const Key('summary-card')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.byKey(const Key('dashboard-help')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.text('Visszaestem'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect((await tester.runAsync(repository.active))!.id, old.id);
      await tester.tap(find.byKey(const Key('restart-recovery')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('0'), findsOneWidget);
      expect(bootstrap.activePeriod!.id, isNot(old.id));
      await tester.pumpWidget(const SizedBox());
      bootstrap.dispose();
      panic.dispose();
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump(const Duration(milliseconds: 1));
    },
  );
}
