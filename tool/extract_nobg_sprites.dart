import 'dart:convert';
import 'dart:io';

/// Extracts transparent WebP sprite frames from the watercolor HTML export.
void main() {
  const outRoot = r'assets\icons\nobg';

  const sources = [
    (
      htmlPath: r'c:\Users\mursa\Downloads\watercolor_animation_nobg (5).html',
      specs: [
        ('butterflyFrames', 'butterfly'),
        ('birdFrames', 'bird'),
        ('foxFrames', 'fox'),
        ('ballFrames', 'ball'),
        ('mushroomFrames', 'mushroom'),
        ('leaf1Frames', 'leaf1'),
        ('leaf2Frames', 'leaf2'),
      ],
    ),
    (
      htmlPath: r'c:\Users\mursa\Downloads\watercolor_world_v3.html',
      specs: [
        ('hareFrames', 'hare'),
        ('dandilionFrames', 'dandelion'),
        ('dolphinFrames', 'dolphin'),
        ('helicopterFrames', 'helicopter'),
        ('horseFrames', 'horse'),
        ('jeepFrames', 'jeep'),
        ('petalsFrames', 'petals'),
        ('unknownFrames', 'unknown'),
      ],
    ),
  ];

  for (final source in sources) {
    final htmlFile = File(source.htmlPath);
    if (!htmlFile.existsSync()) {
      stderr.writeln('HTML not found: ${source.htmlPath}');
      continue;
    }

    final html = htmlFile.readAsStringSync();
    for (final (arrayName, folder) in source.specs) {
      final frames = _extractDataUris(html, arrayName);
      if (frames.isEmpty) {
        stderr.writeln('No frames for $arrayName in ${source.htmlPath}');
        continue;
      }

      final dir = Directory('$outRoot\\$folder');
      dir.createSync(recursive: true);

      for (var i = 0; i < frames.length; i++) {
        final bytes = base64Decode(frames[i]);
        final path = '${dir.path}\\frame_${i.toString().padLeft(3, '0')}.webp';
        File(path).writeAsBytesSync(bytes);
      }
      stdout.writeln('Wrote ${frames.length} frames -> ${dir.path}');
    }
  }
}

List<String> _extractDataUris(String html, String arrayName) {
  final marker = 'const $arrayName';
  final start = html.indexOf(marker);
  if (start < 0) return const [];

  final bracketStart = html.indexOf('[', start);
  if (bracketStart < 0) return const [];

  final end = html.indexOf('];', bracketStart);
  if (end < 0) return const [];

  final block = html.substring(bracketStart, end);
  final matches = RegExp(
    r'data:image/webp;base64,([A-Za-z0-9+/=]+)',
  ).allMatches(block);

  return [for (final match in matches) match.group(1)!];
}
