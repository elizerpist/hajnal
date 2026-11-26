import 'dart:io';
import 'dart:typed_data';
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
}
