import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'app/bootstrap_controller.dart';
import 'app/hajnal_app.dart';
import 'core/database/hajnal_database.dart';
import 'core/artwork/artwork_service.dart';
import 'core/platform/date_picker.dart';
import 'features/recovery/data/drift_recovery_store.dart';
import 'features/recovery/data/recovery_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      return HajnalApp(
        controller: controller!,
        picker: PlatformDatePicker(),
        artwork: artwork,
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
