import 'dart:math' as math;

/// Computes the shared card and sheet geometry in the available safe viewport.
class DashboardLayout {
  const DashboardLayout._({
    required this.cardWidth,
    required this.cardHeight,
    required this.closedTop,
    required this.travel,
  });

  final double cardWidth;
  final double cardHeight;
  final double closedTop;
  final double travel;

  static DashboardLayout resolve({
    required double width,
    required double height,
    required double topInset,
    required double bottomInset,
    required double textScale,
  }) {
    final safeTop = topInset.clamp(0.0, height);
    final safeBottom = (height - bottomInset).clamp(safeTop, height);
    final availableHeight = safeBottom - safeTop;
    final reservedTravel = math.min(48.0, availableHeight * .2);
    final cardHeight = math.min(
      math.max(118.0, 118 + (textScale - 1) * 160),
      availableHeight - reservedTravel,
    );
    final closedTop = math
        .max(safeTop + 64, height - bottomInset - 278)
        .clamp(safeTop, safeBottom - cardHeight);
    return DashboardLayout._(
      cardWidth: math.max(0, math.min(296, width - 32)),
      cardHeight: cardHeight,
      closedTop: closedTop,
      travel: math.min(math.min(96, height * .15), closedTop - safeTop),
    );
  }
}
