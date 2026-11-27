import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/features/onboarding/presentation/onboarding_calendar.dart';
import 'package:hajnal/core/theme/hajnal_theme.dart';

void main() {
  testWidgets('month labels stay readable at the standard phone width', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: hajnalTheme(),
        locale: const Locale('hu'),
        supportedLocales: const [Locale('hu')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 340,
              child: OnboardingCalendar(
                date: DateTime(2026, 11, 27),
                today: DateTime(2026, 11, 27),
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('calendar-month')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('szeptember'),
      80,
      scrollable: find.descendant(
        of: find.byKey(const Key('calendar-selection-panel')),
        matching: find.byType(Scrollable),
      ),
    );
    expect(tester.getSize(find.text('szeptember')).height, lessThan(30));
  });

  testWidgets('today returns from a browsed month even when already selected', (
    tester,
  ) async {
    var selected = DateTime(2026, 11, 27);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('hu'),
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: const [Locale('hu')],
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => OnboardingCalendar(
              date: selected,
              today: DateTime(2026, 11, 27),
              onChanged: (d) => setState(() => selected = d),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byTooltip('Előző hónap'));
    await tester.pumpAndSettle();
    expect(selected, DateTime(2026, 11, 27));
    expect(find.text('október'), findsOneWidget);
    await tester.tap(find.text('Ma'));
    await tester.pumpAndSettle();
    expect(find.text('november'), findsOneWidget);
    expect(selected, DateTime(2026, 11, 27));
  });

  testWidgets(
    'year and month share one panel; navigation never selects a day',
    (tester) async {
      var selected = DateTime(2026, 11, 27);
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('hu'),
          supportedLocales: const [Locale('hu')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => OnboardingCalendar(
                date: selected,
                today: DateTime(2026, 11, 27),
                onChanged: (d) => setState(() => selected = d),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byKey(const Key('calendar-month')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('calendar-selection-panel')), findsOneWidget);
      expect(
        tester
            .widget<TextButton>(find.widgetWithText(TextButton, 'december'))
            .onPressed,
        isNull,
      );
      await tester.tap(find.byKey(const Key('calendar-year')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('calendar-selection-panel')), findsOneWidget);
      await tester.tap(find.text('2024.').last);
      await tester.pumpAndSettle();
      expect(selected, DateTime(2026, 11, 27));
      await tester.tap(find.byKey(const Key('calendar-month')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('február').last);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('calendar-day-2024-2-29')), findsOneWidget);
      await tester.tap(find.byKey(const Key('calendar-day-2024-2-29')));
      await tester.pumpAndSettle();
      expect(selected, DateTime(2024, 2, 29));
      await tester.tap(find.byKey(const Key('calendar-year')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ma'));
      await tester.pumpAndSettle();
      expect(selected, DateTime(2026, 11, 27));
      expect(find.text('november'), findsOneWidget);
      expect(find.byKey(const Key('calendar-selection-panel')), findsNothing);
    },
  );

  testWidgets('today circle is contained and is not duplicated on selection', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var selected = DateTime(2026, 11, 26);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('hu'),
        supportedLocales: const [Locale('hu')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => OnboardingCalendar(
              date: selected,
              today: DateTime(2026, 11, 27),
              onChanged: (d) => setState(() => selected = d),
            ),
          ),
        ),
      ),
    );
    final cell = find.byKey(const Key('calendar-day-2026-11-27'));
    final previouslySelected = find.byKey(const Key('calendar-day-2026-11-26'));
    expect(
      tester
          .getSemantics(previouslySelected)
          .getSemanticsData()
          .flagsCollection
          .isSelected,
      Tristate.isTrue,
    );
    expect(
      tester.getSemantics(previouslySelected).label,
      contains('2026. november 26.'),
    );
    BoxDecoration decoration() =>
        tester
                .widget<Container>(
                  find
                      .descendant(of: cell, matching: find.byType(Container))
                      .first,
                )
                .decoration!
            as BoxDecoration;
    expect(decoration().shape, BoxShape.circle);
    expect(decoration().border, isNotNull);
    final circleSize = tester.getSize(
      find.descendant(of: cell, matching: find.byType(Container)).first,
    );
    expect(circleSize.width, circleSize.height);
    expect(circleSize.width, lessThanOrEqualTo(tester.getSize(cell).width));
    await tester.tap(cell);
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(cell).getSemanticsData().flagsCollection.isSelected,
      Tristate.isTrue,
    );
    expect(decoration().border, isNull);
    expect(decoration().color, isNotNull);
    semantics.dispose();
  });
}
