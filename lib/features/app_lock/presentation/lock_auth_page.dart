import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/brand/brand_assets.dart';
import '../../../core/brand/fingerprint_icon.dart';
import '../../../core/theme/hajnal_tokens.dart';
import '../application/lock_controller.dart';
import '../domain/lock_mode.dart';
import 'pin_pad.dart';

class LockAuthPage extends StatefulWidget {
  const LockAuthPage({
    super.key,
    required this.controller,
    this.reauthentication = false,
  });
  final LockController controller;
  final bool reauthentication;
  @override
  State<LockAuthPage> createState() => _LockAuthPageState();
}

class _LockAuthPageState extends State<LockAuthPage> {
  bool usePin = false;
  Future<void> pin(String value) async {
    final success = await widget.controller.submitPin(
      value,
      reauthentication: widget.reauthentication,
    );
    if (mounted && success && widget.reauthentication) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> bio() async {
    final success = await widget.controller.submitBiometric(
      reauthentication: widget.reauthentication,
    );
    if (mounted && success && widget.reauthentication) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) {
      final controller = widget.controller;
      final mode = controller.mode;
      final hasPin = widget.reauthentication
          ? controller.reauthPinVerified
          : controller.pinVerified;
      final showPin =
          mode == LockMode.pin ||
          (mode == LockMode.pinAndBiometric && !hasPin) ||
          (mode == LockMode.biometricOrPin && usePin);
      if (showPin) {
        return PinPad(
          header: widget.reauthentication ? 'Azonosítás' : null,
          title: 'Add meg a PIN-kódod',
          subtitle: 'Oldd fel a Hajnalt a folytatáshoz.',
          button: 'Feloldás',
          footer: 'Elfelejtett PIN-kódhoz jelenleg nincs helyreállítás.',
          message: controller.message,
          busy: controller.busy,
          onSubmit: pin,
        );
      }
      return Scaffold(
        backgroundColor: HajnalColors.sheet,
        appBar: widget.reauthentication
            ? AppBar(backgroundColor: HajnalColors.sheet)
            : null,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    // Spacers preserve the reference's relative vertical gaps.
                    children: [
                      const Spacer(flex: 36),
                      SvgPicture.asset(
                        BrandAssets.logo,
                        width: 140,
                        height: 140,
                        semanticsLabel: 'Hajnal',
                      ),
                      const Spacer(flex: 22),
                      const Text(
                        'Jó, hogy itt vagy.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: HajnalColors.navy,
                        ),
                      ),
                      const Spacer(flex: 9),
                      const Text(
                        'Oldd fel a Hajnalt a folytatáshoz.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          color: HajnalColors.navy,
                        ),
                      ),
                      const Spacer(flex: 30),
                      if (mode == LockMode.pinAndBiometric)
                        Card(
                          color: HajnalColors.card,
                          elevation: 2,
                          shadowColor: HajnalColors.cardShadow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: const BorderSide(
                              color: HajnalColors.keyBorder,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 22,
                            ),
                            child: Column(
                              children: [
                                _step(Icons.check_circle, '1. PIN ellenőrizve'),
                                const SizedBox(
                                  height: 28,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 32,
                                        child: Center(
                                          child: VerticalDivider(
                                            width: 1,
                                            thickness: 1,
                                            color: HajnalColors.purple,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _step(
                                  Icons.radio_button_checked,
                                  '2. Biometrikus azonosítás',
                                ),
                              ],
                            ),
                          ),
                        ),
                      const Spacer(flex: 36),
                      const HajnalFingerprint(),
                      const Spacer(flex: 19),
                      const Text(
                        'Folytasd a telefonod azonosítójával.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          color: HajnalColors.navy,
                        ),
                      ),
                      if (controller.message != null)
                        Text(
                          controller.message!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: HajnalColors.navy),
                        ),
                      const Spacer(flex: 56),
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: FilledButton(
                          onPressed: controller.busy ? null : bio,
                          style: FilledButton.styleFrom(
                            backgroundColor: HajnalColors.purple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Azonosítás indítása',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      if (mode == LockMode.biometricOrPin)
                        TextButton(
                          onPressed: controller.busy
                              ? null
                              : () => setState(() => usePin = true),
                          child: const Text('PIN használata'),
                        ),
                      const Spacer(flex: 13),
                      const Text(
                        'A rendszer saját ablaka nyílik meg.',
                        style: TextStyle(
                          fontSize: 16,
                          color: HajnalColors.navy,
                        ),
                      ),
                      const Spacer(flex: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
  Widget _step(IconData icon, String label) => Row(
    children: [
      Icon(icon, color: HajnalColors.purple, size: 32),
      const SizedBox(width: 20),
      Expanded(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: HajnalColors.navy,
          ),
        ),
      ),
    ],
  );
}
