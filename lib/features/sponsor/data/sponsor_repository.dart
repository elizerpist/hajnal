import 'package:drift/drift.dart';
import '../../../core/database/hajnal_database.dart';

class SponsorRepository {
  SponsorRepository(this._db);
  final HajnalDatabase _db;

  Future<SponsorContact?> read() => (_db.select(
    _db.sponsorContacts,
  )..where((contact) => contact.id.equals(1))).getSingleOrNull();

  Future<void> save(String name, String phone) async {
    await _db
        .into(_db.sponsorContacts)
        .insertOnConflictUpdate(
          SponsorContactsCompanion.insert(
            id: const Value(1),
            name: name.trim(),
            phone: Value(phone.trim()),
          ),
        );
  }
}
