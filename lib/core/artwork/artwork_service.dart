import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import '../database/hajnal_database.dart';
import 'artwork_catalog.dart';
import 'artwork_source.dart';

/// Owns dashboard artwork selection and app-private override files.
class ArtworkService extends ChangeNotifier implements ArtworkSource {
  ArtworkService(this.db, this.directory, [this.validate = decodeImage]);
  final HajnalDatabase db;
  final Directory directory;
  final Future<bool> Function(Uint8List) validate;
  int _generation = 0;
  static final role = dashboardArtwork.role;
  static const maxBytes = 8 * 1024 * 1024;

  static Future<bool> decodeImage(Uint8List data) async {
    ui.ImmutableBuffer? buffer;
    ui.ImageDescriptor? descriptor;
    ui.Codec? codec;
    try {
      buffer = await ui.ImmutableBuffer.fromUint8List(data);
      descriptor = await ui.ImageDescriptor.encoded(buffer);
      if (descriptor.width > 8192 ||
          descriptor.height > 8192 ||
          descriptor.width * descriptor.height > 32000000) {
        return false;
      }
      codec = await descriptor.instantiateCodec(
        targetWidth: descriptor.width > 1024 ? 1024 : descriptor.width,
      );
      final frame = await codec.getNextFrame();
      frame.image.dispose();
      return true;
    } catch (_) {
      return false;
    } finally {
      codec?.dispose();
      descriptor?.dispose();
      buffer?.dispose();
    }
  }

  Future<void> cleanup() async {
    await directory.create(recursive: true);
    await for (final item in directory.list()) {
      if (item is File && item.path.endsWith('.tmp')) await item.delete();
    }
  }

  @override
  Future<ArtworkDescriptor> resolve() async {
    await directory.create(recursive: true);
    final row = await (db.select(
      db.artworkOverrides,
    )..where((t) => t.role.equals(role))).getSingleOrNull();
    if (row == null ||
        row.filename.contains('/') ||
        row.filename.contains('..')) {
      return ArtworkDescriptor(revision: dashboardArtwork.revision);
    }
    final file = File('${directory.path}/${row.filename}');
    try {
      if (!await file.exists() || await file.length() > maxBytes) {
        return ArtworkDescriptor(revision: dashboardArtwork.revision);
      }
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty || bytes.length > maxBytes || !await validate(bytes)) {
        return ArtworkDescriptor(revision: dashboardArtwork.revision);
      }
      return ArtworkDescriptor(file: file, revision: row.revision);
    } on FileSystemException {
      return ArtworkDescriptor(revision: dashboardArtwork.revision);
    }
  }

  Future<void> install(File source) async {
    final generation = ++_generation;
    if (await source.length() > maxBytes) {
      throw const FormatException('Kép túl nagy');
    }
    final bytes = await source.readAsBytes();
    if (bytes.isEmpty || bytes.length > maxBytes || !await validate(bytes)) {
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
