import '../../../core/theme/practice_visual.dart';
import '../../../core/theme/reflection_visual.dart';
import '../../practice/application/practice_controller.dart';
import '../../practice/presentation/practice_manager.dart';
import '../../reflection/application/reflection_store.dart';
import '../../../core/artwork/practice_artwork.dart';
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
    this.practice,
    this.reflection,
    this.onReflection,
  });
  final BootstrapController controller;
  final VoidCallback onOnboarding;
  final VoidCallback? onLockSettings;
  final VoidCallback? onStyle;
  final ArtworkSource? artwork;
  final VoidCallback? onPanic;
  final VoidCallback? onHistory;
  final PracticeController? practice;
  final ReflectionStore? reflection;
  final VoidCallback? onReflection;
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
  Stream<bool>? reflectionEnabled;
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
    reflectionEnabled = widget.reflection?.watchEnabled();
  }

  @override
  void didUpdateWidget(covariant Dashboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reflection != widget.reflection) {
      reflectionEnabled = widget.reflection?.watchEnabled();
    }
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
                        child: Stack(
                          children: [
                            if (widget.practice != null)
                              AnimatedBuilder(
                                animation: widget.practice!,
                                builder: (context, _) {
                                  final active = widget.practice!.active;
                                  return active == null
                                      ? const SizedBox.shrink()
                                      : Positioned.fill(
                                          child: IgnorePointer(
                                            child: ClipRRect(
                                              borderRadius:
                                                  DashboardVisual.sheet,
                                              child: Opacity(
                                                opacity: .27,
                                                child: Image.asset(
                                                  PracticeArtwork.forId(
                                                    active.id,
                                                  ).decoration,
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                },
                              ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: LayoutBuilder(
                                builder: (context, sheetSize) => SingleChildScrollView(
                                  reverse: true,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minHeight: sheetSize.maxHeight,
                                    ),
                                    child: IntrinsicHeight(
                                      child: Padding(
                                        padding: EdgeInsets.fromLTRB(
                                          24,
                                          widget.practice == null ? 0 : 54,
                                          24,
                                          media.padding.bottom + 12,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            if (widget.practice != null)
                                              AnimatedBuilder(
                                                animation: widget.practice!,
                                                builder: (context, _) {
                                                  final active =
                                                      widget.practice!.active;
                                                  return Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Amit gyakorlok',
                                                        style:
                                                            HajnalStyle.of(
                                                              context,
                                                            ).text(
                                                              TextRole
                                                                  .cardTitle,
                                                            ),
                                                      ),
                                                      InkWell(
                                                        key: const Key(
                                                          'dashboard-practice',
                                                        ),
                                                        onTap: () => showDialog<void>(
                                                          context: context,
                                                          builder: (_) =>
                                                              PracticeManager(
                                                                controller: widget
                                                                    .practice!,
                                                              ),
                                                        ),
                                                        child: ConstrainedBox(
                                                          constraints:
                                                              const BoxConstraints(
                                                                minHeight: 48,
                                                              ),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                child: Text(
                                                                  active?.text ??
                                                                      'Még nem választottál gyakorlatot.',
                                                                  maxLines: 2,
                                                                  style:
                                                                      PracticeVisual.homeText(
                                                                        context,
                                                                      ),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ),
                                                              const Icon(
                                                                Icons
                                                                    .chevron_right,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 12,
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ),
                                            const Spacer(),
                                            Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                key: const Key(
                                                  'dashboard-help',
                                                ),
                                                borderRadius:
                                                    PanicVisual.corner,
                                                onTap: widget.onPanic,
                                                child: ConstrainedBox(
                                                  constraints:
                                                      const BoxConstraints(
                                                        minHeight: 48,
                                                        minWidth:
                                                            double.infinity,
                                                      ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 3,
                                                        ),
                                                    child: DecoratedBox(
                                                      key: const Key(
                                                        'dashboard-help-surface',
                                                      ),
                                                      decoration: BoxDecoration(
                                                        gradient: PanicVisual
                                                            .helpGradient,
                                                        borderRadius:
                                                            PanicVisual.corner,
                                                      ),
                                                      child: ConstrainedBox(
                                                        constraints:
                                                            const BoxConstraints(
                                                              minHeight: 42,
                                                            ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 8,
                                                                vertical: 6,
                                                              ),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              const Icon(
                                                                Icons
                                                                    .favorite_border,
                                                                color:
                                                                    PanicVisual
                                                                        .white,
                                                                size: 20,
                                                              ),
                                                              const SizedBox(
                                                                width: 8,
                                                              ),
                                                              Flexible(
                                                                child: Text(
                                                                  'Segítség kell',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: HajnalStyle.of(context)
                                                                      .text(
                                                                        TextRole
                                                                            .button,
                                                                      )
                                                                      .copyWith(
                                                                        color: PanicVisual
                                                                            .white,
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
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
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
                            Expanded(
                              child: widget.reflection == null
                                  ? const SizedBox()
                                  : StreamBuilder<bool>(
                                      stream: reflectionEnabled,
                                      builder: (context, snapshot) =>
                                          snapshot.data != true ||
                                              widget.onReflection == null
                                          ? const SizedBox()
                                          : Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                key: const Key(
                                                  'daily-reflection-entry',
                                                ),
                                                onTap: widget.onReflection,
                                                child: Center(
                                                  child: FittedBox(
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Container(
                                                          width: 48,
                                                          height: 48,
                                                          decoration:
                                                              ReflectionVisual.dashboardIcon(
                                                                HajnalStyle.of(
                                                                  context,
                                                                ).color(
                                                                  'accent',
                                                                ),
                                                              ),
                                                          child: Icon(
                                                            Icons.favorite,
                                                            color:
                                                                HajnalStyle.of(
                                                                  context,
                                                                ).color(
                                                                  'surface',
                                                                ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 8,
                                                        ),
                                                        Text(
                                                          'Napi\nreflexió',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              HajnalStyle.of(
                                                                context,
                                                              ).text(
                                                                TextRole.helper,
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
