/// Counts local calendar dates, independent of the duration of local days.
int cleanDays(DateTime start, DateTime today) {
  final startDay = DateTime.utc(start.year, start.month, start.day);
  final todayDay = DateTime.utc(today.year, today.month, today.day);
  final days = todayDay.difference(startDay).inDays;
  return days < 0 ? 0 : days;
}

String validatedStartDate(DateTime start, DateTime now) {
  final date = DateTime.utc(start.year, start.month, start.day);
  if (date.isAfter(DateTime.utc(now.year, now.month, now.day))) {
    throw ArgumentError('Future start date');
  }
  return '${start.year.toString().padLeft(4, '0')}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';
}
