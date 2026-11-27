import 'package:flutter/material.dart';
import '../application/style_controller.dart';
import '../domain/style_roles.dart';
import '../hajnal_components.dart';
import '../hajnal_theme.dart';

class StyleEditor extends StatefulWidget {
  const StyleEditor({super.key, required this.owner});
  final StyleOwner owner;
  @override
  State<StyleEditor> createState() => _StyleEditorState();
}

class _StyleEditorState extends State<StyleEditor> {
  late final StyleEditorController editor = StyleEditorController(widget.owner);
  @override
  void dispose() {
    editor.dispose();
    super.dispose();
  }

  Future<void> close() async {
    if (!editor.dirty) {
      Navigator.of(context).pop();
      return;
    }
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elveted a módosításokat?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Szerkesztés folytatása'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Elvetés'),
          ),
        ],
      ),
    );
    if (discard == true && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: editor,
    builder: (context, _) => PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !editor.saving) close();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: HajnalNavigationIcon(
            icon: Icons.arrow_back_ios_new,
            label: 'Vissza',
            onPressed: close,
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: HajnalStyle.of(context).spacing('margin'),
                ),
                child: const HajnalHeading(
                  title: 'Stílus',
                  subtitle:
                      'Globális megjelenés\nEgy módosítás mindenhol érvényes.',
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(
                    HajnalStyle.of(context).spacing('margin'),
                  ),
                  children: [
                    for (final role in TextRole.values) _textSection(role),
                    _paletteSection(),
                    for (final role in CardRole.values) _cardSection(role),
                    for (final role in ButtonRole.values) _buttonSection(role),
                    _spacingSection(),
                    TextButton(
                      onPressed: editor.resetAll,
                      child: const Text('Minden alapérték visszaállítása'),
                    ),
                    if (_contrastWarning())
                      const Text(
                        'Figyelem: a szöveg és a háttér kontrasztja alacsony.',
                      ),
                    if (editor.error != null)
                      const Text(
                        'A mentés nem sikerült. Nyisd meg újra a szerkesztőt, és próbáld újra.',
                      ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(
                  HajnalStyle.of(context).spacing('margin'),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: HajnalAction(
                        label: 'Mégse',
                        role: ButtonRole.secondary,
                        onPressed: editor.saving
                            ? null
                            : () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: HajnalAction(
                        label: 'Alkalmazás',
                        loading: editor.saving,
                        onPressed: editor.saving
                            ? null
                            : () async {
                                if (await editor.apply() && context.mounted) {
                                  Navigator.of(context).pop();
                                }
                              },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  String _textName(TextRole role) => switch (role) {
    TextRole.title1 => 'Title 1',
    TextRole.title2 => 'Title 2',
    TextRole.cardTitle => 'Szövegcím',
    TextRole.cardSubtitle => 'Szövegalcím',
    TextRole.body => 'Törzsszöveg',
    TextRole.editor => 'Editor alapszöveg',
    TextRole.button => 'Gombfelirat',
    TextRole.helper => 'Segédszöveg',
    TextRole.brand => 'Márkafelirat',
    TextRole.brandTagline => 'Márkajelmondat',
    TextRole.artworkHelper => 'Kép fölötti segédszöveg',
    TextRole.pinDigit => 'PIN-számjegy',
    TextRole.dayCount => 'Napszámláló',
  };
  String _cardName(CardRole role) => switch (role) {
    CardRole.large => 'Nagy kártya',
    CardRole.small => 'Kis kártya',
    CardRole.content => 'Tartalomkártya',
  };
  String _buttonName(ButtonRole role) => switch (role) {
    ButtonRole.primary => 'Kiemelt gomb',
    ButtonRole.secondary => 'Másodlagos gomb',
    ButtonRole.compact => 'Kompakt gomb',
  };

  Widget _preview(Widget child) => Theme(
    data: hajnalTheme(editor.draft),
    child: Builder(
      builder: (context) => Container(
        width: double.infinity,
        color: HajnalStyle.of(context).color('background'),
        padding: const EdgeInsets.all(12),
        child: child,
      ),
    ),
  );

  Widget _textSection(TextRole role) {
    final t = editor.draft.texts[role]!;
    void set(String key, Object value) => editor.setText(role, key, value);
    return ExpansionTile(
      title: Text(_textName(role)),
      children: [
        _preview(
          Builder(
            builder: (context) => Text(
              'Árvíztűrő tükörfúrógép',
              style: HajnalStyle.of(context).text(role),
            ),
          ),
        ),
        DropdownButtonFormField<String>(
          initialValue: t.family,
          decoration: const InputDecoration(labelText: 'Betűcsalád'),
          items: const [
            'Roboto',
            'DejaVu Sans',
          ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (v) {
            if (v != null) set('family', v);
          },
        ),
        _number('Betűméret', t.size, 10, 72, (v) => set('size', v)),
        _number(
          'Betűvastagság',
          t.weight.toDouble(),
          100,
          900,
          (v) => set('weight', (v / 100).round() * 100),
          divisions: 8,
        ),
        SwitchListTile(
          title: const Text('Dőlt'),
          value: t.italic,
          onChanged: (v) => set('italic', v),
        ),
        _colorField('Szín', t.color, (v) => set('color', v)),
        if (role == TextRole.button)
          const Text('A feliratszín módosítása minden gombtípusra érvényes.'),
        _number('Sormagasság', t.lineHeight, 1, 3, (v) => set('lineHeight', v)),
        _number(
          'Betűköz',
          t.letterSpacing,
          -3,
          10,
          (v) => set('letterSpacing', v),
        ),
        if (role == TextRole.editor) ...[
          DropdownButtonFormField<String>(
            initialValue: t.align,
            decoration: const InputDecoration(labelText: 'Igazítás'),
            items:
                const {
                      'left': 'Balra',
                      'center': 'Középre',
                      'right': 'Jobbra',
                      'justify': 'Sorkizárt',
                    }.entries
                    .map(
                      (e) =>
                          DropdownMenuItem(value: e.key, child: Text(e.value)),
                    )
                    .toList(),
            onChanged: (v) {
              if (v != null) set('align', v);
            },
          ),
          SwitchListTile(
            title: const Text('Aláhúzás'),
            value: t.underline,
            onChanged: (v) => set('underline', v),
          ),
          _number('Behúzás', t.indent, 0, 64, (v) => set('indent', v)),
          _colorField(
            'Kiemelő háttér',
            t.highlight,
            (v) => set('highlight', v),
          ),
        ],
        TextButton(
          onPressed: () => editor.resetText(role),
          child: const Text('Alapérték visszaállítása'),
        ),
      ],
    );
  }

  Widget _cardSection(CardRole role) {
    final c = editor.draft.cards[role]!;
    void set(String key, Object value) => editor.setCard(role, key, value);
    return ExpansionTile(
      title: Text(_cardName(role)),
      children: [
        _preview(
          Column(
            children: [
              HajnalChoiceCard(
                title: 'Példa kártya',
                subtitle: 'Normál állapot',
                selected: false,
                onTap: () {},
                role: role,
              ),
              const SizedBox(height: 12),
              HajnalChoiceCard(
                title: 'Kiválasztott kártya',
                subtitle: 'Kijelölt állapot',
                selected: true,
                onTap: () {},
                role: role,
              ),
            ],
          ),
        ),
        _colorField('Kitöltés', c.fill, (v) => set('fill', v)),
        _colorField('Keret', c.border, (v) => set('border', v)),
        _number(
          'Keretvastagság',
          c.borderWidth,
          0,
          8,
          (v) => set('borderWidth', v),
        ),
        _number('Sarokkerekítés', c.radius, 0, 64, (v) => set('radius', v)),
        _number(
          'Vízszintes belső térköz',
          c.paddingX,
          0,
          64,
          (v) => set('paddingX', v),
        ),
        _number(
          'Függőleges belső térköz',
          c.paddingY,
          0,
          64,
          (v) => set('paddingY', v),
        ),
        _number(
          'Minimális magasság',
          c.minHeight,
          0,
          240,
          (v) => set('minHeight', v),
        ),
        _colorField('Árnyék', c.shadow, (v) => set('shadow', v)),
        _number(
          'Árnyék fedettsége',
          c.shadowOpacity,
          0,
          1,
          (v) => set('shadowOpacity', v),
        ),
        _number('Árnyék elmosása', c.blur, 0, 48, (v) => set('blur', v)),
        _number(
          'Árnyék vízszintes eltolása',
          c.offsetX,
          -24,
          24,
          (v) => set('offsetX', v),
        ),
        _number(
          'Árnyék függőleges eltolása',
          c.offsetY,
          -24,
          24,
          (v) => set('offsetY', v),
        ),
        TextButton(
          onPressed: () => editor.resetCard(role),
          child: const Text('Alapérték visszaállítása'),
        ),
      ],
    );
  }

  Widget _buttonSection(ButtonRole role) {
    final b = editor.draft.buttons[role]!;
    void set(String key, Object value) => editor.setButton(role, key, value);
    return ExpansionTile(
      title: Text(_buttonName(role)),
      children: [
        _preview(
          HajnalAction(label: 'Példa gomb', role: role, onPressed: () {}),
        ),
        _colorField('Kitöltés', b.fill, (v) => set('fill', v)),
        _colorField('Felirat', b.foreground, (v) => set('foreground', v)),
        _colorField('Keret', b.border, (v) => set('border', v)),
        _number(
          'Keretvastagság',
          b.borderWidth,
          0,
          8,
          (v) => set('borderWidth', v),
        ),
        _number('Sarokkerekítés', b.radius, 0, 64, (v) => set('radius', v)),
        _number(
          'Minimális magasság',
          b.minHeight,
          48,
          120,
          (v) => set('minHeight', v),
        ),
        TextButton(
          onPressed: () => editor.resetButton(role),
          child: const Text('Alapérték visszaállítása'),
        ),
      ],
    );
  }

  Widget _paletteSection() => ExpansionTile(
    title: const Text('Menüháttér és globális paletta'),
    children: [
      _preview(
        const HajnalHeading(title: 'Mintacím', subtitle: 'Globális megjelenés'),
      ),
      for (final entry in editor.draft.palette.entries)
        ExpansionTile(
          title: Text(switch (entry.key) {
            'background' => 'Menüháttér',
            'surface' => 'Kártyakitöltés',
            'primary' => 'Elsődleges szöveg',
            'secondary' => 'Másodlagos szöveg',
            'accent' => 'Kiemelőszín',
            'selected' => 'Kiválasztott kártya',
            'border' => 'Keret',
            'shadow' => 'Árnyék',
            'onAccent' => 'Kiemelés szövege',
            'artworkIcon' => 'Kép fölötti ikon',
            'brandAccent' => 'Márkaszín',
            _ => entry.key,
          }),
          children: [
            _colorField(
              entry.key,
              '#${entry.value.toRadixString(16).padLeft(8, '0')}',
              (v) {
                if (v.startsWith('#')) {
                  editor.setPalette(
                    entry.key,
                    int.parse(v.substring(1), radix: 16),
                  );
                }
              },
              paletteOnly: true,
            ),
            TextButton(
              onPressed: () => editor.resetPaletteColor(entry.key),
              child: const Text('Alapérték visszaállítása'),
            ),
          ],
        ),
      TextButton(
        onPressed: editor.resetPalette,
        child: const Text('Paletta visszaállítása'),
      ),
    ],
  );
  Widget _spacingSection() => ExpansionTile(
    title: const Text('Térközök és jelölők'),
    children: [
      _preview(
        Builder(
          builder: (context) => Column(
            children: [
              const HajnalHeading(title: 'Mintacím', subtitle: 'Minta alcím'),
              SizedBox(height: HajnalStyle.of(context).spacing('sectionGap')),
              const HajnalCard(child: Text('Tartalom')),
            ],
          ),
        ),
      ),
      for (final e in editor.draft.spacing.entries)
        _number(
          switch (e.key) {
            'margin' => 'Oldalmargó',
            'cardGap' => 'Kártyák távolsága',
            'titleGap' => 'Cím és alcím távolsága',
            'sectionGap' => 'Fejléc és tartalom távolsága',
            'touch' => 'Érintési terület',
            'dayDiameter' => 'Napjelölő átmérője',
            'dayOutline' => 'Mai nap körvonalvastagsága',
            _ => e.key,
          },
          e.value,
          e.key == 'touch' ? 48 : (e.key == 'dayDiameter' ? 20 : 0),
          e.key == 'touch' ? 96 : (e.key == 'dayOutline' ? 4 : 80),
          (v) => editor.setSpacing(e.key, v),
        ),
      TextButton(
        onPressed: editor.resetSpacing,
        child: const Text('Térközök visszaállítása'),
      ),
    ],
  );

  Widget _number(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> changed, {
    int? divisions,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label),
      Row(
        children: [
          Expanded(
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              onChanged: changed,
            ),
          ),
          SizedBox(
            width: 78,
            child: TextFormField(
              key: ValueKey('$label-$value'),
              initialValue: value.toStringAsFixed(2),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              onFieldSubmitted: (s) {
                final v = double.tryParse(s.replaceAll(',', '.'));
                if (v != null && v >= min && v <= max) changed(v);
              },
            ),
          ),
        ],
      ),
    ],
  );

  Widget _colorField(
    String label,
    String value,
    ValueChanged<String> changed, {
    bool paletteOnly = false,
  }) {
    final s = HajnalStyle(editor.draft);
    final hsv = HSVColor.fromColor(s.color(value));
    void applyColor(HSVColor color) => changed(
      '#${color.toColor().toARGB32().toRadixString(16).padLeft(8, '0')}',
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        if (!paletteOnly)
          DropdownButtonFormField<String>(
            initialValue: value.startsWith('#') ? 'custom' : value,
            decoration: const InputDecoration(
              labelText: 'Palettaszerep vagy saját szín',
            ),
            items: [
              for (final name in editor.draft.palette.keys)
                DropdownMenuItem(value: name, child: Text(name)),
              const DropdownMenuItem(
                value: 'custom',
                child: Text('Saját szín'),
              ),
            ],
            onChanged: (v) {
              if (v != null) {
                changed(
                  v == 'custom'
                      ? '#${s.color(value).toARGB32().toRadixString(16).padLeft(8, '0')}'
                      : v,
                );
              }
            },
          ),
        Wrap(
          spacing: 8,
          children: [
            for (final color in [
              0xff231e61,
              0xff71668a,
              0xff6d52ae,
              0xfffef9fa,
              0xfff9f1f7,
              0xffede4f8,
              0xffffffff,
              0xff000000,
            ])
              IconButton(
                tooltip: 'Szín #${color.toRadixString(16)}',
                onPressed: () => changed('#${color.toRadixString(16)}'),
                icon: Icon(Icons.circle, color: Color(color)),
              ),
          ],
        ),
        ExpansionTile(
          title: const Text('Színválasztó'),
          children: [
            _number(
              'Árnyalat',
              hsv.hue,
              0,
              360,
              (v) => applyColor(hsv.withHue(v)),
            ),
            _number(
              'Telítettség',
              hsv.saturation,
              0,
              1,
              (v) => applyColor(hsv.withSaturation(v)),
            ),
            _number(
              'Világosság',
              hsv.value,
              0,
              1,
              (v) => applyColor(hsv.withValue(v)),
            ),
            _number(
              'Fedettség',
              hsv.alpha,
              0,
              1,
              (v) => applyColor(hsv.withAlpha(v)),
            ),
          ],
        ),
        TextFormField(
          key: ValueKey('$label-$value'),
          initialValue: value.startsWith('#')
              ? value
              : '#${s.color(value).toARGB32().toRadixString(16).padLeft(8, '0')}',
          decoration: const InputDecoration(labelText: 'HEX (AARRGGBB)'),
          onFieldSubmitted: (v) {
            if (RegExp(r'^#[0-9a-fA-F]{8}$').hasMatch(v)) changed(v);
          },
        ),
      ],
    );
  }

  bool _contrastWarning() {
    final s = HajnalStyle(editor.draft);
    bool low(Color foreground, Color background) {
      final backgroundLuminance = background.computeLuminance();
      final foregroundLuminance = Color.alphaBlend(
        foreground,
        background,
      ).computeLuminance();
      return (foregroundLuminance > backgroundLuminance
              ? (foregroundLuminance + .05) / (backgroundLuminance + .05)
              : (backgroundLuminance + .05) / (foregroundLuminance + .05)) <
          4.5;
    }

    return [
          TextRole.title1,
          TextRole.title2,
          TextRole.body,
          TextRole.helper,
        ].any(
          (r) =>
              low(s.color(editor.draft.texts[r]!.color), s.color('background')),
        ) ||
        [CardRole.large, CardRole.small, CardRole.content].any(
          (r) => low(
            s.color(editor.draft.texts[TextRole.cardTitle]!.color),
            s.color(editor.draft.cards[r]!.fill),
          ),
        ) ||
        ButtonRole.values.any(
          (r) => low(
            s.color(editor.draft.buttons[r]!.foreground),
            s.color(editor.draft.buttons[r]!.fill),
          ),
        );
  }
}
