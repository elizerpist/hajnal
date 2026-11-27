import 'dart:convert';

enum OnboardingModule { reflection, sponsor, meetings, steps }

class OnboardingDraft {
  OnboardingDraft({
    required this.periodId,
    required this.date,
    required this.motivation,
    required Set<OnboardingModule> modules,
    required this.sponsorName,
    required this.sponsorPhone,
    required this.completed,
    required Map<String, Object?> baseline,
    Set<String> dirty = const {},
    this.sponsorChoice = 1,
  }) : modules = Set.unmodifiable(modules),
       baseline = Map.unmodifiable(baseline),
       dirty = Set.unmodifiable(dirty);

  final int? periodId;
  final DateTime date;
  final String motivation;
  final Set<OnboardingModule> modules;
  final String sponsorName;
  final String sponsorPhone;
  final bool completed;
  final Map<String, Object?> baseline;
  final Set<String> dirty;
  final int sponsorChoice;

  OnboardingDraft copyWith({
    DateTime? date,
    String? motivation,
    Set<OnboardingModule>? modules,
    String? sponsorName,
    String? sponsorPhone,
    Set<String>? dirty,
    int? sponsorChoice,
  }) => OnboardingDraft(
    periodId: periodId,
    date: date ?? this.date,
    motivation: motivation ?? this.motivation,
    modules: modules ?? this.modules,
    sponsorName: sponsorName ?? this.sponsorName,
    sponsorPhone: sponsorPhone ?? this.sponsorPhone,
    completed: completed,
    baseline: baseline,
    dirty: dirty ?? this.dirty,
    sponsorChoice: sponsorChoice ?? this.sponsorChoice,
  );

  String encode() => jsonEncode({
    'periodId': periodId,
    'date': date.toIso8601String(),
    'motivation': motivation,
    'modules': modules.map((m) => m.name).toList(),
    'sponsorName': sponsorName,
    'sponsorPhone': sponsorPhone,
    'completed': completed,
    'baseline': baseline,
    'dirty': dirty.toList(),
    'sponsorChoice': sponsorChoice,
  });

  factory OnboardingDraft.decode(String data) {
    final json = jsonDecode(data) as Map<String, dynamic>;
    return OnboardingDraft(
      periodId: json['periodId'] as int?,
      date: DateTime.parse(json['date'] as String),
      motivation: json['motivation'] as String,
      modules: (json['modules'] as List)
          .map((e) => OnboardingModule.values.byName(e as String))
          .toSet(),
      sponsorName: json['sponsorName'] as String,
      sponsorPhone: json['sponsorPhone'] as String,
      completed: json['completed'] as bool,
      baseline: Map<String, Object?>.from(json['baseline'] as Map),
      dirty: Set<String>.from(json['dirty'] as List),
      sponsorChoice: json['sponsorChoice'] as int,
    );
  }
}
