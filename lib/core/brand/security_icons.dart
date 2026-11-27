import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import '../theme/hajnal_theme.dart';
import '../theme/hajnal_components.dart';

class HajnalBackButton extends StatelessWidget {
  const HajnalBackButton({super.key});

  @override
  Widget build(BuildContext context) => HajnalNavigationIcon(
    label: MaterialLocalizations.of(context).backButtonTooltip,
    onPressed: () => Navigator.maybePop(context),
    icon: CupertinoIcons.chevron_back,
  );
}

/// The outlined key used for PIN management throughout the app.
class HajnalKeyIcon extends StatelessWidget {
  const HajnalKeyIcon({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 30,
    height: 30,
    child: CustomPaint(
      painter: _KeyPainter(HajnalStyle.of(context).color('accent')),
    ),
  );
}

class HajnalLockIcon extends StatelessWidget {
  const HajnalLockIcon({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 54,
    height: 54,
    child: CustomPaint(
      painter: _LockPainter(HajnalStyle.of(context).color('primary')),
    ),
  );
}

class _LockPainter extends CustomPainter {
  const _LockPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 54, size.height / 54);
    final stroke = Paint()
      ..color = color
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
    canvas.drawCircle(const Offset(27, 35), 3, Paint()..color = color);
    canvas.drawLine(const Offset(27, 37), const Offset(27, 43), stroke);
  }

  @override
  bool shouldRepaint(_LockPainter oldDelegate) => oldDelegate.color != color;
}

class _KeyPainter extends CustomPainter {
  const _KeyPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 30, size.height / 30);
    final stroke = Paint()
      ..color = color
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
  bool shouldRepaint(_KeyPainter oldDelegate) => oldDelegate.color != color;
}
