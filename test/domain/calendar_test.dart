import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/features/recovery/domain/calendar.dart';

void main() {
  test('counts calendar days without elapsed-hour DST errors', () {
    expect(cleanDays(DateTime(2024, 3, 30), DateTime(2024, 4, 1)), 2);
    expect(cleanDays(DateTime(2024, 10, 26), DateTime(2024, 10, 28)), 2);
    expect(cleanDays(DateTime(2024, 2, 28), DateTime(2024, 3, 1)), 2);
    expect(cleanDays(DateTime(2025, 1, 1), DateTime(2024, 12, 31)), 0);
    expect(cleanDays(DateTime(2024, 1, 1), DateTime(2024, 1, 1)), 0);
    expect(cleanDays(DateTime(2020, 2, 29), DateTime(2024, 3, 1)), 1462);
  });
}
