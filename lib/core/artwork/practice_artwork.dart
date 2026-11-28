class PracticeArtwork {
  const PracticeArtwork(this.image, this.decoration);
  final String image, decoration;
  static const _names = ['heart', 'wave', 'sprout', 'sunrise', 'moon'];
  static PracticeArtwork forId(int id) {
    final name = _names[id % _names.length];
    final image = name == 'heart' ? 'heart_blossom' : name;
    return PracticeArtwork(
      'assets/artwork/practice/practice_$image.png',
      'assets/artwork/practice/decor/${name}_sheet_field_v4.png',
    );
  }
}
