/// Bilateral stimulation speed presets (seconds per half-cycle: left→right or right→left).
///
/// Tuned faster than earlier builds — clinical BLS apps typically use ~0.6–1.2s per beat.
class BlsSpeedPresets {
  BlsSpeedPresets._();

  static const double slow = 8.0;    // full cycle = 16s
  static const double medium = 5.0;  // full cycle = 10s
  static const double fast = 3.0;    // full cycle = 6s

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
