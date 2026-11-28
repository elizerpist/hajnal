class PracticeCard {
  const PracticeCard({
    required this.id,
    required this.text,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.title,
    this.promptKind,
    this.activatedAt,
    this.sourceReference,
    this.sourceName,
    this.sourceText,
  });
  final int id;
  final String text, status;
  final String? title, promptKind, sourceReference, sourceName, sourceText;
  final DateTime createdAt, updatedAt;
  final DateTime? activatedAt;
  String get label => title?.trim().isNotEmpty == true ? title! : text;
  PracticeSnapshot snapshot() => PracticeSnapshot(title: title, text: text);
}

class PracticeSnapshot {
  const PracticeSnapshot({this.title, required this.text});
  final String? title;
  final String text;
  factory PracticeSnapshot.fromJson(Map<String, Object?> json) {
    final text = json['text'];
    final title = json['title'];
    if (text is! String || (title != null && title is! String)) {
      throw const FormatException('Érvénytelen gyakorlat-pillanatkép');
    }
    return PracticeSnapshot(text: text, title: title as String?);
  }
  Map<String, Object?> toJson() => {'title': title, 'text': text};
}

class PracticeContent {
  const PracticeContent({
    required this.text,
    this.title,
    this.promptKind,
    this.sourceReference,
    this.sourceName,
    this.sourceText,
  });
  final String text;
  final String? title, promptKind, sourceReference, sourceName, sourceText;
}

abstract interface class PracticeStore {
  Stream<List<PracticeCard>> watch();
  Future<void> add(PracticeContent content, {required bool activate});
  Future<void> saveChanges(int id, PracticeContent content);
  Future<void> activate(int id);
  Future<void> remove(int id);
}
