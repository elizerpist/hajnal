import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PredictiveBackEvent;
import 'dart:async';
import '../features/onboarding/application/date_picker.dart';
import '../core/theme/hajnal_tokens.dart';
import '../core/artwork/artwork_source.dart';
import '../features/dashboard/presentation/dashboard.dart';
import '../features/onboarding/presentation/onboarding.dart';
import 'bootstrap_controller.dart';
import '../features/app_lock/application/lock_controller.dart';
import '../features/app_lock/presentation/lock_gate.dart';
import '../features/app_lock/presentation/lock_settings.dart';

class HajnalApp extends StatefulWidget {
  const HajnalApp({
    super.key,
    required this.controller,
    required this.picker,
    this.artwork,
    this.onRetry,
    this.lock,
  });
  final BootstrapController controller;
  final DatePicker picker;
  final ArtworkSource? artwork;
  final VoidCallback? onRetry;
  final LockController? lock;
  @override
  State<HajnalApp> createState() => _HajnalAppState();
}

class _HajnalAppState extends State<HajnalApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.controller.tracker.resume();
    final state = WidgetsBinding.instance.lifecycleState;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      widget.lock?.background();
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      widget.lock?.inactive();
    } else {
      _revealAfterFrame();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      widget.controller.tracker.resume();
      widget.lock?.resumed();
      _revealAfterFrame();
    } else {
      widget.controller.tracker.pause();
      if (state == AppLifecycleState.paused ||
          state == AppLifecycleState.detached) {
        widget.lock?.background();
      } else {
        widget.lock?.inactive();
      }
    }
  }

  void _revealAfterFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.lock != null) {
        unawaited(widget.lock!.revealAfterFrame().catchError((Object _) {}));
      }
    });
  }

  @override
  Future<bool> didPopRoute() async =>
      widget.lock?.locked == true || widget.lock?.obscured == true;

  @override
  bool handleStartBackGesture(PredictiveBackEvent backEvent) =>
      widget.lock?.locked == true || widget.lock?.obscured == true;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.controller.tracker.pause();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Hajnal',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: HajnalColors.purple),
      scaffoldBackgroundColor: HajnalColors.sheet,
      textTheme: ThemeData.light().textTheme.apply(
        bodyColor: HajnalColors.navy,
        displayColor: HajnalColors.navy,
      ),
    ),
    builder: (context, child) => widget.lock == null
        ? child!
        : LockGate(controller: widget.lock!, child: child!),
    home: _Bootstrap(
      controller: widget.controller,
      picker: widget.picker,
      artwork: widget.artwork,
      onRetry: widget.onRetry,
      lock: widget.lock,
    ),
  );
}

class _Bootstrap extends StatefulWidget {
  const _Bootstrap({
    required this.controller,
    required this.picker,
    this.artwork,
    this.onRetry,
    this.lock,
  });
  final BootstrapController controller;
  final DatePicker picker;
  final ArtworkSource? artwork;
  final VoidCallback? onRetry;
  final LockController? lock;
  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  bool _first = true;
  void _openOnboarding() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            Onboarding(controller: widget.controller, picker: widget.picker),
      ),
    );
  }

  void _openLockSettings() {
    final lock = widget.lock;
    if (lock == null || lock.locked) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LockSettingsPage(controller: lock),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) {
      final controller = widget.controller;
      if (controller.loading) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (controller.error != null) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Az adatok nem tölthetők be.'),
                TextButton(
                  onPressed: widget.onRetry ?? controller.retry,
                  child: const Text('Újrapróbálás'),
                ),
              ],
            ),
          ),
        );
      }
      if (_first) {
        _first = false;
        if (controller.startDate == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _openOnboarding();
          });
        }
      }
      return Dashboard(
        controller: controller,
        onOnboarding: _openOnboarding,
        onLockSettings: widget.lock == null ? null : _openLockSettings,
        artwork: widget.artwork,
      );
    },
  );
}
