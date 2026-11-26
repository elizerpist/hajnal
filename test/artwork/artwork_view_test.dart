import 'dart:async';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/core/artwork/artwork_service.dart';
import 'package:hajnal/core/artwork/artwork_source.dart';
import 'package:hajnal/core/artwork/artwork_view.dart';
import 'package:hajnal/core/database/hajnal_database.dart';

class ControlledArtwork extends ArtworkService {
  ControlledArtwork(super.db, super.directory);
  final responses = <Completer<ArtworkDescriptor>>[];
  @override
  Future<ArtworkDescriptor> resolve() {
    final completer = Completer<ArtworkDescriptor>();
    responses.add(completer);
    return completer.future;
  }

  void changed() => notifyListeners();
}

void main() {
  testWidgets('older load cannot replace a newer decoded artwork', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final dir = await Directory.systemTemp.createTemp('art-view-');
      final bytes = await File(
        'assets/artwork/dashboard/placeholder.png',
      ).readAsBytes();
      final old = await File('${dir.path}/old.png').writeAsBytes(bytes);
      final newer = await File('${dir.path}/new.png').writeAsBytes(bytes);
      final db = HajnalDatabase(NativeDatabase.memory());
      final service = ControlledArtwork(db, dir);
      try {
        await tester.pumpWidget(
          MaterialApp(home: ArtworkView(service: service)),
        );
        ImageProvider selected() =>
            (tester.widget<Image>(find.byType(Image)).image as ResizeImage)
                .imageProvider;
        expect(service.responses.length, 1);
        expect(selected(), isA<AssetImage>());
        service.changed();
        expect(service.responses.length, 2);
        service.responses[1].complete(
          ArtworkDescriptor(file: newer, revision: 'new'),
        );
        await tester.pumpAndSettle();
        for (var i = 0; i < 40 && selected() is! FileImage; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          await tester.pump();
        }
        expect(selected(), isA<FileImage>());
        expect((selected() as FileImage).file.path, newer.path);
        service.responses[0].complete(
          ArtworkDescriptor(file: old, revision: 'old'),
        );
        await tester.pumpAndSettle();
        expect((selected() as FileImage).file.path, newer.path);
        await tester.pumpWidget(const SizedBox());
      } finally {
        service.dispose();
        await db.close();
        await dir.delete(recursive: true);
      }
    });
  });
}
