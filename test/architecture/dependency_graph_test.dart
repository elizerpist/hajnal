import 'dart:io';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

class Dependency {
  const Dependency(this.target, this.isExport);
  final String target;
  final bool isExport;
}

class MutationCalls extends RecursiveAstVisitor<void> {
  MutationCalls(this.source);
  final String source;
  final calls = <String>[];
  final dbUpdates = <String>[];
  final dbTables = <String>[];
  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (const {'into', 'update', 'delete'}.contains(node.methodName.name)) {
      for (final argument in node.argumentList.arguments) {
        final expression = argument.toSource();
        for (final table in const [
          'recoveryPeriods',
          'sponsorContacts',
          'onboardingProfiles',
          'onboardingDrafts',
          'styleSettings',
          'survivalSessions',
          'survivalNotes',
        ]) {
          if (expression.endsWith('.$table')) dbTables.add(table);
        }
      }
    }
    if (!(source == 'lib/features/app_lock/data/lock_repository.dart' &&
        node.methodName.name == 'create' &&
        node.target?.toSource() == '_hasher')) {
      calls.add(node.methodName.name);
    }
    if (node.methodName.name == 'update' &&
        (node.target?.toSource() == '_db' || node.target?.toSource() == 'db')) {
      dbUpdates.add(node.toSource());
    }
    super.visitMethodInvocation(node);
  }
}

List<Dependency> dependencies(String source, String from) {
  final parsed = parseString(content: source, path: from);
  expect(parsed.errors, isEmpty, reason: from);
  final result = <Dependency>[];
  for (final directive
      in parsed.unit.directives.whereType<UriBasedDirective>()) {
    final uris = <String?>[directive.uri.stringValue];
    if (directive is NamespaceDirective) {
      uris.addAll(directive.configurations.map((c) => c.uri.stringValue));
    }
    for (final uri in uris) {
      expect(uri, isNotNull, reason: 'Nonconstant directive in $from');
      final value = uri!;
      final String target;
      if (value.startsWith('package:hajnal/')) {
        target = 'lib/${value.substring('package:hajnal/'.length)}';
      } else if (value.startsWith('dart:') || value.startsWith('package:')) {
        target = value;
      } else {
        target = p.posix.normalize(p.posix.join(p.posix.dirname(from), value));
      }
      result.add(Dependency(target, directive is ExportDirective));
    }
  }
  return result;
}

