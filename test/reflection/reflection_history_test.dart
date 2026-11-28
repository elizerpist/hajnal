import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/core/theme/hajnal_theme.dart';
import 'package:hajnal/features/history/application/history_store.dart';
import 'package:hajnal/features/history/presentation/history_calendar.dart';
import 'package:hajnal/features/history/presentation/history_event_list.dart';

void main() {
  testWidgets('timeline and calendar open the saved old-day reflection id', (
    tester,
  ) async {
    final date = DateTime(2020, 2, 3);
    final event = HistoryEvent(
      HistoryEventType.reflection,
      date,
      'Korábbi nap',
      reflectionId: 47,
    );
    int? opened;
    await tester.pumpWidget(
      MaterialApp(
        theme: hajnalTheme(),
        home: Scaffold(
          body: HistoryEventList(
            events: [event],
            active: false,
            onReflection: (id) => opened = id,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Napi reflexió'));
    expect(opened, 47);
    opened = null;
    await tester.pumpWidget(
      MaterialApp(
        theme: hajnalTheme(),
        home: Scaffold(
          body: HistoryCalendar(
            events: [event],
            initialDate: date,
            active: false,
            onReflection: (id) => opened = id,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Napi reflexió'));
    await tester.tap(find.text('Napi reflexió'));
    expect(opened, 47);
  });
}
