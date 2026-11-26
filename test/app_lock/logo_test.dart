import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/core/brand/brand_assets.dart';

void main() {
  testWidgets('official SVG loads in Flutter', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: SvgPicture.asset(BrandAssets.logo)),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(SvgPicture), findsOneWidget);
  });
}
