import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/core/platform/date_picker.dart';
import 'package:hajnal/features/onboarding/application/date_picker.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('hu.elizerpist.hajnal/date_picker');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('passes calendar components and prevents concurrent dialogs', () async {
    final completer = Completer<Object?>();
    var calls = 0;
    messenger.setMockMethodCallHandler(channel, (call) {
      calls++;
      expect(call.arguments, {
        'year': 2024,
        'month': 2,
        'day': 29,
        'maxYear': 2024,
        'maxMonth': 3,
        'maxDay': 1,
      });
      return completer.future;
    });
    final picker = PlatformDatePicker();
    final pending = picker.pick(DateTime(2024, 2, 29), DateTime(2024, 3, 1));
    expect(
      await picker.pick(DateTime(2024), DateTime(2024)),
      isA<DatePickCancelled>(),
    );
    expect(calls, 1);
    completer.complete({'year': 2024, 'month': 2, 'day': 29});
    expect((await pending as DatePicked).date, DateTime(2024, 2, 29));
  });
  test('distinguishes cancellation and platform error', () async {
    final picker = PlatformDatePicker();
    messenger.setMockMethodCallHandler(channel, (_) async => null);
    expect(
      await picker.pick(DateTime(2024), DateTime(2024)),
      isA<DatePickCancelled>(),
    );
    messenger.setMockMethodCallHandler(
      channel,
      (_) async => throw PlatformException(code: 'unavailable'),
    );
    expect(
      await picker.pick(DateTime(2024), DateTime(2024)),
      isA<DatePickFailed>(),
    );
  });
  test('malformed native date is a failure, not a normalized date', () async {
    messenger.setMockMethodCallHandler(
      channel,
      (_) async => {'year': 2024, 'month': 2, 'day': 31},
    );
    expect(
      await PlatformDatePicker().pick(
        DateTime(2024, 2, 1),
        DateTime(2024, 3, 1),
      ),
      isA<DatePickFailed>(),
    );
  });
}
