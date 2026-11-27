class HistoryNote {
  const HistoryNote(this.id, this.text, this.createdAt);
  final int id;
  final String text;
  final DateTime createdAt;
}

class HistoryPeriod {
  HistoryPeriod({
    required this.id,
    required this.start,
    required this.createdAt,
    required this.closedAt,
    required List<HistoryNote> notes,
  }) : notes = List.unmodifiable(notes);
  final int id;
  final DateTime start;
  final DateTime createdAt;
  final DateTime? closedAt;
  final List<HistoryNote> notes;
  bool get active => closedAt == null;
}

enum HistoryEventType { start, note, close }

class HistoryEvent {
  const HistoryEvent(this.type, this.date, this.detail, {this.noteId});
  final HistoryEventType type;
  final DateTime date;
  final String detail;
  final int? noteId;
}

abstract interface class HistoryStore {
  Stream<List<HistoryPeriod>> watch();
}
