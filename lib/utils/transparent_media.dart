const String butterflyTransparentAsset = 'assets/images/butterfly.png';

bool isButterflyVisual({String? label, String? source}) {
  final haystack = '${label ?? ''} ${source ?? ''}'.toLowerCase();
  return haystack.contains('butterfly') || haystack.contains('buterfly');
}

bool isCloudinaryUrl(String value) {
  final uri = Uri.tryParse(value.trim());
  return uri != null && uri.host.contains('cloudinary.com');
}

String mediaPath(String value) {
  final trimmed = value.trim();
  final uri = Uri.tryParse(trimmed);
  return (uri?.path.isNotEmpty == true ? uri!.path : trimmed).toLowerCase();
}

bool isLikelyOpaqueVisual(String source) {
  final path = mediaPath(source);
  return path.endsWith('.gif') ||
      path.endsWith('.jpg') ||
      path.endsWith('.jpeg') ||
      path.endsWith('.webp') ||
      path.endsWith('.mp4') ||
      path.endsWith('.mov') ||
      path.endsWith('.webm');
}

bool alreadyTransparentVisual(String source) {
  final path = mediaPath(source);
  return path.endsWith('.png') ||
      path.contains('transparent') ||
      path.contains('alpha') ||
      source.contains('e_make_transparent') ||
      source.contains('e_bgremoval');
}

/// Prefer transparent variants for API visuals with solid backgrounds.
String resolveTransparentVisualUrl(
  String source, {
  String? label,
  String mediaType = 'image',
}) {
  final trimmed = source.trim();
  if (trimmed.isEmpty) return trimmed;

  final isVideo = mediaType.toLowerCase() == 'video' || _looksLikeVideo(trimmed);

  if (isButterflyVisual(label: label, source: trimmed) && !isVideo) {
    if (trimmed.startsWith('assets/')) return trimmed;
    return butterflyTransparentAsset;
  }

  if (alreadyTransparentVisual(trimmed)) return trimmed;

  if (isCloudinaryUrl(trimmed) && isLikelyOpaqueVisual(trimmed)) {
    return cloudinaryTransparentUrl(trimmed, mediaType: isVideo ? 'video' : mediaType);
  }

  return trimmed;
}

bool looksLikeVideoMedia(String source) => _looksLikeVideo(source);

bool _looksLikeVideo(String source) {
  final path = mediaPath(source);
  return path.endsWith('.mp4') ||
      path.endsWith('.mov') ||
      path.endsWith('.webm') ||
      path.contains('/video/upload/');
}

/// Use the original API video URL for playback. Transformed Cloudinary URLs
/// often fail to decode on device, which leaves a frozen frame during movement.
String resolveVisualPlaybackUrl(
  String source, {
  String mediaType = 'image',
}) {
  final trimmed = source.trim();
  if (trimmed.isEmpty) return trimmed;

  if (mediaType.toLowerCase() == 'video' || _looksLikeVideo(trimmed)) {
    return stripCloudinaryVideoTransforms(trimmed);
  }

  return resolveTransparentVisualUrl(
    trimmed,
    mediaType: mediaType,
  );
}

String stripCloudinaryVideoTransforms(String source) {
  final uri = Uri.tryParse(source.trim());
  if (uri == null || !uri.host.contains('cloudinary.com')) return source;

  var path = uri.path;
  path = path.replaceAll(
    RegExp(r'/e_make_transparent(?:,[^/]+)*/', caseSensitive: false),
    '/',
  );
  path = path.replaceAll(
    RegExp(r'/f_webm/', caseSensitive: false),
    '/',
  );
  path = path.replaceAll(
    RegExp(r'\.webm$', caseSensitive: false),
    '.mp4',
  );
  return uri.replace(path: path).toString();
}

String cloudinaryTransparentUrl(
  String source, {
  String mediaType = 'image',
  bool keepOriginalFormat = false,
}) {
  final uri = Uri.tryParse(source.trim());
  if (uri == null || !uri.host.contains('cloudinary.com')) return source;

  var path = uri.path;
  if (path.contains('e_make_transparent') ||
      path.contains('e_bgremoval') ||
      path.contains('e_background_removal')) {
    return source;
  }

  final isVideo =
      mediaType.toLowerCase() == 'video' || path.contains('/video/upload/');

  if (isVideo && path.contains('/video/upload/')) {
    path = path.replaceFirst(
      '/video/upload/',
      '/video/upload/e_make_transparent/',
    );
    if (!keepOriginalFormat) {
      path = path.replaceFirst(
        '/video/upload/e_make_transparent/',
        '/video/upload/e_make_transparent,f_webm/',
      );
      path = path.replaceAll(
        RegExp(r'\.(mov|mp4|webm)$', caseSensitive: false),
        '.webm',
      );
    }
  } else if (path.contains('/image/upload/')) {
    path = path.replaceFirst(
      '/image/upload/',
      '/image/upload/e_make_transparent/',
    );
  } else if (path.contains('/upload/')) {
    path = path.replaceFirst('/upload/', '/upload/e_make_transparent/');
  } else {
    return source;
  }

  return uri.replace(path: path).toString();
}

