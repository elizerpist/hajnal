import 'package:flutter/material.dart';
import '../../../app/bootstrap_controller.dart';
import '../../../core/artwork/artwork_source.dart';
import '../../../core/artwork/artwork_catalog.dart';
import '../../../core/artwork/artwork_view.dart';
import '../../../core/theme/hajnal_tokens.dart';
import 'dashboard_layout.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({
    super.key,
    required this.controller,
    required this.onOnboarding,
    this.onLockSettings,
    this.artwork,
  });
  final BootstrapController controller;
  final VoidCallback onOnboarding;
  final VoidCallback? onLockSettings;
  final ArtworkSource? artwork;
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  late final AnimationController progress = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  late final AnimationController sheetOpacity = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
  );
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final sheetOpen = ValueNotifier(false);
  bool moved = false;
  double drag = 0;
  void settle(bool open) {
    if (open || progress.value == 0) sheetOpen.value = open;
    if (MediaQuery.disableAnimationsOf(context)) {
      progress.value = open ? 1 : 0;
      sheetOpacity.value = open ? 1 : 0;
    } else {
      progress.animateTo(open ? 1 : 0, curve: const Cubic(.2, .85, .25, 1));
      sheetOpacity.animateTo(open ? 1 : 0, curve: Curves.ease);
    }
  }

  @override
  void initState() {
    super.initState();
    progress.addListener(_refreshBack);
  }

  void _refreshBack() {
    final open = progress.value > 0;
    if (sheetOpen.value != open) sheetOpen.value = open;
  }

  @override
  void dispose() {
    progress.removeListener(_refreshBack);
    progress.dispose();
    sheetOpacity.dispose();
    sheetOpen.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
    valueListenable: sheetOpen,
    builder: (context, open, child) => PopScope(
      canPop: !open,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && scaffoldKey.currentState?.isDrawerOpen == true) {
          scaffoldKey.currentState!.closeDrawer();
        } else if (!didPop && sheetOpen.value) {
          settle(false);
        }
      },
      child: child!,
    ),
    child: Scaffold(
      key: scaffoldKey,
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
              if (widget.onLockSettings != null)
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Alkalmazászár'),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onLockSettings!();
                  },
                ),
            ],
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final media = MediaQuery.of(context);
          final layout = DashboardLayout.resolve(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            topInset: media.padding.top,
            bottomInset: media.padding.bottom,
            textScale: media.textScaler.scale(1),
          );
          final cardWidth = layout.cardWidth;
          final cardHeight = layout.cardHeight;
          final travel = layout.travel;
          return Stack(
            fit: StackFit.expand,
            children: [
              ArtworkView(role: dashboardArtwork.role, service: widget.artwork),
              AnimatedBuilder(
                animation: Listenable.merge([progress, sheetOpacity]),
                builder: (context, _) => Positioned(
                  top: layout.sheetTop(progress.value),
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Opacity(
                    key: const Key('sheet-opacity'),
                    opacity: sheetOpacity.value,
                    child: const DecoratedBox(
                      key: Key('empty-sheet'),
                      decoration: BoxDecoration(
                        color: HajnalColors.sheet,
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
                  top: layout.cardTop(progress.value),
                  left: layout.cardLeft,
                  width: cardWidth,
                  height: cardHeight,
                  child: Semantics(
                    container: true,
                    button: true,
                    label: 'Napi összegzés',
                    hint: progress.value < .5
                        ? 'Panel megnyitása'
                        : 'Panel bezárása',
                    onTap: () => settle(progress.value < .5),
                    child: GestureDetector(
                      excludeFromSemantics: true,
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
                        sheetOpacity.stop();
                      },
                      onVerticalDragUpdate: (d) {
                        moved = true;
                        drag -= d.delta.dy;
                        progress.value =
                            (progress.value -
                                    d.delta.dy / (travel == 0 ? 1 : travel))
                                .clamp(0, 1);
                        sheetOpacity.value = progress.value;
                      },
                      onVerticalDragEnd: (_) {
                        settle(drag > 30 || progress.value >= .42);
                      },
                      onVerticalDragCancel: () => settle(progress.value >= .5),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: HajnalColors.card,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: HajnalColors.border),
                          boxShadow: const [
                            BoxShadow(
                              color: HajnalColors.cardShadow,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  15,
                                  13,
                                  15,
                                  10,
                                ),
                                child: ListenableBuilder(
                                  listenable: widget.controller.tracker,
                                  builder: (context, _) => FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.topLeft,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Tiszta napok',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: HajnalColors.muted,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.baseline,
                                          textBaseline: TextBaseline.alphabetic,
                                          children: [
                                            Text(
                                              '${widget.controller.tracker.days ?? '—'}',
                                              style: const TextStyle(
                                                fontSize: 27,
                                                height: 1,
                                                fontWeight: FontWeight.w800,
                                                color: HajnalColors.navy,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            const Text(
                                              'nap',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: HajnalColors.purple,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              height: 74,
                              width: 1,
                              color: HajnalColors.border,
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
                left: 20,
                child: Builder(
                  builder: (context) => IconButton(
                    tooltip: 'Menü',
                    style: IconButton.styleFrom(
                      fixedSize: const Size(54, 54),
                      backgroundColor: HajnalColors.heroControl,
                      foregroundColor: Colors.white,
                      side: const BorderSide(
                        color: HajnalColors.heroControlBorder,
                      ),
                    ),
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
