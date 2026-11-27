import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/theme/hajnal_theme.dart';
import '../../../core/theme/domain/style_roles.dart';
import '../../../core/theme/panic_visual.dart';
import '../application/panic_controller.dart';

Future<void> showPanicHelp(BuildContext context, PanicController controller) =>
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hívj fel valakit'),
        content: const Text('Nem indul automatikus hívás vagy üzenet.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bezárás'),
          ),
          FilledButton.icon(
            key: const Key('emergency-112'),
            onPressed: () async {
              final opened = await controller.callEmergency();
              if (!context.mounted || opened) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('A tárcsázó nem nyitható meg.')),
              );
            },
            icon: const Icon(Icons.phone),
            label: const Text('112 – Sürgősségi segítség'),
          ),
        ],
      ),
    );

Future<void> showMotivation(BuildContext context, PanicController controller) =>
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Miért kezdtem el?'),
        content: ListenableBuilder(
          listenable: controller,
          builder: (context, _) => SingleChildScrollView(
            child: Text(
              controller.motivationLoading
                  ? 'Emlékeztető betöltése…'
                  : controller.motivationFailed
                  ? 'Az emlékeztető nem tölthető be. Próbáld újra.'
                  : controller.motivation.trim().isEmpty
                  ? 'Írd le a saját emlékeztetődet az Onboarding menüben.'
                  : controller.motivation,
              style: HajnalStyle.of(context).text(TextRole.body),
            ),
          ),
        ),
        actions: [
          ListenableBuilder(
            listenable: controller,
            builder: (context, _) => controller.motivationFailed
                ? TextButton(
                    onPressed: controller.load,
                    child: const Text('Újrapróbálás'),
                  )
                : const SizedBox.shrink(),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bezárás'),
          ),
        ],
      ),
    );

class PanicPulse extends StatefulWidget {
  const PanicPulse({super.key, required this.onPressed});
  final VoidCallback onPressed;
  @override
  State<PanicPulse> createState() => _PanicPulseState();
}

class _PanicPulseState extends State<PanicPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      _controller.value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, child) => Transform.scale(
      scale: 1 + .085 * Curves.easeInOut.transform(_controller.value),
      child: child,
    ),
    child: SizedBox(
      width: math.max(146, MediaQuery.textScalerOf(context).scale(110)),
      height: math.max(146, MediaQuery.textScalerOf(context).scale(110)),
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          Positioned(
            left: -42,
            top: -42,
            right: -42,
            bottom: -42,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      PanicVisual.pink.withValues(alpha: .36),
                      PanicVisual.pink.withValues(alpha: .14),
                      PanicVisual.pink.withValues(alpha: 0),
                    ],
                    stops: const [0, .53, .8],
                  ),
                ),
              ),
            ),
          ),
          Material(
            shape: const CircleBorder(),
            color: PanicVisual.pink,
            child: InkWell(
              key: const Key('panic-help'),
              customBorder: const CircleBorder(),
              onTap: widget.onPressed,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.favorite_border,
                    color: PanicVisual.white,
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Segítség\nkell',
                    textAlign: TextAlign.center,
                    style: HajnalStyle.of(context)
                        .text(TextRole.cardTitle)
                        .copyWith(color: PanicVisual.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
