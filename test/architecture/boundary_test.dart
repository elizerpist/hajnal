import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('domain and presentation do not depend on platform or storage', () {
    final root = Directory('lib/features');
    expect(root.existsSync(), isTrue);
    final files = root
        .listSync(recursive: true)
        .whereType<File>()
        .where(
          (file) =>
              file.path.endsWith('.dart') &&
              (file.path.contains('/domain/') ||
                  file.path.contains('/presentation/')),
        );
    expect(files, isNotEmpty);
    for (final file in files) {
      final source = file.readAsStringSync();
      expect(source, isNot(contains('package:drift/')), reason: file.path);
      expect(source, isNot(contains('package:sqlite3/')), reason: file.path);
      expect(source, isNot(contains('MethodChannel')), reason: file.path);
      if (file.path.contains('/domain/')) {
        expect(source, isNot(contains('package:flutter/')), reason: file.path);
        expect(source, isNot(contains('dart:io')), reason: file.path);
      }
    }
  });
}
