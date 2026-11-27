import 'package:flutter/material.dart';
import '../../../core/artwork/artwork_catalog.dart';
import '../../../core/theme/domain/style_roles.dart';
import '../../../core/theme/hajnal_components.dart';
import '../../../core/theme/hajnal_theme.dart';
import '../../../core/theme/history_visual.dart';
import '../application/history_controller.dart';
import '../application/history_store.dart';
import 'history_calendar.dart';
import 'history_event_list.dart';
import 'history_switch.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key, required this.controller});
  final HistoryController controller;
  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  PageController? _pages;
  bool _calendar = false;

  @override
  void dispose() {
    _pages?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) {
      final c = widget.controller;
      if (c.loading) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (c.error != null) {
        return Scaffold(
          appBar: AppBar(),
          body: const Center(child: Text('Az idővonal nem tölthető be.')),
        );
      }
      if (c.periods.isEmpty) {
        return Scaffold(
          appBar: AppBar(),
          body: const Center(child: Text('Még nincs időszak.')),
        );
      }
      final index = c.periods
          .indexWhere((p) => p.id == c.selectedId)
          .clamp(0, c.periods.length - 1);
      _pages ??= PageController(initialPage: index);
      if (_pages!.hasClients &&
          _pages!.page?.round() != index &&
          !(_pages!.position.isScrollingNotifier.value)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted &&
              _pages!.hasClients &&
              !_pages!.position.isScrollingNotifier.value) {
            _pages!.jumpToPage(index);
          }
        });
      }
      return Scaffold(
        backgroundColor: HajnalStyle.of(context).color('background'),
        body: Stack(
          children: [
            PageView.builder(
              key: const Key('history-pager'),
              controller: _pages,
              itemCount: c.periods.length,
              onPageChanged: (index) => c.select(c.periods[index].id),
              itemBuilder: (context, index) {
                final period = c.periods[index];
                return _HistoryChapter(
                  key: ValueKey(period.id),
                  controller: c,
                  period: period,
                  calendar: _calendar,
                );
              },
            ),
            Positioned(
              top: MediaQuery.paddingOf(context).top + 8,
              left: 8,
              right: 20,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HajnalNavigationIcon(
                    icon: Icons.arrow_back,
                    label: 'Vissza',
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Történetem',
                          style: HistoryVisual.heroTitle(
                            HajnalStyle.of(context),
                          ),
                        ),
                        Text(
                          'Fejezeteim és emlékeim',
                          style: HajnalStyle.of(context).text(TextRole.helper),
                        ),
                      ],
                    ),
                  ),
                  HistorySwitch(
                    firstLabel: 'Idővonal',
                    secondLabel: 'Naptár',
                    firstIcon: Icons.menu,
                    secondIcon: Icons.calendar_today_outlined,
                    secondSelected: _calendar,
                    onChanged: (value) => setState(() => _calendar = value),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _HistoryChapter extends StatefulWidget {
  const _HistoryChapter({
    super.key,
    required this.controller,
    required this.period,
    required this.calendar,
  });
  final HistoryController controller;
  final HistoryPeriod period;
  final bool calendar;
  @override
  State<_HistoryChapter> createState() => _HistoryChapterState();
}

class _HistoryChapterState extends State<_HistoryChapter> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final style = HajnalStyle.of(context);
    final p = widget.period;
    final events = widget.controller.events(p);
    final infoTop = HistoryVisual.infoTopFor(context);
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: HistoryVisual.heroHeight,
          child: ShaderMask(
            shaderCallback: (bounds) =>
                HistoryVisual.heroFade.createShader(bounds),
            blendMode: BlendMode.dstIn,
            child: Opacity(
              opacity: p.active ? 1 : .68,
              child: ColorFiltered(
                colorFilter: p.active
                    ? const ColorFilter.mode(Colors.transparent, BlendMode.dst)
                    : HistoryVisual.grayscale,
                child: Image.asset(
                  historyArtwork,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(18, infoTop, 18, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: HistoryVisual.cardMaxHeight(
                    context,
                    infoTop,
                    events.length,
                  ),
                ),
                child: SingleChildScrollView(
                  child: AnimatedSize(
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : const Duration(milliseconds: 280),
                    alignment: Alignment.topCenter,
                    child: Container(
                      key: const Key('history-period-card'),
                      constraints: const BoxConstraints(minHeight: 102),
                      decoration: style
                          .card(CardRole.content)
                          .copyWith(borderRadius: HistoryVisual.infoCorner),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () => setState(() => _expanded = !_expanded),
                            borderRadius: HistoryVisual.infoCorner,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                18,
                                14,
                                16,
                                12,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.active
                                              ? 'JELENLEGI IDŐSZAK'
                                              : 'LEZÁRT IDŐSZAK',
                                          style: HistoryVisual.heading(style),
                                        ),
                                        Text(
                                          '${widget.controller.days(p)} nap tiszta',
                                          style: HistoryVisual.periodDays(
                                            style,
                                          ),
                                        ),
                                        Text(
                                          '${historyDate(context, p.start)} – ${p.active ? 'jelenleg' : historyDate(context, p.closedAt!.toLocal())}',
                                          style: style.text(TextRole.helper),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircleAvatar(
                                        radius: 27,
                                        backgroundColor: style.color(
                                          'selected',
                                        ),
                                        child: Icon(
                                          Icons.eco_outlined,
                                          color: style.color('accent'),
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: 64,
                                            child: Text(
                                              'Számokban',
                                              textAlign: TextAlign.center,
                                              style: HistoryVisual.caption(
                                                style,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            _expanded
                                                ? Icons.keyboard_arrow_up
                                                : Icons.keyboard_arrow_down,
                                            size: 12,
                                            color: style.color('secondary'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (_expanded)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Divider(),
                                  Text(
                                    'Idővonalam számokban',
                                    style: style.text(TextRole.helper),
                                  ),
                                  Text(
                                    '${p.notes.length} pánikjegyzet',
                                    key: const Key('history-note-count'),
                                    style: style.text(TextRole.cardTitle),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Az utam pillanatai',
                          style: style.text(TextRole.cardTitle),
                        ),
                        Text(
                          '${events.length} esemény',
                          style: style.text(TextRole.helper),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.bar_chart, color: style.color('secondary')),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: widget.calendar
                    ? HistoryCalendar(
                        key: ValueKey('calendar-${p.id}'),
                        events: events,
                        initialDate: p.active
                            ? widget.controller.now()
                            : p.start,
                        active: p.active,
                      )
                    : HistoryEventList(events: events, active: p.active),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
