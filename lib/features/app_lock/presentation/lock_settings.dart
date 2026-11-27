import 'package:flutter/material.dart';
import '../../../core/theme/hajnal_theme.dart';
import '../../../core/theme/hajnal_components.dart';
import '../../../core/theme/domain/style_roles.dart';
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
    backgroundColor: HajnalStyle.of(context).color('background'),
    appBar: AppBar(
      backgroundColor: HajnalStyle.of(context).color('background'),
      foregroundColor: HajnalStyle.of(context).color('primary'),
      leading: Navigator.canPop(context) ? const HajnalBackButton() : null,
    ),
    body: SafeArea(
      child: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          final c = widget.controller;
          return ListView(
            padding: EdgeInsets.symmetric(
              horizontal: HajnalStyle.of(context).spacing('margin'),
            ),
            children: [
              const SizedBox(height: 8),
              const HajnalHeading(
                title: 'Alkalmazászár',
                subtitle: 'Te döntöd el, hogyan lépsz be.',
              ),
              SizedBox(height: HajnalStyle.of(context).spacing('sectionGap')),
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
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'A biometria nem érhető el, vagy nincs beállítva.',
                    style: HajnalStyle.of(context).text(TextRole.helper),
                  ),
                ),
              const SizedBox(height: 14),
              Text(
                'Zárolás minden visszatéréskor.',
                textAlign: TextAlign.center,
                style: HajnalStyle.of(context).text(TextRole.body),
              ),
              const SizedBox(height: 28),
              if (c.mode != LockMode.off)
                HajnalNavigationRow(
                  label: 'PIN módosítása',
                  leading: const HajnalKeyIcon(),
                  onTap: c.busy || changing
                      ? null
                      : () => choose(c.mode, changePin: true),
                ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 18,
                    color: HajnalStyle.of(context).color('primary'),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Az azonosítás a készülékeden történik.',
                      style: HajnalStyle.of(context).text(TextRole.helper),
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
      padding: EdgeInsets.only(
        bottom: HajnalStyle.of(context).spacing('cardGap'),
      ),
      child: HajnalChoiceCard(
        title: title,
        subtitle: description,
        selected: selected,
        role: CardRole.large,
        onTap: widget.controller.busy || changing ? null : () => choose(mode),
      ),
    );
  }
}
