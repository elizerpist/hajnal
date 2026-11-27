import 'dart:convert';

import 'style_roles.dart';
export 'style_roles.dart';

double _number(Object? value, double min, double max) {
  if (value is! num || !value.isFinite || value < min || value > max) {
    throw const FormatException('Invalid style number');
  }
  return value.toDouble();
}

int _integer(Object? value, int min, int max) {
  if (value is! int || value < min || value > max) {
    throw const FormatException('Invalid style integer');
  }
  return value;
}

String _color(Object? value) {
  if (value is! String ||
      !(RegExp(r'^#[0-9a-fA-F]{8}$').hasMatch(value) ||
          const {
            'primary',
            'secondary',
            'accent',
            'surface',
            'background',
            'selected',
            'border',
            'shadow',
            'onAccent',
            'artworkIcon',
            'brandAccent',
          }.contains(value))) {
    throw const FormatException('Invalid color reference');
  }
  return value;
}

class TextDefinition {
  const TextDefinition({
    required this.family,
    required this.size,
    required this.weight,
    required this.italic,
    required this.color,
    required this.lineHeight,
    required this.letterSpacing,
    this.align = 'left',
    this.underline = false,
    this.indent = 0,
    this.highlight = '#00000000',
  });
  final String family;
  final double size;
  final int weight;
  final bool italic;
  final String color;
  final double lineHeight;
  final double letterSpacing;
  final String align;
  final bool underline;
  final double indent;
  final String highlight;

  Map<String, Object> toJson() => {
    'family': family,
    'size': size,
    'weight': weight,
    'italic': italic,
    'color': color,
    'lineHeight': lineHeight,
    'letterSpacing': letterSpacing,
    'align': align,
    'underline': underline,
    'indent': indent,
    'highlight': highlight,
  };
  factory TextDefinition.fromJson(Map<String, dynamic> json) {
    final family = json['family'];
    final align = json['align'];
    if (!const {'Roboto', 'DejaVu Sans'}.contains(family) ||
        !const {'left', 'center', 'right', 'justify'}.contains(align) ||
        json['italic'] is! bool ||
        json['underline'] is! bool) {
      throw const FormatException('Invalid text style');
    }
    final weight = _integer(json['weight'], 100, 900);
    if (weight % 100 != 0) throw const FormatException('Invalid font weight');
    return TextDefinition(
      family: family as String,
      size: _number(json['size'], 10, 72),
      weight: weight,
      italic: json['italic'] as bool,
      color: _color(json['color']),
      lineHeight: _number(json['lineHeight'], 1, 3),
      letterSpacing: _number(json['letterSpacing'], -3, 10),
      align: align as String,
      underline: json['underline'] as bool,
      indent: _number(json['indent'], 0, 64),
      highlight: _color(json['highlight']),
    );
  }
  TextDefinition change(String key, Object value) =>
      TextDefinition.fromJson({...toJson(), key: value});
}

class CardDefinition {
  const CardDefinition({
    required this.fill,
    required this.border,
    required this.borderWidth,
    required this.radius,
    required this.paddingX,
    required this.paddingY,
    required this.minHeight,
    required this.shadow,
    required this.shadowOpacity,
    required this.blur,
    required this.offsetX,
    required this.offsetY,
  });
  final String fill, border, shadow;
  final double borderWidth,
      radius,
      paddingX,
      paddingY,
      minHeight,
      shadowOpacity,
      blur,
      offsetX,
      offsetY;
  Map<String, Object> toJson() => {
    'fill': fill,
    'border': border,
    'borderWidth': borderWidth,
    'radius': radius,
    'paddingX': paddingX,
    'paddingY': paddingY,
    'minHeight': minHeight,
    'shadow': shadow,
    'shadowOpacity': shadowOpacity,
    'blur': blur,
    'offsetX': offsetX,
    'offsetY': offsetY,
  };
  factory CardDefinition.fromJson(Map<String, dynamic> j) => CardDefinition(
    fill: _color(j['fill']),
    border: _color(j['border']),
    borderWidth: _number(j['borderWidth'], 0, 8),
    radius: _number(j['radius'], 0, 64),
    paddingX: _number(j['paddingX'], 0, 64),
    paddingY: _number(j['paddingY'], 0, 64),
    minHeight: _number(j['minHeight'], 0, 240),
    shadow: _color(j['shadow']),
    shadowOpacity: _number(j['shadowOpacity'], 0, 1),
    blur: _number(j['blur'], 0, 48),
    offsetX: _number(j['offsetX'], -24, 24),
    offsetY: _number(j['offsetY'], -24, 24),
  );
  CardDefinition change(String key, Object value) =>
      CardDefinition.fromJson({...toJson(), key: value});
}

