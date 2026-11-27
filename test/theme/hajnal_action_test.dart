import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/core/theme/hajnal_components.dart';
import 'package:hajnal/core/theme/hajnal_theme.dart';

void main() {
  testWidgets('loading is visible and cannot submit again', (tester) async {
    var submissions = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: hajnalTheme(),
        home: Scaffold(
          body: HajnalAction(
            label: 'Mentés',
            loading: true,
            onPressed: () => submissions++,
          ),
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Mentés'), findsOneWidget);
    await tester.tap(find.byType(FilledButton), warnIfMissed: false);
    expect(submissions, 0);
  });
}