String cloudinaryVideoTransform(String source, String transform) {
  final uri = Uri.tryParse(source.trim());
  if (uri == null || !uri.host.contains('cloudinary.com')) return source;
  if (!uri.path.contains('/video/upload/')) return source;
  if (uri.path.contains('/$transform/')) return source;

  final path = uri.path.replaceFirst(
    '/video/upload/',
    '/video/upload/$transform/',
  );
  return uri.replace(path: path).toString();
}

String cloudinaryAnimatedTransparentGif(String source, {int width = 320}) {
  final raw = stripCloudinaryVideoTransforms(source);
  final uri = Uri.tryParse(raw);
  if (uri == null || !uri.host.contains('cloudinary.com')) return raw;
  if (!uri.path.contains('/video/upload/')) return raw;

  var path = uri.path.replaceFirst(
    RegExp(r'\.(mp4|mov|webm)$', caseSensitive: false),
    '.gif',
  );
  if (path.contains('fl_animated') && path.contains('e_make_transparent')) {
    return uri.replace(path: path).toString();
  }

  path = path.replaceFirst(
    '/video/upload/',
    '/video/upload/e_make_transparent,fl_animated,f_gif,w_$width,fps_12/',
  );
  return uri.replace(path: path).toString();
}

String cloudinaryAnimatedTransparentWebp(String source, {int width = 320}) {
  final raw = stripCloudinaryVideoTransforms(source);
  final uri = Uri.tryParse(raw);
  if (uri == null || !uri.host.contains('cloudinary.com')) return raw;
  if (!uri.path.contains('/video/upload/')) return raw;

  var path = uri.path.replaceFirst(
    RegExp(r'\.(mp4|mov|webm|gif)$', caseSensitive: false),
    '.webp',
  );
  if (path.contains('fl_animated') && path.contains('e_make_transparent')) {
    return uri.replace(path: path).toString();
  }

  path = path.replaceFirst(
    '/video/upload/',
    '/video/upload/e_make_transparent,fl_animated,f_webp,w_$width,fps_12/',
  );
  return uri.replace(path: path).toString();
}

String cloudinaryTransparentVideoFrame(String source, {int width = 320}) {
  final raw = stripCloudinaryVideoTransforms(source);
  final uri = Uri.tryParse(raw);
  if (uri == null || !uri.host.contains('cloudinary.com')) return raw;
  if (!uri.path.contains('/video/upload/')) return raw;

  var path = uri.path.replaceFirst(
    RegExp(r'\.(mp4|mov|webm|gif|webp)$', caseSensitive: false),
    '.png',
  );
  if (path.contains('e_make_transparent')) {
    return uri.replace(path: path).toString();
  }

  path = path.replaceFirst(
    '/video/upload/',
    '/video/upload/e_make_transparent,w_$width/',
  );
  return uri.replace(path: path).toString();
}

/// Transparent-first URLs for the live simulation (grid keeps raw playback).
List<String> simulationVideoCandidates(
  String source, {
  String? label,
  String mediaType = 'video',
}) {
  final urls = <String>[];
  void add(String value) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty && !urls.contains(trimmed)) {
      urls.add(trimmed);
    }
  }

  final raw = stripCloudinaryVideoTransforms(source);
  if (isCloudinaryUrl(raw) && raw.contains('/video/upload/')) {
    add(cloudinaryAnimatedTransparentGif(raw));
    add(cloudinaryAnimatedTransparentWebp(raw));
    add(cloudinaryTransparentVideoFrame(raw));
    add(raw);
  } else {
    add(raw);
    add(source.trim());
  }
  return urls;
}

String resolveSimulationVisualUrl(
  String source, {
  String? label,
  String mediaType = 'image',
}) {
  final trimmed = source.trim();
  if (trimmed.isEmpty) return trimmed;

  final isVideo = mediaType.toLowerCase() == 'video' || _looksLikeVideo(trimmed);
  if (isVideo) {
    return cloudinaryAnimatedTransparentGif(trimmed);
  }

  return resolveTransparentVisualUrl(
    trimmed,
    label: label,
    mediaType: mediaType,
  );
}

String? cloudinaryVideoPoster(String source) {
  final uri = Uri.tryParse(source.trim());
  if (uri == null || !uri.host.contains('cloudinary.com')) return null;
  if (!uri.path.contains('/video/upload/')) return null;

  var path = uri.path;
  path = path.replaceFirst(
    RegExp(r'\.(mp4|mov|webm)$', caseSensitive: false),
    '.jpg',
  );
  path = path.replaceFirst(
    '/video/upload/',
    '/video/upload/e_make_transparent/',
  );
  return uri.replace(path: path).toString();
}