class ButtonDefinition {
  const ButtonDefinition({
    required this.fill,
    required this.foreground,
    required this.border,
    required this.borderWidth,
    required this.radius,
    required this.minHeight,
  });
  final String fill, foreground, border;
  final double borderWidth, radius, minHeight;
  Map<String, Object> toJson() => {
    'fill': fill,
    'foreground': foreground,
    'border': border,
    'borderWidth': borderWidth,
    'radius': radius,
    'minHeight': minHeight,
  };
  factory ButtonDefinition.fromJson(Map<String, dynamic> j) => ButtonDefinition(
    fill: _color(j['fill']),
    foreground: _color(j['foreground']),
    border: _color(j['border']),
    borderWidth: _number(j['borderWidth'], 0, 8),
    radius: _number(j['radius'], 0, 64),
    minHeight: _number(j['minHeight'], 48, 120),
  );
  ButtonDefinition change(String key, Object value) =>
      ButtonDefinition.fromJson({...toJson(), key: value});
}

class StyleDefinitions {
  StyleDefinitions({
    required Map<TextRole, TextDefinition> texts,
    required Map<CardRole, CardDefinition> cards,
    required Map<ButtonRole, ButtonDefinition> buttons,
    required Map<String, int> palette,
    required Map<String, double> spacing,
  }) : texts = Map.unmodifiable(texts),
       cards = Map.unmodifiable(cards),
       buttons = Map.unmodifiable(buttons),
       palette = Map.unmodifiable(palette),
       spacing = Map.unmodifiable(spacing);
  final Map<TextRole, TextDefinition> texts;
  final Map<CardRole, CardDefinition> cards;
  final Map<ButtonRole, ButtonDefinition> buttons;
  final Map<String, int> palette;
  final Map<String, double> spacing;

  factory StyleDefinitions.defaults() {
    TextDefinition text(
      double size,
      int weight,
      double height, {
      String color = 'primary',
    }) => TextDefinition(
      family: 'Roboto',
      size: size,
      weight: weight,
      italic: false,
      color: color,
      lineHeight: height,
      letterSpacing: 0,
    );
    CardDefinition card(double padding, double min) => CardDefinition(
      fill: 'surface',
      border: 'border',
      borderWidth: 1,
      radius: 18,
      paddingX: padding,
      paddingY: padding,
      minHeight: min,
      shadow: 'shadow',
      shadowOpacity: .04,
      blur: 8,
      offsetX: 0,
      offsetY: 3,
    );
    return StyleDefinitions(
      texts: {
        TextRole.title1: text(28, 800, 1.2),
        TextRole.title2: text(16, 400, 1.4, color: 'secondary'),
        TextRole.cardTitle: text(18, 700, 1.3),
        TextRole.cardSubtitle: text(14, 400, 1.4, color: 'secondary'),
        TextRole.body: text(16, 400, 1.5),
        TextRole.editor: text(17, 400, 1.55),
        TextRole.button: text(17, 700, 1.25),
        TextRole.helper: text(14, 400, 1.4, color: 'secondary'),
        TextRole.brand: text(42, 800, 1.2),
        TextRole.brandTagline: text(18, 700, 1.3, color: 'brandAccent'),
        TextRole.artworkHelper: text(14, 400, 1.4, color: 'artworkIcon'),
        TextRole.pinDigit: text(34, 600, 1.2),
        TextRole.dayCount: text(27, 800, 1),
      },
      cards: {
        CardRole.large: card(20, 88),
        CardRole.small: card(16, 64),
        CardRole.content: card(16, 0),
      },
      buttons: {
        ButtonRole.primary: const ButtonDefinition(
          fill: 'accent',
          foreground: 'onAccent',
          border: 'accent',
          borderWidth: 0,
          radius: 18,
          minHeight: 56,
        ),
        ButtonRole.secondary: const ButtonDefinition(
          fill: 'surface',
          foreground: 'accent',
          border: 'accent',
          borderWidth: 1,
          radius: 18,
          minHeight: 56,
        ),
        ButtonRole.compact: const ButtonDefinition(
          fill: 'surface',
          foreground: 'accent',
          border: 'accent',
          borderWidth: 1,
          radius: 18,
          minHeight: 48,
        ),
      },
      palette: {
        'primary': 0xff231e61,
        'secondary': 0xff71668a,
        'accent': 0xff6d52ae,
        'surface': 0xfffef9fa,
        'background': 0xfff9f1f7,
        'selected': 0xffede4f8,
        'border': 0x246d52ae,
        'shadow': 0xff231e61,
        'onAccent': 0xffffffff,
        'artworkIcon': 0xffffffff,
        'brandAccent': 0xffd94778,
      },
      spacing: {
        'margin': 20,
        'cardGap': 12,
        'titleGap': 8,
        'sectionGap': 24,
        'touch': 48,
        'dayDiameter': 36,
        'dayOutline': 1.5,
      },
    );
  }

