import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app_services.dart';
import 'app/bootstrap_controller.dart';
import 'app/hajnal_app.dart';
import 'features/app_lock/application/lock_controller.dart';
import 'core/artwork/artwork_source.dart';
import 'core/platform/date_picker.dart';
import 'features/onboarding/application/onboarding_store.dart';
import 'core/theme/application/style_controller.dart';
import 'features/panic/application/panic_controller.dart';
import 'features/history/application/history_store.dart';

final bootstrapProvider = Provider<BootstrapController>(
  (ref) => throw StateError('Bootstrap not initialized'),
);
final artworkProvider = Provider<ArtworkSource>(
  (ref) => throw StateError('Artwork not initialized'),
);
final lockProvider = Provider<LockController>(
  (ref) => throw StateError('Lock not initialized'),
);
final onboardingProvider = Provider<OnboardingStore>(
  (ref) => throw StateError('Onboarding not initialized'),
);
final styleProvider = Provider<StyleOwner>(
  (ref) => throw StateError('Style not initialized'),
);
final panicProvider = Provider<PanicController>(
  (ref) => throw StateError('Panic not initialized'),
);
final historyProvider = Provider<HistoryStore>(
  (ref) => throw StateError('History not initialized'),
);

class _AppScope extends ConsumerWidget {
  const _AppScope({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context, WidgetRef ref) => HajnalApp(
    controller: ref.watch(bootstrapProvider),
    artwork: ref.watch(artworkProvider),
    picker: PlatformDatePicker(),
    lock: ref.watch(lockProvider),
    onboardingStore: ref.watch(onboardingProvider),
    style: ref.watch(styleProvider),
    panic: ref.watch(panicProvider),
    history: ref.watch(historyProvider),
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
  AppServices? services;
  Object? error;
  bool opening = false;
  @override
  void initState() {
    super.initState();
    open();
  }

  Future<void> open() async {
    if (opening) return;
    opening = true;
    if (error != null && mounted) setState(() => error = null);
    try {
      final result = await AppServices.open();
      if (!mounted) {
        await result.close();
        return;
      }
      setState(() {
        services = result;
        error = null;
      });
    } catch (e) {
      if (mounted) setState(() => error = e);
    } finally {
      opening = false;
    }
  }

  void retry() {
    final old = services;
    setState(() {
      services = null;
      error = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await old?.close();
        if (mounted) await open();
      } catch (e) {
        if (mounted) setState(() => error = e);
      }
    });
  }

  @override
  void dispose() {
    services?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = services;
    if (current != null) {
      return ProviderScope(
        overrides: [
          bootstrapProvider.overrideWithValue(current.controller),
          artworkProvider.overrideWithValue(current.artwork),
          lockProvider.overrideWithValue(current.lock),
          onboardingProvider.overrideWithValue(current.onboarding),
          styleProvider.overrideWithValue(current.style),
          panicProvider.overrideWithValue(current.panic),
          historyProvider.overrideWithValue(current.history),
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
