/// Local bilateral stimulation visuals.
///
/// Prefer transparent sprite sheets under [kBlsSpriteRoot] (from HTML export).
/// Falls back to bundled GIF/WebP in [kBlsVisualAssetsDir].
const String kBlsVisualAssetsDir = 'assets/icons';
const String kBlsSpriteRoot = '$kBlsVisualAssetsDir/nobg';

class BlsLocalVisual {
  const BlsLocalVisual({
    required this.id,
    required this.label,
    this.assetPath,
    this.spriteFrameCount = 0,
    this.fps = 12,
    this.sessionSize = 140,
    this.mediaType = 'sprite',
  });

  final String id;
  final String label;
  final String? assetPath;
  final int spriteFrameCount;
  final double fps;
  /// Display size during BLS session (matches HTML `.obj` canvas CSS).
  final double sessionSize;
  final String mediaType;

  bool get usesSpriteFrames => spriteFrameCount > 0;

  List<String> get spriteFrameAssets => List.generate(
        spriteFrameCount,
        (index) =>
            '$kBlsSpriteRoot/$id/frame_${index.toString().padLeft(3, '0')}.webp',
      );
}

/// Primary selectable visuals (transparent sprite sheets).
const List<BlsLocalVisual> kBlsSelectableLocalVisuals = [
  BlsLocalVisual(
    id: 'butterfly',
    label: 'Butterfly',
    spriteFrameCount: 24,
    fps: 12,
    sessionSize: 155,
  ),
  BlsLocalVisual(
    id: 'bird',
    label: 'Bird',
    spriteFrameCount: 24,
    fps: 10,
    sessionSize: 125,
  ),
  BlsLocalVisual(
    id: 'fox',
    label: 'Fox',
    spriteFrameCount: 24,
    fps: 10,
    sessionSize: 210,
  ),
  BlsLocalVisual(
    id: 'ball',
    label: 'Ball',
    spriteFrameCount: 24,
    fps: 8,
    sessionSize: 130,
  ),
  BlsLocalVisual(
    id: 'mushroom',
    label: 'Mushroom',
    spriteFrameCount: 24,
    fps: 10,
    sessionSize: 170,
  ),
  BlsLocalVisual(
    id: 'leaf1',
    label: 'Leaf 1',
    spriteFrameCount: 24,
    fps: 6,
    sessionSize: 110,
  ),
  BlsLocalVisual(
    id: 'leaf2',
    label: 'Leaf 2',
    spriteFrameCount: 24,
    fps: 6,
    sessionSize: 100,
  ),
  BlsLocalVisual(
    id: 'hare',
    label: 'Hare',
    spriteFrameCount: 41,
    fps: 10,
    sessionSize: 150,
  ),
  BlsLocalVisual(
    id: 'dandelion',
    label: 'Dandelion',
    spriteFrameCount: 41,
    fps: 8,
    sessionSize: 120,
  ),
  BlsLocalVisual(
    id: 'helicopter',
    label: 'Helicopter',
    spriteFrameCount: 41,
    fps: 10,
    sessionSize: 160,
  ),
  BlsLocalVisual(
    id: 'petals',
    label: 'Petals',
    spriteFrameCount: 41,
    fps: 8,
    sessionSize: 130,
  ),
  BlsLocalVisual(
    id: 'unknown',
    label: 'Unknown',
    spriteFrameCount: 41,
    fps: 10,
    sessionSize: 150,
  ),
  BlsLocalVisual(
    id: 'horse',
    label: 'Horse',
    spriteFrameCount: 41,
    fps: 10,
    sessionSize: 200,
  ),
  BlsLocalVisual(
    id: 'dolphin',
    label: 'Dolphin',
    spriteFrameCount: 41,
    fps: 10,
    sessionSize: 180,
  ),
  BlsLocalVisual(
    id: 'jeep',
    label: 'Jeep',
    spriteFrameCount: 41,
    fps: 8,
    sessionSize: 190,
  ),
];

const List<BlsLocalVisual> kBlsLocalVisuals = [
  ...kBlsSelectableLocalVisuals,
  BlsLocalVisual(
    id: 'butterfly-webp',
    label: 'Butterfly (GIF fallback)',
    assetPath: '$kBlsVisualAssetsDir/buterfy.gif',
    mediaType: 'gif',
  ),
];

BlsLocalVisual? blsLocalVisualById(String? id) {
  final key = id?.trim().toLowerCase();
  if (key == null || key.isEmpty) return null;
  for (final visual in kBlsLocalVisuals) {
    if (visual.id == key) return visual;
  }
  return null;
}

BlsLocalVisual? blsLocalVisualForSource(String source) {
  final trimmed = source.trim();
  if (trimmed.isEmpty) return null;

  for (final visual in kBlsLocalVisuals) {
    if (visual.assetPath == trimmed) return visual;
    if (visual.id == trimmed) return visual;
    if (visual.usesSpriteFrames &&
        trimmed.startsWith('$kBlsSpriteRoot/${visual.id}/')) {
      return visual;
    }
  }

  final fileName = trimmed.split('/').last.toLowerCase();
  for (final visual in kBlsLocalVisuals) {
    final assetName = visual.assetPath?.split('/').last.toLowerCase();
    if (assetName != null && assetName == fileName) return visual;
  }
  return null;
}

bool isBlsLocalVisualAsset(String source) {
  final trimmed = source.trim();
  if (blsLocalVisualForSource(trimmed) != null) return true;
  if (blsLocalVisualById(trimmed) != null) return true;
  return trimmed.startsWith('$kBlsVisualAssetsDir/');
}

bool isAnimatedAssetVisual(String source) {
  final visual = resolveLocalVisual(source);
  if (visual != null) return true;

  final path = source.trim().toLowerCase();
  return path.endsWith('.gif') ||
      path.endsWith('.webp') ||
      path.contains('/nobg/');
}

String resolveLocalVisualAsset(String source) {
  final trimmed = source.trim();
  final byId = blsLocalVisualById(trimmed);
  if (byId != null) {
    if (byId.usesSpriteFrames) return byId.id;
    if (byId.assetPath != null) return byId.assetPath!;
  }

  final mapped = blsLocalVisualForSource(trimmed);
  if (mapped?.usesSpriteFrames == true) return mapped!.id;
  if (mapped?.assetPath != null) return mapped!.assetPath!;
  return trimmed;
}

BlsLocalVisual? resolveLocalVisual(String source) {
  return blsLocalVisualForSource(source) ??
      blsLocalVisualById(source.trim());
}

bool shouldUseSpriteVisual(String source) {
  final visual = resolveLocalVisual(source);
  return visual?.usesSpriteFrames == true;
}

List<String> spriteFrameAssetsFor(String source) {
  final visual = resolveLocalVisual(source);
  if (visual == null || !visual.usesSpriteFrames) return const [];
  return visual.spriteFrameAssets;
}

double spriteFpsFor(String source) {
  return resolveLocalVisual(source)?.fps ?? 12;
}

double spriteSessionSizeFor(String source) {
  return resolveLocalVisual(source)?.sessionSize ?? 140;
}