  Map<String, Object> toJson() => {
    'version': 1,
    'texts': {for (final e in texts.entries) e.key.name: e.value.toJson()},
    'cards': {for (final e in cards.entries) e.key.name: e.value.toJson()},
    'buttons': {for (final e in buttons.entries) e.key.name: e.value.toJson()},
    'palette': palette,
    'spacing': spacing,
  };
  String encode() => jsonEncode(toJson());
  factory StyleDefinitions.decode(String source) {
    try {
      final raw = jsonDecode(source);
      if (raw is! Map<String, dynamic> || raw['version'] != 1) {
        throw const FormatException('Unsupported style version');
      }
      final base = StyleDefinitions.defaults().toJson();
      Map<String, dynamic> merged(String name) {
        final incoming = raw[name];
        if (incoming != null && incoming is! Map<String, dynamic>) {
          throw const FormatException('Invalid style section');
        }
        return {...(base[name] as Map), ...?incoming as Map<String, dynamic>?};
      }

      final t = merged('texts'),
          c = merged('cards'),
          b = merged('buttons'),
          p = merged('palette'),
          s = merged('spacing');
      return StyleDefinitions(
        texts: {
          for (final role in TextRole.values)
            role: TextDefinition.fromJson(
              Map<String, dynamic>.from(t[role.name] as Map),
            ),
        },
        cards: {
          for (final role in CardRole.values)
            role: CardDefinition.fromJson(
              Map<String, dynamic>.from(c[role.name] as Map),
            ),
        },
        buttons: {
          for (final role in ButtonRole.values)
            role: ButtonDefinition.fromJson(
              Map<String, dynamic>.from(b[role.name] as Map),
            ),
        },
        palette: {
          for (final key in (base['palette'] as Map).keys.cast<String>())
            key: _integer(p[key], 0, 0xffffffff),
        },
        spacing: {
          for (final key in (base['spacing'] as Map).keys.cast<String>())
            key: _number(
              s[key],
              key == 'touch' ? 48 : (key == 'dayDiameter' ? 20 : 0),
              key == 'touch' ? 96 : (key == 'dayOutline' ? 4 : 80),
            ),
        },
      );
    } on FormatException {
      rethrow;
    } catch (_) {
      throw const FormatException('Invalid style data');
    }
  }

  StyleDefinitions copyWith({
    Map<TextRole, TextDefinition>? texts,
    Map<CardRole, CardDefinition>? cards,
    Map<ButtonRole, ButtonDefinition>? buttons,
    Map<String, int>? palette,
    Map<String, double>? spacing,
  }) => StyleDefinitions(
    texts: texts ?? this.texts,
    cards: cards ?? this.cards,
    buttons: buttons ?? this.buttons,
    palette: palette ?? this.palette,
    spacing: spacing ?? this.spacing,
  );
}
