import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/artwork/artwork_catalog.dart';
import '../../../core/theme/domain/style_roles.dart';
import '../../../core/theme/hajnal_theme.dart';
import '../application/panic_controller.dart';
import '../application/survival_controller.dart';
import 'panic_dialogs.dart';

const _titles = [
  'Állj meg egy pillanatra.',
  'Lélegezz.',
  'Igyál egy korty vizet.',
  'Válts környezetet.',
  'Nem kell egyedül maradnod.',
  'Maradj még itt egy kicsit.',
  'Hogy vagy most?',
];
const _copies = [
  'Most nem kell semmit eldöntened. Csak figyelj arra, ami körülötted van.',
  'Próbálj néhány lassú, kényelmes lélegzetet venni.',
  'Ha van kéznél víz, igyál egy kortyot. Ennyi is elég.',
  'Ha biztonságos, menj egy nyugodtabb helyre, vagy távolodj el attól, ami most nehéz.',
  'Ha szeretnéd, keress meg valakit, akiben megbízol.',
  'Most nem kell semmit megoldanod.',
  'Nem kell jobban lenned ahhoz, hogy őszintén válaszolj.',
];

class SurvivalPage extends StatefulWidget {
  const SurvivalPage({
    super.key,
    required this.controller,
    required this.panic,
  });
  final SurvivalController controller;
  final PanicController panic;
  @override
  State<SurvivalPage> createState() => _SurvivalPageState();
}