bool allowed(String source, String target) {
  // The emergency dialer alone owns the external telephone launcher.
  final emergencyLauncher =
      source == 'lib/core/platform/emergency_dialer.dart' &&
      target.startsWith('package:url_launcher/');
  // Flutter SVG exposes its backdrop rendering strategy through this one API.
  final welcomeRaster =
      source == 'lib/features/onboarding/presentation/onboarding.dart' &&
      target == 'package:vector_graphics/vector_graphics_compat.dart';
  if (target.startsWith('package:local_auth/') &&
      source != 'lib/features/app_lock/data/biometric_adapter.dart') {
    return false;
  }
  if (target.startsWith('package:flutter_secure_storage/') &&
      source != 'lib/features/app_lock/data/secure_lock_store.dart') {
    return false;
  }
  if (target.startsWith('package:cryptography/') &&
      source != 'lib/features/app_lock/data/pin_hasher.dart') {
    return false;
  }
  if (target.contains('/legacy/') ||
      target.contains('exptv2/') ||
      target.startsWith('package:firebase_') ||
      target.startsWith('package:http/') ||
      target.startsWith('package:dio/') ||
      target.startsWith('package:sqflite/')) {
    return false;
  }
  final domain = source.contains('/domain/');
  final presentation =
      source.contains('/presentation/') || source == 'lib/app/hajnal_app.dart';
  final application =
      source.contains('/application/') ||
      source == 'lib/app/bootstrap_controller.dart';
  if (target.startsWith('package:')) {
    final package = target.substring('package:'.length).split('/').first;
    if (!const {
          'flutter',
          'flutter_localizations',
          'flutter_riverpod',
          'drift',
          'path',
          'path_provider',
          'local_auth',
          'flutter_secure_storage',
          'cryptography',
          'flutter_svg',
        }.contains(package) &&
        !welcomeRaster &&
        !emergencyLauncher) {
      return false;
    }
    if ((presentation || application) &&
        package != 'flutter' &&
        !welcomeRaster &&
        !(presentation &&
            (package == 'flutter_svg' || package == 'flutter_localizations'))) {
      return false;
    }
  }
  if (target.startsWith('package:drift/') &&
      source != 'lib/app/app_services.dart' &&
      source != 'lib/features/recovery/data/recovery_repository.dart' &&
      source != 'lib/features/history/data/history_repository.dart' &&
      source != 'lib/features/panic/data/panic_repository.dart' &&
      source != 'lib/features/onboarding/data/onboarding_repository.dart' &&
      source != 'lib/features/sponsor/data/sponsor_repository.dart' &&
      source != 'lib/features/app_lock/data/lock_repository.dart' &&
      source != 'lib/core/theme/data/style_repository.dart' &&
      source != 'lib/core/database/hajnal_database.dart') {
    return false;
  }
  if (target == 'dart:io' &&
      !const {
        'lib/app/app_services.dart',
        'lib/core/artwork/artwork_source.dart',
        'lib/core/artwork/artwork_service.dart',
        'lib/core/artwork/artwork_view.dart',
      }.contains(source)) {
    return false;
  }
  if ((domain || presentation || application) &&
      target.startsWith('dart:') &&
      !const {
        'dart:core',
        'dart:async',
        'dart:math',
        'dart:collection',
        'dart:convert',
      }.contains(target)) {
    return false;
  }
  if (domain &&
      (target.startsWith('package:') ||
          target == 'dart:io' ||
          target == 'dart:ui')) {
    return false;
  }
  if (domain && target.startsWith('lib/') && !target.contains('/domain/')) {
    return false;
  }
  if ((presentation || application) &&
      (target == 'dart:io' ||
          target == 'dart:ui' ||
          target.startsWith('package:drift/') ||
          target.startsWith('package:sqlite3/') ||
          (target == 'package:flutter/services.dart' &&
              source != 'lib/app/hajnal_app.dart') ||
          target.startsWith('lib/core/database/') ||
          target.startsWith('lib/core/platform/') ||
          target.contains('/data/') ||
          target == 'lib/core/artwork/artwork_store.dart' ||
          target == 'lib/core/artwork/drift_artwork_store.dart' ||
          target == 'lib/core/artwork/artwork_service.dart')) {
    return false;
  }
  // These enum-only role files are immutable view contracts, not engines.
  if (presentation &&
      target.contains('/domain/') &&
      target != 'lib/features/app_lock/domain/lock_mode.dart' &&
      target != 'lib/core/theme/domain/style_roles.dart') {
    return false;
  }
  if (application &&
      (target == 'package:flutter/material.dart' ||
          target == 'package:flutter/widgets.dart')) {
    return false;
  }
  if (target.startsWith('lib/core/database/') &&
      source != 'lib/app/app_services.dart' &&
      source != 'lib/features/onboarding/data/onboarding_repository.dart' &&
      source != 'lib/features/sponsor/data/sponsor_repository.dart' &&
      source != 'lib/core/artwork/drift_artwork_store.dart' &&
      source != 'lib/features/recovery/data/recovery_repository.dart' &&
      source != 'lib/features/history/data/history_repository.dart' &&
      source != 'lib/features/panic/data/panic_repository.dart' &&
      source != 'lib/features/app_lock/data/lock_repository.dart' &&
      source != 'lib/core/theme/data/style_repository.dart' &&
      source != 'lib/core/database/hajnal_database.dart') {
    return false;
  }
  return true;
}

List<String> violations(Map<String, List<Dependency>> graph) {
  final found = <String>[];
  for (final entry in graph.entries) {
    for (final dependency in entry.value) {
      final pending = [dependency.target];
      final visited = <String>{};
      while (pending.isNotEmpty) {
        final target = pending.removeLast();
        if (!visited.add(target)) continue;
        if (!allowed(entry.key, target)) found.add('${entry.key} -> $target');
        if (target.startsWith('lib/') &&
            !target.endsWith('.g.dart') &&
            !graph.containsKey(target)) {
          found.add('${entry.key} -> missing $target');
        }
        pending.addAll(
          (graph[target] ?? const <Dependency>[])
              .where((d) => d.isExport)
              .map((d) => d.target),
        );
      }
    }
  }
  return found;
}

