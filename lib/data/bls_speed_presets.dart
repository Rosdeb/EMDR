/// Bilateral stimulation speed presets (seconds per half-cycle: left→right or right→left).
///
/// Tuned faster than earlier builds — clinical BLS apps typically use ~0.6–1.2s per beat.
class BlsSpeedPresets {
  BlsSpeedPresets._();

  static const double slow = 1.15;
  static const double medium = 0.85;
  static const double fast = 0.6;

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
