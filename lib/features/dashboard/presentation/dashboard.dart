import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../app/bootstrap_controller.dart';
import '../../../core/artwork/artwork_service.dart';
import '../../../core/artwork/artwork_view.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({
    super.key,
    required this.controller,
    required this.onOnboarding,
    this.artwork,
  });
  final BootstrapController controller;
  final VoidCallback onOnboarding;
  final ArtworkService? artwork;
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  late final AnimationController progress = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  bool moved = false;
  double drag = 0;
  void settle(bool open) {
    if (MediaQuery.disableAnimationsOf(context)) {
      progress.value = open ? 1 : 0;
    } else {
      progress.animateTo(open ? 1 : 0, curve: const Cubic(.2, .85, .25, 1));
    }
  }

  @override
  void initState() {
    super.initState();
    progress.addListener(_refreshBack);
  }

  void _refreshBack() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    progress.removeListener(_refreshBack);
    progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: progress.value == 0,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop && progress.value > 0) settle(false);
    },
    child: Scaffold(
      extendBodyBehindAppBar: true,
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              ListTile(
                title: const Text('Onboarding'),
                onTap: () {
                  Navigator.pop(context);
                  widget.onOnboarding();
                },
              ),
            ],
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxHeight;
          final cardWidth = math.min(296.0, constraints.maxWidth - 32);
          final travel = math.min(96.0, height * .15);
          final closedTop = math.max(
            MediaQuery.paddingOf(context).top + 64,
            height - 278,
          );
          return Stack(
            fit: StackFit.expand,
            children: [
              ArtworkView(service: widget.artwork),
              AnimatedBuilder(
                animation: progress,
                builder: (context, _) => Positioned(
                  top: closedTop + 68 - travel * progress.value,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Opacity(
                    opacity: progress.value,
                    child: const DecoratedBox(
                      key: Key('empty-sheet'),
                      decoration: BoxDecoration(
                        color: Color(0xfffffcfb),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.elliptical(92, 70),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: progress,
                builder: (context, _) => Positioned(
                  top: closedTop - travel * progress.value,
                  left: (constraints.maxWidth - cardWidth) / 2,
                  width: cardWidth,
                  height: 118,
                  child: Semantics(
                    button: true,
                    label: 'Napi összegzés',
                    hint: progress.value < .5
                        ? 'Panel megnyitása'
                        : 'Panel bezárása',
                    onTap: () => settle(progress.value < .5),
                    child: GestureDetector(
                      key: const Key('summary-card'),
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (_) {
                        moved = false;
                      },
                      onTap: () {
                        if (!moved) settle(progress.value < .5);
                      },
                      onVerticalDragStart: (_) {
                        moved = false;
                        drag = 0;
                        progress.stop();
                      },
                      onVerticalDragUpdate: (d) {
                        moved = true;
                        drag -= d.delta.dy;
                        progress.value = (progress.value - d.delta.dy / travel)
                            .clamp(0, 1);
                      },
                      onVerticalDragEnd: (_) {
                        settle(drag > 30 || progress.value >= .42);
                      },
                      onVerticalDragCancel: () => settle(progress.value >= .5),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xfffffcfb),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0x246a56b4)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0a2c2e77),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                child: ListenableBuilder(
                                  listenable: widget.controller.tracker,
                                  builder: (context, _) => Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Tiszta napok',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        '${widget.controller.tracker.days ?? '—'}',
                                        style: const TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(
                                        'nap',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              height: 74,
                              width: 1,
                              color: const Color(0x246a56b4),
                            ),
                            const Expanded(child: SizedBox()),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.paddingOf(context).top + 8,
                left: 16,
                child: Builder(
                  builder: (context) => IconButton.filledTonal(
                    tooltip: 'Menü',
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    icon: const Icon(Icons.menu),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}
