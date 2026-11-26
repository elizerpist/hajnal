import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hajnal/core/artwork/artwork_catalog.dart';
import 'package:hajnal/core/artwork/artwork_service.dart';
import 'package:hajnal/core/artwork/drift_artwork_store.dart';
import 'package:hajnal/core/artwork/artwork_store.dart';
import 'package:hajnal/core/database/hajnal_database.dart';

class DelayedStore implements ArtworkStore {
  DelayedStore(this.delegate);
  final ArtworkStore delegate;
  Completer<void>? entered;
  Completer<void>? resume;
  bool fail = false;
  bool failAfterWrite = false;
  bool failReads = false;

  @override
  Future<List<String>> filenames() {
    if (failReads) throw StateError('database read failed');
    return delegate.filenames();
  }

  @override
  Future<ArtworkRecord?> find(String role) => delegate.find(role);
  @override
  Future<void> delete(String role) => delegate.delete(role);
  @override
  Future<void> put(String role, String filename, String revision) async {
    if (entered != null && !entered!.isCompleted) entered!.complete();
    if (resume != null) await resume!.future;
    if (fail) throw StateError('database write failed');
    await delegate.put(role, filename, revision);
    if (failAfterWrite) throw StateError('database write outcome unknown');
  }
}

void main() {
  late Directory dir;
  late Directory private;
  late HajnalDatabase db;
  late DelayedStore store;
  late ArtworkService service;
  late File first;
  late File second;
  final role = dashboardArtwork.role;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('artwork-ordered-');
    private = Directory('${dir.path}/private');
    db = HajnalDatabase(NativeDatabase.memory());
    store = DelayedStore(DriftArtworkStore(db));
    service = ArtworkService(store, private, (_) async => true);
    first = await File('${dir.path}/first').writeAsBytes([1]);
    second = await File('${dir.path}/second').writeAsBytes([2]);
  });
  tearDown(() async {
    service.dispose();
    await db.close();
    await dir.delete(recursive: true);
  });

  test('clear during a delayed write cannot resurrect the selection', () async {
    store.entered = Completer<void>();
    store.resume = Completer<void>();
    final install = service.install(role, first);
    await store.entered!.future;
    final clear = service.clear(role);
    store.resume!.complete();
    await Future.wait([install, clear]);
    expect((await service.resolve(role)).file, isNull);
    expect(await private.list().toList(), isEmpty);
  });

  test('overlapping installs publish the last accepted selection', () async {
    store.entered = Completer<void>();
    store.resume = Completer<void>();
    final old = service.install(role, first);
    await store.entered!.future;
    final newer = service.install(role, second);
    store.resume!.complete();
    await old;
    store.entered = null;
    store.resume = null;
    await newer;
    final selected = await service.resolve(role);
    expect(await selected.file!.readAsBytes(), [2]);
    expect(await private.list().length, 1);
  });

  test(
    'DB failure removes new file and preserves previous selection',
    () async {
      await service.install(role, first);
      final previous = await service.resolve(role);
      store.fail = true;
      await expectLater(service.install(role, second), throwsStateError);
      final selected = await service.resolve(role);
      expect(selected.file!.path, previous.file!.path);
      expect(await selected.file!.readAsBytes(), [1]);
      expect(await private.list().length, 1);
    },
  );

  test('restart cleanup removes interrupted files and is repeatable', () async {
    await service.install(role, first);
    final active = (await service.resolve(role)).file!;
    await File('${private.path}/artwork-interrupted.img').writeAsBytes([3]);
    await File('${private.path}/artwork-interrupted.img.tmp').writeAsBytes([4]);
    service.dispose();
    service = ArtworkService(store, private, (_) async => true);
    await service.cleanup();
    await service.cleanup();
    expect(await active.exists(), isTrue);
    expect(await private.list().length, 1);
    expect(await (await service.resolve(role)).file!.readAsBytes(), [1]);
  });

  test('old displayed file survives replacement until released', () async {
    await service.install(role, first);
    final old = (await service.resolve(role)).file!;
    service.retain(old);
    await service.install(role, second);
    expect(await old.exists(), isTrue);
    await service.release(old);
    expect(await old.exists(), isFalse);
    expect(await (await service.resolve(role)).file!.readAsBytes(), [2]);
  });
  test(
    'cleanup waits for in-flight write and keeps its selected file',
    () async {
      store.entered = Completer<void>();
      store.resume = Completer<void>();
      final install = service.install(role, first);
      await store.entered!.future;
      final pending = await private.list().toList();
      expect(pending, hasLength(1));
      final cleanup = service.cleanup();
      expect(await File(pending.single.path).exists(), isTrue);
      store.resume!.complete();
      await Future.wait([install, cleanup]);
      expect(await (await service.resolve(role)).file!.readAsBytes(), [1]);
    },
  );
  test('post-commit DB error never removes the referenced file', () async {
    await service.install(role, first);
    store.failAfterWrite = true;
    await expectLater(
      service.install(role, second),
      throwsA(
        isA<StateError>().having(
          (e) => e.message,
          'message',
          'database write outcome unknown',
        ),
      ),
    );
    final active = await service.resolve(role);
    expect(await active.file!.readAsBytes(), [2]);
    await service.cleanup();
    expect(await active.file!.exists(), isTrue);
  });

  test(
    'unreadable DB preserves uncertain file and original write error',
    () async {
      store.failAfterWrite = true;
      store.failReads = true;
      await expectLater(
        service.install(role, first),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            'database write outcome unknown',
          ),
        ),
      );
      expect(await private.list().length, 1);
      store.failReads = false;
      expect(await (await service.resolve(role)).file!.readAsBytes(), [1]);
    },
  );

  test('invalid later request does not cancel earlier valid install', () async {
    final validationStarted = Completer<void>();
    final validationResume = Completer<bool>();
    service.dispose();
    service = ArtworkService(store, private, (bytes) {
      if (bytes.first == 1) {
        if (!validationStarted.isCompleted) validationStarted.complete();
        return validationResume.future;
      }
      return Future.value(false);
    });
    final earlier = service.install(role, first);
    await validationStarted.future;
    await expectLater(service.install(role, second), throwsFormatException);
    validationResume.complete(true);
    await earlier;
    expect(await (await service.resolve(role)).file!.readAsBytes(), [1]);
  });
}
