import 'package:drift/drift.dart';
import '../../../core/database/hajnal_database.dart';
import '../application/practice_store.dart';

class PracticeRepository implements PracticeStore {
  PracticeRepository(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;
  final HajnalDatabase _db;
  final DateTime Function() _clock;
  DateTime get _now => _clock().toUtc();
  PracticeCard _map(PracticeCardData row) => PracticeCard(
    id: row.id,
    text: row.cardText,
    title: row.title,
    promptKind: row.promptKind,
    status: row.status,
    createdAt: row.createdAtUtc,
    updatedAt: row.updatedAtUtc,
    activatedAt: row.activatedAtUtc,
    sourceReference: row.sourceReference,
    sourceName: row.sourceName,
    sourceText: row.sourceText,
  );
  @override
  Stream<List<PracticeCard>> watch() =>
      (_db.select(_db.practiceCards)..orderBy([
            (t) => OrderingTerm.desc(t.updatedAtUtc),
            (t) => OrderingTerm.asc(t.id),
          ]))
          .watch()
          .map((rows) => List.unmodifiable(rows.map(_map)));
  void _validate(PracticeContent content) {
    if (content.text.trim().isEmpty) {
      throw ArgumentError('A kártya szövege nem lehet üres.');
    }
  }

  Future<void> _pauseActive() async {
    await (_db.update(_db.practiceCards)
          ..where((t) => t.status.equals('active')))
        .write(const PracticeCardsCompanion(status: Value('paused')));
  }

  @override
  Future<void> add(PracticeContent content, {required bool activate}) =>
      _db.transaction(() async {
        _validate(content);
        final now = _now;
        if (activate) await _pauseActive();
        await _db
            .into(_db.practiceCards)
            .insert(
              PracticeCardsCompanion.insert(
                cardText: content.text.trim(),
                title: Value(content.title),
                promptKind: Value(content.promptKind),
                sourceReference: Value(content.sourceReference),
                sourceName: Value(content.sourceName),
                sourceText: Value(content.sourceText),
                status: activate ? 'active' : 'paused',
                createdAtUtc: now,
                updatedAtUtc: now,
                activatedAtUtc: Value(activate ? now : null),
              ),
            );
      });
  @override
  Future<void> saveChanges(int id, PracticeContent content) async {
    _validate(content);
    final changed =
        await (_db.update(
          _db.practiceCards,
        )..where((t) => t.id.equals(id))).write(
          PracticeCardsCompanion(
            cardText: Value(content.text.trim()),
            title: Value(content.title),
            promptKind: Value(content.promptKind),
            updatedAtUtc: Value(_now),
          ),
        );
    if (changed != 1) throw StateError('A kártya már nem található.');
  }

  @override
  Future<void> activate(int id) => _db.transaction(() async {
    final target = await (_db.select(
      _db.practiceCards,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (target == null) throw StateError('A kártya már nem található.');
    if (target.status == 'active') return;
    final now = _now;
    await _pauseActive();
    await (_db.update(_db.practiceCards)..where((t) => t.id.equals(id))).write(
      PracticeCardsCompanion(
        status: const Value('active'),
        activatedAtUtc: Value(now),
        updatedAtUtc: Value(now),
      ),
    );
  });
  @override
  Future<void> remove(int id) async {
    final changed = await (_db.delete(
      _db.practiceCards,
    )..where((t) => t.id.equals(id))).go();
    if (changed != 1) throw StateError('A kártya már nem található.');
  }
}
