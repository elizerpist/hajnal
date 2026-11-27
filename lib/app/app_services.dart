import 'dart:io';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../core/artwork/artwork_service.dart';
import '../core/artwork/drift_artwork_store.dart';
import '../core/database/hajnal_database.dart';
import '../features/recovery/data/drift_recovery_store.dart';
import '../features/recovery/data/recovery_repository.dart';
import '../features/onboarding/application/onboarding_store.dart';
import '../features/onboarding/data/onboarding_repository.dart';
import '../features/sponsor/data/sponsor_repository.dart';
import '../features/app_lock/application/lock_controller.dart';
import '../features/app_lock/data/biometric_adapter.dart';
import '../features/app_lock/data/lock_repository.dart';
import '../features/app_lock/data/pin_hasher.dart';
import '../features/app_lock/data/secure_lock_store.dart';
import '../core/platform/lock_guard.dart';
import 'bootstrap_controller.dart';

class AppServices {
  AppServices._(
    this.database,
    this.controller,
    this.artwork,
    this.lock,
    this.onboarding,
  );
  final HajnalDatabase database;
  final BootstrapController controller;
  final ArtworkService artwork;
  final LockController lock;
  final OnboardingStore onboarding;

  static Future<AppServices> open() async {
    final directory = await getApplicationSupportDirectory();
    final database = HajnalDatabase(
      NativeDatabase.createInBackground(
        File(p.join(directory.path, 'hajnal.sqlite')),
      ),
    );
    final artwork = ArtworkService(
      DriftArtworkStore(database),
      Directory(p.join(directory.path, 'artwork')),
    );
    try {
      await artwork.cleanup();
      final recovery = RecoveryRepository(database);
      final controller = BootstrapController(
        DriftRecoveryStore(recovery),
        DateTime.now,
      );
      final lock = LockController(
        LockRepository(database, const SecureLockStore(), PinHasher()),
        BiometricAdapter(),
        DeviceGuardAdapter(),
      );
      await lock.initialize();
      return AppServices._(
        database,
        controller,
        artwork,
        lock,
        OnboardingRepository(database, recovery, SponsorRepository(database)),
      );
    } catch (_) {
      artwork.dispose();
      await database.close();
      rethrow;
    }
  }

  Future<void> close() async {
    controller.dispose();
    lock.dispose();
    artwork.dispose();
    await database.close();
  }
}
