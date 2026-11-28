import '../features/practice/application/practice_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PredictiveBackEvent;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:async';
import '../features/onboarding/application/date_picker.dart';
import '../features/onboarding/application/onboarding_controller.dart';
import '../features/onboarding/application/onboarding_store.dart';
import '../core/theme/application/style_controller.dart';
import '../core/theme/hajnal_theme.dart';
import '../core/theme/presentation/style_editor.dart';
import '../core/artwork/artwork_source.dart';
import '../features/dashboard/presentation/dashboard.dart';
import '../features/onboarding/presentation/onboarding.dart';
import 'bootstrap_controller.dart';
import '../features/app_lock/application/lock_controller.dart';
import '../features/app_lock/presentation/lock_gate.dart';
import '../features/app_lock/presentation/lock_settings.dart';
import '../features/panic/application/panic_controller.dart';
import '../features/panic/presentation/panic_page.dart';
import '../features/history/application/history_store.dart';
import '../features/history/application/history_controller.dart';
import '../features/history/presentation/history_page.dart';

class HajnalApp extends StatefulWidget {
  const HajnalApp({
    super.key,
    required this.controller,
    required this.picker,
    this.artwork,
    this.onRetry,
    this.lock,
    this.onboardingStore,
    this.style,
    this.panic,
    this.history,
    this.practice,
  });
  final BootstrapController controller;
  final DatePicker picker;
  final ArtworkSource? artwork;
  final VoidCallback? onRetry;
  final LockController? lock;
  final OnboardingStore? onboardingStore;
  final StyleOwner? style;
  final PanicController? panic;
  final HistoryStore? history;
  final PracticeController? practice;
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
  Widget build(BuildContext context) => widget.style == null
      ? _app(hajnalTheme())
      : ListenableBuilder(
          listenable: widget.style!,
          builder: (context, _) =>
              _app(hajnalTheme(widget.style!.current.definitions)),
        );

  Widget _app(ThemeData theme) => MaterialApp(
    title: 'Hajnal',
    debugShowCheckedModeBanner: false,
    locale: const Locale('hu'),
    supportedLocales: const [Locale('hu')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: theme,
    builder: (context, child) => widget.lock == null
        ? child!
        : LockGate(controller: widget.lock!, child: child!),
    home: _Bootstrap(
      controller: widget.controller,
      picker: widget.picker,
      artwork: widget.artwork,
      onRetry: widget.onRetry,
      lock: widget.lock,
      onboardingStore: widget.onboardingStore,
      style: widget.style,
      panic: widget.panic,
      history: widget.history,
      practice: widget.practice,
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
    this.onboardingStore,
    this.style,
    this.panic,
    this.history,
    this.practice,
  });
  final BootstrapController controller;
  final DatePicker picker;
  final ArtworkSource? artwork;
  final VoidCallback? onRetry;
  final LockController? lock;
  final OnboardingStore? onboardingStore;
  final StyleOwner? style;
  final PanicController? panic;
  final HistoryStore? history;
  final PracticeController? practice;
  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  bool _first = true;
  bool _onboardingOpen = false;
  void _openOnboarding() {
    final store = widget.onboardingStore;
    if (_onboardingOpen || store == null) return;
    _onboardingOpen = true;
    final flow = OnboardingController(
      store,
      DateTime.now,
      dayChanges: widget.controller.tracker.calendarDay,
    );
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(builder: (_) => Onboarding(controller: flow)),
        )
        .whenComplete(() async {
          await flow.idle;
          flow.dispose();
          _onboardingOpen = false;
        });
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

  void _openStyle() {
    final owner = widget.style;
    if (owner == null) return;
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => StyleEditor(owner: owner)));
  }

  bool _panicOpen = false;
  bool _historyOpen = false;
  void _openHistory() {
    final history = widget.history;
    if (_historyOpen || history == null) return;
    _historyOpen = true;
    final controller = HistoryController(history, DateTime.now);
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (_) => HistoryPage(controller: controller),
          ),
        )
        .whenComplete(() {
          controller.dispose();
          _historyOpen = false;
        });
  }

  void _openPanic() {
    final panic = widget.panic;
    if (_panicOpen || panic == null) return;
    _panicOpen = true;
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(builder: (_) => PanicPage(controller: panic)),
        )
        .whenComplete(() => _panicOpen = false);
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
        onStyle: widget.style == null ? null : _openStyle,
        artwork: widget.artwork,
        onPanic: widget.panic == null ? null : _openPanic,
        onHistory: widget.history == null ? null : _openHistory,
        practice: widget.practice,
      );
    },
  );
}
