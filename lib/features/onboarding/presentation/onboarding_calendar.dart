import 'package:flutter/material.dart';
import '../../../core/theme/domain/style_roles.dart';
import '../../../core/theme/hajnal_components.dart';
import '../../../core/theme/hajnal_theme.dart';

enum _Panel { days, years, months }

class OnboardingCalendar extends StatefulWidget {
  const OnboardingCalendar({
    super.key,
    required this.date,
    required this.today,
    required this.onChanged,
  });
  final DateTime date, today;
  final ValueChanged<DateTime> onChanged;
  @override
  State<OnboardingCalendar> createState() => _OnboardingCalendarState();
}

class _OnboardingCalendarState extends State<OnboardingCalendar> {
  late DateTime displayedMonth;
  late final ScrollController _years;
  _Panel panel = _Panel.days;
  DateTime get today => DateUtils.dateOnly(widget.today);
  DateTime get lastMonth => DateTime(today.year, today.month);
  int get _panelColumns =>
      MediaQuery.textScalerOf(context).scale(1) > 1.3 ? 2 : 3;
  double get _panelTileHeight {
    final style = HajnalStyle.of(context);
    final text = style.definitions.texts[TextRole.button]!;
    final needed =
        MediaQuery.textScalerOf(context).scale(text.size) *
            text.lineHeight *
            (_panelColumns == 2 ? 2 : 1) +
        style.spacing('titleGap') * 2;
    return needed < style.spacing('touch') ? style.spacing('touch') : needed;
  }

  double _dayTouch(BuildContext context) {
    final style = HajnalStyle.of(context);
    final text = style.definitions.texts[TextRole.body]!;
    final needed =
        MediaQuery.textScalerOf(context).scale(text.size) * text.lineHeight +
        style.spacing('dayOutline') * 4 +
        4;
    return needed < style.spacing('touch') ? style.spacing('touch') : needed;
  }

  @override
  void initState() {
    super.initState();
    final shown = widget.date.isAfter(today) ? today : widget.date;
    displayedMonth = DateTime(shown.year, shown.month);
    _years = ScrollController();
  }

  @override
  void dispose() {
    _years.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant OnboardingCalendar old) {
    super.didUpdateWidget(old);
    if (displayedMonth.isAfter(lastMonth)) displayedMonth = lastMonth;
  }

  void _showMonth(DateTime month) {
    if (month.year < 1 || month.isAfter(lastMonth)) return;
    setState(() => displayedMonth = month);
  }

  void _today() {
    setState(() {
      displayedMonth = lastMonth;
      panel = _Panel.days;
    });
    widget.onChanged(today);
  }

