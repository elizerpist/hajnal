import 'package:flutter/material.dart';
import 'domain/style_definitions.dart';

class HajnalStyle extends ThemeExtension<HajnalStyle> {
  const HajnalStyle(this.definitions);
  final StyleDefinitions definitions;
  static HajnalStyle of(BuildContext context) =>
      Theme.of(context).extension<HajnalStyle>() ??
      HajnalStyle(StyleDefinitions.defaults());

  Color color(String ref) => Color(
    ref.startsWith('#')
        ? int.parse(ref.substring(1), radix: 16)
        : definitions.palette[ref]!,
  );
  TextStyle text(TextRole role) {
    final t = definitions.texts[role]!;
    return TextStyle(
      fontFamily: t.family,
      fontSize: t.size,
      fontWeight: FontWeight.values[t.weight ~/ 100 - 1],
      fontVariations: t.family == 'Roboto'
          ? [FontVariation('wght', t.weight.toDouble())]
          : null,
      fontStyle: t.italic ? FontStyle.italic : FontStyle.normal,
      color: color(t.color),
      height: t.lineHeight,
      letterSpacing: t.letterSpacing,
      decoration: t.underline ? TextDecoration.underline : TextDecoration.none,
      backgroundColor: color(t.highlight),
    );
  }

  BoxDecoration card(CardRole role, {bool selected = false}) {
    final c = definitions.cards[role]!;
    return BoxDecoration(
      color: color(selected ? 'selected' : c.fill),
      borderRadius: BorderRadius.circular(c.radius),
      border: Border.all(
        color: color(selected ? 'accent' : c.border),
        width: c.borderWidth,
      ),
      boxShadow: [
        BoxShadow(
          color: color(
            c.shadow,
          ).withValues(alpha: color(c.shadow).a * c.shadowOpacity),
          blurRadius: c.blur,
          offset: Offset(c.offsetX, c.offsetY),
        ),
      ],
    );
  }

  BoxDecoration calendarMarker({required bool selected, required bool today}) =>
      BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? color('accent') : null,
        border: today && !selected
            ? Border.all(color: color('accent'), width: spacing('dayOutline'))
            : null,
      );

  BoxDecoration indicator({required bool selected}) => BoxDecoration(
    color: color(selected ? 'accent' : 'border'),
    borderRadius: BorderRadius.circular(
      definitions.cards[CardRole.small]!.radius,
    ),
  );

  ButtonStyle button(ButtonRole role) {
    final b = definitions.buttons[role]!;
    return ButtonStyle(
      minimumSize: WidgetStatePropertyAll(
        Size(
          spacing('touch'),
          b.minHeight < spacing('touch') ? spacing('touch') : b.minHeight,
        ),
      ),
      backgroundColor: WidgetStateProperty.resolveWith(
        (states) => color(b.fill).withValues(
          alpha:
              color(b.fill).a *
              (states.contains(WidgetState.disabled) ? .45 : 1),
        ),
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => color(b.foreground).withValues(
          alpha:
              color(b.foreground).a *
              (states.contains(WidgetState.disabled) ? .55 : 1),
        ),
      ),
      side: WidgetStatePropertyAll(
        BorderSide(color: color(b.border), width: b.borderWidth),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(b.radius)),
      ),
      textStyle: WidgetStatePropertyAll(text(TextRole.button)),
    );
  }

  double spacing(String role) => definitions.spacing[role]!;
  @override
  HajnalStyle copyWith({StyleDefinitions? definitions}) =>
      HajnalStyle(definitions ?? this.definitions);
  @override
  HajnalStyle lerp(covariant HajnalStyle? other, double t) =>
      t < .5 ? this : (other ?? this);
}

ThemeData hajnalTheme([StyleDefinitions? definitions]) {
  final style = HajnalStyle(definitions ?? StyleDefinitions.defaults());
  final base = ThemeData.light();
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: style.color('accent'),
      surface: style.color('surface'),
    ),
    scaffoldBackgroundColor: style.color('background'),
    textTheme: base.textTheme.copyWith(
      displayLarge: style.text(TextRole.title1),
      headlineMedium: style.text(TextRole.title1),
      titleLarge: style.text(TextRole.title1),
      titleMedium: style.text(TextRole.cardTitle),
      titleSmall: style.text(TextRole.cardSubtitle),
      bodyLarge: style.text(TextRole.body),
      bodyMedium: style.text(TextRole.body),
      bodySmall: style.text(TextRole.helper),
      labelLarge: style.text(TextRole.button),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: style.button(ButtonRole.primary),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: style.button(ButtonRole.secondary),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        minimumSize: WidgetStatePropertyAll(
          Size(style.spacing('touch'), style.spacing('touch')),
        ),
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        minimumSize: WidgetStatePropertyAll(
          Size.square(style.spacing('touch')),
        ),
      ),
    ),
    extensions: [style],
  );
}
