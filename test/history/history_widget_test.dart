import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:hajnal/core/database/hajnal_database.dart';
import 'package:hajnal/app/bootstrap_controller.dart';
import 'package:hajnal/app/hajnal_app.dart';
import 'package:hajnal/core/artwork/artwork_catalog.dart';
import 'package:hajnal/core/theme/hajnal_theme.dart';
import 'package:hajnal/features/history/application/history_controller.dart';
import 'package:hajnal/features/history/application/history_store.dart';
import 'package:hajnal/features/history/presentation/history_page.dart';
import 'package:hajnal/features/history/presentation/history_calendar.dart';
import 'package:hajnal/features/history/data/history_repository.dart';
import 'package:hajnal/features/panic/data/panic_repository.dart';
import 'package:hajnal/features/recovery/data/recovery_repository.dart';
import 'package:hajnal/features/recovery/application/recovery_store.dart';
import '../widget_test.dart' as fixtures;

class HistoryFixture implements HistoryStore {
  final stream = StreamController<List<HistoryPeriod>>.broadcast(sync: true);
  @override
  Stream<List<HistoryPeriod>> watch() => stream.stream;
}

Future<void> waitForHistory(
  HistoryController controller,
  bool Function() ready,
) async {
  if (ready()) return;
  final done = Completer<void>();
  void check() {
    if (ready() && !done.isCompleted) done.complete();
  }

  controller.addListener(check);
  try {
    await done.future.timeout(const Duration(seconds: 10));
  } finally {
    controller.removeListener(check);
  }
}

HistoryPeriod chapter(
  int id, {
  bool active = true,
  List<HistoryNote> notes = const [],
}) => HistoryPeriod(
  id: id,
  start: DateTime(2025, 4, 1),
  createdAt: DateTime.utc(2025, 4, 1),
  closedAt: active ? null : DateTime.utc(2025, 4, 4),
  notes: notes,
);

