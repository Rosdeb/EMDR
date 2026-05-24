import 'dart:io';

import 'package:image/image.dart' as img;

void main() {
  final input = File(r'build\unit_test_assets\assets\icons\buterfly.webp');
  if (!input.existsSync()) {
    stderr.writeln('Input not found: ${input.path}');
    exit(1);
  }

  final source = img.decodeImage(input.readAsBytesSync());
  if (source == null) {
    stderr.writeln('Could not decode ${input.path}');
    exit(1);
  }

  final image = source.convert(numChannels: 4);

  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      final r = pixel.r.toDouble();
      final g = pixel.g.toDouble();
      final b = pixel.b.toDouble();
      final maxChannel = r > g ? (r > b ? r : b) : (g > b ? g : b);
      final minChannel = r < g ? (r < b ? r : b) : (g < b ? g : b);
      final saturation = maxChannel - minChannel;
      final brightness = (r + g + b) / 3.0;
      final whiteness = brightness - (saturation * 1.15);

      var alpha = 255;
      if (whiteness >= 246) {
        alpha = 0;
      } else if (whiteness >= 210 && saturation < 56) {
        final t = ((whiteness - 210) / 36).clamp(0.0, 1.0);
        alpha = (255 * (1 - t)).round();
      } else if (brightness > 226 && saturation < 112) {
        final t = ((brightness - 226) / 29).clamp(0.0, 1.0);
        alpha = (255 * (1 - t)).round();
      }

      if (alpha < 36) alpha = 0;
      image.setPixelRgba(x, y, pixel.r, pixel.g, pixel.b, alpha);
    }
  }

  final out = File(r'assets\icons\buterfly-transparent.png');
  out.parent.createSync(recursive: true);
  out.writeAsBytesSync(img.encodePng(image));
  print('Wrote ${out.path} ${image.width}x${image.height}');
}
