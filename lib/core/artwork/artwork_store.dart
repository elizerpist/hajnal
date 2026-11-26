class ArtworkRecord {
  const ArtworkRecord(this.filename, this.revision);
  final String filename;
  final String revision;
}

abstract interface class ArtworkStore {
  Future<List<String>> filenames();
  Future<ArtworkRecord?> find(String role);
  Future<void> put(String role, String filename, String revision);
  Future<void> delete(String role);
}