  void _panel(_Panel next) {
    setState(() => panel = panel == next ? _Panel.days : next);
    if (panel == _Panel.years) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_years.hasClients) return;
        final offset =
            ((displayedMonth.year - 1) ~/ _panelColumns - 2) * _panelTileHeight;
        _years.jumpTo(offset.clamp(0, _years.position.maxScrollExtent));
      });
    }
  }

  String _monthName(MaterialLocalizations l, int month) =>
      l.formatMonthYear(DateTime(2000, month)).replaceAll('2000. ', '');
  @override
  Widget build(BuildContext context) {
    final s = HajnalStyle.of(context), l = MaterialLocalizations.of(context);
    return Column(
      children: [
        if (DateUtils.dateOnly(widget.date).isAfter(today))
          const Text('A kezdőnap a mai dátumnál későbbi. Válassz új napot.'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              tooltip: 'Előző hónap',
              onPressed: displayedMonth.year == 1 && displayedMonth.month == 1
                  ? null
                  : () => _showMonth(
                      DateUtils.addMonthsToMonthDate(displayedMonth, -1),
                    ),
              icon: const Icon(Icons.chevron_left),
            ),
            Flexible(
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  TextButton(
                    key: const Key('calendar-year'),
                    onPressed: () => _panel(_Panel.years),
                    child: Text(
                      '${displayedMonth.year}.',
                      style: s.text(TextRole.cardTitle),
                    ),
                  ),
                  TextButton(
                    key: const Key('calendar-month'),
                    onPressed: () => _panel(_Panel.months),
                    child: Text(
                      _monthName(l, displayedMonth.month),
                      style: s.text(TextRole.cardTitle),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Következő hónap',
              onPressed: displayedMonth == lastMonth
                  ? null
                  : () => _showMonth(
                      DateUtils.addMonthsToMonthDate(displayedMonth, 1),
                    ),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.topCenter,
          child: panel == _Panel.days
              ? _days(context)
              : _selectionPanel(context, l),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: 96,
            child: HajnalAction(
              label: 'Ma',
              role: ButtonRole.compact,
              onPressed: _today,
            ),
          ),
        ),
      ],
    );
  }

  Widget _selectionPanel(BuildContext context, MaterialLocalizations l) {
    final years = panel == _Panel.years;
    return SizedBox(
      key: const Key('calendar-selection-panel'),
      height: 208,
      child: GridView.builder(
        key: ValueKey(panel),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _panelColumns,
          mainAxisExtent: _panelTileHeight,
        ),
        controller: years ? _years : null,
        itemCount: years ? today.year : 12,
        itemBuilder: (context, index) {
          final value = index + 1;
          final enabled =
              years || displayedMonth.year < today.year || value <= today.month;
          return TextButton(
            onPressed: !enabled
                ? null
                : () {
                    final year = years ? value : displayedMonth.year,
                        month = years ? displayedMonth.month : value;
                    final next = DateTime(year, month);
                    setState(() {
                      displayedMonth = next.isAfter(lastMonth)
                          ? lastMonth
                          : next;
                      panel = _Panel.days;
                    });
                  },
            child: Text(
              years ? '$value.' : _monthName(l, value),
              textAlign: TextAlign.center,
            ),
          );
        },
      ),
    );
  }

  Widget _days(BuildContext context) {
    final l = MaterialLocalizations.of(context);
    final offset = DateUtils.firstDayOffset(
      displayedMonth.year,
      displayedMonth.month,
      l,
    );
    final count = DateUtils.getDaysInMonth(
      displayedMonth.year,
      displayedMonth.month,
    );
    final rows = (offset + count + 6) ~/ 7;
    final touch = _dayTouch(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth < touch * 7
            ? touch * 7
            : constraints.maxWidth;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: width,
            child: Column(
              key: const Key('calendar-days'),
              children: [
                Row(
                  children: [
                    for (var i = 0; i < 7; i++)
                      Expanded(
                        child: Center(
                          child: Text(
                            l.narrowWeekdays[(i + l.firstDayOfWeekIndex) % 7],
                          ),
                        ),
                      ),
                  ],
                ),
                for (var row = 0; row < rows; row++)
                  Row(
                    children: [
                      for (var col = 0; col < 7; col++)
                        Expanded(
                          child: _dayCell(
                            context,
                            row * 7 + col - offset + 1,
                            count,
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _dayCell(BuildContext context, int day, int count) {
    final style = HajnalStyle.of(context);
    final touch = _dayTouch(context);
    if (day < 1 || day > count) return SizedBox(height: touch);
    final date = DateTime(displayedMonth.year, displayedMonth.month, day);
    final selected = DateUtils.isSameDay(date, widget.date);
    final isToday = DateUtils.isSameDay(date, today);
    final enabled = !date.isAfter(today);
    final text = style.definitions.texts[TextRole.body]!;
    final textSize =
        MediaQuery.textScalerOf(context).scale(text.size) * text.lineHeight;
    final minimum = textSize + style.spacing('dayOutline') * 2;
    final diameter =
        (style.spacing('dayDiameter') < minimum
                ? minimum
                : style.spacing('dayDiameter'))
            .clamp(0.0, touch - style.spacing('dayOutline') * 2);
    return SizedBox(
      height: touch,
      child: Semantics(
        button: true,
        selected: selected,
        enabled: enabled,
        label: MaterialLocalizations.of(context).formatFullDate(date),
        child: InkWell(
          key: Key('calendar-day-${date.year}-${date.month}-${date.day}'),
          onTap: enabled ? () => widget.onChanged(date) : null,
          customBorder: const CircleBorder(),
          child: Center(
            child: Container(
              width: diameter,
              height: diameter,
              alignment: Alignment.center,
              decoration: style.calendarMarker(
                selected: selected,
                today: isToday,
              ),
              child: Text(
                '$day',
                style: style
                    .text(TextRole.body)
                    .copyWith(
                      color: selected
                          ? style.color('onAccent')
                          : style.color(enabled ? 'primary' : 'secondary'),
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
