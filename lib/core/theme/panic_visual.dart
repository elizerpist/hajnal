import 'package:flutter/material.dart';

abstract final class PanicVisual {
  static const pink = Color(0xfff15d9a);
  static const background = Color(0xff171848);
  static const white = Colors.white;
  static final corner = BorderRadius.circular(18);
  static const helpGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xffff78a8), Color(0xffe04d86)],
  );
}

abstract final class DashboardVisual {
  static final card = BorderRadius.circular(24);
  static const sheet = BorderRadius.vertical(top: Radius.elliptical(92, 70));
}
