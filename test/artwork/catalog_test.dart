import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/core/artwork/artwork_catalog.dart';

void main() {
  test(
    'dashboard artwork catalog has a stable, fully described placeholder',
    () {
      expect(dashboardArtwork.id, 'dashboard.default');
      expect(dashboardArtwork.role, 'dashboard.default');
      expect(dashboardArtwork.revision, 'bundle-1');
      expect(dashboardArtwork.width, 853);
      expect(dashboardArtwork.height, 1843);
      expect(dashboardArtwork.aspectRatio, closeTo(853 / 1843, 0.000001));
      expect(dashboardArtwork.crop, 'cover');
      expect(dashboardArtwork.focus, 'center-top');
      expect(dashboardArtwork.placeholder, isTrue);
      expect(dashboardArtwork.source, contains('app-shell'));
      expect(File(dashboardArtwork.asset).existsSync(), isTrue);
    },
  );
}
