import 'package:flutter/material.dart';
import 'domain/style_roles.dart';
import 'hajnal_theme.dart';

class HajnalHeading extends StatelessWidget {
  const HajnalHeading({super.key, required this.title, this.subtitle});
  final String title;
  final String? subtitle;
  @override
  Widget build(BuildContext context) {
    final theme = HajnalStyle.of(context);
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.text(TextRole.title1),
        ),
        if (subtitle != null) ...[
          SizedBox(height: theme.spacing('titleGap')),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: theme.text(TextRole.title2),
          ),
        ],
      ],
    );
  }
}

class HajnalCard extends StatelessWidget {
  const HajnalCard({
    super.key,
    required this.child,
    this.role = CardRole.content,
    this.selected = false,
  });
  final Widget child;
  final CardRole role;
  final bool selected;
  @override
  Widget build(BuildContext context) {
    final style = HajnalStyle.of(context);
    final spec = style.definitions.cards[role]!;
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: double.infinity,
        minHeight: spec.minHeight,
      ),
      child: Ink(
        padding: EdgeInsets.symmetric(
          horizontal: spec.paddingX,
          vertical: spec.paddingY,
        ),
        decoration: style.card(role, selected: selected),
        child: child,
      ),
    );
  }
}

class HajnalChoiceCard extends StatelessWidget {
  const HajnalChoiceCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.selected,
    required this.onTap,
    this.multiple = false,
    this.role = CardRole.large,
  });
  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool selected, multiple;
  final VoidCallback? onTap;
  final CardRole role;
  @override
  Widget build(BuildContext context) {
    final s = HajnalStyle.of(context);
    return Semantics(
      button: true,
      selected: selected,
      checked: selected,
      inMutuallyExclusiveGroup: !multiple,
      enabled: onTap != null,
      child: Opacity(
        opacity: onTap == null ? .55 : 1,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(
              s.definitions.cards[role]!.radius,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: s.spacing('touch')),
              child: HajnalCard(
                role: role,
                selected: selected,
                child: Row(
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: s.color('accent')),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: s.text(TextRole.cardTitle)),
                          if (subtitle != null)
                            Text(
                              subtitle!,
                              style: s.text(TextRole.cardSubtitle),
                            ),
                        ],
                      ),
                    ),
                    Icon(
                      multiple
                          ? (selected
                                ? Icons.check_box
                                : Icons.check_box_outline_blank)
                          : (selected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked),
                      color: s.color('accent'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HajnalAction extends StatelessWidget {
  const HajnalAction({
    super.key,
    required this.label,
    required this.onPressed,
    this.role = ButtonRole.primary,
  });
  final String label;
  final VoidCallback? onPressed;
  final ButtonRole role;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: FilledButton(
      style: HajnalStyle.of(context).button(role),
      onPressed: onPressed,
      child: Text(label, textAlign: TextAlign.center),
    ),
  );
}

class HajnalNavigationRow extends StatelessWidget {
  const HajnalNavigationRow({
    super.key,
    required this.label,
    required this.onTap,
    this.leading,
  });
  final String label;
  final VoidCallback? onTap;
  final Widget? leading;
  @override
  Widget build(BuildContext context) {
    final style = HajnalStyle.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          style.definitions.cards[CardRole.small]!.radius,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: style.spacing('touch')),
          child: HajnalCard(
            role: CardRole.small,
            child: Row(
              children: [
                if (leading != null) ...[
                  leading!,
                  SizedBox(width: style.spacing('cardGap')),
                ],
                Expanded(
                  child: Text(label, style: style.text(TextRole.cardTitle)),
                ),
                Icon(Icons.chevron_right, color: style.color('primary')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HajnalNavigationIcon extends StatelessWidget {
  const HajnalNavigationIcon({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.overArtwork = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool overArtwork;
  @override
  Widget build(BuildContext context) {
    final s = HajnalStyle.of(context);
    return IconButton(
      tooltip: label,
      onPressed: onPressed,
      icon: Icon(icon),
      style: ButtonStyle(
        minimumSize: WidgetStatePropertyAll(Size.square(s.spacing('touch'))),
        backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => s
              .color(overArtwork ? 'artworkIcon' : 'primary')
              .withValues(
                alpha:
                    s.color(overArtwork ? 'artworkIcon' : 'primary').a *
                    (states.contains(WidgetState.pressed) ? .6 : 1),
              ),
        ),
      ),
    );
  }
}
