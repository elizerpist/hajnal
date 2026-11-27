import '../domain/survival_session.dart';

abstract interface class PanicStore {
  Future<String> motivation();
  Future<SurvivalSession?> loadSession();
  Future<void> saveSession(SurvivalSession session);
  Future<void> saveNote(String body, DateTime now);
}
