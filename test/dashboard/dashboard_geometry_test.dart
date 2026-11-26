import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/features/dashboard/presentation/dashboard_layout.dart';

void main() {
  test('reference geometry matches the 412 × 892 design', () {
    final layout = DashboardLayout.resolve(
      width: 412,
      height: 892,
      topInset: 0,
      bottomInset: 0,
      textScale: 1,
    );
    expect(layout.cardWidth, 296);
    expect(layout.cardHeight, 118);
    expect(layout.closedTop, 614);
    expect(layout.travel, 96);
    expect(layout.cardLeft, 58);
    expect(layout.cardTop(0), 614);
    expect(layout.cardTop(1), 518);
    expect(layout.sheetTop(0), 682);
    expect(layout.sheetTop(1), 586);
  });

  test('card stays in safe viewport at large scale and with system insets', () {
    for (final size in [(220.0, 320.0), (360.0, 800.0), (412.0, 892.0)]) {
      for (final scale in [1.0, 1.5, 3.0]) {
        final layout = DashboardLayout.resolve(
          width: size.$1,
          height: size.$2,
          topInset: 24,
          bottomInset: 48,
          textScale: scale,
        );
        expect(layout.cardWidth, lessThanOrEqualTo(size.$1));
        expect(layout.travel, greaterThan(0));
        expect(layout.closedTop - layout.travel, greaterThanOrEqualTo(24));
        expect(
          layout.closedTop + layout.cardHeight,
          lessThanOrEqualTo(size.$2 - 48),
        );
      }
    }
  });
}
