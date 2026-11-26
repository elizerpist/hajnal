import 'package:flutter/services.dart';

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

class PlatformDatePicker implements DatePicker {
  static const _channel = MethodChannel('hu.elizerpist.hajnal/date_picker');
  bool _pending = false;
  @override
  Future<DatePickerResult> pick(DateTime initial, DateTime today) async {
    if (_pending) return const DatePickCancelled();
    _pending = true;
    try {
      final result = await _channel.invokeMapMethod<String, int>('pick', {
        'year': initial.year,
        'month': initial.month,
        'day': initial.day,
        'maxYear': today.year,
        'maxMonth': today.month,
        'maxDay': today.day,
      });
      if (result == null) return const DatePickCancelled();
      return DatePicked(
        DateTime(result['year']!, result['month']!, result['day']!),
      );
    } on PlatformException catch (e) {
      return DatePickFailed(e.message ?? e.code);
    } on MissingPluginException catch (e) {
      return DatePickFailed(e.message ?? 'A dátumválasztó nem érhető el.');
    } finally {
      _pending = false;
    }
  }
}
