import '../domain/style_definitions.dart';
import 'style_store.dart';

class SaveStyle {
  const SaveStyle(this._store);
  final StyleStore _store;

  Future<StyleSnapshot> call(StyleDefinitions definitions, int revision) async {
    final validated = StyleDefinitions.decode(definitions.encode());
    final next = await _store.save(validated, revision);
    return StyleSnapshot(validated, next);
  }
}
