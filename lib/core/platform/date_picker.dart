import 'package:flutter/services.dart';
import '../../features/onboarding/application/date_picker.dart';

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
      final year = result['year'], month = result['month'], day = result['day'];
      if (year == null || month == null || day == null || year < 1) {
        return const DatePickFailed('Érvénytelen dátum');
      }
      final selected = DateTime(year, month, day);
      if (selected.year != year ||
          selected.month != month ||
          selected.day != day ||
          selected.isAfter(DateTime(today.year, today.month, today.day))) {
        return const DatePickFailed('Érvénytelen dátum');
      }
      return DatePicked(selected);
    } on PlatformException catch (e) {
      return DatePickFailed(e.message ?? e.code);
    } on MissingPluginException catch (e) {
      return DatePickFailed(e.message ?? 'A dátumválasztó nem érhető el.');
    } on TypeError {
      return const DatePickFailed('Érvénytelen dátum');
    } on ArgumentError {
      return const DatePickFailed('Érvénytelen dátum');
    } finally {
      _pending = false;
    }
  }
}
