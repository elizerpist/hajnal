import 'package:flutter/material.dart';
import '../../../core/theme/domain/style_roles.dart';
import '../../../core/theme/hajnal_theme.dart';
import '../../../core/theme/history_visual.dart';
import '../application/history_store.dart';
import 'history_event_list.dart';
import 'history_switch.dart';

class HistoryCalendar extends StatefulWidget {
  const HistoryCalendar({
    super.key,
    required this.events,
    required this.initialDate,
    required this.active,
  });
  final List<HistoryEvent> events;
  final DateTime initialDate;
  final bool active;
  @override
  State<HistoryCalendar> createState() => _HistoryCalendarState();
}

class _HistoryCalendarState extends State<HistoryCalendar> {
  late DateTime selected = DateUtils.dateOnly(widget.initialDate);
  late DateTime month = DateTime(selected.year, selected.month);
  bool rail = false;

  @override
  Widget build(BuildContext context) {
    final style = HajnalStyle.of(context);
    final local = MaterialLocalizations.of(context);
    final firstOffset = DateUtils.firstDayOffset(
      month.year,
      month.month,
      local,
    );
    final days = DateUtils.getDaysInMonth(month.year, month.month);
    final cells = ((firstOffset + days + 6) ~/ 7) * 7;
    final selectedEvents = widget.events
        .where((e) => DateUtils.isSameDay(e.date, selected))
        .toList();
    final weekday = local.narrowWeekdays;
    final scale = MediaQuery.textScalerOf(context).scale(1);
    final eventDays =
        widget.events
            .map((event) => DateUtils.dateOnly(event.date))
            .toSet()
            .toList()
          ..sort();
    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: HistorySwitch(
            firstLabel: 'Naptár',
            secondLabel: 'Sáv',
            secondSelected: rail,
            onChanged: (value) => setState(() => rail = value),
          ),
        ),
        const SizedBox(height: 6),
        if (rail)
          SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: eventDays.length,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final date = eventDays[index];
                return ChoiceChip(
                  label: Text(historyDate(context, date)),
                  selected: DateUtils.isSameDay(date, selected),
                  onSelected: (_) => setState(() {
                    selected = date;
                    month = DateTime(date.year, date.month);
                  }),
                );
              },
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(10),
            decoration: style.card(CardRole.content),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Előző hónap',
                      onPressed: () => setState(
                        () => month = DateUtils.addMonthsToMonthDate(month, -1),
                      ),
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Expanded(
                      child: Text(
                        local.formatMonthYear(month),
                        textAlign: TextAlign.center,
                        style: style.text(TextRole.cardTitle),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Következő hónap',
                      onPressed: () => setState(
                        () => month = DateUtils.addMonthsToMonthDate(month, 1),
                      ),
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
                Row(
                  children: List.generate(
                    7,
                    (i) => Expanded(
                      child: Center(
                        child: Text(
                          weekday[(local.firstDayOfWeekIndex + i) % 7],
                          style: style.text(TextRole.helper),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 3,
                    crossAxisSpacing: 3,
                    mainAxisExtent: 48 * (scale < 1 ? 1 : scale),
                  ),
                  itemCount: cells,
                  itemBuilder: (context, index) {
                    final date = DateTime(
                      month.year,
                      month.month,
                      index - firstOffset + 1,
                    );
                    final inMonth = date.month == month.month;
                    final isSelected = DateUtils.isSameDay(date, selected);
                    final hasEvent = widget.events.any(
                      (e) => DateUtils.isSameDay(e.date, date),
                    );
                    return Semantics(
                      selected: isSelected,
                      button: true,
                      label: local.formatFullDate(date),
                      child: InkWell(
                        onTap: () => setState(() {
                          selected = date;
                          month = DateTime(date.year, date.month);
                        }),
                        borderRadius: HistoryVisual.calendarCorner,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? style.color('accent')
                                : style.color('surface'),
                            borderRadius: HistoryVisual.calendarCorner,
                            border: Border.all(color: style.color('border')),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${date.day}',
                                style: style
                                    .text(TextRole.helper)
                                    .copyWith(
                                      color: isSelected
                                          ? HistoryVisual.white
                                          : style.color(
                                              inMonth ? 'primary' : 'secondary',
                                            ),
                                    ),
                              ),
                              if (hasEvent)
                                Container(
                                  key: ValueKey(
                                    'history-dot-${date.year}-${date.month}-${date.day}',
                                  ),
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? HistoryVisual.white
                                        : style.color('accent'),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        const SizedBox(height: 18),
        Text('Aznapi események', style: style.text(TextRole.cardTitle)),
        Text(
          '${selectedEvents.length} esemény',
          style: style.text(TextRole.helper),
        ),
        const SizedBox(height: 8),
        HistoryEventList(
          events: selectedEvents,
          active: widget.active,
          scrollable: false,
        ),
      ],
    );
  }
}
