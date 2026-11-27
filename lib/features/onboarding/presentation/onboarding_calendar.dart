import 'package:flutter/material.dart';

class OnboardingCalendar extends StatelessWidget {
  const OnboardingCalendar({
    super.key,
    required this.date,
    required this.today,
    required this.onChanged,
  });
  final DateTime date;
  final DateTime today;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final last = DateUtils.dateOnly(today);
    final first = DateTime(1);
    final shown = date.isAfter(last)
        ? last
        : (date.isBefore(first) ? first : date);
    final material = MaterialLocalizations.of(context);
    void changeMonth(int year, int month) {
      final day = shown.day.clamp(1, DateUtils.getDaysInMonth(year, month));
      final selected = DateTime(year, month, day);
      onChanged(selected.isAfter(last) ? last : selected);
    }

    return Column(
      children: [
        if (date.isAfter(last))
          const Text('A kezdőnap a mai dátumnál későbbi. Válassz új napot.'),
        Theme(
          data: ThemeData.from(
            colorScheme: Theme.of(context).colorScheme,
            textTheme: Theme.of(context).textTheme,
            useMaterial3: false,
          ),
          child: CalendarDatePicker(
            key: ValueKey('${shown.year}-${shown.month}-${shown.day}'),
            initialDate: shown,
            firstDate: first,
            lastDate: last,
            currentDate: last,
            onDateChanged: onChanged,
          ),
        ),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          children: [
            TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Év kiválasztása'),
                  content: SizedBox(
                    width: 280,
                    height: 300,
                    child: YearPicker(
                      firstDate: first,
                      lastDate: last,
                      selectedDate: shown,
                      onChanged: (selected) {
                        Navigator.of(context).pop();
                        changeMonth(selected.year, shown.month);
                      },
                    ),
                  ),
                ),
              ),
              child: Text('${shown.year}'),
            ),
            SizedBox(
              width: MediaQuery.textScalerOf(context).scale(1) > 1.2
                  ? 200
                  : 176,
              child: DropdownButton<int>(
                isExpanded: true,
                value: shown.month,
                hint: const Text('Hónap'),
                items: [
                  for (var month = 1; month <= 12; month++)
                    DropdownMenuItem(
                      value: month,
                      enabled: shown.year < last.year || month <= last.month,
                      child: Text(
                        material
                            .formatMonthYear(DateTime(2000, month))
                            .replaceAll('2000. ', ''),
                      ),
                    ),
                ],
                onChanged: (month) {
                  if (month != null) changeMonth(shown.year, month);
                },
              ),
            ),
            OutlinedButton(
              onPressed: () => onChanged(last),
              child: const Text('Ma'),
            ),
          ],
        ),
      ],
    );
  }
}
