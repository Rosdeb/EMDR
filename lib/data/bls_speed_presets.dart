/// Bilateral stimulation speed presets (seconds per half-cycle: left→right or right→left).
///
/// Deliberately paced for slower bilateral movement.
class BlsSpeedPresets {
  BlsSpeedPresets._();

  static const double slow = 10.0; // full cycle = 20s
  static const double medium = 7.0; // full cycle = 14s
  static const double fast = 5.0; // full cycle = 10s

  static double secondsForKey(String? key) {
    switch (key) {
      case 'slow':
        return slow;
      case 'fast':
        return fast;
      case 'medium':
      default:
        return medium;
    }
  }
}
