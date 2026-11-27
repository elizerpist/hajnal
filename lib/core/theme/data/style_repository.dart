import 'package:drift/drift.dart';
import '../../database/hajnal_database.dart';
import '../application/style_store.dart';
import '../domain/style_definitions.dart';

class StyleRepository implements StyleStore {
  StyleRepository(this._db);
  final HajnalDatabase _db;

  @override
  Future<StyleSnapshot> load() async {
    final row = await (_db.select(
      _db.styleSettings,
    )..where((t) => t.id.equals(1))).getSingleOrNull();
    if (row == null) return StyleSnapshot(StyleDefinitions.defaults(), 0);
    try {
      return StyleSnapshot(StyleDefinitions.decode(row.payload), row.revision);
    } on FormatException {
      return StyleSnapshot(StyleDefinitions.defaults(), row.revision);
    }
  }

  @override
  Future<int> save(StyleDefinitions definitions, int expectedRevision) async {
    final payload = definitions.encode();
    StyleDefinitions.decode(payload);
    return _db.transaction(() async {
      final current = await (_db.select(
        _db.styleSettings,
      )..where((t) => t.id.equals(1))).getSingleOrNull();
      if ((current?.revision ?? 0) != expectedRevision) {
        throw StateError('Stale style revision');
      }
      final next = expectedRevision + 1;
      if (current == null) {
        await _db
            .into(_db.styleSettings)
            .insert(
              StyleSettingsCompanion.insert(
                id: const Value(1),
                revision: next,
                payload: payload,
              ),
            );
      } else {
        final count =
            await (_db.update(_db.styleSettings)..where(
                  (t) => t.id.equals(1) & t.revision.equals(expectedRevision),
                ))
                .write(
                  StyleSettingsCompanion(
                    revision: Value(next),
                    payload: Value(payload),
                  ),
                );
        if (count != 1) throw StateError('Stale style revision');
      }
      return next;
    });
  }
}
