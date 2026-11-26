import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'package:cryptography/cryptography.dart';
import '../domain/lock_policy.dart';

class PinHasher {
  Future<String> create(String pin) async {
    if (!validPin(pin)) {
      throw ArgumentError('PIN must contain at least six digits');
    }
    final random = Random.secure();
    final salt = List<int>.generate(16, (_) => random.nextInt(256));
    final hash = await _derive(pin, salt);
    return jsonEncode({
      'version': 1,
      'salt': base64Encode(salt),
      'hash': base64Encode(hash),
    });
  }

  Future<bool> verify(String pin, String record) async {
    final data = jsonDecode(record);
    if (data is! Map ||
        data['version'] != 1 ||
        data['salt'] is! String ||
        data['hash'] is! String) {
      throw const FormatException('Invalid PIN credential');
    }
    final salt = base64Decode(data['salt'] as String);
    final expected = base64Decode(data['hash'] as String);
    if (salt.length != 16 || expected.length != 32) {
      throw const FormatException('Invalid PIN credential');
    }
    final actual = await _derive(pin, salt);
    var difference = 0;
    for (var i = 0; i < expected.length; i++) {
      difference |= expected[i] ^ actual[i];
    }
    return difference == 0;
  }

  Future<List<int>> _derive(String pin, List<int> salt) =>
      Isolate.run(() async {
        final algorithm = Argon2id(
          memory: 19456,
          parallelism: 1,
          iterations: 2,
          hashLength: 32,
        );
        final key = await algorithm.deriveKeyFromPassword(
          password: pin,
          nonce: salt,
        );
        return key.extractBytes();
      });
}
