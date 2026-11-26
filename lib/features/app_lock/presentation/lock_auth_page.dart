import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/brand/brand_assets.dart';
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SvgPicture.asset(
                      BrandAssets.logo,
                      width: 110,
                      height: 110,
                      semanticsLabel: 'Hajnal',
                    ),
                    const Text(
                      'Jó, hogy itt vagy.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: HajnalColors.navy,
                      ),
                    ),
                    const Text(
                      'Oldd fel a Hajnalt a folytatáshoz.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: HajnalColors.navy),
                    ),
                    if (mode == LockMode.pinAndBiometric)
                      Card(
                        color: HajnalColors.card,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              _step(Icons.check_circle, '1. PIN ellenőrizve'),
                              const SizedBox(height: 20),
                              _step(
                                Icons.radio_button_checked,
                                '2. Biometrikus azonosítás',
                              ),
                            ],
                          ),
                        ),
                      ),
                    const Icon(
                      Icons.fingerprint,
                      size: 104,
                      color: HajnalColors.purple,
                    ),
                    const Text(
                      'Folytasd a telefonod azonosítójával.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: HajnalColors.navy),
                    ),
                    if (controller.message != null)
                      Text(
                        controller.message!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: HajnalColors.navy),
                      ),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
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
                            fontSize: 19,
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
                    const Text(
                      'A rendszer saját ablaka nyílik meg.',
                      style: TextStyle(color: HajnalColors.navy),
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
  Widget _step(IconData icon, String label) => Row(
    children: [
      Icon(icon, color: HajnalColors.purple),
      const SizedBox(width: 16),
      Expanded(
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: HajnalColors.navy,
          ),
        ),
      ),
    ],
  );
}
