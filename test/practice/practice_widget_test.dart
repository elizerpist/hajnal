import 'package:hajnal/app/bootstrap_controller.dart';
import 'package:hajnal/app/hajnal_app.dart';
import 'package:hajnal/features/recovery/application/recovery_store.dart';
import '../dashboard/dashboard_layout_test.dart' show Store, Picker;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/core/theme/hajnal_theme.dart';
import 'package:hajnal/features/practice/application/practice_controller.dart';
import 'package:hajnal/features/practice/application/practice_store.dart';
import 'package:hajnal/features/practice/presentation/practice_manager.dart';

class MemoryPracticeStore implements PracticeStore {
  final events = StreamController<List<PracticeCard>>.broadcast(sync: true);
  final cards = <PracticeCard>[];
  int next = 1;
  void emit() => events.add(List.unmodifiable(cards));
  @override
  Stream<List<PracticeCard>> watch() => events.stream;
  PracticeCard copy(PracticeCard c, {String? status, String? text}) =>
      PracticeCard(
        id: c.id,
        text: text ?? c.text,
        status: status ?? c.status,
        createdAt: c.createdAt,
        updatedAt: c.updatedAt,
      );
  @override
  Future<void> add(PracticeContent content, {required bool activate}) async {
    if (activate) {
      for (var i = 0; i < cards.length; i++) {
        if (cards[i].status == 'active') {
          cards[i] = copy(cards[i], status: 'paused');
        }
      }
    }
    cards.add(
      PracticeCard(
        id: next++,
        text: content.text,
        status: activate ? 'active' : 'paused',
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      ),
    );
    emit();
  }

  @override
  Future<void> saveChanges(int id, PracticeContent content) async {
    final i = cards.indexWhere((c) => c.id == id);
    cards[i] = copy(cards[i], text: content.text);
    emit();
  }

  @override
  Future<void> activate(int id) async {
    for (var i = 0; i < cards.length; i++) {
      cards[i] = copy(
        cards[i],
        status: cards[i].id == id ? 'active' : 'paused',
      );
    }
    emit();
  }

  @override
  Future<void> remove(int id) async {
    cards.removeWhere((c) => c.id == id);
    emit();
  }
}

void main() {
  testWidgets('small viewport and large text keep practice controls usable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = MemoryPracticeStore();
    final controller = PracticeController(store);
    await store.add(
      const PracticeContent(text: 'Egy hosszabb személyes mondat a kártyámon.'),
      activate: true,
    );
    await store.add(
      const PracticeContent(text: 'Másik elmentett kártya'),
      activate: false,
    );
    await store.add(
      const PracticeContent(text: 'Harmadik elmentett kártya'),
      activate: false,
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: hajnalTheme(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.5)),
          child: child!,
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => PracticeManager(controller: controller),
              ),
              child: const Text('Kártyák'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Kártyák'));
    await tester.pumpAndSettle();
    expect(find.text('＋ Új kártya hozzáadása'), findsOneWidget);
    await tester.ensureVisible(find.text('＋ Új kártya hozzáadása'));
    await tester.tap(find.text('＋ Új kártya hozzáadása'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Segíts elindulni'));
    await tester.tap(find.text('Segíts elindulni'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Apró lépés'));
    await tester.tap(find.text('Apró lépés'));
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
    await store.events.close();
  });
  testWidgets('dashboard and manager observe the same active card', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(412, 892);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final recovery = Store();
    final bootstrap = BootstrapController(recovery, DateTime.now);
    final store = MemoryPracticeStore();
    final practice = PracticeController(store);
    await store.add(const PracticeContent(text: 'Első szöveg'), activate: true);
    await store.add(
      const PracticeContent(text: 'Második szöveg'),
      activate: false,
    );
    await tester.pumpWidget(
      HajnalApp(controller: bootstrap, picker: Picker(), practice: practice),
    );
    recovery.stream.add(ActiveRecovery(1, DateTime(2024)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('summary-card')));
    await tester.pumpAndSettle();
    expect(find.text('Első szöveg'), findsOneWidget);
    await tester.tap(find.byKey(const Key('dashboard-practice')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Második szöveg aktiválása'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Bezárás'));
    await tester.pumpAndSettle();
    expect(find.text('Második szöveg'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    bootstrap.dispose();
    practice.dispose();
    await recovery.stream.close();
    await store.events.close();
  });
  testWidgets(
    'create, prompt switching, separate body and activation, confirm delete',
    (tester) async {
      final store = MemoryPracticeStore();
      final controller = PracticeController(store);
      await tester.pumpWidget(
        MaterialApp(
          theme: hajnalTheme(),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => PracticeManager(controller: controller),
                ),
                child: const Text('Amit gyakorlok'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Amit gyakorlok'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('＋ Új kártya hozzáadása'));
      await tester.pumpAndSettle();
      expect(find.text('Mit írnál magadnak?'), findsOneWidget);
      await tester.tap(find.text('Segíts elindulni'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Felismerés'));
      await tester.pumpAndSettle();
      expect(find.text('Észrevettem, hogy'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Most ezt választom'),
            )
            .onPressed,
        isNull,
      );
      await tester.enterText(find.byType(TextField).first, 'Saját mondatom');
      await tester.pump();
      await tester.tap(find.text('Kérdés'));
      await tester.pump();
      expect(find.text('Saját mondatom'), findsOneWidget);
      await tester.ensureVisible(find.text('Most ezt választom'));
      await tester.tap(find.text('Most ezt választom'));
      await tester.pumpAndSettle();
      expect(controller.active?.text, 'Saját mondatom');
      await tester.tap(find.text('＋ Új kártya hozzáadása'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Második mondat');
      await tester.pump();
      await tester.ensureVisible(find.text('Mentés későbbre'));
      await tester.tap(find.text('Mentés későbbre'));
      await tester.pumpAndSettle();
      expect(controller.active?.text, 'Saját mondatom');
      await tester.tap(find.text('Második mondat'));
      await tester.pumpAndSettle();
      expect(find.text('Kártya szerkesztése'), findsOneWidget);
      await tester.enterText(
        find.byType(TextField).first,
        'Szerkesztett második',
      );
      await tester.pump();
      await tester.tap(find.text('Mentés'));
      await tester.pumpAndSettle();
      expect(controller.active?.text, 'Saját mondatom');
      await tester.tap(find.byTooltip('Szerkesztett második aktiválása'));
      await tester.pumpAndSettle();
      expect(controller.active?.text, 'Szerkesztett második');
      await tester.tap(find.text('Szerkesztett második'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kártya törlése'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mégse'));
      await tester.pumpAndSettle();
      expect(find.text('Szerkesztett második'), findsOneWidget);
      await tester.tap(find.text('Kártya törlése'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Törlés'));
      await tester.pumpAndSettle();
      expect(controller.active, isNull);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
      await store.events.close();
    },
  );
}
