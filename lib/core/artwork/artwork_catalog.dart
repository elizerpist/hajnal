class ArtworkDefinition {
  const ArtworkDefinition({
    required this.id,
    required this.role,
    required this.asset,
    required this.source,
    required this.revision,
    required this.width,
    required this.height,
    required this.crop,
    required this.focus,
    required this.placeholder,
  });
  final String id, role, asset, source, revision, crop, focus;
  final int width, height;
  final bool placeholder;
  double get aspectRatio => width / height;
}

const dashboardArtwork = ArtworkDefinition(
  id: 'dashboard.default',
  role: 'dashboard.default',
  asset: 'assets/artwork/dashboard/placeholder.png',
  source: 'html-prototypes/app-shell/assets/backgrounds/index1.png',
  revision: 'bundle-1',
  width: 853,
  height: 1843,
  crop: 'cover',
  focus: 'center-top',
  placeholder: true,
);

const welcomeArtwork = 'assets/artwork/onboarding/welcome.svg';
