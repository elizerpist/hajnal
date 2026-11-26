import 'dart:async';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/core/artwork/artwork_service.dart';
import 'package:hajnal/core/artwork/drift_artwork_store.dart';
import 'package:hajnal/core/artwork/artwork_catalog.dart';
import 'package:hajnal/core/artwork/artwork_source.dart';
import 'package:hajnal/core/artwork/artwork_view.dart';
import 'package:hajnal/core/database/hajnal_database.dart';

class ControlledArtwork extends ArtworkService {
  ControlledArtwork(super.store, super.directory);
  final responses = <Completer<ArtworkDescriptor>>[];
  final held = <String>{};
  @override
  void retain(File file) => held.add(file.path);
  @override
  Future<void> release(File file) async {
    held.remove(file.path);
  }

  @override
  Future<ArtworkDescriptor> resolve(String role) {
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
      final service = ControlledArtwork(DriftArtworkStore(db), dir);
      try {
        await tester.pumpWidget(
          MaterialApp(
            home: ArtworkView(role: dashboardArtwork.role, service: service),
          ),
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
  testWidgets('visible file remains retained until replacement decodes', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final dir = await Directory.systemTemp.createTemp('art-view-retain-');
      final bytes = await File(
        'assets/artwork/dashboard/placeholder.png',
      ).readAsBytes();
      final old = await File('${dir.path}/old.png').writeAsBytes(bytes);
      final newer = await File('${dir.path}/new.png').writeAsBytes(bytes);
      final db = HajnalDatabase(NativeDatabase.memory());
      final service = ControlledArtwork(DriftArtworkStore(db), dir);
      try {
        await tester.pumpWidget(
          MaterialApp(
            home: ArtworkView(role: dashboardArtwork.role, service: service),
          ),
        );
        String? selectedPath() {
          final image =
              (tester.widget<Image>(find.byType(Image)).image as ResizeImage)
                  .imageProvider;
          return image is FileImage ? image.file.path : null;
        }

        service.responses.single.complete(
          ArtworkDescriptor(file: old, revision: 'old'),
        );
        for (var i = 0; i < 40 && selectedPath() != old.path; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          await tester.pump();
        }
        expect(selectedPath(), old.path);
        expect(service.held, contains(old.path));
        service.changed();
        expect(service.held, contains(old.path));
        service.responses.last.complete(
          ArtworkDescriptor(file: newer, revision: 'new'),
        );
        for (var i = 0; i < 40 && selectedPath() != newer.path; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          await tester.pump();
        }
        expect(selectedPath(), newer.path);
        expect(service.held, {newer.path});
        await tester.pumpWidget(const SizedBox());
        expect(service.held, isEmpty);
      } finally {
        service.dispose();
        await db.close();
        await dir.delete(recursive: true);
      }
    });
  });
}
