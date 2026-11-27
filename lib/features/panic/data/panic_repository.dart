import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../core/database/hajnal_database.dart' hide SurvivalSession;
import '../application/panic_store.dart';
import '../domain/survival_session.dart';

class PanicRepository implements PanicStore {
  PanicRepository(this._db);
  final HajnalDatabase _db;

  @override
  Future<String> motivation() async =>
      (await (_db.select(
        _db.onboardingProfiles,
      )..where((p) => p.id.equals(1))).getSingleOrNull())?.motivation ??
      '';

  @override
  Future<SurvivalSession?> loadSession() async {
    final row = await (_db.select(
      _db.survivalSessions,
    )..where((p) => p.id.equals(1))).getSingleOrNull();
    return row == null
        ? null
        : SurvivalSession.fromJson(
            jsonDecode(row.payload) as Map<String, dynamic>,
          );
  }

  @override
  Future<void> saveSession(SurvivalSession session) async {
    await _db
        .into(_db.survivalSessions)
        .insertOnConflictUpdate(
          SurvivalSessionsCompanion.insert(
            id: const Value(1),
            payload: jsonEncode(session.toJson()),
          ),
        );
  }

  @override
  Future<void> saveNote(String body, DateTime now) => _db.transaction(() async {
    final active = await (_db.select(
      _db.recoveryPeriods,
    )..where((period) => period.closedAtUtc.isNull())).getSingleOrNull();
    if (active == null) throw StateError('No active recovery period');
    await _db
        .into(_db.survivalNotes)
        .insert(
          SurvivalNotesCompanion.insert(
            body: body,
            createdAtUtc: now.toUtc(),
            periodId: Value(active.id),
          ),
        );
  });
}
