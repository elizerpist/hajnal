import 'package:flutter/material.dart';
import '../../../core/artwork/practice_artwork.dart';
import '../../../core/theme/practice_visual.dart';
import '../application/practice_controller.dart';
import '../application/practice_store.dart';
import 'practice_editor.dart';

class PracticeManager extends StatefulWidget {
  const PracticeManager({super.key, required this.controller});
  final PracticeController controller;
  @override
  State<PracticeManager> createState() => _PracticeManagerState();
}

class _PracticeManagerState extends State<PracticeManager> {
  PracticeCard? editing;
  bool editor = false;
  void edit([PracticeCard? card]) => setState(() {
    editing = card;
    editor = true;
  });
  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: PracticeVisual.background(context),
    shape: PracticeVisual.popupShape,
    insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 19),
    child: AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        if (editor) {
          return PracticeEditor(
            key: ValueKey(editing?.id ?? 0),
            controller: widget.controller,
            card: editing,
            onBack: () => setState(() => editor = false),
          );
        }
        final active = widget.controller.active;
        final others = widget.controller.cards
            .where((c) => c.id != active?.id)
            .toList();
        return SizedBox(
          width: 368,
          height: 784,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact =
                  constraints.maxHeight < 650 ||
                  MediaQuery.textScalerOf(context).scale(1) > 1.2;
              final contents = Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 17),
                child: Column(
                  mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ezt szeretném gyakorolni',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: PracticeVisual.ink(context),
                                    ),
                              ),
                              Text(
                                'Válassz a kártyáid közül, vagy hozz létre újat.',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: PracticeVisual.muted(context),
                                    ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          tooltip: 'Bezárás',
                          style: PracticeVisual.iconButton(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Material(
                      color: PracticeVisual.lavender(context),
                      borderRadius: PracticeVisual.activeRadius,
                      child: InkWell(
                        borderRadius: PracticeVisual.activeRadius,
                        onTap: active == null ? null : () => edit(active),
                        child: Padding(
                          padding: const EdgeInsets.all(9),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 72),
                            child: Row(
                              children: [
                                _Artwork(id: active?.id ?? 0),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'MOST GYAKORLOM',
                                        style: PracticeVisual.label(context),
                                      ),
                                      Text(
                                        active?.label ??
                                            'Most nincs aktív gyakorlatod.',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: PracticeVisual.cardTitle(
                                          context,
                                        ),
                                      ),
                                      Text(
                                        active?.sourceName ??
                                            (active == null
                                                ? 'Válassz egyet a kártyáid közül.'
                                                : 'Saját kártya'),
                                        style: PracticeVisual.caption(context),
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
                    const SizedBox(height: 12),
                    Text(
                      'Kártyáim',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: PracticeVisual.ink(context),
                      ),
                    ),
                    const SizedBox(height: 7),
                    if (compact && others.isEmpty)
                      const Text('Még nincs további kártyád.'),
                    if (!compact || others.isNotEmpty)
                      Flexible(
                        fit: compact ? FlexFit.loose : FlexFit.tight,
                        child: others.isEmpty
                            ? const Text('Még nincs további kártyád.')
                            : ListView.separated(
                                shrinkWrap: compact,
                                physics: compact
                                    ? const NeverScrollableScrollPhysics()
                                    : null,
                                padding: EdgeInsets.zero,
                                itemCount: others.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 7),
                                itemBuilder: (context, i) {
                                  final card = others[i];
                                  return DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: PracticeVisual.background(context),
                                      borderRadius: PracticeVisual.rowRadius,
                                      border: Border.all(
                                        color: PracticeVisual.border(context),
                                      ),
                                    ),
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        minHeight: 72,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: InkWell(
                                              onTap: () => edit(card),
                                              borderRadius:
                                                  PracticeVisual.rowRadius,
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  7,
                                                ),
                                                child: Row(
                                                  children: [
                                                    _Artwork(id: card.id),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            card.label,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                PracticeVisual.cardTitle(
                                                                  context,
                                                                ),
                                                          ),
                                                          Text(
                                                            card.sourceName ??
                                                                'Saját kártya',
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                PracticeVisual.caption(
                                                                  context,
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
                                          IconButton(
                                            tooltip: '${card.label} aktiválása',
                                            style: PracticeVisual.iconButton(
                                              context,
                                            ),
                                            onPressed: widget.controller.saving
                                                ? null
                                                : () => widget.controller
                                                      .activate(card.id),
                                            icon: Icon(
                                              Icons.chevron_right,
                                              color: PracticeVisual.accent(
                                                context,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    if (widget.controller.error != null)
                      const Text('A művelet nem sikerült. Próbáld újra.'),
                    const SizedBox(height: 7),
                    FilledButton.tonal(
                      style: PracticeVisual.addButton(context),
                      onPressed: () => edit(),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Új kártya hozzáadása',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Icon(
                      Icons.spa_outlined,
                      color: PracticeVisual.accent(context),
                      size: 24,
                    ),
                    Text(
                      'Tiszta gondolatok. Derűsebb holnap.',
                      textAlign: TextAlign.center,
                      style: PracticeVisual.footer(context),
                    ),
                  ],
                ),
              );
              return compact
                  ? SingleChildScrollView(child: contents)
                  : contents;
            },
          ),
        );
      },
    ),
  );
}

class _Artwork extends StatelessWidget {
  const _Artwork({required this.id});
  final int id;
  @override
  Widget build(BuildContext context) => Container(
    width: 52,
    height: 52,
    decoration: BoxDecoration(
      color: PracticeVisual.artworkSurface(context, id),
      shape: BoxShape.circle,
    ),
    child: Image.asset(PracticeArtwork.forId(id).image, width: 44, height: 44),
  );
}