void main() {
  test(
    'imports, conditional imports, exports, and reexports obey boundaries',
    () {
      final graph = <String, List<Dependency>>{};
      for (final file in Directory(
        'lib',
      ).listSync(recursive: true).whereType<File>()) {
        if (!file.path.endsWith('.dart') || file.path.endsWith('.g.dart')) {
          continue;
        }
        graph[p.posix.normalize(file.path)] = dependencies(
          file.readAsStringSync(),
          file.path,
        );
      }
      expect(graph, isNotEmpty);
      expect(violations(graph), isEmpty);
    },
  );

  test(
    'boundary detects aliases, conditional imports and exported adapters',
    () {
      const view = 'lib/features/demo/presentation/view.dart';
      final fixtures = <String, List<Dependency>>{
        view: dependencies(
          "import 'package:hajnal/core/barrel.dart' as x;",
          view,
        ),
        'lib/core/barrel.dart': dependencies(
          "export 'database/hajnal_database.dart';",
          'lib/core/barrel.dart',
        ),
        'lib/core/database/hajnal_database.dart': const [],
      };
      expect(violations(fixtures), isNotEmpty);
      expect(
        allowed(
          view,
          dependencies(
            "import 'dart:math' if (dart.library.io) 'dart:io';",
            view,
          ).last.target,
        ),
        isFalse,
      );
      expect(
        allowed(
          view,
          dependencies(
            "import '../../../core/database/hajnal_database.dart' as hidden;",
            view,
          ).single.target,
        ),
        isFalse,
      );
      expect(
        allowed('lib/features/demo/domain/model.dart', 'dart:io'),
        isFalse,
      );
      expect(
        allowed(
          'lib/features/demo/application/controller.dart',
          'package:flutter/widgets.dart',
        ),
        isFalse,
      );
      expect(
        allowed(view, 'lib/core/artwork/drift_artwork_store.dart'),
        isFalse,
      );
      expect(allowed(view, 'package:unexpected/client.dart'), isFalse);
      expect(allowed(view, 'package:url_launcher/url_launcher.dart'), isFalse);
      expect(
        allowed(
          'lib/core/platform/emergency_dialer.dart',
          'package:url_launcher/url_launcher.dart',
        ),
        isTrue,
      );
      expect(
        allowed(view, 'lib/features/panic/data/panic_repository.dart'),
        isFalse,
      );
      expect(allowed('lib/core/other.dart', 'dart:io'), isFalse);
      expect(
        allowed('lib/core/other.dart', 'package:drift/drift.dart'),
        isFalse,
      );
      expect(
        allowed(
          'lib/features/demo/domain/model.dart',
          'lib/core/platform/date_picker.dart',
        ),
        isFalse,
      );
    },
  );

  test('lifecycle root imports only the predictive back event type', () {
    final source = File('lib/app/hajnal_app.dart').readAsStringSync();
    final imports = parseString(content: source).unit.directives
        .whereType<ImportDirective>()
        .where((d) => d.uri.stringValue == 'package:flutter/services.dart')
        .toList();
    expect(imports, hasLength(1));
    expect(
      imports.single.toSource(),
      "import 'package:flutter/services.dart' show PredictiveBackEvent;",
    );
  });

  test('storage mutations are owned by the designated adapters', () {
    const dbWriters = {
      'lib/features/recovery/data/recovery_repository.dart',
      'lib/features/panic/data/panic_repository.dart',
      'lib/features/onboarding/data/onboarding_repository.dart',
      'lib/features/sponsor/data/sponsor_repository.dart',
      'lib/features/app_lock/data/lock_repository.dart',
      'lib/core/artwork/drift_artwork_store.dart',
      'lib/core/theme/data/style_repository.dart',
    };
    const fileOwner = 'lib/core/artwork/artwork_service.dart';
    const fileMutations = {
      'writeAsBytes',
      'writeAsString',
      'writeAsBytesSync',
      'writeAsStringSync',
      'rename',
      'renameSync',
      'copy',
      'copySync',
      'openWrite',
      'create',
      'createSync',
      'deleteSync',
    };
    for (final file in Directory(
      'lib',
    ).listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart') || file.path.endsWith('.g.dart')) {
        continue;
      }
      final visitor = MutationCalls(file.path);
      parseString(
        content: file.readAsStringSync(),
        path: file.path,
      ).unit.accept(visitor);
      const tableOwners = {
        'recoveryPeriods':
            'lib/features/recovery/data/recovery_repository.dart',
        'sponsorContacts': 'lib/features/sponsor/data/sponsor_repository.dart',
        'onboardingProfiles':
            'lib/features/onboarding/data/onboarding_repository.dart',
        'onboardingDrafts':
            'lib/features/onboarding/data/onboarding_repository.dart',
        'styleSettings': 'lib/core/theme/data/style_repository.dart',
        'survivalSessions': 'lib/features/panic/data/panic_repository.dart',
        'survivalNotes': 'lib/features/panic/data/panic_repository.dart',
      };
      for (final table in visitor.dbTables) {
        expect(file.path, tableOwners[table], reason: 'write owner of $table');
      }
      if (!dbWriters.contains(file.path)) {
        expect(visitor.dbUpdates, isEmpty, reason: file.path);
        expect(visitor.calls, isNot(contains('into')), reason: file.path);
        for (final method in ['customInsert', 'customUpdate', 'customDelete']) {
          expect(visitor.calls, isNot(contains(method)), reason: file.path);
        }
      }
      if (file.path != fileOwner &&
          file.path != 'lib/features/app_lock/data/secure_lock_store.dart' &&
          !dbWriters.contains(file.path)) {
        expect(visitor.calls, isNot(contains('delete')), reason: file.path);
      }
      if (file.path != 'lib/core/database/hajnal_database.dart') {
        expect(
          visitor.calls,
          isNot(contains('customStatement')),
          reason: file.path,
        );
      }
      if (file.path != fileOwner) {
        expect(
          visitor.calls.where(fileMutations.contains),
          isEmpty,
          reason: file.path,
        );
      }
    }
  });
}
