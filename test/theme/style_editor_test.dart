import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/core/theme/application/style_controller.dart';
import 'package:hajnal/core/theme/domain/style_definitions.dart';
import 'package:hajnal/core/theme/presentation/style_editor.dart';
import 'style_controller_test.dart' show FakeStyleStore;

void main() {
  testWidgets('preview is a draft; cancel discards and apply persists', (
    tester,
  ) async {
    final owner = StyleOwner(FakeStyleStore());
    await owner.load();
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => StyleEditor(owner: owner),
                ),
              ),
              child: const Text('Megnyitás'),
            ),
          ),
        ),
      ),
    );
    Future<void> edit() async {
      await tester.tap(find.text('Megnyitás'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Title 1'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(Slider).first);
      await tester.drag(find.byType(Slider).first, const Offset(100, 0));
      await tester.pumpAndSettle();
    }

    await edit();
    expect(owner.current.definitions.texts[TextRole.title1]!.size, 28);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Szerkesztés folytatása'), findsOneWidget);
    await tester.tap(find.text('Szerkesztés folytatása'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mégse'));
    await tester.pumpAndSettle();
    expect(owner.current.definitions.texts[TextRole.title1]!.size, 28);
    await edit();
    await tester.tap(find.text('Alkalmazás'));
    await tester.pumpAndSettle();
    expect(
      owner.current.definitions.texts[TextRole.title1]!.size,
      greaterThan(28),
    );
    owner.dispose();
  });
}
