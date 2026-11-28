class HistoryNote {
  const HistoryNote(this.id, this.text, this.createdAt);
  final int id;
  final String text;
  final DateTime createdAt;
}

class HistoryReflection {
  const HistoryReflection(this.id, this.date, this.text);
  final int id;
  final DateTime date;
  final String text;
}

class HistoryPeriod {
  HistoryPeriod({
    required this.id,
    required this.start,
    required this.createdAt,
    required this.closedAt,
    required List<HistoryNote> notes,
    List<HistoryReflection> reflections = const [],
  }) : notes = List.unmodifiable(notes),
       reflections = List.unmodifiable(reflections);
  final int id;
  final DateTime start;
  final DateTime createdAt;
  final DateTime? closedAt;
  final List<HistoryNote> notes;
  final List<HistoryReflection> reflections;
  bool get active => closedAt == null;
}

enum HistoryEventType { start, note, close, reflection }

class HistoryEvent {
  const HistoryEvent(
    this.type,
    this.date,
    this.detail, {
    this.noteId,
    this.reflectionId,
  });
  final HistoryEventType type;
  final DateTime date;
  final String detail;
  final int? noteId;
  final int? reflectionId;
}

abstract interface class HistoryStore {
  Stream<List<HistoryPeriod>> watch();
}
