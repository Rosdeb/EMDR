/// Bilateral stimulation speed presets (seconds per half-cycle: left→right or right→left).
///
/// Deliberately paced for slower bilateral movement.
class BlsSpeedPresets {
  BlsSpeedPresets._();

  static const double slow = 0.69; // full cycle =  value  - 8 - 7
  static const double medium = 0.5; // full cycle =
  static const double fast = 0.4; // full cycle =

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
