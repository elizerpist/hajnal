import 'package:flutter/material.dart';
import '../../../core/theme/hajnal_tokens.dart';

class PinPad extends StatefulWidget {
  const PinPad({
    super.key,
    required this.title,
    required this.subtitle,
    required this.button,
    required this.onSubmit,
    this.header,
    this.step,
    this.message,
    this.busy = false,
    this.footer,
  });
  final String title, subtitle, button;
  final String? header, step, message, footer;
  final bool busy;
  final ValueChanged<String> onSubmit;
  @override
  State<PinPad> createState() => _PinPadState();
}

class _PinPadState extends State<PinPad> {
  String value = '';
  void add(String digit) {
    if (!widget.busy) setState(() => value += digit);
  }

  void erase() {
    if (!widget.busy && value.isNotEmpty) {
      setState(() => value = value.substring(0, value.length - 1));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: HajnalColors.sheet,
    appBar: widget.header == null
        ? null
        : AppBar(
            backgroundColor: HajnalColors.sheet,
            foregroundColor: HajnalColors.navy,
            title: Text(
              widget.header!,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            actions: [
              if (widget.step != null)
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Chip(
                    label: Text(widget.step!),
                    backgroundColor: HajnalColors.selectedCard,
                    side: BorderSide.none,
                  ),
                ),
            ],
          ),
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 54,
                  color: HajnalColors.navy,
                ),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: HajnalColors.navy,
                  ),
                ),
                Text(
                  widget.subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    color: HajnalColors.navy,
                  ),
                ),
                Semantics(
                  label: 'PIN-kód, ${value.length} számjegy',
                  child: SizedBox(
                    height: 72,
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            value.length.clamp(6, 20),
                            (i) => Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                              ),
                              child: Icon(
                                i < value.length
                                    ? Icons.circle
                                    : Icons.circle_outlined,
                                size: 18,
                                color: HajnalColors.purple,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(width: 276, height: 1, color: HajnalColors.keyBorder),
                if (widget.message != null)
                  Text(
                    widget.message!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: HajnalColors.navy),
                  ),
                GridView(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisExtent: 70,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for (final digit in [
                      '1',
                      '2',
                      '3',
                      '4',
                      '5',
                      '6',
                      '7',
                      '8',
                      '9',
                    ])
                      _key(digit, () => add(digit)),
                    ExcludeSemantics(child: _key('', null)),
                    _key('0', () => add('0')),
                    _key('Törlés', erase, icon: Icons.backspace_outlined),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: FilledButton(
                    onPressed: widget.busy || value.length < 6
                        ? null
                        : () => widget.onSubmit(value),
                    style: FilledButton.styleFrom(
                      backgroundColor: HajnalColors.purple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      widget.button,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                if (widget.footer != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      widget.footer!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: HajnalColors.navy,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Widget _key(String label, VoidCallback? onTap, {IconData? icon}) => Semantics(
    button: true,
    label: label,
    child: OutlinedButton(
      onPressed: widget.busy ? null : onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: HajnalColors.keyboardSurface,
        disabledBackgroundColor: HajnalColors.keyboardSurface,
        elevation: 2,
        shadowColor: HajnalColors.cardShadow,
        side: const BorderSide(color: HajnalColors.keyBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
        foregroundColor: HajnalColors.navy,
        minimumSize: const Size(48, 48),
      ),
      child: icon == null
          ? Text(
              label,
              style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w600),
            )
          : Icon(icon, size: 28),
    ),
  );
}
