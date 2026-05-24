/// Built-in bilateral stimulation tones (HTML export parity).
class BlsBuiltInSounds {
  BlsBuiltInSounds._();

  static const entries = <MapEntry<String, String>>[
    MapEntry('gentle-tone', 'Gentle Tone'),
    MapEntry('soft-chime', 'Soft Chime'),
    MapEntry('water', 'Water'),
    MapEntry('breath', 'Breath'),
    MapEntry('bowl', 'Singing Bowl'),
    MapEntry('warm-tap', 'Warm Tap'),
    MapEntry('deep-pulse', 'Deep Pulse'),
    MapEntry('rain-bell', 'Rain Bell'),
  ];

  static const defaultKey = 'gentle-tone';

  static String normalizeKey(String value) {
    final key = value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    switch (key) {
      case 'gentle-tone':
      case 'soft-bilateral-pulse':
        return 'gentle-tone';
      case 'crystal-chime':
      case 'soft-chime':
        return 'soft-chime';
      case 'water':
      case 'water-drop':
      case 'ocean-drop':
        return 'water';
      case 'breath':
      case 'soft-breath':
        return 'breath';
      case 'singing-bowl':
      case 'bowl':
        return 'bowl';
      case 'warm-tap':
      case 'deep-pulse':
      case 'rain-bell':
        return key;
      default:
        return key;
    }
  }

  static bool isBuiltInKey(String value) {
    final key = normalizeKey(value);
    return entries.any((entry) => entry.key == key);
  }
}
