import 'package:flutter/material.dart';
import '../../../app/bootstrap_controller.dart';
import '../../../core/artwork/artwork_source.dart';
import '../../../core/artwork/artwork_catalog.dart';
import '../../../core/artwork/artwork_view.dart';
import '../../../core/theme/hajnal_theme.dart';
import '../../../core/theme/domain/style_roles.dart';
import '../../../core/theme/hajnal_components.dart';
import '../../../core/theme/panic_visual.dart';
import 'dashboard_layout.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({
    super.key,
    required this.controller,
    required this.onOnboarding,
    this.onLockSettings,
    this.onStyle,
    this.artwork,
    this.onPanic,
    this.onHistory,
  });
  final BootstrapController controller;
  final VoidCallback onOnboarding;
  final VoidCallback? onLockSettings;
  final VoidCallback? onStyle;
  final ArtworkSource? artwork;
  final VoidCallback? onPanic;
  final VoidCallback? onHistory;
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
        backgroundColor: HajnalStyle.of(context).color('background'),
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.all(HajnalStyle.of(context).spacing('margin')),
            children: [
              HajnalNavigationRow(
                label: 'Onboarding',
                onTap: () {
                  Navigator.pop(context);
                  widget.onOnboarding();
                },
              ),
              SizedBox(height: HajnalStyle.of(context).spacing('cardGap')),
              if (widget.onLockSettings != null) ...[
                HajnalNavigationRow(
                  label: 'Alkalmazászár',
                  leading: const Icon(Icons.lock_outline),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onLockSettings!();
                  },
                ),
                SizedBox(height: HajnalStyle.of(context).spacing('cardGap')),
              ],
              if (widget.onStyle != null)
                HajnalNavigationRow(
                  label: 'Stílus',
                  leading: const Icon(Icons.palette_outlined),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onStyle!();
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
                    child: IgnorePointer(
                      ignoring: progress.value < .5,
                      child: DecoratedBox(
                        key: const Key('empty-sheet'),
                        decoration: HajnalStyle.of(context)
                            .card(CardRole.content)
                            .copyWith(borderRadius: DashboardVisual.sheet),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              24,
                              0,
                              24,
                              media.padding.bottom + 12,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                key: const Key('dashboard-help'),
                                borderRadius: PanicVisual.corner,
                                onTap: widget.onPanic,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    minHeight: 48,
                                    minWidth: double.infinity,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 3,
                                    ),
                                    child: DecoratedBox(
                                      key: const Key('dashboard-help-surface'),
                                      decoration: BoxDecoration(
                                        gradient: PanicVisual.helpGradient,
                                        borderRadius: PanicVisual.corner,
                                      ),
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          minHeight: 42,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 6,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.favorite_border,
                                                color: PanicVisual.white,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Flexible(
                                                child: Text(
                                                  'Segítség kell',
                                                  textAlign: TextAlign.center,
                                                  style: HajnalStyle.of(context)
                                                      .text(TextRole.button)
                                                      .copyWith(
                                                        color:
                                                            PanicVisual.white,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
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
                        decoration: HajnalStyle.of(context)
                            .card(CardRole.large)
                            .copyWith(borderRadius: DashboardVisual.card),
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
                                        Text(
                                          'Tiszta napok',
                                          style: HajnalStyle.of(
                                            context,
                                          ).text(TextRole.helper),
                                        ),
                                        const SizedBox(height: 3),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.baseline,
                                          textBaseline: TextBaseline.alphabetic,
                                          children: [
                                            Text(
                                              '${widget.controller.tracker.days ?? '—'}',
                                              style: HajnalStyle.of(
                                                context,
                                              ).text(TextRole.dayCount),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'nap',
                                              style: HajnalStyle.of(
                                                context,
                                              ).text(TextRole.helper),
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
                              color: HajnalStyle.of(context).color('border'),
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
                  builder: (context) => HajnalNavigationIcon(
                    label: 'Menü',
                    overArtwork: true,
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    icon: Icons.menu,
                  ),
                ),
              ),
              if (widget.onHistory != null)
                Positioned(
                  top: MediaQuery.paddingOf(context).top + 8,
                  right: 20,
                  child: HajnalNavigationIcon(
                    label: 'Történetem',
                    overArtwork: true,
                    onPressed: widget.onHistory,
                    icon: Icons.timeline,
                  ),
                ),
            ],
          );
        },
      ),
    ),
  );
}
