import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../core/database/hajnal_database.dart';
import '../../onboarding/application/onboarding_draft.dart';
import '../../practice/application/practice_store.dart';
import '../../recovery/domain/calendar.dart';
import '../application/reflection_store.dart';

class ReflectionRepository implements ReflectionStore {
  ReflectionRepository(this._db, this._practice);
  final HajnalDatabase _db;
  final PracticeStore _practice;

  ReflectionEntry _entry(DailyReflection row) => ReflectionEntry(
    id: row.id,
    periodId: row.periodId,
    date: DateTime.parse(row.localDate),
    mood: row.mood,
    prompt: row.prompt,
    text: row.body,
    snapshot: row.practiceSnapshot == null
        ? null
        : PracticeSnapshot.fromJson(
            Map<String, Object?>.from(jsonDecode(row.practiceSnapshot!) as Map),
          ),
    observation: row.observation,
    note: row.note,
    completed: row.completed,
  );

  @override
  Stream<bool> watchEnabled() =>
      (_db.select(
        _db.onboardingProfiles,
      )..where((p) => p.id.equals(1))).watchSingleOrNull().map(
        (profile) =>
            ((profile?.modules ?? 0) &
                (1 << OnboardingModule.reflection.index)) !=
            0,
      );

  @override
  Future<ReflectionEntry> open(
    int periodId,
    DateTime date,
  ) => _db.transaction(() async {
    final day = validatedStartDate(date, DateTime.now());
    final query = _db.select(_db.dailyReflections)
      ..where((r) => r.periodId.equals(periodId) & r.localDate.equals(day));
    var row = await query.getSingleOrNull();
    if (row == null) {
      final active =
          await (_db.select(_db.recoveryPeriods)
                ..where((p) => p.id.equals(periodId) & p.closedAtUtc.isNull()))
              .getSingleOrNull();
      if (active == null) throw StateError('Az aktív időszak megváltozott.');
      final cards = await _practice.watch().first;
      final activeCards = cards.where((c) => c.status == 'active');
      final card = activeCards.isEmpty ? null : activeCards.single;
      final snapshot = card == null
          ? null
          : jsonEncode(card.snapshot().toJson());
      final id = await _db
          .into(_db.dailyReflections)
          .insert(
            DailyReflectionsCompanion.insert(
              periodId: periodId,
              localDate: day,
              practiceSnapshot: Value(snapshot),
            ),
          );
      row = await (_db.select(
        _db.dailyReflections,
      )..where((r) => r.id.equals(id))).getSingle();
    }
    return _entry(row);
  });

  @override
  Future<ReflectionEntry> openById(int id) async => _entry(
    await (_db.select(
      _db.dailyReflections,
    )..where((r) => r.id.equals(id))).getSingle(),
  );

  Future<void> _write(ReflectionEntry entry, bool complete) async {
    final count =
        await (_db.update(
          _db.dailyReflections,
        )..where((r) => r.id.equals(entry.id))).write(
          DailyReflectionsCompanion(
            mood: Value(entry.mood),
            prompt: Value(entry.prompt),
            body: Value(entry.text),
            observation: Value(entry.observation),
            note: Value(entry.note),
            completed: Value(entry.completed || (complete && entry.hasContent)),
          ),
        );
    if (count != 1) throw StateError('A reflexió már nem található.');
  }

  @override
  Future<void> saveDraft(ReflectionEntry entry) => _write(entry, false);
  @override
  Future<void> finish(ReflectionEntry entry) => _write(entry, true);
}
