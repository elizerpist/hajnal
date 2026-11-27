import 'package:flutter/material.dart';
import '../../../core/brand/security_icons.dart';
import '../../../core/theme/hajnal_theme.dart';
import '../../../core/theme/hajnal_components.dart';
import '../../../core/theme/domain/style_roles.dart';

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
    backgroundColor: HajnalStyle.of(context).color('background'),
    appBar: widget.header == null
        ? null
        : AppBar(
            toolbarHeight: 76,
            backgroundColor: HajnalStyle.of(context).color('background'),
            foregroundColor: HajnalStyle.of(context).color('primary'),
            leading: Navigator.canPop(context)
                ? const HajnalBackButton()
                : null,
            title: Text(
              widget.header!,
              style: HajnalStyle.of(context).text(TextRole.cardTitle),
            ),
            actions: [
              if (widget.step != null)
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Chip(
                    label: Text(widget.step!),
                    backgroundColor: HajnalStyle.of(context).color('selected'),
                    shape: const StadiumBorder(),
                    side: BorderSide.none,
                  ),
                ),
            ],
          ),
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: HajnalStyle.of(context).spacing('margin'),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(height: widget.header == null ? 30 : 14),
                const HajnalLockIcon(),
                SizedBox(height: widget.header == null ? 12 : 8),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: HajnalStyle.of(context).text(TextRole.title1),
                ),
                Text(
                  widget.subtitle,
                  textAlign: TextAlign.center,
                  style: HajnalStyle.of(context).text(TextRole.title2),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 11),
                  child: Semantics(
                    label: 'PIN-kód, ${value.length} számjegy',
                    child: SizedBox(
                      height: 54,
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                              value.length.clamp(6, 20),
                              (i) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                ),
                                child: Icon(
                                  i < value.length
                                      ? Icons.circle
                                      : Icons.circle_outlined,
                                  size: 22,
                                  color: HajnalStyle.of(
                                    context,
                                  ).color('accent'),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 276,
                  height: 1,
                  color: HajnalStyle.of(context).color('border'),
                ),
                const SizedBox(height: 21),
                if (widget.message != null)
                  Text(
                    widget.message!,
                    textAlign: TextAlign.center,
                    style: HajnalStyle.of(context).text(TextRole.body),
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
                const SizedBox(height: 23),
                HajnalAction(
                  label: widget.button,
                  onPressed: widget.busy || value.length < 6
                      ? null
                      : () => widget.onSubmit(value),
                ),
                if (widget.footer != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Text(
                      widget.footer!,
                      textAlign: TextAlign.center,
                      style: HajnalStyle.of(context).text(TextRole.helper),
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
      style: HajnalStyle.of(context).button(ButtonRole.secondary),
      child: icon == null
          ? Text(label, style: HajnalStyle.of(context).text(TextRole.pinDigit))
          : Icon(icon, size: 28),
    ),
  );
}
