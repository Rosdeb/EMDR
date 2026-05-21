enum AnimationDirection { horizontal, vertical, diagonal, diagonalReverse }

class SimulationSettings {
  final String environmentImage;
  final String visualObject;
  final double speed;
  final String audioAsset;
  final String soundKey;
  final AnimationDirection direction;
  final bool isNetworkImage;
  final bool requireNetworkAudio;
  final bool showCompletionQuestions;
  final int totalSets;

  SimulationSettings({
    required this.environmentImage,
    required this.visualObject,
    required this.speed,
    required this.audioAsset,
    this.soundKey = '',
    required this.direction,
    this.isNetworkImage = false,
    this.requireNetworkAudio = false,
    this.showCompletionQuestions = false,
    this.totalSets = 0,
  });
}
