import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/features/onboarding/application/onboarding_controller.dart';
import 'package:hajnal/features/onboarding/application/onboarding_draft.dart';
import 'package:hajnal/features/onboarding/application/onboarding_store.dart';
import 'package:hajnal/features/onboarding/presentation/onboarding.dart';
import 'package:hajnal/features/onboarding/presentation/onboarding_calendar.dart';

class MemoryOnboarding implements OnboardingStore {
  late OnboardingDraft draft;
  int finished = 0;
  @override
  Future<OnboardingDraft> load(DateTime now) async => draft;
  @override
  Future<void> saveDraft(OnboardingDraft value) async {
    draft = value;
  }

  @override
  Future<void> finish(OnboardingDraft value, DateTime now) async {
    draft = value;
    finished++;
  }
}

void main() {
  testWidgets(
    'standard viewport shows the preview and keeps the note reachable',
    (tester) async {
      tester.view.physicalSize = const Size(412, 892);
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(bottom: 48);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPadding);
      final store = MemoryOnboarding()
        ..draft = OnboardingDraft(
          periodId: null,
          date: DateTime(2026, 11, 27),
          motivation: '',
          modules: {},
          sponsorName: '',
          sponsorPhone: '',
          completed: false,
          baseline: const {},
        );
      final controller = OnboardingController(
        store,
        () => DateTime(2026, 11, 27),
      );
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('hu'),
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: const [Locale('hu')],
          home: Onboarding(controller: controller),
        ),
      );
      await tester.pumpAndSettle();
      controller.next();
      controller.next();
      controller.next();
      await tester.pumpAndSettle();
      final note = find.text('A kezdődátumot később is módosíthatod.');
      final action = find.text('Tovább');
      expect(
        tester.getBottomLeft(find.text('Ma a 0. napnál tartasz.')).dy,
        lessThan(tester.getTopLeft(action).dy),
      );
      await tester.ensureVisible(note);
      await tester.pumpAndSettle();
      expect(
        tester.getBottomLeft(note).dy,
        lessThan(tester.getTopLeft(action).dy),
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await controller.idle;
      controller.dispose();
    },
  );
  testWidgets('clock moving backwards keeps the calendar usable', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('hu'),
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: const [Locale('hu')],
        home: Scaffold(
          body: OnboardingCalendar(
            date: DateTime(2026, 11, 27),
            today: DateTime(2026, 10, 1),
            onChanged: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('A kezdőnap a mai dátumnál későbbi. Válassz új napot.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'calendar uses Hungarian Monday-first locale, quick year and today',
    (tester) async {
      var selected = DateTime(2026, 11, 27);
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('hu'),
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: const [Locale('hu')],
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, update) => OnboardingCalendar(
                date: selected,
                today: DateTime(2026, 11, 27),
                onChanged: (date) => update(() => selected = date),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(OnboardingCalendar));
      expect(MaterialLocalizations.of(context).firstDayOfWeekIndex, 1);
      await tester.tap(find.byKey(const Key('calendar-month')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextButton>(find.widgetWithText(TextButton, 'december'))
            .onPressed,
        isNull,
      );
      await tester.tap(find.byKey(const Key('calendar-year')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('2025.').last);
      await tester.pumpAndSettle();
      expect(selected, DateTime(2026, 11, 27));
      await tester.tap(find.byKey(const Key('calendar-month')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('március').last);
      await tester.pumpAndSettle();
      expect(selected, DateTime(2026, 11, 27));
      await tester.tap(find.byKey(const Key('calendar-day-2025-3-15')));
      await tester.pumpAndSettle();
      expect(selected, DateTime(2025, 3, 15));
      await tester.tap(find.text('Ma'));
      await tester.pumpAndSettle();
      expect(selected, DateTime(2026, 11, 27));
    },
  );
  testWidgets(
    'small viewport and large text retain reachable fields and actions',
    (tester) async {
      tester.view.physicalSize = const Size(320, 600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = MemoryOnboarding()
        ..draft = OnboardingDraft(
          periodId: null,
          date: DateTime(2026, 11, 27),
          motivation: '',
          modules: {},
          sponsorName: '',
          sponsorPhone: '',
          completed: false,
          baseline: const {},
        );
      final controller = OnboardingController(
        store,
        () => DateTime(2026, 11, 27),
      );
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('hu'),
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: const [Locale('hu')],
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: Onboarding(controller: controller),
        ),
      );
      await tester.pumpAndSettle();
      controller.next();
      controller.next();
      controller.next();
      await tester.pumpAndSettle();
      expect(find.byType(OnboardingCalendar), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Tovább'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tovább'));
      await tester.pumpAndSettle();
      await tester.showKeyboard(find.byType(TextField));
      tester.view.viewInsets = const FakeViewPadding(bottom: 250);
      addTearDown(tester.view.resetViewInsets);
      await tester.enterText(find.byType(TextField), 'Tartalom');
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Tovább'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tovább'));
      await tester.pumpAndSettle();
      expect(find.text('Mire használom a Hajnalt?'), findsOneWidget);
      expect(tester.takeException(), isNull);
      tester.view.resetViewInsets();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Szponzor'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Szponzor'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Tovább'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tovább'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hozzáadom a szponzoromat'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('sponsor-name')));
      await tester.pumpAndSettle();
      await tester.showKeyboard(find.byKey(const Key('sponsor-name')));
      tester.view.viewInsets = const FakeViewPadding(bottom: 250);
      await tester.enterText(find.byKey(const Key('sponsor-name')), 'Anna');
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Mentés és indulás'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mentés és indulás'));
      await tester.pumpAndSettle();
      expect(store.finished, 1);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await controller.idle;
      controller.dispose();
    },
  );
  testWidgets('full order, sponsor branch and durable completion', (
    tester,
  ) async {
    final store = MemoryOnboarding()
      ..draft = OnboardingDraft(
        periodId: null,
        date: DateTime(2026, 11, 27),
        motivation: '',
        modules: {},
        sponsorName: '',
        sponsorPhone: '',
        completed: false,
        baseline: const {},
      );
    final controller = OnboardingController(
      store,
      () => DateTime(2026, 11, 27),
    );
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('hu'),
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: const [Locale('hu')],
        home: Onboarding(controller: controller),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Hajnal'), findsOneWidget);
    expect(find.text('Jó, hogy itt vagy.'), findsNothing);
    expect(find.text('Lépésről lépésre, a saját tempódban.'), findsNothing);
    await tester.tap(find.text('Kezdjük el'));
    await tester.pumpAndSettle();
    expect(find.text('Üdv a Hajnalban!'), findsOneWidget);
    await tester.tap(find.text('Tovább'));
    await tester.pumpAndSettle();
    expect(find.text('Fontos tudnivalók'), findsOneWidget);
    await tester.tap(find.text('Értem, tovább'));
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingCalendar), findsOneWidget);
    await tester.ensureVisible(find.text('Tovább'));
    await tester.tap(find.text('Tovább'));
    await tester.pumpAndSettle();
    expect(find.text('Miért kezdtem el?'), findsOneWidget);
    expect(find.text('Miért fontos nekem a változás?'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Az egészségemért');
    await tester.ensureVisible(find.text('Tovább'));
    await tester.tap(find.text('Tovább'));
    await tester.pumpAndSettle();
    expect(find.text('Mire használom a Hajnalt?'), findsOneWidget);
    await tester.tap(find.text('Szponzor'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Tovább'));
    await tester.tap(find.text('Tovább'));
    await tester.pumpAndSettle();
    expect(find.text('Szeretnéd hozzáadni a szponzorodat?'), findsOneWidget);
    expect(find.text('Most kihagyom'), findsOneWidget);
    await tester.tap(find.text('Hozzáadom a szponzoromat'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('sponsor-name')), 'Anna');
    await tester.ensureVisible(find.text('Mentés és indulás'));
    await tester.tap(find.text('Mentés és indulás'));
    await tester.pumpAndSettle();
    expect(store.finished, 1);
    expect(store.draft.sponsorName, 'Anna');
    controller.dispose();
  });
}
