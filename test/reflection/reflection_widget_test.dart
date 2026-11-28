import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/core/theme/hajnal_theme.dart';
import 'package:hajnal/features/reflection/application/reflection_controller.dart';
import 'package:hajnal/features/reflection/application/reflection_store.dart';
import 'package:hajnal/features/reflection/presentation/reflection_page.dart';
import 'package:hajnal/app/bootstrap_controller.dart';
import 'package:hajnal/app/hajnal_app.dart';
import 'package:hajnal/features/recovery/application/recovery_store.dart';
import 'package:hajnal/features/practice/application/practice_store.dart';
import '../dashboard/dashboard_layout_test.dart' show Picker, Store;

class MemoryReflection implements ReflectionStore {
  final enabled = StreamController<bool>.broadcast();
  ReflectionEntry entry = ReflectionEntry(
    id: 1,
    periodId: 1,
    date: DateTime(2026, 1, 1),
  );
  @override
  Stream<bool> watchEnabled() => enabled.stream;
  @override
  Future<ReflectionEntry> open(int periodId, DateTime date) async => entry;
  @override
  Future<ReflectionEntry> openById(int id) async => entry;
  @override
  Future<void> saveDraft(ReflectionEntry value) async {
    entry = value;
  }

  @override
  Future<void> finish(ReflectionEntry value) async {
    entry = value.copyWith(completed: value.hasContent);
  }
}

