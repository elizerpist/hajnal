import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('practice persistence has one repository owner', () {
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart') && !f.path.endsWith('.g.dart'));
    for (final file in files) {
      final source = file.readAsStringSync();
      if (file.path != 'lib/features/practice/data/practice_repository.dart' &&
          file.path != 'lib/core/database/hajnal_database.dart') {
        expect(source, isNot(contains('_db.practiceCards')), reason: file.path);
      }
    }
    expect(
      File('lib/features/practice/data/practice_repository.dart').existsSync(),
      isTrue,
    );
  });
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
      '../application/date_picker.dart',
      '../application/onboarding_controller.dart',
      '../application/onboarding_draft.dart',
      'onboarding_calendar.dart',
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
    // These consumers render the shared style adapter and enum-only role contract.
    const themeConsumers = {
      'lib/features/dashboard/presentation/dashboard.dart',
      'lib/features/onboarding/presentation/onboarding.dart',
      'lib/features/onboarding/presentation/onboarding_calendar.dart',
      'lib/features/app_lock/presentation/pin_pad.dart',
      'lib/features/app_lock/presentation/lock_auth_page.dart',
      'lib/features/app_lock/presentation/lock_settings.dart',
      'lib/features/app_lock/presentation/lock_gate.dart',
      'lib/features/panic/presentation/panic_page.dart',
      'lib/features/panic/presentation/panic_dialogs.dart',
      'lib/features/panic/presentation/relapse_page.dart',
      'lib/features/panic/presentation/survival_page.dart',
      'lib/features/history/presentation/history_page.dart',
      'lib/features/history/presentation/history_calendar.dart',
      'lib/features/history/presentation/history_event_list.dart',
      'lib/features/history/presentation/history_switch.dart',
    };
    const themeImports = {
      '../../../core/theme/hajnal_theme.dart',
      '../../../core/theme/hajnal_components.dart',
      '../../../core/theme/domain/style_roles.dart',
    };
    const editorImports = {
      'package:flutter/material.dart',
      '../application/style_controller.dart',
      '../domain/style_roles.dart',
      '../hajnal_components.dart',
      '../hajnal_theme.dart',
    };
    const practiceImports = <String, Set<String>>{
      'lib/features/dashboard/presentation/dashboard.dart': {
        '../../practice/application/practice_controller.dart',
        '../../practice/presentation/practice_manager.dart',
        '../../../core/artwork/practice_artwork.dart',
      },
      'lib/features/practice/presentation/practice_manager.dart': {
        '../../../core/artwork/practice_artwork.dart',
        '../../../core/theme/practice_visual.dart',
        '../application/practice_controller.dart',
        '../application/practice_store.dart',
        'practice_editor.dart',
      },
      'lib/features/practice/presentation/practice_editor.dart': {
        'package:flutter_svg/flutter_svg.dart',
        '../../../core/artwork/practice_artwork.dart',
        '../../../core/theme/practice_visual.dart',
        '../application/practice_controller.dart',
        '../application/practice_store.dart',
      },
    };
    const panicImports = <String, Set<String>>{
      'lib/features/panic/presentation/panic_page.dart': {
        'dart:async',
        '../application/panic_controller.dart',
        'panic_dialogs.dart',
        'relapse_page.dart',
        'survival_page.dart',
      },
      'lib/features/panic/presentation/panic_dialogs.dart': {
        '../application/panic_controller.dart',
      },
      'lib/features/panic/presentation/relapse_page.dart': {
        '../application/panic_controller.dart',
      },
      'lib/features/panic/presentation/survival_page.dart': {
        'dart:async',
        '../application/panic_controller.dart',
        '../application/survival_controller.dart',
        'panic_dialogs.dart',
      },
    };
    // History reads only the view contract and its own renderers; the visual
    // treatment is shared by the history hero and event-node renderers.
    const historyImports = <String, Set<String>>{
      'lib/features/history/presentation/history_page.dart': {
        '../application/history_controller.dart',
        '../application/history_store.dart',
        '../../../core/theme/history_visual.dart',
        'history_calendar.dart',
        'history_event_list.dart',
        'history_switch.dart',
      },
      'lib/features/history/presentation/history_calendar.dart': {
        '../application/history_store.dart',
        '../../../core/theme/history_visual.dart',
        'history_event_list.dart',
        'history_switch.dart',
      },
      'lib/features/history/presentation/history_event_list.dart': {
        '../application/history_store.dart',
        '../../../core/theme/history_visual.dart',
      },
      'lib/features/history/presentation/history_switch.dart': {
        '../../../core/theme/history_visual.dart',
      },
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
          final uri = match.group(1);
          expect(
            presentationImports.contains(uri) ||
                (practiceImports[file.path]?.contains(uri) ?? false) ||
                (panicImports[file.path]?.contains(uri) ?? false) ||
                (historyImports[file.path]?.contains(uri) ?? false) ||
                (uri == '../../../core/theme/panic_visual.dart' &&
                    (file.path ==
                            'lib/features/dashboard/presentation/dashboard.dart' ||
                        file.path ==
                            'lib/features/panic/presentation/panic_page.dart' ||
                        file.path ==
                            'lib/features/panic/presentation/panic_dialogs.dart' ||
                        file.path ==
                            'lib/features/panic/presentation/relapse_page.dart')) ||
                // Only the existing Welcome SVG selects this render strategy.
                (file.path ==
                        'lib/features/onboarding/presentation/onboarding.dart' &&
                    uri ==
                        'package:vector_graphics/vector_graphics_compat.dart') ||
                (themeConsumers.contains(file.path) &&
                    themeImports.contains(uri)) ||
                (file.path == 'lib/core/theme/presentation/style_editor.dart' &&
                    editorImports.contains(uri)),
            isTrue,
            reason: '${file.path}: $uri',
          );
        }
      }
      if (source.contains('.into(') ||
          source.contains('db.delete(') ||
          source.contains('_db.delete(')) {
        expect([
          'lib/features/recovery/data/recovery_repository.dart',
          'lib/features/panic/data/panic_repository.dart',
          'lib/features/practice/data/practice_repository.dart',
          'lib/features/onboarding/data/onboarding_repository.dart',
          'lib/features/sponsor/data/sponsor_repository.dart',
          'lib/features/app_lock/data/lock_repository.dart',
          'lib/core/artwork/drift_artwork_store.dart',
          'lib/core/theme/data/style_repository.dart',
        ], contains(file.path));
      }
    }
  });
}
