import 'dart:io';
import 'package:flutter/foundation.dart';

class ArtworkDescriptor {
  const ArtworkDescriptor({this.file, required this.revision});
  final File? file;
  final String revision;
}

abstract interface class ArtworkSource implements Listenable {
  Future<ArtworkDescriptor> resolve(String role);
}