void main() {
  testWidgets('an older reflection shows its own date', (tester) async {
    final store = MemoryReflection();
    final controller = ReflectionController(store);
    await controller.open(1, store.entry.date);
    await tester.pumpWidget(
      MaterialApp(
        theme: hajnalTheme(),
        home: ReflectionPage(controller: controller),
      ),
    );
    final context = tester.element(find.byType(ReflectionPage));
    expect(
      find.text(
        MaterialLocalizations.of(context).formatCompactDate(store.entry.date),
      ),
      findsOneWidget,
    );
    expect(find.text('A mai nap'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
    await store.enabled.close();
  });
  testWidgets('today remains labelled as today', (tester) async {
    final store = MemoryReflection();
    store.entry = ReflectionEntry(id: 1, periodId: 1, date: DateTime.now());
    final controller = ReflectionController(store);
    await controller.open(1, store.entry.date);
    await tester.pumpWidget(
      MaterialApp(
        theme: hajnalTheme(),
        home: ReflectionPage(controller: controller),
      ),
    );
    expect(find.text('A mai nap'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
    await store.enabled.close();
  });
  testWidgets(
    'reflection entry fits 220 by 320 at triple text scale with system inset',
    (tester) async {
      tester.view.physicalSize = const Size(220, 320);
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(top: 24, bottom: 48);
      tester.platformDispatcher.textScaleFactorTestValue = 3;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPadding);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final recovery = Store();
      final bootstrap = BootstrapController(
        recovery,
        () => DateTime(2026, 1, 2),
      );
      final store = MemoryReflection();
      await tester.pumpWidget(
        HajnalApp(controller: bootstrap, picker: Picker(), reflection: store),
      );
      recovery.stream.add(ActiveRecovery(1, DateTime(2026, 1, 1)));
      await tester.pumpAndSettle();
      store.enabled.add(true);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('daily-reflection-entry')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      bootstrap.dispose();
      await recovery.stream.close();
      await store.enabled.close();
    },
  );
  testWidgets('last typed text is saved when leaving the draft', (
    tester,
  ) async {
    final store = MemoryReflection();
    final controller = ReflectionController(store);
    await controller.open(1, DateTime(2026));
    await tester.pumpWidget(
      MaterialApp(
        theme: hajnalTheme(),
        home: ReflectionPage(controller: controller),
      ),
    );
    await tester.tap(find.text('Tovább'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Az utolsó betű');
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await controller.idle;
    expect(store.entry.text, 'Az utolsó betű');
    expect(store.entry.completed, isFalse);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
    await store.enabled.close();
  });
  testWidgets(
    'two-step flow saves a mood without practice and can deselect it',
    (tester) async {
      final store = MemoryReflection();
      final controller = ReflectionController(store);
      await controller.open(1, DateTime(2026));
      await tester.pumpWidget(
        MaterialApp(
          theme: hajnalTheme(),
          home: ReflectionPage(controller: controller),
        ),
      );
      await tester.tap(find.text('Jó volt'));
      await tester.pump();
      expect(controller.entry!.mood, 5);
      await tester.tap(find.text('Jó volt'));
      await tester.pump();
      expect(controller.entry!.mood, isNull);
      await tester.tap(find.text('Jó volt'));
      await tester.tap(find.text('Tovább'));
      await tester.pumpAndSettle();
      expect(find.text('Mentés'), findsOneWidget);
      await tester.tap(find.text('Mentés'));
      await tester.pumpAndSettle();
      expect(store.entry.completed, isTrue);
      expect(store.entry.mood, 5);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
      await store.enabled.close();
    },
  );
  testWidgets('all three reflection states render their real widgets', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(412, 892);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = MemoryReflection();
    store.entry = ReflectionEntry(
      id: 1,
      periodId: 1,
      date: DateTime(2026),
      snapshot: const PracticeSnapshot(
        title: 'Figyelek magamra',
        text: 'Megállok egy pillanatra.',
      ),
    );
    final controller = ReflectionController(store);
    await controller.open(1, DateTime(2026));
    final capture = GlobalKey();
    final destination = Platform.environment['HAJNAL_REFLECTION_CAPTURE'];
    if (destination != null) {
      await tester.runAsync(() async {
        final text = FontLoader('Roboto')
          ..addFont(rootBundle.load('assets/fonts/roboto/Roboto.ttf'));
        final icons = FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
        await text.load();
        await icons.load();
      });
    }
    await tester.pumpWidget(
      RepaintBoundary(
        key: capture,
        child: MaterialApp(
          theme: hajnalTheme(),
          debugShowCheckedModeBanner: false,
          home: ReflectionPage(controller: controller),
        ),
      ),
    );
    Future<void> take(String name) async {
      if (destination == null) return;
      final context = tester.element(find.byType(Scaffold));
      await tester.runAsync(
        () => precacheImage(
          AssetImage('assets/artwork/reflection/daily_reflection_$name.png'),
          context,
        ),
      );
      await tester.pumpAndSettle();
      final boundary =
          capture.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 1);
        final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!;
        image.dispose();
        await Directory(destination).create(recursive: true);
        await File(
          '$destination/$name.png',
        ).writeAsBytes(bytes.buffer.asUint8List());
      });
    }

    await tester.pumpAndSettle();
    expect(find.text('Hogyan érezted magad ma?'), findsOneWidget);
    await take('mood');
    await tester.tap(find.text('Tovább'));
    await tester.pumpAndSettle();
    expect(find.text('Mi maradt meg benned ma?'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Az én napom');
    await tester.tap(find.text('Amit megőrzök'));
    await tester.pumpAndSettle();
    expect(find.text('Az én napom'), findsOneWidget);
    await take('writing');
    await tester.tap(find.text('Mentés és folytatás'));
    await tester.pumpAndSettle();
    expect(find.text('Megállok egy pillanatra.'), findsOneWidget);
    await take('practice');
    await tester.tap(find.text('Eszembe jutott.'));
    await tester.pumpAndSettle();
    await controller.idle;
    expect(store.entry.observation, 'remembered');
    await tester.ensureVisible(find.text('Befejezés'));
    await tester.tap(find.text('Befejezés'));
    await tester.pumpAndSettle();
    expect(store.entry.completed, isTrue);
    expect(store.entry.text, 'Az én napom');
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
    await store.enabled.close();
  });
  testWidgets(
    'dashboard action taps the reflection while drag still opens sheet',
    (tester) async {
      tester.view.physicalSize = const Size(412, 892);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final recovery = Store();
      final bootstrap = BootstrapController(
        recovery,
        () => DateTime(2026, 1, 2),
      );
      final store = MemoryReflection();
      final capture = GlobalKey();
      final destination = Platform.environment['HAJNAL_REFLECTION_CAPTURE'];
      if (destination != null) {
        await tester.runAsync(() async {
          final text = FontLoader('Roboto')
            ..addFont(rootBundle.load('assets/fonts/roboto/Roboto.ttf'));
          final icons = FontLoader('MaterialIcons')
            ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
          await text.load();
          await icons.load();
        });
      }
      await tester.pumpWidget(
        RepaintBoundary(
          key: capture,
          child: HajnalApp(
            controller: bootstrap,
            picker: Picker(),
            reflection: store,
          ),
        ),
      );
      recovery.stream.add(ActiveRecovery(1, DateTime(2026, 1, 1)));
      await tester.pumpAndSettle();
      store.enabled.add(true);
      await tester.pumpAndSettle();
      if (destination != null) {
        final context = tester.element(find.byType(Scaffold).first);
        await tester.runAsync(
          () => precacheImage(
            const AssetImage('assets/artwork/dashboard/placeholder.png'),
            context,
          ),
        );
        await tester.pumpAndSettle();
        final boundary =
            capture.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 1);
          final bytes = (await image.toByteData(
            format: ui.ImageByteFormat.png,
          ))!;
          image.dispose();
          await Directory(destination).create(recursive: true);
          await File(
            '$destination/dashboard.png',
          ).writeAsBytes(bytes.buffer.asUint8List());
        });
      }
      final card = find.byKey(const Key('summary-card'));
      final button = find.byKey(const Key('daily-reflection-entry'));
      expect(button, findsOneWidget);
      store.enabled.add(false);
      await tester.pumpAndSettle();
      expect(button, findsNothing);
      store.enabled.add(true);
      await tester.pumpAndSettle();
      expect(button, findsOneWidget);
      final closed = tester.getTopLeft(card).dy;
      await tester.drag(button, const Offset(0, -100));
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(card).dy, lessThan(closed));
      expect(find.byType(ReflectionPage), findsNothing);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(find.byType(ReflectionPage), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      bootstrap.dispose();
      await recovery.stream.close();
      await store.enabled.close();
    },
  );
  testWidgets(
    'mood, text and draft survive a small screen with enlarged text',
    (tester) async {
      tester.view.physicalSize = const Size(220, 320);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = MemoryReflection();
      final controller = ReflectionController(store);
      await controller.open(1, DateTime(2026));
      await tester.pumpWidget(
        MaterialApp(
          theme: hajnalTheme(),
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(220, 320),
              textScaler: TextScaler.linear(3),
              padding: EdgeInsets.only(bottom: 24),
            ),
            child: ReflectionPage(controller: controller),
          ),
        ),
      );
      await tester.pump();
      controller.update(controller.entry!.copyWith(mood: 4));
      controller.move(1);
      await tester.pump();
      controller.update(controller.entry!.copyWith(text: 'Saját szöveg'));
      controller.update(controller.entry!.copyWith(prompt: 'keep'));
      await controller.idle;
      expect(store.entry.mood, 4);
      expect(store.entry.text, 'Saját szöveg');
      expect(store.entry.prompt, 'keep');
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
      await store.enabled.close();
    },
  );
}
