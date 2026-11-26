import 'package:flutter/material.dart';
import 'artwork_catalog.dart';
import 'artwork_service.dart';

class ArtworkView extends StatefulWidget {
  const ArtworkView({super.key, this.service});
  final ArtworkService? service;
  @override
  State<ArtworkView> createState() => _ArtworkViewState();
}

class _ArtworkViewState extends State<ArtworkView> {
  ImageProvider image = const AssetImage(dashboardArtwork);
  int sequence = 0;
  @override
  void initState() {
    super.initState();
    widget.service?.addListener(_load);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  @override
  void didUpdateWidget(covariant ArtworkView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.service != widget.service) {
      oldWidget.service?.removeListener(_load);
      widget.service?.addListener(_load);
      _load();
    }
  }

  Future<void> _load() async {
    final ticket = ++sequence;
    try {
      final descriptor = await widget.service?.resolve();
      final ImageProvider next = descriptor?.file == null
          ? const AssetImage(dashboardArtwork)
          : FileImage(descriptor!.file!);
      if (!mounted || ticket != sequence) return;
      await precacheImage(next, context);
      if (mounted && ticket == sequence) setState(() => image = next);
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
  Widget build(BuildContext context) =>
      Image(image: image, fit: BoxFit.cover, alignment: Alignment.topCenter);
}
