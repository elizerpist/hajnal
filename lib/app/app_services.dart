import 'dart:io';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../core/artwork/artwork_service.dart';
import '../core/database/hajnal_database.dart';
import '../features/recovery/data/drift_recovery_store.dart';
import '../features/recovery/data/recovery_repository.dart';
import 'bootstrap_controller.dart';

class AppServices {
  AppServices._(this.database, this.controller, this.artwork);
  final HajnalDatabase database;
  final BootstrapController controller;
  final ArtworkService artwork;

  static Future<AppServices> open() async {
    final directory = await getApplicationSupportDirectory();
    final database = HajnalDatabase(
      NativeDatabase.createInBackground(
        File(p.join(directory.path, 'hajnal.sqlite')),
      ),
    );
    final artwork = ArtworkService(
      database,
      Directory(p.join(directory.path, 'artwork')),
    );
    try {
      await artwork.cleanup();
      final controller = BootstrapController(
        DriftRecoveryStore(RecoveryRepository(database)),
        DateTime.now,
      );
      return AppServices._(database, controller, artwork);
    } catch (_) {
      artwork.dispose();
      await database.close();
      rethrow;
    }
  }

  Future<void> close() async {
    controller.dispose();
    artwork.dispose();
    await database.close();
  }
}
