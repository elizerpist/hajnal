import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/artwork/artwork_catalog.dart';
import '../../../core/theme/hajnal_theme.dart';
import '../../../core/theme/domain/style_roles.dart';
import '../../../core/theme/panic_visual.dart';
import '../application/panic_controller.dart';

class RelapsePage extends StatelessWidget {
  const RelapsePage({
    super.key,
    required this.controller,
    required this.activeId,
  });
  final PanicController controller;
  final int? activeId;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: PanicVisual.background,
    body: Stack(
      fit: StackFit.expand,
      children: [
        SvgPicture.asset(
          relapseArtwork,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                PanicVisual.background.withValues(alpha: .3),
                PanicVisual.background.withValues(alpha: .58),
                PanicVisual.background.withValues(alpha: .94),
              ],
            ),
          ),
        ),
        SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            tooltip: 'Vissza a Pánik módhoz',
                            icon: const Icon(
                              Icons.arrow_back,
                              color: PanicVisual.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 80),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 45),
                        child: Text(
                          'Köszönjük,\nhogy őszinte voltál.\n\nHolnap újra\nindulhatunk.',
                          textAlign: TextAlign.center,
                          style: HajnalStyle.of(context)
                              .text(TextRole.title1)
                              .copyWith(color: PanicVisual.white),
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(34, 0, 34, 25),
                        child: ListenableBuilder(
                          listenable: controller,
                          builder: (context, _) => Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (controller.error != null)
                                Text(
                                  'Az újrakezdés nem sikerült. Próbáld újra.',
                                  style: HajnalStyle.of(context)
                                      .text(TextRole.helper)
                                      .copyWith(color: PanicVisual.white),
                                ),
                              FilledButton(
                                key: const Key('restart-recovery'),
                                onPressed: controller.busy
                                    ? null
                                    : () async {
                                        if (await controller.restart(
                                              activeId,
                                            ) &&
                                            context.mounted) {
                                          Navigator.of(
                                            context,
                                          ).popUntil((route) => route.isFirst);
                                        }
                                      },
                                child: const Text('Újrakezdem'),
                              ),
                              const SizedBox(height: 11),
                              OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Segítséget kérek'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
