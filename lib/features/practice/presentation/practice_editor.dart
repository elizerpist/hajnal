import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import '../../../core/artwork/practice_artwork.dart';
import '../../../core/theme/practice_visual.dart';
import '../application/practice_controller.dart';
import '../application/practice_store.dart';

class _Prompt {
  const _Prompt(this.name, this.subtitle, this.question, this.icon);
  final String name, subtitle, question;
  final String icon;
}

const _prompts = [
  _Prompt(
    'Felismerés',
    'Amit észrevettem',
    'Mit vettél észre magadon?',
    'assets/artwork/practice/practice_sprout.png',
  ),
  _Prompt(
    'Iránytű',
    'Ami fontos nekem',
    'Mi fontos neked ebben a helyzetben?',
    'assets/artwork/practice/prompts/compass.svg',
  ),
  _Prompt(
    'Kérdés',
    'Amin gondolkodom',
    'Milyen kérdést vinnél ma magaddal?',
    'assets/artwork/practice/prompts/question.svg',
  ),
  _Prompt(
    'Apró lépés',
    'Amit kipróbálok',
    'Mit próbálnál ki legközelebb?',
    'assets/artwork/practice/prompts/footsteps.svg',
  ),
];

class PracticeEditor extends StatefulWidget {
  const PracticeEditor({
    super.key,
    required this.controller,
    required this.onBack,
    this.card,
  });
  final PracticeController controller;
  final PracticeCard? card;
  final VoidCallback onBack;
  @override
  State<PracticeEditor> createState() => _PracticeEditorState();
}

class _PracticeEditorState extends State<PracticeEditor> {
  late final TextEditingController text = TextEditingController(
    text: widget.card?.text ?? '',
  );
  late final TextEditingController title = TextEditingController(
    text: widget.card?.title ?? '',
  );
  int? selected;
  bool expanded = false, showTitle = false;
  String? insertedPrefix;
  @override
  void initState() {
    super.initState();
    text.addListener(_refresh);
    selected = _prompts.indexWhere((p) => p.name == widget.card?.promptKind);
    if (selected == -1) selected = null;
  }

  void _refresh() {
    setState(() {});
  }

  @override
  void dispose() {
    text.removeListener(_refresh);
    text.dispose();
    title.dispose();
    super.dispose();
  }

  bool get valid => widget.controller.canSave(text.text);
  void choose(int index) {
    final replacement =
        text.text.trim().isEmpty || text.text.trim() == insertedPrefix;
    setState(() {
      selected = index;
      if (replacement) {
        insertedPrefix = widget.controller.promptPrefix(_prompts[index].name);
        text.value = TextEditingValue(
          text: insertedPrefix!,
          selection: TextSelection.collapsed(offset: insertedPrefix!.length),
        );
      }
    });
  }

  Future<void> save(bool activate) async {
    final content = PracticeContent(
      text: text.text,
      title: title.text.trim().isEmpty ? null : title.text.trim(),
      promptKind: selected == null ? null : _prompts[selected!].name,
    );
    final success = widget.card == null
        ? await widget.controller.add(content, activate)
        : await widget.controller.saveChanges(widget.card!.id, content);
    if (success && mounted) widget.onBack();
  }

  Future<void> remove() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kártya törlése'),
        content: Text('Törlöd ezt a kártyát: „${widget.card!.label}”?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Mégse'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Törlés'),
          ),
        ],
      ),
    );
    if (confirmed == true &&
        await widget.controller.remove(widget.card!.id) &&
        mounted) {
      widget.onBack();
    }
  }

  Widget _promptTile(BuildContext context, int i) => Semantics(
    button: true,
    selected: selected == i,
    label: '${_prompts[i].name}: ${_prompts[i].subtitle}',
    child: InkWell(
      onTap: () => choose(i),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: PracticeVisual.lavender(context),
          borderRadius: PracticeVisual.promptRadius,
          border: Border.all(
            color: selected == i
                ? PracticeVisual.accent(context)
                : PracticeVisual.border(context),
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _prompts[i].icon.endsWith('.svg')
                        ? SvgPicture.asset(
                            _prompts[i].icon,
                            width: 30,
                            height: 30,
                          )
                        : Image.asset(_prompts[i].icon, width: 30, height: 30),
                    Text(_prompts[i].name, textAlign: TextAlign.center),
                    Text(
                      _prompts[i].subtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            if (selected == i)
              Positioned(
                top: 2,
                right: 2,
                child: Icon(
                  Icons.check,
                  size: 16,
                  color: PracticeVisual.accent(context),
                ),
              ),
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 368,
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.card == null ? 'Új kártya' : 'Kártya szerkesztése',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                onPressed: widget.onBack,
                tooltip: 'Bezárás',
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          if (widget.card?.sourceName != null)
            Text(
              widget.card!.sourceName!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          const SizedBox(height: 12),
          Text(
            selected == null
                ? 'Mit írnál magadnak?'
                : _prompts[selected!].question,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              color: PracticeVisual.field(context),
              borderRadius: PracticeVisual.fieldRadius,
            ),
            child: Stack(
              children: [
                Positioned(
                  right: 4,
                  bottom: 0,
                  child: Opacity(
                    opacity: .35,
                    child: Image.asset(
                      PracticeArtwork.forId(widget.card?.id ?? 2).image,
                      width: 65,
                      height: 65,
                    ),
                  ),
                ),
                TextField(
                  controller: text,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(14),
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () => setState(() => expanded = !expanded),
            icon: const Icon(Icons.lightbulb_outline),
            label: Row(
              children: [
                const Expanded(child: Text('Segíts elindulni')),
                Icon(expanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
          ),
          if (expanded) ...[
            for (var row = 0; row < 2; row++) ...[
              if (row > 0) const SizedBox(height: 6),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var col = 0; col < 2; col++) ...[
                      if (col > 0) const SizedBox(width: 6),
                      Expanded(child: _promptTile(context, row * 2 + col)),
                    ],
                  ],
                ),
              ),
            ],
            if (valid && !showTitle)
              TextButton(
                onPressed: () => setState(() => showTitle = true),
                child: const Text('Cím hozzáadása'),
              ),
            if (showTitle || title.text.isNotEmpty)
              TextField(
                controller: title,
                decoration: const InputDecoration(
                  labelText: 'Cím (opcionális)',
                ),
              ),
          ],
          const SizedBox(height: 12),
          FilledButton(
            onPressed: !valid || widget.controller.saving
                ? null
                : () => save(true),
            child: Text(widget.card == null ? 'Most ezt választom' : 'Mentés'),
          ),
          if (widget.card == null)
            TextButton(
              onPressed: !valid || widget.controller.saving
                  ? null
                  : () => save(false),
              child: const Text('Mentés későbbre'),
            ),
          if (widget.card != null) ...[
            TextButton(
              onPressed: widget.controller.saving ? null : remove,
              child: Text(
                'Kártya törlése',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: PracticeVisual.alert(context),
                ),
              ),
            ),
            TextButton(onPressed: widget.onBack, child: const Text('Mégsem')),
          ],
          if (widget.controller.error != null)
            const Text('A mentés nem sikerült. Próbáld újra.'),
        ],
      ),
    ),
  );
}
