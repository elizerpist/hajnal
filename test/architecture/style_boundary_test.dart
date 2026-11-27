import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:flutter_test/flutter_test.dart';

import 'dependency_graph_test.dart' as graph;

class VisualConstruction extends RecursiveAstVisitor<void> {
  final violations = <String>[];
  final owners = <String>[];
  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final name = node.constructorName.type.toSource();
    if (name == 'StyleOwner') owners.add(node.toSource());
    if (const {
      'TextStyle',
      'Color',
      'RoundedRectangleBorder',
      'Radius',
      'BorderRadius',
    }.contains(name)) {
      violations.add(node.toSource());
    }
    super.visitInstanceCreationExpression(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name == 'StyleOwner') owners.add(node.toSource());
    if (const {
      'TextStyle',
      'Color',
      'RoundedRectangleBorder',
      'Radius',
      'BorderRadius',
    }.contains(node.methodName.name)) {
      violations.add(node.toSource());
    }
    if (const {
      'Color',
      'Radius',
      'BorderRadius',
    }.contains(node.target?.toSource())) {
      violations.add(node.toSource());
    }
    super.visitMethodInvocation(node);
  }

  @override
  void visitNamedExpression(NamedExpression node) {
    if (const {
      'fontSize',
      'fontWeight',
      'fontFamily',
      'fontStyle',
      'letterSpacing',
    }.contains(node.name.label.name)) {
      violations.add(node.toSource());
    }
    super.visitNamedExpression(node);
  }
}

void main() {
  test('global style has one persistent writer and a pure domain', () {
    final domain = Directory('lib/core/theme/domain');
    expect(domain.existsSync(), isTrue);
    final production = Directory(
      'lib',
    ).listSync(recursive: true).whereType<File>();
    final writers = <String>[];
    for (final file in production) {
      if (!file.path.endsWith('.dart') || file.path.endsWith('.g.dart')) {
        continue;
      }
      final source = file.readAsStringSync();
      if (source.contains('.styleSettings') &&
          RegExp(r'\.(into|update|delete)\s*\(').hasMatch(source)) {
        writers.add(file.path);
      }
      if (file.path.contains('/theme/domain/')) {
        for (final dep in graph.dependencies(source, file.path)) {
          expect(
            dep.target.startsWith('package:flutter/'),
            isFalse,
            reason: file.path,
          );
          expect(
            dep.target.startsWith('package:drift/'),
            isFalse,
            reason: file.path,
          );
        }
      }
    }
    expect(writers, ['lib/core/theme/data/style_repository.dart']);
  });

  test('feature renderers do not redeclare shared visual styles', () {
    final ownerLocations = <String>[];
    for (final file in Directory(
      'lib',
    ).listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart') || file.path.endsWith('.g.dart')) {
        continue;
      }
      final source = file.readAsStringSync();
      final parsed = parseString(content: source, path: file.path);
      expect(parsed.errors, isEmpty, reason: file.path);
      final visitor = VisualConstruction();
      parsed.unit.accept(visitor);
      if (visitor.owners.isNotEmpty) ownerLocations.add(file.path);
      if (file.path.contains('/features/') &&
          file.path.contains('/presentation/')) {
        expect(visitor.violations, isEmpty, reason: file.path);
        expect(
          RegExp(r'\bColors\.(?!transparent\b)').hasMatch(source),
          isFalse,
          reason: '${file.path}: use semantic theme colors',
        );
      }
    }
    expect(ownerLocations, ['lib/app/app_services.dart']);
  });
}
