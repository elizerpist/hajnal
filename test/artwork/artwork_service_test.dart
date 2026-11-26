import 'dart:io';
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
}
