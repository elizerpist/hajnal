import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/features/dashboard/application/day_tracker.dart';

void main() {
  test('updates at local midnight and stops while backgrounded', () {
    fakeAsync((async) {
      final origin = DateTime(2024, 3, 30, 23, 59, 50);
      final tracker = DayTracker(() => origin.add(async.elapsed));
      tracker.setStart(DateTime(2024, 3, 30));
      tracker.resume();
      expect(tracker.days, 0);
      async.elapse(const Duration(seconds: 10));
      expect(tracker.days, 1);
      tracker.pause();
      async.elapse(const Duration(days: 2));
      expect(tracker.days, 1);
      tracker.resume();
      expect(tracker.days, 3);
      tracker.dispose();
      expect(async.pendingTimers, isEmpty);
    });
  });
  test(
    'notifies only when displayed value changes and handles clock rollback',
    () {
      fakeAsync((async) {
        var now = DateTime(2024, 4, 3, 12);
        final tracker = DayTracker(() => now);
        var notifications = 0;
        tracker.setStart(DateTime(2024, 4, 2));
        tracker.addListener(() => notifications++);
        tracker.resume();
        async.elapse(const Duration(seconds: 30));
        expect(notifications, 0);
        now = DateTime(2024, 4, 1, 12);
        async.elapse(const Duration(seconds: 30));
        expect(tracker.days, 0);
        expect(notifications, 1);
        tracker.dispose();
      });
    },
  );
  test(
    'local date change after timezone change recalculates without altering start',
    () {
      fakeAsync((async) {
        var localTime = DateTime(2024, 1, 2, 0, 5);
        final tracker = DayTracker(() => localTime);
        final start = DateTime(2024, 1, 1);
        tracker.setStart(start);
        tracker.resume();
        expect(tracker.days, 1);
        localTime = DateTime(2024, 1, 1, 23, 5);
        async.elapse(const Duration(seconds: 30));
        expect(tracker.days, 0);
        expect(start, DateTime(2024, 1, 1));
        tracker.dispose();
      });
    },
  );
}
