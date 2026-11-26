import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/features/app_lock/data/pin_hasher.dart';

void main() {
  test(
    'salted PIN hashes verify leading zero and reject the prior PIN',
    () async {
      final hasher = PinHasher();
      final a = await hasher.create('001234');
      final b = await hasher.create('001234');
      expect(a, isNot(b));
      expect(a, isNot(contains('001234')));
      expect(await hasher.verify('001234', a), isTrue);
      expect(await hasher.verify('1234', a), isFalse);
      await expectLater(hasher.verify('001234', '{}'), throwsFormatException);
    },
  );
}
