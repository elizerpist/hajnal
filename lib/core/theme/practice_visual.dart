import 'package:flutter/material.dart';
import 'hajnal_theme.dart';
import 'domain/style_roles.dart';

/// Practice surfaces resolve shared color roles through the active Hajnal theme.
abstract final class PracticeVisual {
  static final popupShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(32),
  );
  static final activeRadius = BorderRadius.circular(22);
  static final rowRadius = BorderRadius.circular(20);
  static final promptRadius = BorderRadius.circular(12);
  static final fieldRadius = BorderRadius.circular(16);
  static TextStyle footer(BuildContext context) => HajnalStyle.of(context)
      .text(TextRole.helper)
      .copyWith(fontStyle: FontStyle.italic, color: muted(context));
  static ButtonStyle addButton(BuildContext context) => FilledButton.styleFrom(
    backgroundColor: lavender(context),
    foregroundColor: accent(context),
    minimumSize: const Size(48, 50),
    shape: const StadiumBorder(),
  );
  static ButtonStyle iconButton(BuildContext context) => IconButton.styleFrom(
    backgroundColor: lavender(context),
    foregroundColor: accent(context),
  );
  static Color artworkSurface(BuildContext context, int id) {
    const tones = [
      Color(0xfffde3ed),
      Color(0xffdbeffa),
      Color(0xffdbf3e2),
      Color(0xffffeed4),
      Color(0xffe8e2ff),
    ];
    return Color.lerp(background(context), tones[id % tones.length], .75)!;
  }

  static Color background(BuildContext context) =>
      HajnalStyle.of(context).color('surface');
  static Color lavender(BuildContext context) =>
      HajnalStyle.of(context).color('selected');
  static Color field(BuildContext context) =>
      HajnalStyle.of(context).color('selected');
  static Color ink(BuildContext context) =>
      HajnalStyle.of(context).color('primary');
  static Color muted(BuildContext context) =>
      HajnalStyle.of(context).color('secondary');
  static Color accent(BuildContext context) =>
      HajnalStyle.of(context).color('accent');
  static Color border(BuildContext context) =>
      HajnalStyle.of(context).color('border');
  static TextStyle label(BuildContext context) => HajnalStyle.of(context)
      .text(TextRole.helper)
      .copyWith(
        color: accent(context),
        fontSize: 10,
        fontWeight: FontWeight.w800,
      );
  static Color alert(BuildContext context) =>
      Theme.of(context).colorScheme.error;
}
