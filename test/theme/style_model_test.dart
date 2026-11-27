import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/core/theme/domain/style_definitions.dart';

void main() {
  test('defaults and validated round trip preserve global definitions', () {
    final value = StyleDefinitions.defaults();
    expect(value.texts[TextRole.title1]!.size, 28);
    expect(value.texts[TextRole.title2]!.size, 16);
    expect(value.cards[CardRole.large]!.minHeight, 88);
    expect(StyleDefinitions.decode(value.encode()).encode(), value.encode());
  });

  test('invalid or unsupported style data is rejected', () {
    expect(
      () => StyleDefinitions.decode('{"version":999}'),
      throwsFormatException,
    );
    expect(() => StyleDefinitions.decode('broken'), throwsFormatException);
  });
}
