import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'app/bootstrap_controller.dart';
import 'app/hajnal_app.dart';
import 'core/database/hajnal_database.dart';
import 'core/artwork/artwork_service.dart';
import 'core/platform/date_picker.dart';
import 'features/recovery/data/drift_recovery_store.dart';
import 'features/recovery/data/recovery_repository.dart';

final bootstrapProvider = Provider<BootstrapController>(
  (ref) => throw StateError('Bootstrap not initialized'),
);
final artworkProvider = Provider<ArtworkService>(
  (ref) => throw StateError('Artwork not initialized'),
);

class _AppScope extends ConsumerWidget {
  const _AppScope({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context, WidgetRef ref) => HajnalApp(
    controller: ref.watch(bootstrapProvider),
    artwork: ref.watch(artworkProvider),
    picker: PlatformDatePicker(),
    onRetry: onRetry,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PaintingBinding.instance.imageCache.maximumSize = 40;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 32 * 1024 * 1024;
  runApp(const _Root());
}

class _Root extends StatefulWidget {
  const _Root();
  @override
  State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> {
  HajnalDatabase? database;
  BootstrapController? controller;
  ArtworkService? artwork;
  Object? error;
  @override
  void initState() {
    super.initState();
    open();
  }

  Future<void> open() async {
    try {
      final dir = await getApplicationSupportDirectory();
      final db = HajnalDatabase(
        NativeDatabase.createInBackground(
          File(p.join(dir.path, 'hajnal.sqlite')),
        ),
      );
      final art = ArtworkService(db, Directory(p.join(dir.path, 'artwork')));
      await art.cleanup();
      final vm = BootstrapController(
        DriftRecoveryStore(RecoveryRepository(db)),
        DateTime.now,
      );
      if (!mounted) {
        vm.dispose();
        await db.close();
        return;
      }
      setState(() {
        database = db;
        controller = vm;
        artwork = art;
        error = null;
      });
    } catch (e) {
      if (mounted) setState(() => error = e);
    }
  }

  void retry() {
    final oldController = controller;
    final oldArtwork = artwork;
    final oldDatabase = database;
    setState(() {
      controller = null;
      artwork = null;
      database = null;
      error = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      oldController?.dispose();
      oldArtwork?.dispose();
      await oldDatabase?.close();
      if (mounted) await open();
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    artwork?.dispose();
    database?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller != null) {
      return ProviderScope(
        overrides: [
          bootstrapProvider.overrideWithValue(controller!),
          artworkProvider.overrideWithValue(artwork!),
        ],
        child: _AppScope(onRetry: retry),
      );
    }
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: error == null
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Az adatok nem tölthetők be.'),
                    TextButton(
                      onPressed: open,
                      child: const Text('Újrapróbálás'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
