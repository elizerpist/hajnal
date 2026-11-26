import '../database/hajnal_database.dart';
import 'artwork_store.dart';

class DriftArtworkStore implements ArtworkStore {
  DriftArtworkStore(this.db);
  final HajnalDatabase db;

  @override
  Future<List<String>> filenames() async =>
      (await db.select(db.artworkOverrides).get())
          .map((row) => row.filename)
          .toList();

  @override
  Future<ArtworkRecord?> find(String role) async {
    final row = await (db.select(
      db.artworkOverrides,
    )..where((table) => table.role.equals(role))).getSingleOrNull();
    return row == null ? null : ArtworkRecord(row.filename, row.revision);
  }

  @override
  Future<void> put(String role, String filename, String revision) async {
    await db
        .into(db.artworkOverrides)
        .insertOnConflictUpdate(
          ArtworkOverridesCompanion.insert(
            role: role,
            filename: filename,
            revision: revision,
          ),
        );
  }

  @override
  Future<void> delete(String role) async {
    await (db.delete(
      db.artworkOverrides,
    )..where((table) => table.role.equals(role))).go();
  }
}
