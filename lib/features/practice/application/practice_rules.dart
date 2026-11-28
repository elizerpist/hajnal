const practicePrompts = <String, String>{
  'Felismerés': 'Észrevettem, hogy',
  'Iránytű': 'Fontos nekem, hogy',
  'Kérdés': 'Mi segítene',
  'Apró lépés': 'Legközelebb',
};

bool hasPersonalPracticeText(String text) {
  final trimmed = text.trim();
  return trimmed.isNotEmpty && !practicePrompts.values.contains(trimmed);
}
