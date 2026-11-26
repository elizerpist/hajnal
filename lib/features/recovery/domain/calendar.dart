/// Counts local calendar dates, independent of the duration of local days.
int cleanDays(DateTime start, DateTime today) {
  final startDay = DateTime.utc(start.year, start.month, start.day);
  final todayDay = DateTime.utc(today.year, today.month, today.day);
  final days = todayDay.difference(startDay).inDays;
  return days < 0 ? 0 : days;
}
