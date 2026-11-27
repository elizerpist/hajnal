import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hajnal/app/bootstrap_controller.dart';
import 'package:hajnal/app/hajnal_app.dart';
import 'package:hajnal/features/onboarding/application/date_picker.dart';
import 'package:hajnal/features/onboarding/application/onboarding_draft.dart';
import 'package:hajnal/features/onboarding/application/onboarding_store.dart';
import 'package:hajnal/features/recovery/application/recovery_store.dart';
import 'package:hajnal/features/app_lock/application/biometrics.dart';
import 'package:hajnal/features/app_lock/application/device_guard.dart';
import 'package:hajnal/features/app_lock/application/lock_controller.dart';
import 'package:hajnal/features/app_lock/application/lock_store.dart';
import 'package:hajnal/features/app_lock/domain/lock_policy.dart';
import 'package:hajnal/features/app_lock/presentation/pin_setup.dart';
import 'package:hajnal/core/theme/application/style_controller.dart';
import 'package:hajnal/core/theme/application/style_store.dart';
import 'package:hajnal/core/theme/domain/style_definitions.dart';

class VisualStyleStore implements StyleStore {
  StyleSnapshot current = StyleSnapshot(StyleDefinitions.defaults(), 0);
  @override
  Future<StyleSnapshot> load() async => current;
  @override
  Future<int> save(StyleDefinitions definitions, int expectedRevision) async {
    if (current.revision != expectedRevision) throw StateError('stale style');
    current = StyleSnapshot(definitions, expectedRevision + 1);
    return current.revision;
  }
}

// Visual evidence uses the real widgets and session rules; simulated platform
// responses make the biometric state reproducible without claiming hardware coverage.
class VisualStore implements LockStore {
  @override
  Future<StoredLock> read() async => const StoredLock(
    mode: LockMode.pinAndBiometric,
    slot: 'visual',
    retry: RetryState(),
  );
  @override
  Future<int> retryRemaining({
    required int uptime,
    required String boot,
  }) async => 0;
  @override
  Future<bool> verifyPin(
    String pin, {
    required int uptime,
    required String boot,
  }) async => pin == '123456';
  @override
  Future<void> setMode(LockMode mode, {String? newPin}) async =>
      throw UnsupportedError('visual evidence only');
}

class VisualBiometrics implements Biometrics {
  @override
  Future<BiometricResult> availability() async => BiometricResult.success;
  @override
  Future<BiometricResult> authenticate() async => BiometricResult.success;
  @override
  Future<void> cancel() async {}
}

class VisualDevice implements DeviceGuard {
  @override
  Future<DeviceTime> time() async => const DeviceTime(1, 'visual');
  @override
  Future<void> revealAfterFrame() async {}
}

class VisualRecovery implements RecoveryStore {
  @override
  Stream<ActiveRecovery?> watchStart() =>
      Stream.value(ActiveRecovery(1, DateTime(2024, 1, 1)));
  @override
  Future<void> correctStart(int id, DateTime date, DateTime now) async =>
      throw UnsupportedError('visual evidence only');
  @override
  Future<void> initialize(DateTime date, DateTime now) async =>
      throw UnsupportedError('visual evidence only');
}

class VisualPicker implements DatePicker {
  @override
  Future<DatePickerResult> pick(DateTime initial, DateTime today) async =>
      const DatePickCancelled();
}

class VisualOnboarding implements OnboardingStore {
  OnboardingDraft? draft;
  @override
  Future<OnboardingDraft> load(DateTime now) async =>
      draft ??
      OnboardingDraft(
        periodId: 1,
        date: DateTime(now.year, now.month, now.day),
        motivation: '',
        modules: const {},
        sponsorName: '',
        sponsorPhone: '',
        completed: true,
        baseline: const {
          'motivation': '',
          'modules': 0,
          'sponsorName': '',
          'sponsorPhone': '',
        },
      );
  @override
  Future<void> saveDraft(OnboardingDraft value) async {
    draft = value;
  }

