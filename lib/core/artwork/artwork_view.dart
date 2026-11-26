import 'package:flutter/material.dart';
import 'artwork_catalog.dart';
import 'artwork_source.dart';

class ArtworkView extends StatefulWidget {
  const ArtworkView({super.key, required this.role, this.service});
  final String role;
  final ArtworkSource? service;
  @override
  State<ArtworkView> createState() => _ArtworkViewState();
}

class _ArtworkViewState extends State<ArtworkView> {
  ImageProvider image = AssetImage(dashboardArtwork.asset);
  int sequence = 0;
  int width = 1024;
  @override
  void initState() {
    super.initState();
    widget.service?.addListener(_load);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final media = MediaQuery.of(context);
    width = (media.size.width * media.devicePixelRatio).ceil().clamp(1, 2048);
    _load();
  }

  @override
  void didUpdateWidget(covariant ArtworkView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.service != widget.service || oldWidget.role != widget.role) {
      oldWidget.service?.removeListener(_load);
      widget.service?.addListener(_load);
      _load();
    }
  }

  Future<void> _load() async {
    final ticket = ++sequence;
    try {
      final descriptor = await widget.service?.resolve(widget.role);
      final ImageProvider next = descriptor?.file == null
          ? AssetImage(dashboardArtwork.asset)
          : FileImage(descriptor!.file!);
      if (!mounted || ticket != sequence) return;
      var failed = false;
      await precacheImage(
        ResizeImage.resizeIfNeeded(width, null, next),
        context,
        onError: (_, _) {
          failed = true;
        },
      );
      if (!failed && mounted && ticket == sequence) {
        setState(() => image = next);
      }
    } catch (_) {
      // Keep the last successfully decoded image visible.
    }
  }

  @override
  void dispose() {
    sequence++;
    widget.service?.removeListener(_load);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Image(
    image: ResizeImage.resizeIfNeeded(width, null, image),
    fit: BoxFit.cover,
    alignment: Alignment.topCenter,
  );
}
