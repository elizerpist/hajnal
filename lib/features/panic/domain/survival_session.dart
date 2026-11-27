enum Reassessment { none, relieved, stillHard, stronger, complete }

class SurvivalSession {
  const SurvivalSession({
    required this.startedAt,
    DateTime? stepStartedAt,
    this.step = 0,
    this.reassessment = Reassessment.none,
    this.water,
    this.environment,
    this.note = '',
    this.breathingPaused = false,
  }) : stepStartedAt = stepStartedAt ?? startedAt;

  final DateTime startedAt;
  final DateTime stepStartedAt;
  final int step;
  final Reassessment reassessment;
  final String? water, environment;
  final String note;
  final bool breathingPaused;

  Duration remaining(DateTime now) {
    final seconds = 900 - now.difference(startedAt).inSeconds;
    return Duration(seconds: seconds.clamp(0, 900));
  }

  SurvivalSession copyWith({
    int? step,
    Reassessment? reassessment,
    String? water,
    String? environment,
    String? note,
    bool? breathingPaused,
    DateTime? stepStartedAt,
  }) => SurvivalSession(
    startedAt: startedAt,
    stepStartedAt: stepStartedAt ?? this.stepStartedAt,
    step: step ?? this.step,
    reassessment: reassessment ?? this.reassessment,
    water: water ?? this.water,
    environment: environment ?? this.environment,
    note: note ?? this.note,
    breathingPaused: breathingPaused ?? this.breathingPaused,
  );

  Map<String, Object?> toJson() => {
    'version': 1,
    'startedAt': startedAt.toUtc().toIso8601String(),
    'stepStartedAt': stepStartedAt.toUtc().toIso8601String(),
    'step': step,
    'reassessment': reassessment.name,
    'water': water,
    'environment': environment,
    'note': note,
    'breathingPaused': breathingPaused,
  };

  factory SurvivalSession.fromJson(Map<String, dynamic> json) {
    if (json['version'] != 1 ||
        json['step'] is! int ||
        (json['step'] as int) < 0 ||
        (json['step'] as int) > 6) {
      throw const FormatException('Invalid survival session');
    }
    return SurvivalSession(
      startedAt: DateTime.parse(json['startedAt'] as String),
      stepStartedAt: DateTime.parse(
        (json['stepStartedAt'] ?? json['startedAt']) as String,
      ),
      step: json['step'] as int,
      reassessment: Reassessment.values.byName(json['reassessment'] as String),
      water: json['water'] as String?,
      environment: json['environment'] as String?,
      note: json['note'] as String? ?? '',
      breathingPaused: json['breathingPaused'] as bool? ?? false,
    );
  }
}