  @override
  Future<void> finish(OnboardingDraft value, DateTime now) async {
    draft = value;
  }
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('capture real lock screens with simulated platform responses', (
    tester,
  ) async {
    final controller = LockController(
      VisualStore(),
      VisualBiometrics(),
      VisualDevice(),
    );
    await controller.initialize();
    final directory = await getApplicationSupportDirectory();
    await binding.convertFlutterSurfaceToImage();
    Future<void> capture(String name) async {
      await tester.pumpAndSettle();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(seconds: 1)),
      );
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 500)),
      );
      final bytes = await binding.takeScreenshot(name);
      expect(bytes, isNotEmpty);
      await File(
        '${directory.path}/$name.png',
      ).writeAsBytes(bytes, flush: true);
      if (name == 'boarding-welcome-1') {
        final pixels = await tester.runAsync(() async {
          final codec = await ui.instantiateImageCodec(
            Uint8List.fromList(bytes),
          );
          final frame = await codec.getNextFrame();
          final width = frame.image.width;
          final rgba = (await frame.image.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          ))!;
          frame.image.dispose();
          codec.dispose();
          return (width, rgba);
        });
        expect(pixels, isNotNull);
        final (width, rgba) = pixels!;
        expect(width, 412);
        int channel(int x, int y, int c) =>
            rgba.getUint8((y * width + x) * 4 + c);
        for (final x in [80, 100, 120]) {
          for (var c = 0; c < 3; c++) {
            expect(
              (channel(x, 114, c) - channel(x, 112, c)).abs(),
              lessThan(12),
            );
            expect(
              (channel(x, 114, c) - channel(x, 116, c)).abs(),
              lessThan(12),
            );
          }
        }
      }
    }

    await controller.submitPin('123456');
    await controller.submitBiometric();
    final bootstrap = BootstrapController(VisualRecovery(), DateTime.now);
    final style = StyleOwner(VisualStyleStore());
    await style.load();
    try {
      await tester.pumpWidget(
        HajnalApp(
          controller: bootstrap,
          picker: VisualPicker(),
          lock: controller,
          onboardingStore: VisualOnboarding(),
          style: style,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Menü'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Onboarding'));
      await tester.pumpAndSettle();
      await tester.runAsync(() => vg.waitForPendingDecodes());
      await capture('boarding-welcome-1');
      await tester.tap(find.text('Beállítások áttekintése'));
      await capture('boarding-welcome-2');
      await tester.tap(find.text('Tovább'));
      await capture('boarding-welcome-3');
      await tester.tap(find.text('Értem, tovább'));
      await capture('boarding-date');
      await tester.tap(find.byKey(const Key('calendar-year')));
      await capture('calendar-years');
      await tester.tap(find.byKey(const Key('calendar-month')));
      await capture('calendar-months');
      await tester.tap(find.byKey(const Key('calendar-month')));
      await tester.pumpAndSettle();
      final now = DateTime.now();
      final previous = DateTime(now.year, now.month, now.day - 1);
      if (previous.month != now.month) {
        await tester.tap(find.byTooltip('Előző hónap'));
        await tester.pumpAndSettle();
      }
      await tester.tap(
        find.byKey(
          Key(
            'calendar-day-${previous.year}-${previous.month}-${previous.day}',
          ),
        ),
      );
      await tester.pumpAndSettle();
      if (previous.month != now.month) {
        await tester.ensureVisible(find.byTooltip('Következő hónap'));
        await tester.tap(find.byTooltip('Következő hónap'));
      }
      await capture('calendar-today-outline');
      await tester.ensureVisible(find.text('Ma'));
      await tester.tap(find.text('Ma'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Tovább'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tovább'));
      await capture('boarding-motivation');
      await tester.ensureVisible(find.text('Tovább'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tovább'));
      await capture('boarding-modules');
      await tester.tap(find.text('Szponzor'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Tovább'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tovább'));
      await capture('boarding-sponsor');
      await tester.tap(find.text('Hozzáadom a szponzoromat'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('sponsor-phone')));
      await tester.pumpAndSettle();
      await capture('boarding-sponsor-expanded');
      await tester.tap(find.byTooltip('Bezárás'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Menü'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Alkalmazászár'));
      await tester.pumpAndSettle();
      expect(find.text('Te döntöd el, hogyan lépsz be.'), findsOneWidget);
      await capture('lock-settings');
      final backTooltip = MaterialLocalizations.of(
        tester.element(find.text('Te döntöd el, hogyan lépsz be.')),
      ).backButtonTooltip;
      await tester.tap(find.byTooltip(backTooltip));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Menü'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Stílus'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Title 1'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(Slider).first);
      await tester.pumpAndSettle();
      final titleSlider = tester.getRect(find.byType(Slider).first);
      await tester.tapAt(
        Offset(
          titleSlider.left + titleSlider.width * .58,
          titleSlider.center.dy,
        ),
      );
      await Scrollable.ensureVisible(
        tester.element(find.text('Title 1')),
        alignment: .05,
      );
      await capture('style-editor');
      await tester.scrollUntilVisible(
        find.text('Nagy kártya'),
        300,
        scrollable: find
            .descendant(
              of: find.byType(ListView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Nagy kártya'));
      await tester.pumpAndSettle();
      final largeSection = find
          .ancestor(
            of: find.text('Nagy kártya'),
            matching: find.byType(ExpansionTile),
          )
          .first;
      final cardSliders = find.descendant(
        of: largeSection,
        matching: find.byType(Slider),
      );
      await tester.ensureVisible(cardSliders.at(1));
      await tester.pumpAndSettle();
      final radiusSlider = tester.getRect(cardSliders.at(1));
      await tester.tapAt(
        Offset(
          radiusSlider.left + radiusSlider.width * .55,
          radiusSlider.center.dy,
        ),
      );
      await Scrollable.ensureVisible(
        tester.element(find.text('Példa kártya')),
        alignment: .2,
      );
      await tester.pumpAndSettle();
      await capture('style-preview-card');
      await tester.tap(find.text('Alkalmazás'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Menü'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Onboarding'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Beállítások áttekintése'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tovább'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Értem, tovább'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Tovább'));
      await tester.tap(find.text('Tovább'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Tovább'));
      await tester.tap(find.text('Tovább'));
      await capture('style-onboarding');
      await tester.tap(find.byTooltip('Bezárás'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Menü'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Alkalmazászár'));
      await capture('style-lock');
      final navigator = Navigator.of(
        tester.element(find.text('Alkalmazászár').last),
      );
      unawaited(
        navigator.push<void>(
          MaterialPageRoute(builder: (_) => const PinSetup()),
        ),
      );
      await tester.pumpAndSettle();
      for (final digit in '123456'.split('')) {
        await tester.tap(find.text(digit));
        await tester.pump();
      }
      await capture('lock-pin-setup');
      controller.background();
      controller.resumed();
      await controller.submitPin('123456');
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.text('Jó, hogy itt vagy.'), findsOneWidget);
      await tester.runAsync(() => vg.waitForPendingDecodes());
      await tester.pumpAndSettle();
      await capture('lock-biometric-step');
    } finally {
      await File(
        '${directory.path}/lock-visual-ready',
      ).writeAsString('ready', flush: true);
      await tester.runAsync(() async {
        final copied = File('${directory.path}/lock-visual-copied');
        final deadline = DateTime.now().add(const Duration(minutes: 5));
        while (!await copied.exists()) {
          if (DateTime.now().isAfter(deadline)) {
            throw TimeoutException('Screenshots were not collected');
          }
          await Future<void>.delayed(const Duration(milliseconds: 500));
        }
      });
      await tester.pumpWidget(const SizedBox());
      bootstrap.dispose();
      controller.dispose();
      style.dispose();
    }
  });
}
