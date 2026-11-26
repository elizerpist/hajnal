import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'artwork_catalog.dart';
import 'artwork_source.dart';
import 'artwork_store.dart';

/// Owns dashboard artwork selection and app-private override files.
class ArtworkService extends ChangeNotifier implements ArtworkSource {
  ArtworkService(
    ArtworkStore store,
    this.directory, [
    this.validate = decodeImage,
  ]) : _store = store;
  final ArtworkStore _store;
  final Directory directory;
  final Future<bool> Function(Uint8List) validate;
  int _sequence = 0;
  int _latestAccepted = 0;
  Future<void> _pending = Future.value();
  final Map<String, int> _retained = {};

  Future<void> _enqueue(Future<void> Function() operation) {
    final result = _pending.then((_) => operation());
    _pending = result.catchError((Object _) {});
    return result;
  }

  @override
  void retain(File file) {
    _retained.update(file.path, (count) => count + 1, ifAbsent: () => 1);
  }

  @override
  Future<void> release(File file) {
    final count = _retained[file.path];
    if (count == null) return Future.value();
    if (count > 1) {
      _retained[file.path] = count - 1;
    } else {
      _retained.remove(file.path);
    }
    return cleanup();
  }

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

  void _checkRole(String role) {
    if (role != dashboardArtwork.role) throw ArgumentError.value(role, 'role');
  }

  Future<void> cleanup() => _enqueue(_cleanup);

  Future<void> _cleanup() async {
    await directory.create(recursive: true);
    final active = (await _store.filenames()).toSet();
    await for (final item in directory.list()) {
      if (item is! File) continue;
      final name = item.uri.pathSegments.last;
      if ((name.endsWith('.tmp') ||
              (name.startsWith('artwork-') && name.endsWith('.img'))) &&
          !active.contains(name) &&
          !_retained.containsKey(item.path)) {
        await item.delete();
      }
    }
  }

  @override
  Future<ArtworkDescriptor> resolve(String role) async {
    _checkRole(role);
    await directory.create(recursive: true);
    final row = await _store.find(role);
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

  Future<void> install(String role, File source) async {
    _checkRole(role);
    final generation = ++_sequence;
    if (await source.length() > maxBytes) {
      throw const FormatException('Kép túl nagy');
    }
    final bytes = await source.readAsBytes();
    if (bytes.isEmpty || bytes.length > maxBytes || !await validate(bytes)) {
      throw const FormatException('Érvénytelen kép');
    }
    if (generation < _latestAccepted) return;
    _latestAccepted = generation;
    await _enqueue(() async {
      if (generation != _latestAccepted) return;
      await directory.create(recursive: true);
      final revision = '${DateTime.now().microsecondsSinceEpoch}-$generation';
      final filename = 'artwork-$revision.img';
      final temp = File('${directory.path}/$filename.tmp');
      File? target;
      try {
        await temp.writeAsBytes(bytes, flush: true);
        target = await temp.rename('${directory.path}/$filename');
        if (generation != _latestAccepted) {
          await target.delete();
          return;
        }
        await _store.put(role, filename, revision);
      } catch (_) {
        try {
          if (target != null) {
            final referenced = (await _store.filenames()).contains(filename);
            if (referenced) {
              notifyListeners();
            } else if (await target.exists()) {
              await target.delete();
            }
          }
          if (await temp.exists()) await temp.delete();
        } catch (_) {
          // Keep uncertain files for recovery and preserve the original error.
        }
        rethrow;
      }
      notifyListeners();
      await _cleanup();
    });
  }

  Future<void> clear(String role) {
    _checkRole(role);
    _latestAccepted = ++_sequence;
    return _enqueue(() async {
      await _store.delete(role);
      notifyListeners();
      await _cleanup();
    });
  }
}
