import 'package:flutter/material.dart';
import 'domain/style_roles.dart';
import 'hajnal_theme.dart';

/// Mood identities correspond to the five faces in the reflection reference.
abstract final class ReflectionVisual {
  static const progressRadius = BorderRadius.all(Radius.circular(8));
  static const artworkFade = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Colors.white,
      Colors.white,
      Colors.transparent,
    ],
    stops: [0, .17, .78, 1],
  );
  static LinearGradient accentGradient(Color accent) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, Color.lerp(accent, Colors.white, .4)!],
  );
  static BoxDecoration primaryButton(HajnalStyle style) => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        style.color('accent'),
        Color.lerp(style.color('accent'), Colors.black, .15)!,
      ],
    ),
    borderRadius: BorderRadius.circular(
      style.definitions.buttons[ButtonRole.primary]!.radius,
    ),
  );
  static BoxDecoration dashboardIcon(Color accent) => BoxDecoration(
    shape: BoxShape.circle,
    gradient: accentGradient(accent),
    boxShadow: [
      BoxShadow(
        color: accent.withValues(alpha: .23),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  );
  static const moodColors = [
    Color(0xFFB18AAD),
    Color(0xFFC98E9C),
    Color(0xFFD3A15B),
    Color(0xFF7BA7C4),
    Color(0xFF7FB69A),
  ];
}
