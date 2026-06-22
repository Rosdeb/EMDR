/// Bilateral stimulation speed presets (seconds per half-cycle: left→right or right→left).
///
/// Deliberately paced for slower bilateral movement.
class BlsSpeedPresets {
  BlsSpeedPresets._();

  static const double slow = 0.8;
  static const double medium = 0.5;
  static const double fast = 0.3;
  static const double faster = 0.18;

  static double secondsForKey(String? key) {
    switch (key) {
      case 'slow':
        return slow;
      case 'fast':
        return fast;
      case 'faster':
        return faster;
      case 'medium':
      default:
        return medium;
    }
  }
}
