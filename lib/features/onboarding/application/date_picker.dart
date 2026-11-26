sealed class DatePickerResult {
  const DatePickerResult();
}

class DatePicked extends DatePickerResult {
  const DatePicked(this.date);
  final DateTime date;
}

class DatePickCancelled extends DatePickerResult {
  const DatePickCancelled();
}

class DatePickFailed extends DatePickerResult {
  const DatePickFailed(this.message);
  final String message;
}

abstract interface class DatePicker {
  Future<DatePickerResult> pick(DateTime initial, DateTime today);
}
