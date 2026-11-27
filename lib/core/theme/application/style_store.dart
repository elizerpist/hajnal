import '../domain/style_definitions.dart';

class StyleSnapshot {
  const StyleSnapshot(this.definitions, this.revision);
  final StyleDefinitions definitions;
  final int revision;
}

abstract interface class StyleStore {
  Future<StyleSnapshot> load();
  Future<int> save(StyleDefinitions definitions, int expectedRevision);
}
