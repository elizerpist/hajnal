import '../../practice/application/practice_store.dart';

class ReflectionEntry {
  const ReflectionEntry({
    required this.id,
    required this.periodId,
    required this.date,
    this.mood,
    this.prompt = 'best',
    this.text = '',
    this.snapshot,
    this.observation,
    this.note = '',
    this.completed = false,
  });
  final int id, periodId;
  final DateTime date;
  final int? mood;
  final String prompt, text, note;
  final PracticeSnapshot? snapshot;
  final String? observation;
  final bool completed;
  bool get hasContent =>
      mood != null ||
      text.trim().isNotEmpty ||
      observation != null ||
      note.trim().isNotEmpty;
  ReflectionEntry copyWith({
    int? mood,
    bool clearMood = false,
    String? prompt,
    String? text,
    String? observation,
    bool clearObservation = false,
    String? note,
    bool? completed,
  }) => ReflectionEntry(
    id: id,
    periodId: periodId,
    date: date,
    mood: clearMood ? null : mood ?? this.mood,
    prompt: prompt ?? this.prompt,
    text: text ?? this.text,
    snapshot: snapshot,
    observation: clearObservation ? null : observation ?? this.observation,
    note: note ?? this.note,
    completed: completed ?? this.completed,
  );
}

abstract interface class ReflectionStore {
  Stream<bool> watchEnabled();
  Future<ReflectionEntry> open(int periodId, DateTime date);
  Future<ReflectionEntry> openById(int id);
  Future<void> saveDraft(ReflectionEntry entry);
  Future<void> finish(ReflectionEntry entry);
}
