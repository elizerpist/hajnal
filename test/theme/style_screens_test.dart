import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/app/bootstrap_controller.dart';
import 'package:hajnal/app/hajnal_app.dart';
import 'package:hajnal/core/theme/application/style_controller.dart';
import 'package:hajnal/core/theme/domain/style_definitions.dart';
import 'package:hajnal/core/theme/hajnal_components.dart';
import 'package:hajnal/features/app_lock/application/lock_controller.dart';
import 'package:hajnal/features/app_lock/domain/lock_mode.dart';
import 'package:hajnal/features/recovery/application/recovery_store.dart';
import '../app_lock/lock_controller_test.dart' as lock_fakes;
import '../widget_test.dart' as app_fakes;
import 'style_controller_test.dart' show FakeStyleStore;

void main() {
  testWidgets('changing theme cannot unlock an active lock gate', (
    tester,
  ) async {
    final recovery = app_fakes.MemoryStore();
    final bootstrap = BootstrapController(recovery, DateTime.now);
    final lock = LockController(
      lock_fakes.Store(LockMode.pin),
      lock_fakes.Finger(),
      lock_fakes.Device(),
    );
    await lock.initialize();
    final owner = StyleOwner(FakeStyleStore());
    await owner.load();
    await tester.pumpWidget(
      HajnalApp(
        controller: bootstrap,
        picker: app_fakes.FakePicker(),
        lock: lock,
        style: owner,
      ),
    );
    recovery.stream.add(ActiveRecovery(1, DateTime(2026, 11, 1)));
    await tester.pumpAndSettle();
    expect(lock.locked, isTrue);
    final editor = StyleEditorController(owner);
    editor.setText(TextRole.title1, 'size', 36.0);
    expect(await editor.apply(), isTrue);
    await tester.pumpAndSettle();
    expect(lock.locked, isTrue);
    expect(find.text('Add meg a PIN-kódod'), findsOneWidget);
    expect(find.text('Tiszta napok'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    editor.dispose();
    owner.dispose();
    bootstrap.dispose();
    lock.dispose();
    await recovery.stream.close();
  });
  testWidgets(
    'one saved theme updates onboarding and lock without losing the route',
    (tester) async {
      final recovery = app_fakes.MemoryStore();
      final bootstrap = BootstrapController(
        recovery,
        () => DateTime(2026, 11, 27),
      );
      final onboarding = app_fakes.MemoryOnboarding(bootstrap, recovery);
      final lock = LockController(
        lock_fakes.Store(LockMode.off),
        lock_fakes.Finger(),
        lock_fakes.Device(),
      );
      await lock.initialize();
      final owner = StyleOwner(FakeStyleStore());
      await owner.load();
      await tester.pumpWidget(
        HajnalApp(
          controller: bootstrap,
          picker: app_fakes.FakePicker(),
          onboardingStore: onboarding,
          lock: lock,
          style: owner,
        ),
      );
      recovery.stream.add(ActiveRecovery(1, DateTime(2026, 11, 1)));
      await tester.pumpAndSettle();
      await app_fakes.openOnboarding(tester);
      await tester.tap(find.text('Beállítások áttekintése'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(find.text('Üdv a Hajnalban!')).style!.fontSize,
        28,
      );
      await tester.tap(find.text('Tovább'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Értem, tovább'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Tovább'));
      await tester.tap(find.text('Tovább'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Piszkozat megmarad');
      final editor = StyleEditorController(owner);
      editor.setText(TextRole.title1, 'size', 36.0);
      editor.setCard(CardRole.large, 'radius', 30.0);
      expect(await editor.apply(), isTrue);
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(find.text('Miért kezdtem el?')).style!.fontSize,
        36,
      );
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Piszkozat megmarad',
      );
      await tester.ensureVisible(find.text('Tovább'));
      await tester.tap(find.text('Tovább'));
      await tester.pumpAndSettle();
      final onboardingChoice = find.ancestor(
        of: find.text('Szponzor'),
        matching: find.byType(HajnalChoiceCard),
      );
      final onboardingInk = tester.widget<Ink>(
        find.descendant(of: onboardingChoice, matching: find.byType(Ink)).first,
      );
      expect(
        (onboardingInk.decoration as BoxDecoration).borderRadius!
            .resolve(TextDirection.ltr)
            .topLeft
            .x,
        30,
      );
      await tester.tap(find.byTooltip('Bezárás'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Menü'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Alkalmazászár'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(find.text('Alkalmazászár')).style!.fontSize,
        36,
      );
      final card = tester.widget<HajnalCard>(
        find.descendant(
          of: find.byType(HajnalChoiceCard).first,
          matching: find.byType(HajnalCard),
        ),
      );
      expect(card.role, CardRole.large);
      expect(owner.current.definitions.cards[card.role]!.radius, 30);
      final lockInk = tester.widget<Ink>(
        find
            .descendant(
              of: find.byType(HajnalChoiceCard).first,
              matching: find.byType(Ink),
            )
            .first,
      );
      expect(
        (lockInk.decoration as BoxDecoration).borderRadius!
            .resolve(TextDirection.ltr)
            .topLeft
            .x,
        30,
      );
      await tester.pumpWidget(const SizedBox());
      editor.dispose();
      owner.dispose();
      bootstrap.dispose();
      lock.dispose();
      await recovery.stream.close();
    },
  );
}
