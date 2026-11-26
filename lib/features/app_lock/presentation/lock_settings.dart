import 'package:flutter/material.dart';
import '../../../core/theme/hajnal_tokens.dart';
import '../../../core/brand/security_icons.dart';
import '../application/biometrics.dart';
import '../application/lock_controller.dart';
import '../application/lock_settings_coordinator.dart';
import '../domain/lock_mode.dart';
import 'lock_auth_page.dart';
import 'pin_setup.dart';

class LockSettingsPage extends StatefulWidget {
  const LockSettingsPage({super.key, required this.controller});
  final LockController controller;
  @override
  State<LockSettingsPage> createState() => _LockSettingsPageState();
}

class _LockSettingsPageState extends State<LockSettingsPage> {
  BiometricResult? availability;
  @override
  void initState() {
    super.initState();
    check();
  }

  Future<void> check() async {
    final result = await widget.controller.availability();
    if (mounted) setState(() => availability = result);
  }

  bool changing = false;
  Future<void> choose(LockMode target, {bool changePin = false}) async {
    if (changing) return;
    setState(() => changing = true);
    try {
      final c = widget.controller;
      final result = await LockSettingsCoordinator(c).change(
        target,
        changePin: changePin,
        authenticate: () async {
          if (!mounted) return false;
          return await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) =>
                      LockAuthPage(controller: c, reauthentication: true),
                ),
              ) ==
              true;
        },
        choosePin: () async {
          if (!mounted) return null;
          return Navigator.of(
            context,
          ).push<String>(MaterialPageRoute(builder: (_) => const PinSetup()));
        },
        confirmCombined: () async {
          if (!mounted) return false;
          return await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Mindkét azonosítás szükséges'),
                  content: const Text(
                    'Ha a biometria később nem érhető el, nem tudsz csak PIN-kóddal belépni.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Mégse'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Folytatás'),
                    ),
                  ],
                ),
              ) ==
              true;
        },
      );
      if (!mounted) return;
      if (result == SettingsResult.unavailable ||
          result == SettingsResult.failed) {
        final message = result == SettingsResult.unavailable
            ? 'A biometria nem érhető el, vagy nincs beállítva a telefonon.'
            : c.message ?? 'A beállítást nem sikerült menteni.';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => changing = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: HajnalColors.sheet,
    appBar: AppBar(
      backgroundColor: HajnalColors.sheet,
      foregroundColor: HajnalColors.navy,
      leading: Navigator.canPop(context) ? const HajnalBackButton() : null,
    ),
    body: SafeArea(
      child: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          final c = widget.controller;
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const SizedBox(height: 8),
              const Text(
                'Alkalmazászár',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 33,
                  fontWeight: FontWeight.w800,
                  color: HajnalColors.navy,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Te döntöd el, hogyan lépsz be.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, color: HajnalColors.navy),
              ),
              const SizedBox(height: 32),
              _card(LockMode.off, 'Kikapcsolva', 'Belépés azonosítás nélkül'),
              _card(LockMode.pin, 'Csak PIN', 'Legalább 6 számjegy'),
              _card(
                LockMode.biometricOrPin,
                'Biometria vagy PIN',
                'Ujjlenyomat vagy arcfelismerés',
              ),
              _card(
                LockMode.pinAndBiometric,
                'PIN és biometria',
                'Mindkettő szükséges',
              ),
              if (availability != null &&
                  availability != BiometricResult.success)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'A biometria nem érhető el, vagy nincs beállítva.',
                    style: TextStyle(color: HajnalColors.navy),
                  ),
                ),
              const SizedBox(height: 14),
              const Text(
                'Zárolás minden visszatéréskor.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: HajnalColors.navy),
              ),
              const SizedBox(height: 28),
              if (c.mode != LockMode.off)
                Card(
                  color: HajnalColors.card,
                  elevation: 2,
                  shadowColor: HajnalColors.cardShadow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(color: HajnalColors.keyBorder),
                  ),
                  child: ListTile(
                    minTileHeight: 72,
                    leading: const HajnalKeyIcon(),
                    title: const Text(
                      'PIN módosítása',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: HajnalColors.navy,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: HajnalColors.navy,
                    ),
                    onTap: c.busy || changing
                        ? null
                        : () => choose(c.mode, changePin: true),
                  ),
                ),
              const SizedBox(height: 30),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 18, color: HajnalColors.navy),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Az azonosítás a készülékeden történik.',
                      style: TextStyle(
                        color: HajnalColors.navy,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    ),
  );
  Widget _card(LockMode mode, String title, String description) {
    final selected = widget.controller.mode == mode;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Semantics(
        selected: selected,
        checked: selected,
        inMutuallyExclusiveGroup: true,
        button: true,
        child: Material(
          color: selected ? HajnalColors.selectedCard : HajnalColors.card,
          elevation: 2,
          shadowColor: HajnalColors.cardShadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: HajnalColors.keyBorder),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: widget.controller.busy || changing
                ? null
                : () => choose(mode),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: HajnalColors.navy,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 18,
                            color: HajnalColors.navy,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: HajnalColors.purple,
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
