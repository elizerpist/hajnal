import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/core/artwork/artwork_service.dart';
import 'package:hajnal/core/database/hajnal_database.dart';

void main() {
  test(
    'invalid image leaves prior descriptor and missing file falls back',
    () async {
      final dir = await Directory.systemTemp.createTemp('hajnal-art-');
      final db = HajnalDatabase(NativeDatabase.memory());
      final service = ArtworkService(
        db,
        dir,
        (bytes) async => bytes.first == 1,
      );
      try {
        final good = File('${dir.path}/source');
        await good.writeAsBytes([1, 2]);
        await service.install(good);
        final before = await service.resolve();
        expect(before.file, isNotNull);
        await good.writeAsBytes([0]);
        await expectLater(service.install(good), throwsFormatException);
        expect((await service.resolve()).file?.path, before.file?.path);
        await before.file!.delete();
        expect((await service.resolve()).file, isNull);
      } finally {
        await db.close();
        await dir.delete(recursive: true);
      }
    },
  );
  test(
    'newer installation wins when older validation finishes later',
    () async {
      final dir = await Directory.systemTemp.createTemp('hajnal-art-race-');
      final db = HajnalDatabase(NativeDatabase.memory());
      final slow = Completer<bool>();
      final service = ArtworkService(
        db,
        dir,
        (bytes) => bytes.first == 1 ? slow.future : Future.value(true),
      );
      try {
        final first = File('${dir.path}/first');
        final second = File('${dir.path}/second');
        await first.writeAsBytes([1]);
        await second.writeAsBytes([2]);
        final old = service.install(first);
        await Future<void>.delayed(Duration.zero);
        await service.install(second);
        slow.complete(true);
        await old;
        final reopened = ArtworkService(db, dir, (_) async => true);
        final current = await reopened.resolve();
        expect(await current.file!.readAsBytes(), [2]);
        await reopened.clear();
        expect((await reopened.resolve()).file, isNull);
        reopened.dispose();
      } finally {
        service.dispose();
        await db.close();
        await dir.delete(recursive: true);
      }
    },
  );
  testWidgets('real codec accepts PNG and rejects corrupt bytes', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final png = await File(
        'assets/artwork/dashboard/placeholder.png',
      ).readAsBytes();
      expect(await ArtworkService.decodeImage(png), isTrue);
      expect(
        await ArtworkService.decodeImage(Uint8List.fromList([0, 1, 2])),
        isFalse,
      );
    });
  });
  test('artwork descriptor survives database close and reopen', () async {
    final dir = await Directory.systemTemp.createTemp('hajnal-art-restart-');
    final databaseFile = File('${dir.path}/database.sqlite');
    final source = File('${dir.path}/source');
    await source.writeAsBytes([9]);
    final artworkDir = Directory('${dir.path}/private');
    var db = HajnalDatabase(NativeDatabase(databaseFile));
    var service = ArtworkService(db, artworkDir, (_) async => true);
    try {
      await service.install(source);
      final installed = await service.resolve();
      service.dispose();
      await db.close();
      db = HajnalDatabase(NativeDatabase(databaseFile));
      service = ArtworkService(db, artworkDir, (_) async => true);
      final restored = await service.resolve();
      expect(restored.revision, installed.revision);
      expect(await restored.file!.readAsBytes(), [9]);
    } finally {
      service.dispose();
      await db.close();
      await dir.delete(recursive: true);
    }
  });
  testWidgets('image dimensions are checked before full decoding', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      canvas.drawRect(const ui.Rect.fromLTWH(0, 0, 8193, 1), ui.Paint());
      final image = await recorder.endRecording().toImage(8193, 1);
      final encoded = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      expect(
        await ArtworkService.decodeImage(encoded!.buffer.asUint8List()),
        isFalse,
      );
    });
  });
  test(
    'oversized files are rejected and cleanup only removes temporary files',
    () async {
      final dir = await Directory.systemTemp.createTemp('hajnal-art-cleanup-');
      final db = HajnalDatabase(NativeDatabase.memory());
      final service = ArtworkService(db, dir, (_) async => true);
      try {
        final temporary = File('${dir.path}/unfinished.tmp');
        final keep = File('${dir.path}/keep.img');
        await temporary.writeAsBytes([1]);
        await keep.writeAsBytes([2]);
        await service.cleanup();
        expect(await temporary.exists(), isFalse);
        expect(await keep.exists(), isTrue);
        final big = File('${dir.path}/big');
        await big.writeAsBytes(Uint8List(ArtworkService.maxBytes + 1));
        await expectLater(service.install(big), throwsFormatException);
        expect((await service.resolve()).file, isNull);
      } finally {
        service.dispose();
        await db.close();
        await dir.delete(recursive: true);
      }
    },
  );
}
