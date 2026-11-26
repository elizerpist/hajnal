import 'package:flutter/material.dart';
import 'pin_pad.dart';

class PinSetup extends StatefulWidget {
  const PinSetup({super.key});
  @override
  State<PinSetup> createState() => _PinSetupState();
}

class _PinSetupState extends State<PinSetup> {
  String? first;
  String? error;
  int revision = 0;

  void submit(String value) {
    if (first == null) {
      setState(() {
        first = value;
        error = null;
        revision++;
      });
    } else if (first != value) {
      setState(() {
        first = null;
        error = 'A két PIN-kód nem egyezik. Próbáld újra.';
        revision++;
      });
    } else {
      Navigator.of(context).pop(value);
    }
  }

  @override
  Widget build(BuildContext context) => PinPad(
    key: ValueKey(revision),
    header: 'PIN beállítása',
    step: first == null ? '1 / 2' : '2 / 2',
    title: first == null ? 'Válassz PIN-kódot' : 'Ismételd meg a PIN-kódot',
    subtitle: 'Legalább 6 számjegyet adj meg.',
    button: 'Tovább',
    footer: first == null ? 'A következő lépésben ismételd meg.' : null,
    message: error,
    onSubmit: submit,
  );
}
