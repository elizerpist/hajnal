import 'package:flutter/material.dart';
import '../theme/hajnal_tokens.dart';

/// Decorative fingerprint shape from the approved app-lock reference.
class HajnalFingerprint extends StatelessWidget {
  const HajnalFingerprint({super.key});

  @override
  Widget build(BuildContext context) => const ExcludeSemantics(
    child: CustomPaint(size: Size(145, 140), painter: _FingerprintPainter()),
  );
}

class _FingerprintPainter extends CustomPainter {
  const _FingerprintPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 150, size.height / 145);
    final ink = Paint()
      ..color = HajnalColors.purple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(27, 38)
      ..cubicTo(43, 14, 65, 11, 77, 14)
      ..cubicTo(108, 17, 128, 38, 133, 60)
      ..moveTo(24, 54)
      ..cubicTo(18, 63, 15, 73, 15, 82)
      ..moveTo(25, 102)
      ..cubicTo(30, 92, 29, 76, 34, 65)
      ..cubicTo(40, 45, 58, 32, 76, 32)
      ..cubicTo(104, 32, 120, 52, 120, 78)
      ..cubicTo(120, 89, 120, 100, 117, 108)
      ..moveTo(34, 109)
      ..cubicTo(38, 102, 41, 94, 42, 88)
      ..moveTo(43, 75)
      ..cubicTo(45, 57, 58, 47, 75, 47)
      ..cubicTo(96, 47, 106, 61, 106, 81)
      ..cubicTo(106, 98, 101, 116, 98, 123)
      ..moveTo(53, 122)
      ..cubicTo(64, 109, 68, 95, 68, 79)
      ..cubicTo(68, 70, 69, 64, 76, 64)
      ..cubicTo(87, 64, 91, 72, 91, 82)
      ..cubicTo(90, 104, 86, 121, 79, 132)
      ..moveTo(66, 129)
      ..cubicTo(75, 115, 78, 101, 78, 81);
    canvas.drawPath(path, ink);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FingerprintPainter oldDelegate) => false;
}
