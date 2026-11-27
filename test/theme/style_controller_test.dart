import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/core/theme/application/style_controller.dart';
import 'package:hajnal/core/theme/application/style_store.dart';
import 'package:hajnal/core/theme/domain/style_definitions.dart';

class FakeStyleStore implements StyleStore {
  var snapshot = StyleSnapshot(StyleDefinitions.defaults(), 0);
  bool fail = false;
  @override
  Future<StyleSnapshot> load() async => snapshot;
  @override
  Future<int> save(StyleDefinitions definitions, int expectedRevision) async {
    if (fail || expectedRevision != snapshot.revision) {
      throw StateError('write failed');
    }
    snapshot = StyleSnapshot(definitions, expectedRevision + 1);
    return snapshot.revision;
  }
}

void main() {
  test(
    'changing the global button text color reaches every button role',
    () async {
      final owner = StyleOwner(FakeStyleStore());
      await owner.load();
      final editor = StyleEditorController(owner);
      editor.setText(TextRole.button, 'color', '#ff123456');
      for (final button in ButtonRole.values) {
        expect(editor.draft.buttons[button]!.foreground, '#ff123456');
      }
      expect(await editor.apply(), isTrue);
      expect(
        owner.current.definitions.buttons[ButtonRole.primary]!.foreground,
        '#ff123456',
      );
      editor.setButton(ButtonRole.primary, 'radius', 30.0);
      editor.resetText(TextRole.button);
      expect(editor.draft.buttons[ButtonRole.primary]!.foreground, 'onAccent');
      expect(editor.draft.buttons[ButtonRole.secondary]!.foreground, 'accent');
      expect(editor.draft.buttons[ButtonRole.primary]!.radius, 30);
      editor.dispose();
      owner.dispose();
    },
  );

  test('draft is published only after a successful atomic save', () async {
    final store = FakeStyleStore();
    final owner = StyleOwner(store);
    await owner.load();
    final editor = StyleEditorController(owner);
    editor.setText(TextRole.title1, 'size', 36.0);
    expect(owner.current.definitions.texts[TextRole.title1]!.size, 28);
    store.fail = true;
    expect(await editor.apply(), isFalse);
    expect(owner.current.definitions.texts[TextRole.title1]!.size, 28);
    store.fail = false;
    expect(await editor.apply(), isTrue);
    expect(owner.current.definitions.texts[TextRole.title1]!.size, 36);
    final reopened = StyleOwner(store);
    await reopened.load();
    expect(reopened.current.definitions.texts[TextRole.title1]!.size, 36);
    editor.dispose();
    owner.dispose();
    reopened.dispose();
  });
}