void main() {
  testWidgets('history remains usable on a small screen with enlarged text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final history = HistoryFixture();
    final controller = HistoryController(history, () => DateTime(2025, 4, 5));
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('hu'),
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: const [Locale('hu')],
        theme: hajnalTheme(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.5)),
          child: child!,
        ),
        home: HistoryPage(controller: controller),
      ),
    );
    history.stream.add([chapter(1)]);
    await tester.pumpAndSettle();
    final initialError = tester.takeException();
    expect(
      tester.getBottomLeft(find.text('Fejezeteim és emlékeim')).dy,
      lessThanOrEqualTo(
        tester.getTopLeft(find.byKey(const Key('history-period-card'))).dy,
      ),
    );
    await tester.ensureVisible(find.text('Számokban'));
    await tester.tap(find.text('Számokban'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Idővonalam számokban'));
    await tester.tap(find.byTooltip('Naptár'));
    await tester.pumpAndSettle();
    final calendarError = tester.takeException();
    expect(initialError ?? calendarError, isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
    await history.stream.close();
  });
  testWidgets('dashboard history button opens and returns to the dashboard', (
    tester,
  ) async {
    final recovery = fixtures.MemoryStore();
    final bootstrap = BootstrapController(recovery, () => DateTime(2025, 4, 5));
    final history = HistoryFixture();
    await tester.pumpWidget(
      HajnalApp(
        controller: bootstrap,
        picker: fixtures.CancelPicker(),
        history: history,
      ),
    );
    recovery.stream.add(ActiveRecovery(1, DateTime(2025, 4, 1)));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Történetem'));
    await tester.pump();
    history.stream.add([chapter(1)]);
    await tester.pumpAndSettle();
    expect(find.byType(HistoryPage), findsOneWidget);
    await tester.tap(find.byTooltip('Vissza'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Történetem'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    bootstrap.dispose();
    await recovery.stream.close();
    await history.stream.close();
  });
  testWidgets(
    'committed note updates both views and statistics without reopening',
    (tester) async {
      tester.view.physicalSize = const Size(412, 892);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final db = HajnalDatabase(NativeDatabase.memory());
      final recovery = RecoveryRepository(db);
      final first = await tester.runAsync(
        () => recovery.initialize(DateTime(2025, 4, 1), DateTime(2025, 4, 5)),
      );
      final controller = (await tester.runAsync(
        () async => HistoryController(
          HistoryRepository(db),
          () => DateTime(2025, 4, 5),
        ),
      ))!;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('hu'),
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: const [Locale('hu')],
          theme: hajnalTheme(),
          home: HistoryPage(controller: controller),
          debugShowCheckedModeBanner: false,
        ),
      );
      await tester.runAsync(
        () => waitForHistory(controller, () => controller.periods.isNotEmpty),
      );
      await tester.pumpAndSettle();
      expect(find.text('Kezdet'), findsOneWidget);
      await tester.runAsync(
        () => PanicRepository(
          db,
        ).saveNote('Frissen mentett', DateTime(2025, 4, 5, 10)),
      );
      await tester.runAsync(
        () => waitForHistory(
          controller,
          () => controller.periods.single.notes.isNotEmpty,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Frissen mentett'), findsOneWidget);
      await tester.tap(find.text('Számokban'));
      await tester.pumpAndSettle();
      expect(find.text('1 pánikjegyzet'), findsOneWidget);
      await tester.tap(find.byTooltip('Naptár'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('history-dot-2025-4-5')),
        findsOneWidget,
      );
      await tester.drag(find.byType(HistoryCalendar), const Offset(0, -350));
      await tester.pumpAndSettle();
      expect(find.text('Frissen mentett'), findsOneWidget);
      await tester.runAsync(
        () => recovery.restart(first!.id, DateTime(2025, 4, 6)),
      );
      await tester.runAsync(
        () => waitForHistory(controller, () => controller.periods.length == 2),
      );
      await tester.pumpAndSettle();
      expect(controller.periods.length, 2);
      expect(controller.periods.first.closedAt, isNotNull);
      expect(controller.selectedId, controller.periods.last.id);
      expect(find.text('0 nap tiszta'), findsOneWidget);
      await tester.tap(find.byTooltip('Idővonal'));
      await tester.pumpAndSettle();
      await tester.drag(
        find.byKey(const Key('history-pager')),
        const Offset(330, 0),
      );
      await tester.pumpAndSettle();
      expect(find.text('LEZÁRT IDŐSZAK'), findsOneWidget);
      expect(find.text('Frissen mentett'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.runAsync(() async {
        controller.dispose();
        await db.close();
      });
    },
  );
  testWidgets(
    'timeline, calendar, full note popup, stats and chapter swipe share live data',
    (tester) async {
      final destination = Platform.environment['HAJNAL_CAPTURE_DIR'];
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
      tester.view.physicalSize = const Size(412, 892);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final fixture = HistoryFixture();
      final controller = HistoryController(fixture, () => DateTime(2025, 4, 5));
      final capture = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: capture,
          child: MaterialApp(
            locale: const Locale('hu'),
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            supportedLocales: const [Locale('hu')],
            theme: hajnalTheme(),
            home: HistoryPage(controller: controller),
            debugShowCheckedModeBanner: false,
          ),
        ),
      );
      fixture.stream.add([chapter(1, active: false), chapter(2)]);
      await tester.pumpAndSettle();
      expect(controller.selectedId, 2);
      expect(find.text('Kezdet'), findsOneWidget);
      Future<void> shot(String name) async {
        if (destination == null) return;
        await tester.runAsync(
          () => precacheImage(
            const AssetImage(historyArtwork),
            tester.element(find.byType(HistoryPage)),
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
          await Directory(destination).create(recursive: true);
          await File(
            '$destination/$name.png',
          ).writeAsBytes(bytes.buffer.asUint8List());
          image.dispose();
        });
      }

      await shot('history-timeline');
      final note = HistoryNote(
        8,
        'A teljes mentett jegyzet szövege',
        DateTime(2025, 4, 5, 10).toUtc(),
      );
      fixture.stream.add([
        chapter(1, active: false),
        chapter(2, notes: [note]),
      ]);
      await tester.pumpAndSettle();
      expect(find.text('Pánikjegyzet'), findsOneWidget);
      await tester.tap(find.text('Pánikjegyzet'));
      await tester.pumpAndSettle();
      expect(find.text(note.text), findsWidgets);
      await tester.tap(find.text('Bezárás'));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Számokban'));
      await tester.pumpAndSettle();
      expect(find.text('1 pánikjegyzet'), findsOneWidget);
      await shot('history-expanded');
      await tester.tap(find.text('Számokban'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Naptár'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('history-dot-2025-4-5')),
        findsOneWidget,
      );
      await shot('history-calendar');
      await tester.drag(find.byType(HistoryCalendar), const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(find.text('Pánikjegyzet'), findsOneWidget);
      await tester.drag(find.byType(HistoryCalendar), const Offset(0, 300));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sáv'));
      await tester.pumpAndSettle();
      expect(find.text('Pánikjegyzet'), findsOneWidget);
      await tester.tap(find.widgetWithText(ChoiceChip, '2025. 04. 01.'));
      await tester.pumpAndSettle();
      expect(find.text('Kezdet'), findsOneWidget);
      expect(controller.selectedId, 2);
      await tester.tap(find.text('Naptár'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Következő hónap'));
      await tester.pumpAndSettle();
      expect(controller.selectedId, 2);
      await tester.tap(find.byTooltip('Előző hónap'));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(HistoryCalendar), const Offset(0, -150));
      await tester.pumpAndSettle();
      expect(controller.selectedId, 2);
      await tester.tap(find.byTooltip('Idővonal'));
      await tester.pumpAndSettle();
      await tester.drag(
        find.byKey(const Key('history-pager')),
        const Offset(330, 0),
      );
      await tester.pumpAndSettle();
      expect(controller.selectedId, 1);
      expect(find.text('LEZÁRT IDŐSZAK'), findsOneWidget);
      await shot('history-closed');
      controller.dispose();
      await fixture.stream.close();
    },
  );
}
