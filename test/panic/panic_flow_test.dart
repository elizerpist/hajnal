import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/core/theme/hajnal_theme.dart';
import 'package:hajnal/features/panic/application/emergency_dialer.dart';
import 'package:hajnal/features/panic/application/panic_controller.dart';
import 'package:hajnal/features/panic/presentation/panic_dialogs.dart';
import 'package:hajnal/features/panic/presentation/panic_page.dart';
import 'package:hajnal/features/panic/presentation/survival_page.dart';
import 'package:hajnal/features/panic/domain/survival_session.dart';
import 'package:hajnal/features/recovery/application/restart_recovery.dart';
import 'survival_controller_test.dart';

class FakeDialer implements EmergencyDialer {
  int calls = 0;
  @override
  Future<bool> open112() async {
    calls++;
    return true;
  }
}

class FailingMotivationStore extends MemoryPanicStore {
  bool fail = true;
  String value = 'A családom';
  @override
  Future<String> motivation() async {
    if (fail) throw StateError('read failed');
    return value;
  }
}

class FakeRestart implements RestartRecoveryStore {
  int calls = 0;
  int? id;
  @override
  Future<void> restart(int activePeriodId, DateTime now) async {
    calls++;
    id = activePeriodId;
  }
}

void main() {
  testWidgets(
    'a paused breathing exercise stays still after restoring the session',
    (tester) async {
      final store = MemoryPanicStore()
        ..saved = SurvivalSession(
          startedAt: DateTime(2025),
          step: 1,
          breathingPaused: true,
        );
      final panic = PanicController(
        store,
        RestartRecovery(FakeRestart(), () => DateTime(2025)),
        FakeDialer(),
        () => 1,
        () => DateTime(2025),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: hajnalTheme(),
          home: SurvivalPage(controller: panic.createSurvival(), panic: panic),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      final transform = tester.widget<Transform>(
        find
            .ancestor(of: find.text('Szünet'), matching: find.byType(Transform))
            .first,
      );
      expect(transform.transform.storage[0], 1);
      await tester.pumpWidget(const SizedBox());
      panic.dispose();
    },
  );

  testWidgets(
    'motivation read failure can be retried without pretending it is empty',
    (tester) async {
      final store = FailingMotivationStore();
      final panic = PanicController(
        store,
        RestartRecovery(FakeRestart(), () => DateTime(2025)),
        FakeDialer(),
        () => 1,
        () => DateTime(2025),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: hajnalTheme(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
          home: PanicPage(controller: panic),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Miért kezdtem el?'));
      await tester.pumpAndSettle();
      expect(
        find.text('Az emlékeztető nem tölthető be. Próbáld újra.'),
        findsOneWidget,
      );
      expect(find.textContaining('Onboarding menüben'), findsNothing);
      store.fail = false;
      await tester.tap(find.text('Újrapróbálás'));
      await tester.pumpAndSettle();
      expect(find.text('A családom'), findsWidgets);
      store.value = '';
      await panic.load();
      await tester.pump();
      expect(find.textContaining('Onboarding menüben'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      panic.dispose();
    },
  );

  testWidgets(
    'help pulse completes a 2.8 second cycle and respects reduced motion',
    (tester) async {
      Widget app(bool reduced) => MaterialApp(
        theme: hajnalTheme(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
          child: child!,
        ),
        home: Scaffold(
          body: Center(child: PanicPulse(onPressed: () {})),
        ),
      );
      double scale() => tester
          .widget<Transform>(
            find
                .descendant(
                  of: find.byType(PanicPulse),
                  matching: find.byType(Transform),
                )
                .first,
          )
          .transform
          .storage[0];

      await tester.pumpWidget(app(false));
      expect(scale(), closeTo(1, .001));
      await tester.pump(const Duration(milliseconds: 1400));
      expect(scale(), closeTo(1.085, .001));
      await tester.pump(const Duration(milliseconds: 1400));
      expect(scale(), closeTo(1, .001));
      await tester.pumpWidget(app(true));
      await tester.pump(const Duration(seconds: 2));
      expect(scale(), closeTo(1, .001));
    },
  );

  testWidgets(
    'panic and survival remain reachable on a small screen with larger text',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final panic = PanicController(
        MemoryPanicStore(),
        RestartRecovery(FakeRestart(), () => DateTime(2025, 4, 8)),
        FakeDialer(),
        () => 17,
        () => DateTime(2025, 4, 8),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: hajnalTheme(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              disableAnimations: true,
              textScaler: const TextScaler.linear(1.8),
            ),
            child: child!,
          ),
          home: PanicPage(controller: panic),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Visszaestem'));
      await tester.tap(find.text('Visszaestem'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('Vissza a Pánik módhoz'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('15 perces\ntúlélőcsomag'));
      await tester.tap(find.text('15 perces\ntúlélőcsomag'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Tovább'));
      await tester.tap(find.text('Tovább'));
      await tester.pump();
      expect(find.text('Lélegezz.'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      panic.dispose();
    },
  );

  testWidgets('panic paths, 112 intent, survival choices and restart', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(412, 892);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = MemoryPanicStore();
    final dialer = FakeDialer();
    final restart = FakeRestart();
    var now = DateTime(2025, 4, 8);
    final panic = PanicController(
      store,
      RestartRecovery(restart, () => now),
      dialer,
      () => 17,
      () => now,
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: hajnalTheme(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.push<void>(
                context,
                MaterialPageRoute(builder: (_) => PanicPage(controller: panic)),
              ),
              child: const Text('Pánik megnyitása'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Pánik megnyitása'));
    await tester.pumpAndSettle();
    expect(find.text('Nem vagy egyedül.'), findsOneWidget);
    await tester.tap(find.byKey(const Key('panic-help')));
    await tester.pumpAndSettle();
    expect(dialer.calls, 0);
    expect(find.textContaining('Szponzor'), findsNothing);
    expect(find.textContaining('gyűlés'), findsNothing);
    await tester.tap(find.byKey(const Key('emergency-112')));
    await tester.pumpAndSettle();
    expect(dialer.calls, 1);
    await tester.tap(find.text('Bezárás'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Miért kezdtem el?').first);
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('A családom'),
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Bezárás'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('15 perces\ntúlélőcsomag'));
    await tester.pumpAndSettle();
    expect(find.text('Állj meg egy pillanatra.'), findsOneWidget);
    expect(find.text('15:00'), findsOneWidget);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    now = now.add(const Duration(seconds: 74));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('13:46'), findsOneWidget);
    Future<void> tap(String text) async {
      final target = find.text(text);
      await tester.ensureVisible(target);
      await tester.tap(target);
      await tester.pump();
    }

    await tap('Tovább');
    expect(find.text('Lélegezz.'), findsOneWidget);
    await tap('Tovább');
    await tap('Ittam egy kortyot');
    await tap('Helyet váltottam');
    expect(find.text('Nem kell egyedül maradnod.'), findsOneWidget);
    expect(find.textContaining('Szponzor'), findsNothing);
    await tap('Most még nem szeretnék beszélni');
    expect(find.text('Maradj még itt egy kicsit.'), findsOneWidget);
    await tap('Írd ki, ami benned van');
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('survival-note-input')),
      'A jegyzetem',
    );
    await tester.tap(find.text('Jegyzet megőrzése'));
    await tester.pumpAndSettle();
    expect(store.notes, ['A jegyzetem']);
    await tap('Most értékelem újra');
    await tap('Még nehéz – Még mindig megterhelő.');
    expect(find.text('Maradjunk a következő lépésnél.'), findsOneWidget);
    await tap('Maradok még néhány percet.');
    await tap('Most értékelem újra');
    await tap('Erősebb lett – Most még nagyobb támogatásra van szükségem.');
    expect(find.text('Nagyobb támogatásra van szükséged.'), findsOneWidget);
    await tap('Előző állomás');
    await tap('Most értékelem újra');
    await tap('Enyhült – Kicsit könnyebb, mint amikor elkezdtem.');
    expect(find.text('Adtál magadnak egy kis időt.'), findsOneWidget);
    await tap('Vissza a Főmenübe');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pánik megnyitása'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Visszaestem'));
    await tester.pumpAndSettle();
    expect(restart.calls, 0);
    await tester.tap(find.byKey(const Key('restart-recovery')));
    await tester.pumpAndSettle();
    expect(restart.calls, 1);
    expect(restart.id, 17);
    await tester.pumpWidget(const SizedBox());
    panic.dispose();
  });
}
