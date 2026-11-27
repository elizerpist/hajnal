import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('history is read-only and keeps persistence out of UI and state', () {
    final files = Directory('lib/features/history')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .toList();
    expect(files, isNotEmpty);
    for (final file in files) {
      final source = file.readAsStringSync();
      if (file.path.contains('/presentation/') ||
          file.path.contains('/application/')) {
        for (final forbidden in [
          'package:drift/',
          'core/database/',
          '/data/',
        ]) {
          expect(source, isNot(contains(forbidden)), reason: file.path);
        }
      }
      if (file.path.contains('/domain/')) {
        expect(source, isNot(contains('package:flutter/')), reason: file.path);
      }
      if (file.path.contains('/data/')) {
        for (final mutation in ['.into(', '.update(', '.delete(']) {
          expect(source, isNot(contains(mutation)), reason: file.path);
        }
      }
    }
  });
}
