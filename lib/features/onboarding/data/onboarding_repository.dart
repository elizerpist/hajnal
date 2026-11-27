import 'package:drift/drift.dart';
import '../../../core/database/hajnal_database.dart' hide OnboardingDraft;
import '../../recovery/data/recovery_repository.dart';
import '../../recovery/domain/calendar.dart';
import '../../sponsor/data/sponsor_repository.dart';
import '../application/onboarding_draft.dart';
import '../application/onboarding_store.dart';

export '../application/onboarding_draft.dart';

class OnboardingRepository implements OnboardingStore {
  OnboardingRepository(this._db, this._recovery, this._sponsors);
  final HajnalDatabase _db;
  final RecoveryRepository _recovery;
  final SponsorRepository _sponsors;

  int _mask(Set<OnboardingModule> modules) =>
      modules.fold(0, (v, m) => v | (1 << m.index));
  Set<OnboardingModule> _modules(int mask) =>
      OnboardingModule.values.where((m) => mask & (1 << m.index) != 0).toSet();

  Future<RecoveryPeriod?> _active() => (_db.select(
    _db.recoveryPeriods,
  )..where((p) => p.closedAtUtc.isNull())).getSingleOrNull();
  Future<OnboardingProfile?> _profile() => (_db.select(
    _db.onboardingProfiles,
  )..where((p) => p.id.equals(1))).getSingleOrNull();
  @override
  Future<OnboardingDraft> load(DateTime now) async {
    final pending = await (_db.select(
      _db.onboardingDrafts,
    )..where((d) => d.id.equals(1))).getSingleOrNull();
    if (pending != null) return OnboardingDraft.decode(pending.payload);
    final active = await _active();
    final profile = await _profile();
    final sponsor = await _sponsors.read();
    final date = active == null
        ? DateTime(now.year, now.month, now.day)
        : DateTime.parse(active.startLocalDate);
    final motivation = profile?.motivation ?? '';
    final modules = profile?.modules ?? 0;
    final name = sponsor?.name ?? '';
    final phone = sponsor?.phone ?? '';
    return OnboardingDraft(
      periodId: active?.id,
      date: date,
      motivation: motivation,
      modules: _modules(modules),
      sponsorName: name,
      sponsorPhone: phone,
      completed: profile?.completed ?? (active != null),
      sponsorChoice: sponsor == null ? SponsorChoice.skip : SponsorChoice.add,
      baseline: {
        'date': active?.startLocalDate,
        'motivation': motivation,
        'modules': modules,
        'sponsorName': name,
        'sponsorPhone': phone,
      },
    );
  }

  @override
  Future<void> saveDraft(OnboardingDraft draft) async {
    await _db
        .into(_db.onboardingDrafts)
        .insertOnConflictUpdate(
          OnboardingDraftsCompanion.insert(
            id: const Value(1),
            payload: draft.encode(),
          ),
        );
  }

  @override
  Future<void> finish(OnboardingDraft draft, DateTime now) async {
    final date = validatedStartDate(draft.date, now);
    if (draft.modules.contains(OnboardingModule.sponsor) &&
        draft.sponsorChoice == SponsorChoice.add &&
        draft.sponsorName.trim().isEmpty) {
      throw ArgumentError('A szponzor neve kötelező.');
    }
    await _db.transaction(() async {
      final active = await _active();
      if (active?.id != draft.periodId) {
        throw StateError('Active period changed');
      }
      final profile = await _profile();
      final sponsor = await _sponsors.read();
      var motivation = profile?.motivation ?? '';
      var modules = profile?.modules ?? 0;
      if (draft.dirty.contains('date') &&
          active != null &&
          active.startLocalDate != draft.baseline['date']) {
        throw StateError('Start date changed');
      }
      if (draft.dirty.contains('motivation')) {
        if (motivation != draft.baseline['motivation']) {
          throw StateError('Motivation changed');
        }
        motivation = draft.motivation;
      }
      if (draft.dirty.contains('modules')) {
        final base = draft.baseline['modules'] as int;
        final target = _mask(draft.modules);
        final changed = base ^ target;
        if (((modules ^ base) & changed) != 0) {
          throw StateError('Modules changed');
        }
        modules = (modules & ~changed) | (target & changed);
      }
      if (draft.dirty.contains('sponsor') &&
          draft.sponsorChoice == SponsorChoice.add &&
          draft.modules.contains(OnboardingModule.sponsor)) {
        if ((sponsor?.name ?? '') != draft.baseline['sponsorName'] ||
            (sponsor?.phone ?? '') != draft.baseline['sponsorPhone']) {
          throw StateError('Sponsor changed');
        }
        await _sponsors.save(draft.sponsorName, draft.sponsorPhone);
      }
      if (active == null) {
        await _recovery.initialize(draft.date, now);
      } else if (draft.dirty.contains('date') &&
          active.startLocalDate != date) {
        await _recovery.correctStart(active.id, draft.date, now);
      }
      await _db
          .into(_db.onboardingProfiles)
          .insertOnConflictUpdate(
            OnboardingProfilesCompanion.insert(
              id: const Value(1),
              motivation: Value(motivation),
              modules: Value(modules),
              completed: const Value(true),
            ),
          );
      await (_db.delete(
        _db.onboardingDrafts,
      )..where((d) => d.id.equals(1))).go();
    });
  }
}
