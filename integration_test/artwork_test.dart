import 'dart:io';
import 'dart:ui' as ui;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hajnal/core/artwork/artwork_service.dart';
import 'package:hajnal/core/artwork/artwork_catalog.dart';
import 'package:hajnal/core/artwork/artwork_view.dart';
import 'package:hajnal/core/database/hajnal_database.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'private artwork install survives database reopening and clears',
    (tester) async {
      await tester.runAsync(() async {
        final base = await getTemporaryDirectory();
        final dir = await base.createTemp('artwork-integration-');
        final dbFile = File('${dir.path}/test.sqlite');
        final recorder = ui.PictureRecorder();
        ui.Canvas(
          recorder,
        ).drawColor(const ui.Color(0xff9459aa), ui.BlendMode.src);
        final image = await recorder.endRecording().toImage(4, 4);
        final png = await image.toByteData(format: ui.ImageByteFormat.png);
        image.dispose();
        final input = await File(
          '${dir.path}/input.png',
        ).writeAsBytes(png!.buffer.asUint8List());
        var db = HajnalDatabase(NativeDatabase(dbFile));
        var service = ArtworkService(db, Directory('${dir.path}/private'));
        try {
          await service.install(dashboardArtwork.role, input);
          final installed = await service.resolve(dashboardArtwork.role);
          expect(installed.file, isNotNull);
          service.dispose();
          await db.close();
          db = HajnalDatabase(NativeDatabase(dbFile));
          service = ArtworkService(db, Directory('${dir.path}/private'));
          expect(
            (await service.resolve(dashboardArtwork.role)).revision,
            installed.revision,
          );
          await tester.pumpWidget(
            MaterialApp(
              home: ArtworkView(role: dashboardArtwork.role, service: service),
            ),
          );
          await tester.pumpAndSettle();
          await service.clear(dashboardArtwork.role);
          expect((await service.resolve(dashboardArtwork.role)).file, isNull);
          await tester.pumpWidget(const SizedBox());
        } finally {
          service.dispose();
          await db.close();
          await dir.delete(recursive: true);
        }
      });
    },
  );
}
