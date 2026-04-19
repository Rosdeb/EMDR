enum AnimationDirection { horizontal, vertical, diagonal, diagonalReverse }

class SimulationSettings {
  final String environmentImage;
  final String visualObject;
  final double speed;
  final String audioAsset;
  final AnimationDirection direction;
  final bool isNetworkImage;

  SimulationSettings({
    required this.environmentImage,
    required this.visualObject,
    required this.speed,
    required this.audioAsset,
    required this.direction,
    this.isNetworkImage = false,
  });
}