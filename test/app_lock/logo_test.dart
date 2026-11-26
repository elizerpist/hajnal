import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/core/brand/brand_assets.dart';

void main() {
  testWidgets('official SVG actually paints visible logo pixels', (
    tester,
  ) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: RepaintBoundary(
            key: key,
            child: SvgPicture.asset(BrandAssets.logo, width: 120, height: 120),
          ),
        ),
      ),
    );
    await tester.runAsync(() => vg.waitForPendingDecodes());
    await tester.pumpAndSettle();
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(key),
    );
    final image = (await tester.runAsync(() => boundary.toImage()))!;
    final data = (await tester.runAsync(
      () => image.toByteData(format: ui.ImageByteFormat.rawRgba),
    ))!;
    final bytes = data.buffer.asUint8List();
    var visible = 0;
    for (var i = 3; i < bytes.length; i += 4) {
      if (bytes[i] > 0) {
        visible++;
      }
    }
    image.dispose();
    expect(visible, greaterThan(5000));
  });
}
