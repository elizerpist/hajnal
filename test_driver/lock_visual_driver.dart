import 'dart:io';
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver(
  responseDataCallback: (data) async {
    const names = {'lock-settings', 'lock-pin-setup', 'lock-biometric-step'};
    final screenshots = data?['screenshots'];
    if (screenshots is! List || screenshots.length != names.length) {
      throw StateError('Missing lock screenshots');
    }
    final found = <String>{};
    for (final item in screenshots) {
      final entry = item as Map;
      final name = entry['screenshotName'];
      final bytes = (entry['bytes'] as List).cast<int>();
      if (name is! String ||
          !names.contains(name) ||
          !found.add(name) ||
          bytes.length < 24 ||
          bytes[0] != 0x89 ||
          bytes[1] != 0x50 ||
          bytes[2] != 0x4e ||
          bytes[3] != 0x47) {
        throw StateError('Invalid lock screenshot');
      }
      await File('evidence/$name.png').writeAsBytes(bytes, flush: true);
    }
  },
);
