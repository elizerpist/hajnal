import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/artwork/artwork_catalog.dart';
import '../../../core/theme/hajnal_theme.dart';
import '../../../core/theme/domain/style_roles.dart';
import '../../../core/theme/reflection_visual.dart';
import '../application/reflection_controller.dart';

class ReflectionPage extends StatefulWidget {
  const ReflectionPage({super.key, required this.controller});
  final ReflectionController controller;
  @override
  State<ReflectionPage> createState() => _ReflectionPageState();
}

class _ReflectionPageState extends State<ReflectionPage> {
  final text = TextEditingController();
  final note = TextEditingController();
  bool initialized = false;
  @override
  void dispose() {
    text.dispose();
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) {
      final c = widget.controller;
      final entry = c.entry;
      if (entry == null) {
        return Scaffold(
          appBar: AppBar(),
          body: Center(
            child: c.error == null
                ? const CircularProgressIndicator()
                : const Text('A reflexió nem tölthető be.'),
          ),
        );
      }
      if (!initialized) {
        text.text = entry.text;
        note.text = entry.note;
        initialized = true;
      }
      final style = HajnalStyle.of(context);
      final labels = [
        'Nagyon nehéz',
        'Nehéz',
        'Vegyes',
        'Rendben volt',
        'Jó volt',
      ];
      final icons = [
        Icons.sentiment_very_dissatisfied,
        Icons.sentiment_dissatisfied,
        Icons.sentiment_neutral,
        Icons.sentiment_satisfied,
        Icons.sentiment_very_satisfied,
      ];
      const prompts = {
        'best': ('Ami segített', 'Mi volt ma a legjobb?'),
        'hardest': ('Ami nehéz volt', 'Mi volt ma a legnehezebb?'),
        'keep': (
          'Amit megőrzök',
          'Van valami, amit szeretnél megőrizni ebből a napból?',
        ),
      };
      const observations = {
        'remembered': 'Eszembe jutott.',
        'attempted': 'Megpróbáltam alkalmazni.',
        'no_opportunity': 'Ma nem volt rá alkalom.',
      };
      final count = entry.snapshot == null ? 2 : 3;
      return Scaffold(
        backgroundColor: style.color('background'),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: SizedBox(
                height: math.max(
                  constraints.maxHeight,
                  700 * MediaQuery.textScalerOf(context).scale(1) - 300,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 18, top: 7),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: style.color('surface'),
                            border: Border.all(color: style.color('border')),
                          ),
                          child: BackButton(
                            color: style.color('accent'),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'Napi reflexió',
                                style: style.text(TextRole.helper),
                              ),
                              Text(
                                '${c.step + 1} / $count',
                                style: style.text(TextRole.helper),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 78,
                          child: Column(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 18,
                                color: style.color('accent'),
                              ),
                              Text(
                                DateUtils.isSameDay(entry.date, DateTime.now())
                                    ? 'A mai nap'
                                    : MaterialLocalizations.of(
                                        context,
                                      ).formatCompactDate(entry.date),
                                textAlign: TextAlign.center,
                                style: style.text(TextRole.helper),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: List.generate(
                        count,
                        (i) => Expanded(
                          child: Container(
                            height: 5,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color: style
                                  .color('accent')
                                  .withValues(alpha: i <= c.step ? 1 : .2),
                              borderRadius: ReflectionVisual.progressRadius,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => ReflectionVisual
                                .artworkFade
                                .createShader(bounds),
                            blendMode: BlendMode.dstIn,
                            child: Opacity(
                              opacity: .66,
                              child: Image.asset(
                                reflectionArtworks[c.step],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(24, 32, 24, 18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 310,
                                    ),
                                    child: Text(
                                      c.step == 0
                                          ? 'Hogyan érezted magad ma?'
                                          : c.step == 1
                                          ? 'Mi maradt meg benned ma?'
                                          : 'Amit gyakorlok',
                                      textAlign: TextAlign.center,
                                      style: style.text(TextRole.title1),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (c.step != 2)
                                  Text(
                                    c.step == 0
                                        ? 'Válaszd azt, ami most a leginkább igaz rád.'
                                        : 'Írj annyit, amennyi most jól esik.',
                                    textAlign: TextAlign.center,
                                    style: style.text(TextRole.title2),
                                  ),
                                const SizedBox(height: 22),
                                if (c.step == 0)
                                  Wrap(
                                    alignment: WrapAlignment.center,
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: List.generate(
                                      5,
                                      (i) => Semantics(
                                        selected: entry.mood == i + 1,
                                        button: true,
                                        label: labels[i],
                                        child: InkWell(
                                          onTap: () => c.update(
                                            c.entry!.copyWith(
                                              mood: i + 1,
                                              clearMood: c.entry!.mood == i + 1,
                                            ),
                                          ),
                                          child: Container(
                                            width: 64,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 10,
                                              horizontal: 3,
                                            ),
                                            decoration: style.card(
                                              CardRole.small,
                                              selected: entry.mood == i + 1,
                                            ),
                                            child: Column(
                                              children: [
                                                CircleAvatar(
                                                  radius: 18,
                                                  backgroundColor:
                                                      ReflectionVisual
                                                          .moodColors[i],
                                                  child: Icon(
                                                    icons[i],
                                                    size: 25,
                                                    color: style.color(
                                                      'surface',
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  labels[i],
                                                  textAlign: TextAlign.center,
                                                  style: style.text(
                                                    TextRole.helper,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                if (c.step == 1) ...[
                                  Wrap(
                                    alignment: WrapAlignment.center,
                                    spacing: 6,
                                    children: prompts.entries
                                        .map(
                                          (p) => ChoiceChip(
                                            shape: const StadiumBorder(),
                                            label: Text(p.value.$1),
                                            selected: entry.prompt == p.key,
                                            onSelected: (_) => c.update(
                                              c.entry!.copyWith(prompt: p.key),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    prompts[entry.prompt]?.$2 ??
                                        prompts['best']!.$2,
                                  ),
                                  Container(
                                    decoration: style.card(CardRole.content),
                                    child: TextField(
                                      controller: text,
                                      minLines: 6,
                                      maxLines: null,
                                      decoration: const InputDecoration(
                                        hintText: 'Írj, ha szeretnél…',
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.all(16),
                                      ),
                                      onChanged: (v) =>
                                          c.update(c.entry!.copyWith(text: v)),
                                    ),
                                  ),
                                ],
                                if (c.step == 2) ...[
                                  Container(
                                    decoration: style.card(CardRole.content),
                                    child: Padding(
                                      padding: const EdgeInsets.all(18),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('AKTÍV GYAKORLAT'),
                                          Text(
                                            entry.snapshot!.title ??
                                                'A mai gyakorlatom',
                                            style: style.text(
                                              TextRole.cardTitle,
                                            ),
                                          ),
                                          Text(entry.snapshot!.text),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Ma hogyan találkoztál ezzel?',
                                    style: style.text(TextRole.title2),
                                  ),
                                  for (final option in observations.entries)
                                    Container(
                                      margin: const EdgeInsets.only(top: 8),
                                      decoration: style.card(
                                        CardRole.small,
                                        selected:
                                            entry.observation == option.key,
                                      ),
                                      child: ListTile(
                                        leading: Icon(
                                          entry.observation == option.key
                                              ? Icons.radio_button_checked
                                              : Icons.radio_button_unchecked,
                                        ),
                                        title: Text(option.value),
                                        onTap: () => c.update(
                                          c.entry!.copyWith(
                                            observation: option.key,
                                            clearObservation:
                                                c.entry!.observation ==
                                                option.key,
                                          ),
                                        ),
                                      ),
                                    ),
                                  const Text('Szeretnél hozzáfűzni valamit?'),
                                  Container(
                                    decoration: style.card(CardRole.content),
                                    child: TextField(
                                      controller: note,
                                      minLines: 2,
                                      maxLines: null,
                                      decoration: const InputDecoration(
                                        hintText: 'Írj, ha szeretnél…',
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.all(12),
                                      ),
                                      onChanged: (v) =>
                                          c.update(c.entry!.copyWith(note: v)),
                                    ),
                                  ),
                                ],
                                if (c.error != null)
                                  const Text(
                                    'A mentés nem sikerült. Próbáld újra.',
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 4, 18, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          DecoratedBox(
                            decoration: ReflectionVisual.primaryButton(style),
                            child: FilledButton(
                              style: style
                                  .button(ButtonRole.primary)
                                  .copyWith(
                                    backgroundColor:
                                        const WidgetStatePropertyAll(
                                          Colors.transparent,
                                        ),
                                  ),
                              onPressed: c.saving
                                  ? null
                                  : () async {
                                      if (c.step < count - 1) {
                                        c.move(1);
                                        return;
                                      }
                                      if (await c.finish() && context.mounted) {
                                        Navigator.pop(context);
                                      }
                                    },
                              child: Text(
                                c.step == 0
                                    ? 'Tovább'
                                    : c.step == 1 && count == 3
                                    ? 'Mentés és folytatás'
                                    : c.step == 2
                                    ? 'Befejezés'
                                    : 'Mentés',
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              if (c.step < count - 1) {
                                c.move(1);
                                return;
                              }
                              if (await c.finish() && context.mounted) {
                                Navigator.pop(context);
                              }
                            },
                            child: Text(
                              c.step == 1
                                  ? 'Most nem szeretnék írni'
                                  : 'Kihagyom',
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
        ),
      );
    },
  );
}
