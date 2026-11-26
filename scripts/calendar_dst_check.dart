import 'package:hajnal/features/recovery/domain/calendar.dart';

void main() {
  final springStart = DateTime(2024, 3, 31);
  final springEnd = DateTime(2024, 4, 1);
  final autumnStart = DateTime(2024, 10, 27);
  final autumnEnd = DateTime(2024, 10, 28);
  if (springEnd.difference(springStart).inHours != 23 ||
      autumnEnd.difference(autumnStart).inHours != 25 ||
      cleanDays(springStart, springEnd) != 1 ||
      cleanDays(autumnStart, autumnEnd) != 1) {
    throw StateError('Budapest DST calendar calculation failed');
  }
}
