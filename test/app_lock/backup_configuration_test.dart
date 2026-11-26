import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('backup keeps application data while excluding only secure storage', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    expect(manifest, isNot(contains('android:allowBackup="false"')));
    expect(manifest, contains('android:fullBackupContent="@xml/backup_rules"'));
    expect(
      manifest,
      contains('android:dataExtractionRules="@xml/data_extraction_rules"'),
    );
    for (final name in ['backup_rules', 'data_extraction_rules']) {
      final rules = File(
        'android/app/src/main/res/xml/$name.xml',
      ).readAsStringSync();
      expect(rules, contains('FlutterSecureStorage.xml'));
      expect(rules, contains('FlutterSecureKeyStorage.xml'));
      expect(rules, isNot(contains('domain="database"')));
      expect(rules, isNot(contains('domain="file"')));
    }
  });
}
