import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/artwork/artwork_catalog.dart';
import '../../../core/theme/hajnal_theme.dart';
import '../../../core/theme/domain/style_roles.dart';
import '../../../core/theme/panic_visual.dart';
import '../application/panic_controller.dart';
import 'panic_dialogs.dart';
import 'relapse_page.dart';
import 'survival_page.dart';

class PanicPage extends StatefulWidget {
  const PanicPage({super.key, required this.controller});
  final PanicController controller;
  @override
  State<PanicPage> createState() => _PanicPageState();
}

class _PanicPageState extends State<PanicPage> {
  bool _survivalOpen = false;
  @override
  void initState() {
    super.initState();
    unawaited(widget.controller.load());
  }

  Future<void> _openSurvival() async {
    if (_survivalOpen) return;
    _survivalOpen = true;
    final flow = widget.controller.createSurvival();
    try {
      await Navigator.push<void>(
        context,
        MaterialPageRoute(
          builder: (_) =>
              SurvivalPage(controller: flow, panic: widget.controller),
        ),
      );
    } finally {
      await flow.idle;
      _survivalOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = HajnalStyle.of(context);
    return Scaffold(
      backgroundColor: PanicVisual.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            panicArtwork,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      color: PanicVisual.white,
                      tooltip: 'Vissza a főmenübe',
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                    child: Column(
                      children: [
                        Text(
                          'Nem vagy egyedül.',
                          textAlign: TextAlign.center,
                          style: style
                              .text(TextRole.title1)
                              .copyWith(color: PanicVisual.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Most csak a következő néhány perc számít.',
                          textAlign: TextAlign.center,
                          style: style
                              .text(TextRole.helper)
                              .copyWith(color: PanicVisual.white),
                        ),
                        const SizedBox(height: 18),
                        PanicPulse(
                          onPressed: () =>
                              showPanicHelp(context, widget.controller),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Alatta minden gyors opció külön, nyugodt lépésként indul.',
                          textAlign: TextAlign.center,
                          style: style
                              .text(TextRole.helper)
                              .copyWith(color: PanicVisual.white),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _PanicAction(
                                label: '15 perces\ntúlélőcsomag',
                                icon: Icons.route_outlined,
                                onTap: _openSurvival,
                              ),
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: _PanicAction(
                                label: 'Visszaestem',
                                icon: Icons.favorite_border,
                                onTap: () {
                                  final id = widget.controller.activeId();
                                  Navigator.push<void>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => RelapsePage(
                                        controller: widget.controller,
                                        activeId: id,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ListenableBuilder(
                          listenable: widget.controller,
                          builder: (context, _) => Material(
                            color: PanicVisual.white.withValues(alpha: .14),
                            borderRadius: PanicVisual.corner,
                            child: InkWell(
                              borderRadius: PanicVisual.corner,
                              onTap: () =>
                                  showMotivation(context, widget.controller),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.favorite_border,
                                      color: PanicVisual.white,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Miért kezdtem el?',
                                            style: style
                                                .text(TextRole.cardTitle)
                                                .copyWith(
                                                  color: PanicVisual.white,
                                                ),
                                          ),
                                          Text(
                                            widget.controller.motivationLoading
                                                ? 'Emlékeztető betöltése…'
                                                : widget
                                                      .controller
                                                      .motivationFailed
                                                ? 'Az emlékeztető nem tölthető be.'
                                                : widget.controller.motivation
                                                      .trim()
                                                      .isEmpty
                                                ? 'Írd le, miért fontos neked a felépülés.'
                                                : widget.controller.motivation,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: style
                                                .text(TextRole.helper)
                                                .copyWith(
                                                  color: PanicVisual.white,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: PanicVisual.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PanicAction extends StatelessWidget {
  const _PanicAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: PanicVisual.white.withValues(alpha: .10),
    borderRadius: PanicVisual.corner,
    child: InkWell(
      onTap: onTap,
      borderRadius: PanicVisual.corner,
      child: Container(
        constraints: const BoxConstraints(minHeight: 94),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: PanicVisual.white),
            const SizedBox(height: 7),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: HajnalStyle.of(
                context,
              ).text(TextRole.helper).copyWith(color: PanicVisual.white),
            ),
          ],
        ),
      ),
    ),
  );
}
