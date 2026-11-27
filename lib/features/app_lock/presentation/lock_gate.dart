import 'package:flutter/material.dart';
import '../../../core/theme/hajnal_theme.dart';
import '../application/lock_controller.dart';
import 'lock_auth_page.dart';

class LockGate extends StatelessWidget {
  const LockGate({super.key, required this.controller, required this.child});
  final LockController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final hidden = controller.locked || controller.obscured;
      return Stack(
        fit: StackFit.expand,
        children: [
          Offstage(
            offstage: hidden,
            child: ExcludeSemantics(excluding: hidden, child: child),
          ),
          if (hidden)
            ColoredBox(
              color: HajnalStyle.of(context).color('background'),
              child: controller.obscured || controller.loading
                  ? const Center(child: CircularProgressIndicator())
                  : controller.error
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('A zárolási adatok nem olvashatók.'),
                          TextButton(
                            onPressed: controller.initialize,
                            child: const Text('Újrapróbálás'),
                          ),
                        ],
                      ),
                    )
                  : LockAuthPage(controller: controller),
            ),
        ],
      );
    },
  );
}
