import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jonssony/services/app_url.dart';
import 'package:jonssony/utils/transparent_media.dart';

class BilateralService {
  static const String _baseUrl = '${AppUrl.baseUrl}/bilateral';
  static const String _mediaUrl = '${AppUrl.baseUrl}/media';
  static const String _bilateralSoundCategory = 'bilateral stimulation sound';

  static Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  static Future<Map<String, dynamic>> getConfig(String token) async {
    try {
      final categoriesFuture = _getCategories(token);
      final mediaFuture = _getAllMedia(token: token, limit: 20);
      final categories = await categoriesFuture;
      final mediaItems = await mediaFuture;

      return {
        'success': true,
        'data': {
          'categories': categories['data'],
          'environments': _normaliseEnvironmentItems(mediaItems),
          'objects': _normaliseVisualItems(mediaItems),
          'sounds': _normaliseSoundItems(mediaItems),
        },
      };
    } catch (_) {
      return {'success': false, 'message': 'Unable to load bilateral media'};
    }
  }

  static Future<Map<String, dynamic>> _getCategories(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/config'),
      headers: _headers(token),
    );
    return _handleResponse(response);
  }

  static Future<List<Map<String, dynamic>>> _getAllMedia({
    required String token,
    required int limit,
  }) async {
    final first = await _getMedia(token: token, page: 1, limit: limit);
    final allItems = <Map<String, dynamic>>[..._mediaItems(first['data'])];

    var currentPage = 1;
    var hasMore = _hasMoreMediaPages(first['data'], currentPage);

    while (hasMore) {
      currentPage += 1;
      final response = await _getMedia(
        token: token,
        page: currentPage,
        limit: limit,
      );
      allItems.addAll(_mediaItems(response['data']));
      hasMore = _hasMoreMediaPages(response['data'], currentPage);
    }

    return allItems;
  }

  static bool _hasMoreMediaPages(dynamic data, int currentPage) {
    if (data is! Map) return false;
    final pagination = data['pagination'];
    if (pagination is! Map) return false;

    final totalPages = pagination['totalPages'];
    if (totalPages is num && totalPages.toInt() > currentPage) {
      return true;
    }

    final parsedTotalPages = int.tryParse(totalPages?.toString() ?? '');
    if (parsedTotalPages != null && parsedTotalPages > currentPage) {
      return true;
    }

    return pagination['hasNextPage'] == true;
  }

  static Future<Map<String, dynamic>> _getMedia({
    required String token,
    required int page,
    int? limit,
  }) async {
    final params = <String, String>{'page': page.toString()};
    if (limit != null) params['limit'] = limit.toString();

    final response = await http.get(
      Uri.parse(_mediaUrl).replace(queryParameters: params),
      headers: _headers(token),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> saveSettings({
    required String token,
    required String environmentUrl,
    required String iconUrl,
    required String soundUrl,
    required String speed,
    required String direction,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/settings'),
      headers: _headers(token),
      body: jsonEncode({
        'environmentId': environmentUrl.trim(),
        'iconUrl': iconUrl.trim(),
        'soundId': soundUrl.trim(),
        'speed': speed,
        'direction': direction,
      }),
    );
    return _handleResponse(response);
  }

  static List<Map<String, dynamic>> _mediaItems(dynamic data) {
    final source = _extractList(data);
    return source
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  static List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      final flattened = _flattenGroupedMedia(data['media']);
      if (flattened.isNotEmpty) return flattened;

      for (final key in ['media', 'items', 'docs', 'results', 'data']) {
        final value = data[key];
        if (value is List) return value;
        if (value is Map) {
          final nested = _flattenGroupedMedia(value);
          if (nested.isNotEmpty) return nested;
        }
      }
    }
    return const [];
  }

  static List<dynamic> _flattenGroupedMedia(dynamic media) {
    if (media is List) return media;
    if (media is! Map) return const [];

    final flattened = <dynamic>[];
    for (final key in const [
      'images',
      'videos',
      'musics',
      'music',
      'audios',
      'audio',
      'others',
    ]) {
      final value = media[key];
      if (value is List) flattened.addAll(value);
    }
    return flattened;
  }

  static List<Map<String, dynamic>> _normaliseEnvironmentItems(
    List<Map<String, dynamic>> items,
  ) {
    return items
        .where(_looksLikeEnvironment)
        .map(_environmentFromMedia)
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  static List<Map<String, dynamic>> _normaliseVisualItems(
    List<Map<String, dynamic>> items,
  ) {
    return items
        .where(_looksLikeVisual)
        .map(_visualFromMedia)
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  static List<Map<String, dynamic>> _normaliseSoundItems(
    List<Map<String, dynamic>> items,
  ) {
    final audioCandidates = items.where(_isActiveMediaItem).where((item) {
      final mediaType = item['mediaType']?.toString().trim().toLowerCase();
      if (mediaType == 'audio') return true;
      if (_isBilateralSoundCategory(item)) return true;
      return _looksLikeSound(item);
    }).toList();

    final categoryMatches = audioCandidates
        .where(_isBilateralSoundCategory)
        .toList();
    final source = categoryMatches.isNotEmpty
        ? categoryMatches
        : audioCandidates.isNotEmpty
        ? audioCandidates
        : items.where(_isActiveMediaItem).where(_hasPlayableAudio);

    return source
        .toList()
        .asMap()
        .entries
        .map(
          (entry) => _soundFromMedia(
            entry.value,
            index: entry.key,
          ),
        )
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  static bool _isActiveMediaItem(Map<String, dynamic> item) {
    final status = item['status']?.toString().trim().toLowerCase();
    if (status == null || status.isEmpty) return true;
    return status == 'active';
  }

  static bool _isBilateralSoundCategory(Map<String, dynamic> item) {
    final categoryId = item['categoryId'];
    if (categoryId is Map) {
      final name = categoryId['categoryName']?.toString().trim().toLowerCase();
      if (name == _bilateralSoundCategory) return true;
    }

    final haystack = _classificationText(item);
    return haystack.contains(_bilateralSoundCategory);
  }

  static bool _hasPlayableAudio(Map<String, dynamic> item) {
    return _audioUrlFor(item).isNotEmpty;
  }

  static Map<String, dynamic>? _environmentFromMedia(
    Map<String, dynamic> item,
  ) {
    final image = _mediaUrlFor(item, preferImage: true);
    if (image.isEmpty) return null;
    return {
      'id': _idFor(item),
      'name': _nameFor(item, fallback: 'Scene'),
      'image': image,
      'url': image,
      'mediaType': _mediaTypeFor(item),
      'source': item,
    };
  }

  static Map<String, dynamic>? _visualFromMedia(Map<String, dynamic> item) {
    final name = _nameFor(item, fallback: 'Visual');
    final visualLabel = _visualLabelFor(item, fallback: name);
    final transparentMedia = _transparentMediaFor(item);
    final rawMedia = _mediaUrlFor(item);
    final media = transparentMedia.isNotEmpty ? transparentMedia : rawMedia;
    if (media.isEmpty) return null;

    final mediaType = _mediaTypeForSource(media, fallback: _mediaTypeFor(item));
    final resolvedMedia = _resolveVisualMediaUrl(
      media,
      label: visualLabel,
      mediaType: mediaType,
    );
    final resolvedMediaType = _mediaTypeForSource(
      resolvedMedia,
      fallback: mediaType,
    );

    return {
      'id': _idFor(item),
      'name': name,
      'img': resolvedMedia,
      'image': resolvedMedia,
      'url': resolvedMedia,
      'poster': _posterFor(item),
      'mediaType': resolvedMediaType,
      'source': item,
    };
  }

  static Map<String, dynamic>? _soundFromMedia(
    Map<String, dynamic> item, {
    int index = 0,
  }) {
    final audio = _resolveMediaUrl(_audioUrlFor(item));
    if (audio.isEmpty) return null;
    final poster = _soundPosterFor(item, index: index);
    return {
      'id': _idFor(item),
      'name': _nameFor(item, fallback: 'Sound'),
      'url': audio,
      'poster': poster,
      'image': poster,
      'mediaType': 'audio',
      'source': item,
    };
  }

  static String _soundPosterFor(
    Map<String, dynamic> item, {
    required int index,
  }) {
    final direct = _resolveMediaUrl(_posterFor(item));
    if (direct.isNotEmpty) return direct;

    final id = _idFor(item);
    final seed = id.isNotEmpty ? id : '${index + 1}';
    return 'https://picsum.photos/seed/soundimg$seed/150/150';
  }

  static String _resolveMediaUrl(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '';

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    if (trimmed.startsWith('//')) return 'https:$trimmed';

    final origin = AppUrl.baseUrl.replaceFirst(RegExp(r'/api/?$'), '');
    if (trimmed.startsWith('/')) return '$origin$trimmed';
    return '$origin/$trimmed';
  }

  static bool _looksLikeEnvironment(Map<String, dynamic> item) {
    final haystack = _categoryText(item);
    return haystack.contains('environment') ||
        haystack.contains('scene') ||
        haystack.contains('background') ||
        haystack.contains('sanctuary') ||
        haystack.contains('bilateral stimulation img') ||
        haystack.contains('bilateral-stimulation-img');
  }

  static bool _looksLikeVisual(Map<String, dynamic> item) {
    if (_looksLikeSound(item) || _looksLikeEnvironment(item)) return false;
    final haystack = _categoryText(item);
    return haystack.contains('topon vai') ||
        haystack.contains('topon-vai') ||
        haystack.contains('6a10199a67c4ef887eb9513a');
  }

  static bool _looksLikeSound(Map<String, dynamic> item) {
    final mediaType = item['mediaType']?.toString().trim().toLowerCase();
    if (mediaType == 'audio' || mediaType == 'music') return true;

    final haystack = _classificationText(item);
    return haystack.contains('sound') ||
        haystack.contains('audio') ||
        haystack.contains('music') ||
        _hasAudioUrl(item);
  }

  static bool _hasAudioUrl(Map<String, dynamic> item) {
    final url = _audioUrlFor(item).trim();
    if (url.isEmpty) return false;

    final mediaType = item['mediaType']?.toString().trim().toLowerCase();
    if (mediaType == 'audio' || mediaType == 'music') return true;

    final lower = url.toLowerCase();
    return lower.endsWith('.mp3') ||
        lower.endsWith('.wav') ||
        lower.endsWith('.m4a') ||
        lower.endsWith('.aac') ||
        lower.endsWith('.ogg') ||
        lower.contains('/audio/upload/') ||
        lower.contains('/raw/upload/');
  }

  static String _classificationText(Map<String, dynamic> item) {
    final pieces = <String>[];

    void add(dynamic value) {
      if (value == null) return;
      if (value is Map) {
        pieces.addAll(value.values.map((entry) => entry.toString()));
      } else {
        pieces.add(value.toString());
      }
    }

    add(item['category']);
    add(item['categoryId']);
    add(item['categoryName']);
    add(item['type']);
    add(item['mediaType']);
    add(item['name']);
    add(item['title']);
    add(item['label']);
    return pieces.join(' ').toLowerCase();
  }

  static String _categoryText(Map<String, dynamic> item) {
    final pieces = <String>[];

    void add(dynamic value) {
      if (value == null) return;
      if (value is Map) {
        pieces.addAll(value.values.map((entry) => entry.toString()));
      } else {
        pieces.add(value.toString());
      }
    }

    add(item['category']);
    add(item['categoryId']);
    add(item['categoryName']);
    add(item['slug']);
    return pieces.join(' ').toLowerCase();
  }

  static String _idFor(Map<String, dynamic> item) {
    for (final key in ['id', '_id', 'uuid', 'slug']) {
      final value = _idValue(item[key]);
      if (value.isNotEmpty) return value;
    }
    final media = _mediaUrlFor(item);
    return media.isNotEmpty ? media : _nameFor(item, fallback: 'media');
  }

  static String _idValue(dynamic value) {
    if (value == null) return '';
    if (value is Map) {
      for (final key in [r'$oid', 'oid', '_id', 'id']) {
        final nested = _idValue(value[key]);
        if (nested.isNotEmpty) return nested;
      }
      return '';
    }
    final text = value.toString().trim();
    return text == 'null' ? '' : text;
  }

  static String _nameFor(
    Map<String, dynamic> item, {
    required String fallback,
  }) {
    for (final key in ['name', 'title', 'label', 'displayName']) {
      final value = item[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return fallback;
  }

  static String _visualLabelFor(
    Map<String, dynamic> item, {
    required String fallback,
  }) {
    final pieces = <String>[fallback];
    for (final key in [
      'originalName',
      'original_name',
      'fileName',
      'file_name',
      'filename',
      'title',
      'label',
    ]) {
      final value = item[key]?.toString().trim();
      if (value != null && value.isNotEmpty) pieces.add(value);
    }
    final source = item['source'];
    if (source is Map) {
      pieces.add(
        _visualLabelFor(Map<String, dynamic>.from(source), fallback: ''),
      );
    }
    return pieces.join(' ').trim();
  }

  static String _mediaTypeFor(Map<String, dynamic> item) {
    final mediaType = item['mediaType']?.toString().trim().toLowerCase();
    if (mediaType != null && mediaType.isNotEmpty) {
      final media = _mediaUrlFor(item);
      return _mediaTypeForSource(media, fallback: mediaType);
    }

    final media = _mediaUrlFor(item);
    final type = _mediaTypeForSource(media);
    if (type != 'image') return type;
    final path =
        Uri.tryParse(media.trim())?.path.toLowerCase() ?? media.toLowerCase();
    if (path.endsWith('.png') ||
        path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.webp') ||
        path.endsWith('.gif')) {
      return 'image';
    }
    if (media.toLowerCase().contains('video')) {
      return 'video';
    }
    if (_hasAudioUrl(item)) return 'audio';
    return 'image';
  }

  static String _mediaTypeForSource(
    String source, {
    String fallback = 'image',
  }) {
    final raw = source.trim();
    final path = Uri.tryParse(raw)?.path.toLowerCase() ?? raw.toLowerCase();
    if (path.endsWith('.png') ||
        path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.webp') ||
        path.endsWith('.gif')) {
      return 'image';
    }
    if (path.endsWith('.mp3') ||
        path.endsWith('.wav') ||
        path.endsWith('.m4a') ||
        path.endsWith('.aac') ||
        path.endsWith('.ogg')) {
      return 'audio';
    }
    if (path.endsWith('.mp4') ||
        path.endsWith('.mov') ||
        path.endsWith('.webm')) {
      return 'video';
    }
    return fallback;
  }

  static String _transparentMediaFor(Map<String, dynamic> item) {
    final direct = _firstString(item, [
      'transparentUrl',
      'transparent_url',
      'transparentMedia',
      'transparent_media',
      'alphaUrl',
      'alpha_url',
      'objectUrl',
      'object_url',
      'animationUrl',
      'animation_url',
      'webpUrl',
      'webp_url',
      'gifUrl',
      'gif_url',
    ]);
    if (direct.isNotEmpty) return direct;

    final source = item['source'];
    if (source is Map) {
      return _transparentMediaFor(Map<String, dynamic>.from(source));
    }
    return '';
  }

  static String _resolveVisualMediaUrl(
    String media, {
    required String label,
    required String mediaType,
  }) {
    return resolveTransparentVisualUrl(
      media,
      label: label,
      mediaType: mediaType,
    );
  }

  static String _mediaUrlFor(
    Map<String, dynamic> item, {
    bool preferImage = false,
  }) {
    final keys = preferImage
        ? [
            'transparentUrl',
            'transparent_url',
            'alphaUrl',
            'alpha_url',
            'image',
            'imageUrl',
            'thumbnail',
            'poster',
            'url',
            'fileUrl',
            'mediaUrl',
            'img',
          ]
        : [
            'transparentUrl',
            'transparent_url',
            'transparentMedia',
            'transparent_media',
            'alphaUrl',
            'alpha_url',
            'objectUrl',
            'object_url',
            'animationUrl',
            'animation_url',
            'webpUrl',
            'webp_url',
            'gifUrl',
            'gif_url',
            'img',
            'url',
            'fileUrl',
            'mediaUrl',
            'image',
            'imageUrl',
            'videoUrl',
            'thumbnail',
          ];
    return _firstString(item, keys);
  }

  static String _audioUrlFor(Map<String, dynamic> item) => _firstString(item, [
    'url',
    'audioUrl',
    'soundUrl',
    'fileUrl',
    'mediaUrl',
    'path',
  ]);

  static String _posterFor(Map<String, dynamic> item) => _firstString(item, [
    'musicProfile',
    'music_profile',
    'imageProfile',
    'image_profile',
    'thumbnail',
    'poster',
    'image',
    'imageUrl',
    'image_url',
    'videoProfile',
    'video_profile',
  ]);

  static String _firstString(Map<String, dynamic> item, List<String> keys) {
    for (final key in keys) {
      final value = item[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
      if (value is Map) {
        final nested = Map<String, dynamic>.from(value);
        for (final nestedKey in const [
          'url',
          'secure_url',
          'secureUrl',
          'path',
          'src',
          'href',
          'mediaUrl',
          'media_url',
          'imageUrl',
          'image_url',
          'thumbnail',
          'poster',
          'transparentUrl',
          'transparent_url',
        ]) {
          final nestedValue = nested[nestedKey]?.toString().trim();
          if (nestedValue != null && nestedValue.isNotEmpty) {
            return nestedValue;
          }
        }

        for (final entry in nested.entries) {
          final candidate = entry.value?.toString().trim() ?? '';
          if (candidate.startsWith('http://') ||
              candidate.startsWith('https://') ||
              candidate.startsWith('//')) {
            return candidate;
          }
        }
      }
    }
    return '';
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final bool isSuccess =
          response.statusCode >= 200 && response.statusCode < 300;

      if (isSuccess) {
        return {'success': true, 'data': body['data']};
      }

      String? errorMessage;
      if (body['message'] != null) {
        errorMessage = body['message'].toString();
      } else if (body['error'] != null && body['error'] is Map) {
        errorMessage = body['error']['message']?.toString();
      }

      return {
        'success': false,
        'message': errorMessage ?? 'Server error: ${response.statusCode}',
        ...body,
      };
    } catch (_) {
      return {'success': false, 'message': 'Invalid server response'};
    }
  }
}
