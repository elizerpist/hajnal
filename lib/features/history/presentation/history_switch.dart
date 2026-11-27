import 'package:flutter/material.dart';
import '../../../core/theme/domain/style_roles.dart';
import '../../../core/theme/hajnal_theme.dart';
import '../../../core/theme/history_visual.dart';

class HistorySwitch extends StatelessWidget {
  const HistorySwitch({
    super.key,
    required this.firstLabel,
    required this.secondLabel,
    required this.secondSelected,
    required this.onChanged,
    this.firstIcon,
    this.secondIcon,
  });
  final String firstLabel, secondLabel;
  final bool secondSelected;
  final ValueChanged<bool> onChanged;
  final IconData? firstIcon, secondIcon;

  @override
  Widget build(BuildContext context) {
    final style = HajnalStyle.of(context);
    final scale = MediaQuery.textScalerOf(context).scale(1);
    final textScale = scale < 1 ? 1.0 : scale;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: style.color('surface').withValues(alpha: .9),
        borderRadius: HistoryVisual.switchCorner,
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in [
              (false, firstLabel, firstIcon),
              (true, secondLabel, secondIcon),
            ])
              Semantics(
                button: true,
                selected: secondSelected == option.$1,
                label: option.$2,
                child: Tooltip(
                  message: option.$2,
                  child: InkWell(
                    onTap: () => onChanged(option.$1),
                    borderRadius: HistoryVisual.eventCorner,
                    child: Container(
                      width: option.$3 == null ? 58 * textScale : 42,
                      height: option.$3 == null && textScale > 1
                          ? 48 * textScale
                          : 40,
                      decoration: BoxDecoration(
                        color: secondSelected == option.$1
                            ? style.color('accent')
                            : Colors.transparent,
                        borderRadius: HistoryVisual.eventCorner,
                      ),
                      alignment: Alignment.center,
                      child: option.$3 == null
                          ? Text(
                              option.$2,
                              style: style
                                  .text(TextRole.helper)
                                  .copyWith(
                                    color: secondSelected == option.$1
                                        ? HistoryVisual.white
                                        : style.color('accent'),
                                  ),
                            )
                          : Icon(
                              option.$3,
                              size: 21,
                              color: secondSelected == option.$1
                                  ? HistoryVisual.white
                                  : style.color('accent'),
                            ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
