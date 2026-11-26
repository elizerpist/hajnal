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
            'core/platform/',
            'artwork_service.dart',
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
  test('platform channel and vertical gesture each have one owner', () {
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart') && !f.path.endsWith('.g.dart'))
        .toList();
    final channelOwners = files
        .where((f) => f.readAsStringSync().contains('MethodChannel('))
        .map((f) => f.path)
        .toList();
    expect(channelOwners.toSet(), {
      'lib/core/platform/date_picker.dart',
      'lib/core/platform/lock_guard.dart',
    });
    final gestureOwners = files
        .where((f) => f.readAsStringSync().contains('onVerticalDragUpdate:'))
        .map((f) => f.path)
        .toList();
    expect(gestureOwners, [
      'lib/features/dashboard/presentation/dashboard.dart',
    ]);
  });
  test(
    'app controller and rendering stay independent of concrete adapters',
    () {
      final controller = File(
        'lib/app/bootstrap_controller.dart',
      ).readAsStringSync();
      for (final forbidden in [
        'BuildContext',
        'package:flutter/material.dart',
        'core/database/',
        'core/platform/',
        '/data/',
      ]) {
        expect(controller, isNot(contains(forbidden)), reason: forbidden);
      }
      final app = File('lib/app/hajnal_app.dart').readAsStringSync();
      for (final forbidden in [
        'core/database/',
        'core/platform/',
        'artwork_service.dart',
        'MethodChannel',
      ]) {
        expect(app, isNot(contains(forbidden)), reason: forbidden);
      }
    },
  );
  test('root widget does not coordinate storage or concrete repositories', () {
    final root = File('lib/main.dart').readAsStringSync();
    for (final forbidden in [
      'getApplicationSupportDirectory',
      'NativeDatabase',
      'RecoveryRepository',
      '.cleanup()',
    ]) {
      expect(root, isNot(contains(forbidden)), reason: forbidden);
    }
  });
  test('day count is derived and has no public write path', () {
    final source = File(
      'lib/features/dashboard/application/day_tracker.dart',
    ).readAsStringSync();
    expect(source, contains('int? get days'));
    expect(source, isNot(contains('int? days;')));
  });
  test('bootstrap state is exposed read only', () {
    final source = File('lib/app/bootstrap_controller.dart').readAsStringSync();
    for (final name in [
      'startDate',
      'error',
      'saveError',
      'loading',
      'saving',
    ]) {
      expect(source, contains('get $name'), reason: name);
    }
    final publicFields = RegExp(
      r'\b(?:DateTime\?|Object\?|bool)\s+(startDate|error|saveError|loading|saving)\s*[;=]',
    );
    expect(publicFields.hasMatch(source), isFalse);
  });
  test('feature imports and persistent write owners fail closed', () {
    const presentationImports = {
      'dart:math',
      'package:flutter/material.dart',
      '../../../app/bootstrap_controller.dart',
      '../../../core/artwork/artwork_source.dart',
      '../../../core/artwork/artwork_catalog.dart',
      '../../../core/artwork/artwork_view.dart',
      '../../../core/theme/hajnal_tokens.dart',
      '../application/date_picker.dart',
      'dashboard_layout.dart',
      'package:flutter_svg/flutter_svg.dart',
      '../../../core/brand/brand_assets.dart',
      '../../../core/brand/fingerprint_icon.dart',
      '../../../core/brand/security_icons.dart',
      '../application/biometrics.dart',
      '../application/lock_controller.dart',
      '../application/lock_settings_coordinator.dart',
      '../domain/lock_mode.dart',
      'lock_auth_page.dart',
      'pin_pad.dart',
      'pin_setup.dart',
    };
    final imports = RegExp(r"""^import\s+['"]([^'"]+)['"]""", multiLine: true);
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart') && !f.path.endsWith('.g.dart'))
        .toList();
    for (final file in files) {
      final source = file.readAsStringSync();
      for (final forbidden in [
        'package:firebase_',
        'package:http/',
        'package:dio/',
        'package:sqflite/',
        'exptv2/',
        '/legacy/',
      ]) {
        expect(source, isNot(contains(forbidden)), reason: file.path);
      }
      if (file.path.contains('/presentation/')) {
        for (final match in imports.allMatches(source)) {
          expect(
            presentationImports,
            contains(match.group(1)),
            reason: file.path,
          );
        }
      }
      if (source.contains('.into(') ||
          source.contains('db.delete(') ||
          source.contains('_db.delete(')) {
        expect([
          'lib/features/recovery/data/recovery_repository.dart',
          'lib/features/app_lock/data/lock_repository.dart',
          'lib/core/artwork/drift_artwork_store.dart',
        ], contains(file.path));
      }
    }
  });
}
