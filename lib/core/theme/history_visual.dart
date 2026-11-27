import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'domain/style_roles.dart';
import 'hajnal_theme.dart';

/// History's illustration-specific treatments, shared by its renderers.
abstract final class HistoryVisual {
  static const heroHeight = 320.0;
  static const infoTop = 151.0;
  static const cardRadius = 25.0;
  static const nodeSize = 32.0;
  static const eventRadius = 17.0;
  static final infoCorner = BorderRadius.circular(cardRadius);
  static final eventCorner = BorderRadius.circular(eventRadius);
  static final switchCorner = BorderRadius.circular(22);
  static final calendarCorner = BorderRadius.circular(10);
  static const white = Colors.white;
  static TextStyle caption(HajnalStyle style) =>
      style.text(TextRole.helper).copyWith(fontSize: 10);
  static TextStyle heading(HajnalStyle style) =>
      caption(style).copyWith(fontWeight: FontWeight.w800);
  static TextStyle eventTitle(HajnalStyle style) =>
      style.text(TextRole.cardTitle).copyWith(fontSize: 14);
  static TextStyle eventDetail(HajnalStyle style) =>
      style.text(TextRole.helper).copyWith(fontSize: 11);
  static TextStyle heroTitle(HajnalStyle style) =>
      style.text(TextRole.title1).copyWith(fontSize: 32, letterSpacing: -1.6);
  static TextStyle periodDays(HajnalStyle style) => style
      .text(TextRole.cardTitle)
      .copyWith(fontSize: 21, fontWeight: FontWeight.w800);
  static double _textHeight(
    BuildContext context,
    String text,
    TextStyle style,
    double width,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(maxWidth: math.max(1.0, width));
    final result = painter.height;
    painter.dispose();
    return result;
  }

  static double infoTopFor(BuildContext context) {
    final media = MediaQuery.of(context);
    final style = HajnalStyle.of(context);
    final available = math.max(
      1.0,
      media.size.width - 122 - style.spacing('touch'),
    );
    final copyHeight =
        _textHeight(context, 'Történetem', heroTitle(style), available) +
        _textHeight(
          context,
          'Fejezeteim és emlékeim',
          style.text(TextRole.helper),
          available,
        );
    return math.max(infoTop, media.padding.top + 20 + math.max(50, copyHeight));
  }

  static double cardMaxHeight(
    BuildContext context,
    double top,
    int eventCount,
  ) {
    final size = MediaQuery.sizeOf(context);
    final style = HajnalStyle.of(context);
    final width = size.width - 60;
    final heading =
        _textHeight(
          context,
          'Az utam pillanatai',
          style.text(TextRole.cardTitle),
          width,
        ) +
        _textHeight(
          context,
          '$eventCount esemény',
          style.text(TextRole.helper),
          width,
        );
    final available = size.height - top;
    return math.max(0, math.min(available * .4, available - heading - 88));
  }

  static const mutedNode = Color(0xffe6e6e6);
  static const mutedIcon = Color(0xff5f5f5f);
  static const node = Color(0xffece5fc);
  static const noteNode = Color(0xffffe6ec);
  static const noteIcon = Color(0xffe5416c);
  static const heroFade = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.black, Colors.black, Colors.transparent],
    stops: [0, .48, 1],
  );
  static const grayscale = ColorFilter.matrix([
    .2126,
    .7152,
    .0722,
    0,
    0,
    .2126,
    .7152,
    .0722,
    0,
    0,
    .2126,
    .7152,
    .0722,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ]);
}
