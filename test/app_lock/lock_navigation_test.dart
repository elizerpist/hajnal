import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/app/bootstrap_controller.dart';
import 'package:hajnal/app/hajnal_app.dart';
import 'package:hajnal/features/app_lock/application/lock_controller.dart';
import 'package:hajnal/features/app_lock/domain/lock_mode.dart';
import 'package:hajnal/features/recovery/application/recovery_store.dart';
import '../widget_test.dart' as app_fakes;
import 'lock_controller_test.dart' as lock_fakes;

void main() {
  testWidgets('lock prevents Back bypass and preserves the open route', (
    tester,
  ) async {
    final store = app_fakes.MemoryStore();
    final bootstrap = BootstrapController(store, () => DateTime(2024, 4, 1));
    final onboarding = app_fakes.MemoryOnboarding(bootstrap, store);
    final lock = LockController(
      lock_fakes.Store(LockMode.pin),
      lock_fakes.Finger(),
      lock_fakes.Device(),
    );
    await lock.initialize();
    await tester.pumpWidget(
      HajnalApp(
        controller: bootstrap,
        picker: app_fakes.FakePicker(),
        lock: lock,
        onboardingStore: onboarding,
      ),
    );
    store.stream.add(ActiveRecovery(1, DateTime(2024, 3, 30)));
    await tester.pumpAndSettle();
    expect(find.text('Tiszta napok'), findsNothing);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Tiszta napok'), findsNothing);
    await lock.submitPin('001234');
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Menü'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Onboarding'));
    await tester.pumpAndSettle();
    await app_fakes.toDate(tester, existing: true);
    expect(find.byType(CalendarDatePicker), findsOneWidget);
    await tester.ensureVisible(find.text('Tovább'));
    await tester.tap(find.text('Tovább'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Megmaradó emlékeztető');
    await tester.pumpAndSettle();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.text('Megmaradó emlékeztető'), findsNothing);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await lock.submitPin('001234');
    await tester.pumpAndSettle();
    expect(find.text('Megmaradó emlékeztető'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    lock.dispose();
    bootstrap.dispose();
    await store.stream.close();
  });
}
