import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('panic state and persistence have one declared owner each', () {
    final files = Directory('lib/features/panic')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .toList();
    expect(files, isNotEmpty);
    expect(
      files
          .where(
            (f) => f.readAsStringSync().contains('class SurvivalController'),
          )
          .length,
      1,
    );
    for (final file in files) {
      final source = file.readAsStringSync();
      if (file.path.contains('/presentation/') ||
          file.path.contains('/application/')) {
        for (final forbidden in [
          'package:drift/',
          'core/database/',
          '/data/',
          'customStatement',
        ]) {
          expect(source, isNot(contains(forbidden)), reason: file.path);
        }
      }
      if (file.path.contains('/domain/')) {
        expect(source, isNot(contains('package:flutter/')), reason: file.path);
      }
    }
  });
}
