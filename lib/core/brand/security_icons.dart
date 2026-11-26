import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import '../theme/hajnal_tokens.dart';

class HajnalBackButton extends StatelessWidget {
  const HajnalBackButton({super.key});

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: MaterialLocalizations.of(context).backButtonTooltip,
    onPressed: () => Navigator.maybePop(context),
    icon: const Icon(CupertinoIcons.chevron_back, color: HajnalColors.navy),
  );
}

/// The outlined key used for PIN management throughout the app.
class HajnalKeyIcon extends StatelessWidget {
  const HajnalKeyIcon({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 30,
    height: 30,
    child: CustomPaint(painter: _KeyPainter()),
  );
}

class HajnalLockIcon extends StatelessWidget {
  const HajnalLockIcon({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 54,
    height: 54,
    child: CustomPaint(painter: _LockPainter()),
  );
}

class _LockPainter extends CustomPainter {
  const _LockPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 54, size.height / 54);
    final stroke = Paint()
      ..color = HajnalColors.navy
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(6, 23, 42, 30),
        const Radius.circular(4),
      ),
      stroke,
    );
    canvas.drawPath(
      Path()
        ..moveTo(14, 23)
        ..lineTo(14, 15)
        ..cubicTo(14, -2, 40, -2, 40, 15)
        ..lineTo(40, 23),
      stroke,
    );
    canvas.drawCircle(
      const Offset(27, 35),
      3,
      Paint()..color = HajnalColors.navy,
    );
    canvas.drawLine(const Offset(27, 37), const Offset(27, 43), stroke);
  }

  @override
  bool shouldRepaint(_LockPainter oldDelegate) => false;
}

class _KeyPainter extends CustomPainter {
  const _KeyPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 30, size.height / 30);
    final stroke = Paint()
      ..color = HajnalColors.purple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(15, 16)
        ..lineTo(5, 26)
        ..lineTo(2, 26)
        ..lineTo(2, 22)
        ..lineTo(5, 19)
        ..lineTo(7, 20)
        ..lineTo(9, 18)
        ..lineTo(8, 16)
        ..lineTo(12, 12)
        ..cubicTo(11, 7, 15, 3, 20, 3)
        ..cubicTo(25, 3, 28, 6, 28, 11)
        ..cubicTo(28, 16, 23, 19, 18, 18)
        ..close(),
      stroke,
    );
    canvas.drawCircle(const Offset(21, 10), 1.2, stroke);
  }

  @override
  bool shouldRepaint(_KeyPainter oldDelegate) => false;
}
