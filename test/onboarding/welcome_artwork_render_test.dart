import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('welcome sky renders as a continuous gradient', (tester) async {
    tester.view.physicalSize = const Size(412, 892);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final boundary = GlobalKey();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: RepaintBoundary(
          key: boundary,
          child: SizedBox.expand(
            child: SvgPicture.asset(
              'assets/artwork/onboarding/welcome.svg',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
    await tester.runAsync(() => vg.waitForPendingDecodes());
    await tester.pumpAndSettle();
    final object =
        boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = (await tester.runAsync(object.toImage))!;
    final bytes = (await tester.runAsync(
      () => image.toByteData(format: ui.ImageByteFormat.rawRgba),
    ))!;
    int channel(int x, int y, int component) =>
        bytes.getUint8((y * image.width + x) * 4 + component);
    for (final x in [80, 100, 120, 270, 360]) {
      for (var c = 0; c < 3; c++) {
        expect(
          (channel(x, 114, c) - channel(x, 112, c)).abs(),
          lessThan(12),
          reason: 'discontinuous sky at x=$x',
        );
        expect(
          (channel(x, 114, c) - channel(x, 116, c)).abs(),
          lessThan(12),
          reason: 'discontinuous sky at x=$x',
        );
      }
    }
    image.dispose();
  });
}
