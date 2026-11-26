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
  test(
    'production layers keep storage, platform and state ownership boundaries',
    () {
      final root = Directory('lib');
      final files = root
          .listSync(recursive: true)
          .whereType<File>()
          .where(
            (file) =>
                file.path.endsWith('.dart') && !file.path.endsWith('.g.dart'),
          )
          .toList();
      expect(files.length, greaterThan(8));
      for (final file in files) {
        final source = file.readAsStringSync();
        final presentation = file.path.contains('/presentation/');
        final application = file.path.contains('/application/');
        if (presentation || application) {
          for (final forbidden in [
            'package:drift/',
            'package:sqlite3/',
            'dart:io',
            'MethodChannel',
            '/data/',
            'core/database/',
            'getApplicationSupportDirectory',
            'customStatement',
          ]) {
            expect(
              source,
              isNot(contains(forbidden)),
              reason: '${file.path}: $forbidden',
            );
          }
        }
        if (application) {
          for (final forbidden in [
            'package:flutter/material.dart',
            'package:flutter/widgets.dart',
            'BuildContext',
          ]) {
            expect(source, isNot(contains(forbidden)), reason: file.path);
          }
        }
        if (file.path !=
            'lib/features/recovery/data/recovery_repository.dart') {
          expect(
            source,
            isNot(contains('into(_db.recoveryPeriods)')),
            reason: file.path,
          );
        }
        if (file.path != 'lib/core/artwork/artwork_catalog.dart') {
          expect(
            source,
            isNot(contains('assets/artwork/dashboard/placeholder.png')),
            reason: file.path,
          );
        }
      }
      expect(
        File(
          'lib/features/recovery/data/recovery_repository.dart',
        ).readAsStringSync(),
        contains('into(_db.recoveryPeriods)'),
      );
      expect(
        File(
          'lib/features/dashboard/application/day_tracker.dart',
        ).existsSync(),
        isTrue,
      );
      expect(
        File('lib/core/artwork/artwork_service.dart').existsSync(),
        isTrue,
      );
    },
  );
}
