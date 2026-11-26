import 'package:flutter/material.dart';
import '../core/platform/date_picker.dart';
import '../core/artwork/artwork_service.dart';
import '../features/dashboard/presentation/dashboard.dart';
import '../features/onboarding/presentation/onboarding.dart';
import 'bootstrap_controller.dart';

class HajnalApp extends StatefulWidget {
  const HajnalApp({
    super.key,
    required this.controller,
    required this.picker,
    this.artwork,
  });
  final BootstrapController controller;
  final DatePicker picker;
  final ArtworkService? artwork;
  @override
  State<HajnalApp> createState() => _HajnalAppState();
}

class _HajnalAppState extends State<HajnalApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.controller.tracker.resume();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      widget.controller.tracker.resume();
    } else {
      widget.controller.tracker.pause();
    }
  }

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
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff5b4fc0)),
    ),
    home: _Bootstrap(
      controller: widget.controller,
      picker: widget.picker,
      artwork: widget.artwork,
    ),
  );
}

class _Bootstrap extends StatefulWidget {
  const _Bootstrap({
    required this.controller,
    required this.picker,
    this.artwork,
  });
  final BootstrapController controller;
  final DatePicker picker;
  final ArtworkService? artwork;
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

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) {
      final controller = widget.controller;
      if (controller.loading) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (controller.error != null && controller.startDate == null) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Az adatok nem tölthetők be.'),
                TextButton(
                  onPressed: controller.retry,
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
        artwork: widget.artwork,
      );
    },
  );
}