class _SurvivalPageState extends State<SurvivalPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  );
  SurvivalController get flow => widget.controller;
  @override
  void initState() {
    super.initState();
    unawaited(flow.open());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _breath.stop();
    } else if (!_breath.isAnimating) {
      _breath.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _breath.dispose();
    flow.dispose();
    super.dispose();
  }

  Future<void> _note() => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _SurvivalNoteSheet(flow: flow),
  );

  Widget _action(
    String label,
    VoidCallback onPressed, {
    bool secondary = false,
  }) => SizedBox(
    width: double.infinity,
    child: secondary
        ? OutlinedButton(onPressed: onPressed, child: Text(label))
        : FilledButton(onPressed: onPressed, child: Text(label)),
  );

  Widget _circle(String value, [String? caption]) {
    if (caption != null && MediaQuery.textScalerOf(context).scale(1) > 1.2) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _circle(value),
          const SizedBox(height: 12),
          Text(
            caption,
            textAlign: TextAlign.center,
            style: HajnalStyle.of(context).text(TextRole.helper),
          ),
        ],
      );
    }
    return SizedBox(
      width: 184,
      height: 184,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: HajnalStyle.of(context).color('surface'),
          border: Border.all(
            color: HajnalStyle.of(context).color('accent'),
            width: 5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: HajnalStyle.of(context).text(TextRole.title1)),
            if (caption != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  caption,
                  textAlign: TextAlign.center,
                  style: HajnalStyle.of(context).text(TextRole.helper),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _stage(int step) {
    final session = flow.session!;
    if (step == 0) {
      return _circle(
        '00:${flow.stopRemaining.toString().padLeft(2, '0')}',
        'Nézz körül. Nevezz meg magadban valamit, amit látsz.',
      );
    }
    if (step == 1) {
      return Column(
        children: [
          AnimatedBuilder(
            animation: _breath,
            builder: (context, child) => Transform.scale(
              scale:
                  MediaQuery.disableAnimationsOf(context) ||
                      session.breathingPaused
                  ? 1
                  : .82 + .26 * Curves.easeInOut.transform(_breath.value),
              child: _circle(
                session.breathingPaused
                    ? 'Szünet'
                    : MediaQuery.disableAnimationsOf(context)
                    ? 'Lélegezz'
                    : _breath.status == AnimationStatus.reverse
                    ? 'Kilégzés'
                    : 'Belégzés',
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: () {
              flow.toggleBreathing();
              if (flow.session!.breathingPaused) {
                _breath.stop();
              } else if (!MediaQuery.disableAnimationsOf(context)) {
                _breath.repeat(reverse: true);
              }
            },
            child: Text(
              session.breathingPaused ? 'Folytatás' : 'Szüneteltetés',
            ),
          ),
        ],
      );
    }
    if (step == 2) {
      return Icon(
        Icons.local_drink_outlined,
        size: 120,
        color: HajnalStyle.of(context).color('accent'),
      );
    }
    if (step == 3) {
      return Icon(
        Icons.door_front_door_outlined,
        size: 120,
        color: HajnalStyle.of(context).color('accent'),
      );
    }
    if (step == 4) {
      return Text(
        'A következő lépést a saját tempódban teheted meg.',
        textAlign: TextAlign.center,
        style: HajnalStyle.of(context).text(TextRole.body),
      );
    }
    if (step == 5) {
      final left = flow.remaining.inSeconds;
      return Column(
        children: [
          Text(
            '${(left ~/ 60).toString().padLeft(2, '0')}:${(left % 60).toString().padLeft(2, '0')}',
            style: HajnalStyle.of(context).text(TextRole.title1),
          ),
          Text(
            'Ennyi idő van hátra a 15 percből.',
            textAlign: TextAlign.center,
            style: HajnalStyle.of(context).text(TextRole.helper),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 120,
            child: LinearProgressIndicator(value: left / 900),
          ),
          if (left == 0)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                'Letelt a 15 perc. Akkor lépj tovább, amikor készen állsz.',
              ),
            ),
        ],
      );
    }
    if (flow.complete) return _circle('♥', 'A mai tapasztalatod csak a tiéd.');
    if (!flow.stronger) {
      return Column(
        children: _actions(step)
            .map(
              (action) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: action,
              ),
            )
            .toList(),
      );
    }
    return const SizedBox(height: 4);
  }

  List<Widget> _actions(int step) {
    if (step == 0 || step == 1) return [_action('Tovább', flow.next)];
    if (step == 2) {
      return [
        _action(
          'Ittam egy kortyot',
          () => flow.chooseWater('drank'),
          secondary: true,
        ),
        _action(
          'Most nincs nálam víz',
          () => flow.chooseWater('unavailable'),
          secondary: true,
        ),
      ];
    }
    if (step == 3) {
      return [
        _action(
          'Helyet váltottam',
          () => flow.chooseEnvironment('moved'),
          secondary: true,
        ),
        _action(
          'Most inkább maradok',
          () => flow.chooseEnvironment('stayed'),
          secondary: true,
        ),
      ];
    }
    if (step == 4) {
      return [
        _action('Most még nem szeretnék beszélni', flow.next, secondary: true),
      ];
    }
    if (step == 5) {
      return [
        Row(
          children: [
            Expanded(
              child: _action(
                'Miért kezdtem el?',
                () => showMotivation(context, widget.panic),
                secondary: true,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _action('Írd ki, ami benned van', _note, secondary: true),
            ),
          ],
        ),
        _action('Most értékelem újra', flow.next),
      ];
    }
    if (flow.complete) {
      return [
        _action(
          'Vissza a Főmenübe',
          () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ];
    }
    if (flow.stillHard) {
      return [
        _action(
          'Beszélek valakivel.',
          () => showPanicHelp(context, widget.panic),
          secondary: true,
        ),
        _action('Maradok még néhány percet.', flow.waitAgain, secondary: true),
        _action(
          'Visszalépek a Pánik módba.',
          () => Navigator.pop(context),
          secondary: true,
        ),
      ];
    }
    if (flow.stronger) {
      return [
        _action('Segítséget kérek', () => showPanicHelp(context, widget.panic)),
        _action(
          'Vissza a Pánik módba',
          () => Navigator.pop(context),
          secondary: true,
        ),
      ];
    }
    return [
      _action(
        'Enyhült – Kicsit könnyebb, mint amikor elkezdtem.',
        flow.markRelieved,
        secondary: true,
      ),
      _action(
        'Még nehéz – Még mindig megterhelő.',
        flow.markStillHard,
        secondary: true,
      ),
      _action(
        'Erősebb lett – Most még nagyobb támogatásra van szükségem.',
        flow.markStronger,
        secondary: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ListenableBuilder(
        listenable: flow,
        builder: (context, _) {
          if (flow.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (flow.session == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('A munkamenet nem tölthető be.'),
                  TextButton(
                    onPressed: flow.open,
                    child: const Text('Újrapróbálás'),
                  ),
                ],
              ),
            );
          }
          final session = flow.session!;
          final step = session.step;
          final title = flow.complete
              ? 'Adtál magadnak egy kis időt.'
              : flow.stillHard
              ? 'Maradjunk a következő lépésnél.'
              : flow.stronger
              ? 'Nagyobb támogatásra van szükséged.'
              : _titles[step];
          final copy = flow.complete
              ? 'Bármikor visszatérhetsz ide, ha újra szükséged van egy nyugodt következő lépésre.'
              : flow.stillHard
              ? 'Nem kell újra végigcsinálnod a korábbi állomásokat.'
              : flow.stronger
              ? 'Nem kell ezt egyedül megoldanod.'
              : _copies[step];
          final left = flow.remaining.inSeconds;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Vissza a Pánik módba',
                      icon: const Icon(Icons.arrow_back),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          const Text('15 perces túlélőcsomag'),
                          Text('${step + 1} / 7'),
                        ],
                      ),
                    ),
                    Text(
                      '${(left ~/ 60).toString().padLeft(2, '0')}:${(left % 60).toString().padLeft(2, '0')}',
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Semantics(
                  label: '${step + 1}. állomás a 7-ből',
                  child: Row(
                    children: List.generate(
                      7,
                      (index) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: index == 6 ? 0 : 4),
                          child: LinearProgressIndicator(
                            value: index <= step ? 1 : 0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) => Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        survivalArtworks[step],
                        fit: BoxFit.cover,
                        alignment: Alignment.bottomCenter,
                      ),
                      SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: (constraints.maxHeight - 40).clamp(
                              0,
                              double.infinity,
                            ),
                          ),
                          child: IntrinsicHeight(
                            child: Column(
                              children: [
                                if (flow.resumed) ...[
                                  const Text(
                                    'A korábbi munkameneted itt van. A kezdési időpontja változatlan marad.',
                                    textAlign: TextAlign.center,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _action(
                                          'Folytatom',
                                          flow.dismissResume,
                                          secondary: true,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _action(
                                          'Újrakezdem',
                                          flow.restart,
                                          secondary: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                Text(
                                  title,
                                  textAlign: TextAlign.center,
                                  style: HajnalStyle.of(
                                    context,
                                  ).text(TextRole.title1),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  copy,
                                  textAlign: TextAlign.center,
                                  style: HajnalStyle.of(
                                    context,
                                  ).text(TextRole.body),
                                ),
                                const SizedBox(height: 30),
                                const Spacer(),
                                _stage(step),
                                const Spacer(),
                                const SizedBox(height: 24),
                                ...(step == 6 &&
                                            !flow.complete &&
                                            !flow.stronger
                                        ? <Widget>[]
                                        : _actions(step))
                                    .map(
                                      (action) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        child: action,
                                      ),
                                    ),
                                if (step > 0 && !flow.complete)
                                  TextButton(
                                    onPressed: flow.previous,
                                    child: const Text('Előző állomás'),
                                  ),
                                TextButton(
                                  onPressed: () =>
                                      showPanicHelp(context, widget.panic),
                                  child: const Text('Segítséget kérek'),
                                ),
                                if (flow.error != null)
                                  TextButton(
                                    onPressed: flow.retrySave,
                                    child: const Text(
                                      'A mentés nem sikerült. Újrapróbálás',
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

class _SurvivalNoteSheet extends StatefulWidget {
  const _SurvivalNoteSheet({required this.flow});
  final SurvivalController flow;
  @override
  State<_SurvivalNoteSheet> createState() => _SurvivalNoteSheetState();
}

class _SurvivalNoteSheetState extends State<_SurvivalNoteSheet> {
  late final TextEditingController input = TextEditingController(
    text: widget.flow.session!.note,
  );
  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      20,
      16,
      20,
      MediaQuery.viewInsetsOf(context).bottom + 20,
    ),
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Írd ki, ami benned van.',
            style: HajnalStyle.of(context).text(TextRole.title1),
          ),
          const SizedBox(height: 8),
          Text(
            'Nem kell szépen megfogalmaznod. Írj annyit, amennyi most jól esik.',
            style: HajnalStyle.of(context).text(TextRole.helper),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('survival-note-input'),
            controller: input,
            maxLines: 6,
            style: HajnalStyle.of(context).text(TextRole.editor),
            decoration: const InputDecoration(
              labelText: 'Szabad jegyzet',
              hintText: 'Írj annyit, amennyi most jól esik…',
              border: OutlineInputBorder(),
            ),
            onChanged: widget.flow.setNote,
          ),
          const SizedBox(height: 12),
          ListenableBuilder(
            listenable: widget.flow,
            builder: (context, _) => FilledButton(
              onPressed: widget.flow.saving
                  ? null
                  : () async {
                      final saved = await widget.flow.saveNote();
                      if (!context.mounted) return;
                      if (saved) {
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('A jegyzet nem menthető.'),
                          ),
                        );
                      }
                    },
              child: const Text('Jegyzet megőrzése'),
            ),
          ),
        ],
      ),
    ),
  );
}
