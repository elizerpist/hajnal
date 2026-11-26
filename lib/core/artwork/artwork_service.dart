import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import '../database/hajnal_database.dart';

class ArtworkDescriptor {
  const ArtworkDescriptor({this.file, required this.revision});
  final File? file;
  final String revision;
  static const bundle = ArtworkDescriptor(revision: 'bundle-1');
}

/// Owns dashboard artwork selection and app-private override files.
class ArtworkService extends ChangeNotifier {
  ArtworkService(this.db, this.directory, [this.validate = decodeImage]);
  final HajnalDatabase db;
  final Directory directory;
  final Future<bool> Function(Uint8List) validate;
  int _generation = 0;
  static const role = 'dashboard.default';
  static const maxBytes = 8 * 1024 * 1024;

  static Future<bool> decodeImage(Uint8List data) async {
    try {
      final codec = await ui.instantiateImageCodec(data, targetWidth: 1024);
      final frame = await codec.getNextFrame();
      frame.image.dispose();
      codec.dispose();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> cleanup() async {
    await directory.create(recursive: true);
    await for (final item in directory.list()) {
      if (item is File && item.path.endsWith('.tmp')) await item.delete();
    }
  }

  Future<ArtworkDescriptor> resolve() async {
    await directory.create(recursive: true);
    final row = await (db.select(
      db.artworkOverrides,
    )..where((t) => t.role.equals(role))).getSingleOrNull();
    if (row == null ||
        row.filename.contains('/') ||
        row.filename.contains('..')) {
      return ArtworkDescriptor.bundle;
    }
    final file = File('${directory.path}/${row.filename}');
    if (!await file.exists() || await file.length() > maxBytes) {
      return ArtworkDescriptor.bundle;
    }
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty || !await validate(bytes)) {
      return ArtworkDescriptor.bundle;
    }
    return ArtworkDescriptor(file: file, revision: row.revision);
  }

  Future<void> install(File source) async {
    final generation = ++_generation;
    if (await source.length() > maxBytes) {
      throw const FormatException('Kép túl nagy');
    }
    final bytes = await source.readAsBytes();
    if (bytes.isEmpty || !await validate(bytes)) {
      throw const FormatException('Érvénytelen kép');
    }
    await directory.create(recursive: true);
    final revision = '${DateTime.now().microsecondsSinceEpoch}-$generation';
    final filename = 'artwork-$revision.img';
    final temp = File('${directory.path}/$filename.tmp');
    await temp.writeAsBytes(bytes, flush: true);
    final target = await temp.rename('${directory.path}/$filename');
    if (generation != _generation) {
      await target.delete();
      return;
    }
    await db
        .into(db.artworkOverrides)
        .insertOnConflictUpdate(
          ArtworkOverridesCompanion.insert(
            role: role,
            filename: filename,
            revision: revision,
          ),
        );
    notifyListeners();
  }

  Future<void> clear() async {
    ++_generation;
    await (db.delete(
      db.artworkOverrides,
    )..where((t) => t.role.equals(role))).go();
    notifyListeners();
  }
}
