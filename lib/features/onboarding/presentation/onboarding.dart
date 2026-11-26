import 'package:flutter/material.dart';
import '../../../app/bootstrap_controller.dart';
import '../application/date_picker.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key, required this.controller, required this.picker});
  final BootstrapController controller;
  final DatePicker picker;
  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  late DateTime date;
  late final int? periodId;
  String? error;
  bool picking = false;

  @override
  void initState() {
    super.initState();
    final period = widget.controller.activePeriod;
    periodId = period?.id;
    date = period?.startDate ?? DateTime.now();
  }

  Future<void> choose() async {
    if (picking) return;
    setState(() => picking = true);
    final result = await widget.picker.pick(date, DateTime.now());
    if (!mounted) return;
    setState(() {
      picking = false;
      switch (result) {
        case DatePicked(:final date):
          this.date = date;
          error = null;
        case DatePickFailed(:final message):
          error = message;
        case DatePickCancelled():
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Kezdődátum')),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Mikor kezdődött a jelenlegi tiszta időszakod?',
              style: TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 24),
            Text(
              '${date.year}. ${date.month.toString().padLeft(2, '0')}. ${date.day.toString().padLeft(2, '0')}.',
            ),
            TextButton(
              onPressed: picking ? null : choose,
              child: const Text('Dátum kiválasztása'),
            ),
            if (error != null) Text(error!),
            const Spacer(),
            ListenableBuilder(
              listenable: widget.controller,
              builder: (context, _) => FilledButton(
                onPressed: widget.controller.saving
                    ? null
                    : () async {
                        final id = periodId;
                        final success = id == null
                            ? await widget.controller.initialize(date)
                            : await widget.controller.correctStart(id, date);
                        if (!context.mounted) return;
                        if (success) {
                          Navigator.of(context).pop();
                        } else {
                          setState(
                            () =>
                                error = 'A mentés nem sikerült. Próbáld újra.',
                          );
                        }
                      },
                child: const Text('Mentés'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
