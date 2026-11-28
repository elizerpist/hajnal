import 'package:flutter/material.dart';
import '../../../core/theme/domain/style_roles.dart';
import '../../../core/theme/hajnal_theme.dart';
import '../../../core/theme/history_visual.dart';
import '../application/history_store.dart';

String historyDate(BuildContext context, DateTime date) =>
    MaterialLocalizations.of(context).formatCompactDate(date);

class HistoryEventList extends StatelessWidget {
  const HistoryEventList({
    super.key,
    required this.events,
    required this.active,
    this.scrollable = true,
    this.onReflection,
  });
  final List<HistoryEvent> events;
  final bool active, scrollable;
  final ValueChanged<int>? onReflection;
  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const Center(child: Text('Ezen a napon nincs esemény.'));
    }
    final style = HajnalStyle.of(context);
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 16),
      shrinkWrap: !scrollable,
      physics: scrollable ? null : const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      separatorBuilder: (_, _) => SizedBox(
        height: 7,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: ColoredBox(
              color: style.color('accent').withValues(alpha: .5),
              child: const SizedBox(width: 2, height: 7),
            ),
          ),
        ),
      ),
      itemBuilder: (context, index) {
        final event = events[index];
        final isNote = event.type == HistoryEventType.note;
        final title = switch (event.type) {
          HistoryEventType.start => 'Kezdet',
          HistoryEventType.close => 'Lezárás',
          HistoryEventType.note => 'Pánikjegyzet',
          HistoryEventType.reflection => 'Napi reflexió',
        };
        final icon = switch (event.type) {
          HistoryEventType.start => Icons.flag_outlined,
          HistoryEventType.close => Icons.check,
          HistoryEventType.note => Icons.favorite_border,
          HistoryEventType.reflection => Icons.favorite_border,
        };
        return Stack(
          children: [
            if (events.length > 1)
              Positioned(
                left: 15,
                top: index == 0 ? 32 : 0,
                bottom: index == events.length - 1 ? 32 : 0,
                width: 2,
                child: ColoredBox(
                  color: style.color('accent').withValues(alpha: .5),
                ),
              ),
            Row(
              children: [
                Container(
                  width: HistoryVisual.nodeSize,
                  height: HistoryVisual.nodeSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: active
                        ? (isNote ? HistoryVisual.noteNode : HistoryVisual.node)
                        : HistoryVisual.mutedNode,
                    border: Border.all(color: style.color('surface'), width: 3),
                  ),
                  child: Icon(
                    icon,
                    size: 15,
                    color: active
                        ? (isNote
                              ? HistoryVisual.noteIcon
                              : style.color('accent'))
                        : HistoryVisual.mutedIcon,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: HistoryVisual.eventCorner,
                      onTap: event.reflectionId != null && onReflection != null
                          ? () => onReflection!(event.reflectionId!)
                          : () => showDialog<void>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(title),
                                content: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        MaterialLocalizations.of(
                                          context,
                                        ).formatFullDate(event.date),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(event.detail),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Bezárás'),
                                  ),
                                ],
                              ),
                            ),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 64),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 9,
                        ),
                        decoration: style
                            .card(CardRole.content)
                            .copyWith(borderRadius: HistoryVisual.eventCorner),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    style: HistoryVisual.eventTitle(style),
                                  ),
                                ),
                                Text(
                                  historyDate(context, event.date),
                                  style: HistoryVisual.caption(style),
                                ),
                              ],
                            ),
                            Text(
                              event.detail,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: HistoryVisual.eventDetail(style),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
