import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/brand/brand_assets.dart';
import '../../../core/brand/fingerprint_icon.dart';
import '../../../core/theme/hajnal_theme.dart';
import '../../../core/theme/hajnal_components.dart';
import '../../../core/theme/domain/style_roles.dart';
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
        backgroundColor: HajnalStyle.of(context).color('background'),
        appBar: widget.reauthentication
            ? AppBar(
                backgroundColor: HajnalStyle.of(context).color('background'),
              )
            : null,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: HajnalStyle.of(context).spacing('margin'),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    // Spacers preserve the reference's relative vertical gaps.
                    children: [
                      const Spacer(flex: 41),
                      SvgPicture.asset(
                        BrandAssets.logo,
                        width: 140,
                        height: 140,
                        semanticsLabel: 'Hajnal',
                      ),
                      const Spacer(flex: 15),
                      const HajnalHeading(
                        title: 'Jó, hogy itt vagy.',
                        subtitle: 'Oldd fel a Hajnalt a folytatáshoz.',
                      ),
                      const Spacer(flex: 30),
                      if (mode == LockMode.pinAndBiometric)
                        HajnalCard(
                          child: Column(
                            children: [
                              _step(Icons.check_circle, '1. PIN ellenőrizve'),
                              const SizedBox(height: 28),
                              _step(
                                Icons.radio_button_checked,
                                '2. Biometrikus azonosítás',
                              ),
                            ],
                          ),
                        ),
                      const Spacer(flex: 25),
                      const HajnalFingerprint(),
                      const Spacer(flex: 8),
                      Text(
                        'Folytasd a telefonod azonosítójával.',
                        textAlign: TextAlign.center,
                        style: HajnalStyle.of(context).text(TextRole.body),
                      ),
                      if (controller.message != null)
                        Text(
                          controller.message!,
                          textAlign: TextAlign.center,
                          style: HajnalStyle.of(context).text(TextRole.body),
                        ),
                      const Spacer(flex: 59),
                      HajnalAction(
                        label: 'Azonosítás indítása',
                        onPressed: controller.busy ? null : bio,
                      ),
                      if (mode == LockMode.biometricOrPin)
                        TextButton(
                          onPressed: controller.busy
                              ? null
                              : () => setState(() => usePin = true),
                          child: const Text('PIN használata'),
                        ),
                      const Spacer(flex: 20),
                      Text(
                        'A rendszer saját ablaka nyílik meg.',
                        style: HajnalStyle.of(context).text(TextRole.helper),
                      ),
                      const Spacer(flex: 21),
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
      Icon(icon, color: HajnalStyle.of(context).color('accent'), size: 32),
      const SizedBox(width: 20),
      Expanded(
        child: Text(
          label,
          style: HajnalStyle.of(context).text(TextRole.cardTitle),
        ),
      ),
    ],
  );
}
