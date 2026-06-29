enum AnimationDirection { horizontal, vertical, diagonal, diagonalReverse }

class SimulationSettings {
  final String environmentImage;
  final String visualObject;
  final double speed;
  final String audioAsset;
  final String soundKey;
  final String visualMediaType;
  final String? visualPoster;
  final String? visualPlaybackUrl;
  final String? visualTransparentUrl;
  final String? visualLabel;
  final AnimationDirection direction;
  final bool isNetworkImage;
  final bool requireNetworkAudio;
  final bool showCompletionQuestions;
  final int totalSets;
  final int maxDurationMinutes;
  final String? roadmapSummary;
  final String? roadmapSummaryAudioUrl;
  final String? roadmapSummaryAudioProvider;

  SimulationSettings({
    required this.environmentImage,
    required this.visualObject,
    required this.speed,
    required this.audioAsset,
    this.soundKey = '',
    this.visualMediaType = 'image',
    this.visualPoster,
    this.visualPlaybackUrl,
    this.visualTransparentUrl,
    this.visualLabel,
    required this.direction,
    this.isNetworkImage = false,
    this.requireNetworkAudio = false,
    this.showCompletionQuestions = false,
    this.totalSets = 0,
    this.maxDurationMinutes = 0,
    this.roadmapSummary,
    this.roadmapSummaryAudioUrl,
    this.roadmapSummaryAudioProvider,
  });
}
