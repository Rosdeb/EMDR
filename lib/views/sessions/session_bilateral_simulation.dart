// import 'dart:async';
//
// import 'package:audioplayers/audioplayers.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:jonssony/controller/auth_controller.dart';
// import 'package:jonssony/controller/bilateral_controller.dart';
// import 'package:jonssony/models/app_theme.dart';
// import 'package:jonssony/services/session_completion_service.dart';
// import 'package:jonssony/services/session_progress_service.dart';
// import 'package:jonssony/services/voice_service.dart';
// import 'package:jonssony/data/bls_built_in_sounds.dart';
// import 'package:jonssony/data/bls_local_visuals.dart';
// import 'package:jonssony/data/bls_tone_profiles.dart';
// import 'package:jonssony/data/bls_speed_presets.dart';
// import 'package:jonssony/widgets/asset_animated_visual.dart';
// import 'package:jonssony/widgets/white_key_asset_image.dart';
// import 'package:jonssony/views/Library/bls_pdf_visuals.dart';
// import 'package:jonssony/views/Library/simulation_screen.dart';
// import 'package:jonssony/views/Library/simulation_settings.dart';
// import 'package:jonssony/views/sessions/session_seven.dart';
//
//
// class SessionBilateralSimulation extends StatefulWidget {
//   const SessionBilateralSimulation({
//     super.key,
//     this.showSaveSettings = true,
//     this.showBeginSession = true,
//     this.backTitle = 'Session 6',
//   });
//
//   final bool showSaveSettings;
//   final bool showBeginSession;
//   final String backTitle;
//
//   @override
//   State<SessionBilateralSimulation> createState() =>
//       _SessionBilateralSimulationState();
// }
//
// class _SessionBilateralSimulationState
//     extends State<SessionBilateralSimulation> {
//   static const _storageKey = 'bls_html_config';
//   static const _brand = 'The UK InKind Psychology Clinic';
//
//   final GetStorage _storage = GetStorage();
//   final VoiceService _voice = VoiceService();
//   final AudioPlayer _soundPreviewPlayer = AudioPlayer();
//   Timer? _savedTimer;
//   BilateralController? _bilateralController;
//   bool _appliedRemoteSettings = false;
//
//   late _BlsMediaOption _selectedScene;
//   late _BlsMediaOption _selectedVisual;
//   late _BlsMediaOption _selectedSound;
//   _BlsSpeed _selectedSpeed = _BlsSpeed.medium;
//   _BlsDirection _selectedDirection = _BlsDirection.horizontal;
//   _BlsSessionDuration _selectedDuration = _BlsSessionDuration.sixty;
//   bool _showSavedIndicator = false;
//   bool _sceneGridExpanded = false;
//   bool _visualGridExpanded = false;
//   bool _soundGridExpanded = false;
//   static const _gridPreviewRows = 2;
//
//   static const _emptySceneOption = _BlsMediaOption(
//     name: '',
//     url: '',
//     type: _BlsMediaType.scene,
//   );
//   static const _emptyVisualOption = _BlsMediaOption(
//     name: '',
//     url: '',
//     type: _BlsMediaType.visual,
//   );
//   static const _emptySoundOption = _BlsMediaOption(
//     name: '',
//     url: '',
//     type: _BlsMediaType.sound,
//   );
//
//   @override
//   void initState() {
//     super.initState();
//     _selectedScene = _emptySceneOption;
//     _selectedVisual = _emptyVisualOption;
//     _selectedSound = _emptySoundOption;
//     if (Get.isRegistered<BilateralController>()) {
//       _bilateralController = Get.find<BilateralController>();
//       if (_bilateralController!.environments.isEmpty &&
//           !_bilateralController!.isLoading.value) {
//         unawaited(_bilateralController!.fetchConfig());
//       }
//     }
//     _loadPreferences();
//     if (_selectedVisual == _emptyVisualOption && kBlsLocalVisuals.isNotEmpty) {
//       _selectedVisual = _localVisualOptions.first;
//     }
//     if (_selectedScene.url.isEmpty && _sceneOptions.isNotEmpty) {
//       _selectedScene = _sceneOptions.first;
//     }
//     if (_selectedSound.url.isEmpty && _soundOptions.isNotEmpty) {
//       _selectedSound = _soundOptions.first;
//     }
//     unawaited(_configureSoundPreviewPlayer());
//     unawaited(_checkSessionAccess());
//   }
//
//   Future<void> _configureSoundPreviewPlayer() async {
//     await _soundPreviewPlayer.setReleaseMode(ReleaseMode.release);
//     await _soundPreviewPlayer.setVolume(0.5);
//   }
//
//   Future<void> _stopSoundPreview() async {
//     try {
//       await _soundPreviewPlayer.stop();
//     } catch (_) {
//       // Preview stop is best-effort.
//     }
//   }
//
//   @override
//   void dispose() {
//     _savedTimer?.cancel();
//     unawaited(_stopSoundPreview());
//     _soundPreviewPlayer.dispose();
//     _voice.dispose();
//     super.dispose();
//   }
//
//   List<_BlsMediaOption> get _sceneOptions {
//     final apiScenes =
//         _apiOptions(_bilateralController?.environments, _BlsMediaType.scene);
//     if (apiScenes.isNotEmpty) return apiScenes;
//     return _localSceneOptions;
//   }
//
//   List<_BlsMediaOption> get _localSceneOptions {
//     return kBlsLocalScenes
//         .map(
//           (scene) => _BlsMediaOption(
//             id: scene.key,
//             name: scene.value,
//             url: '$blsScenePrefix${scene.key}',
//             playbackUrl: '$blsScenePrefix${scene.key}',
//             type: _BlsMediaType.scene,
//             mediaType: 'scene',
//             icon: Icons.landscape_rounded,
//           ),
//         )
//         .toList(growable: false);
//   }
//
//   // API visuals disabled — local GIF/WebP from assets/icons/ are used instead.
//   // List<_BlsMediaOption> get _apiVisualOptions =>
//   //     _apiOptions(_bilateralController?.objects, _BlsMediaType.visual);
//
//   List<_BlsMediaOption> get _visualOptions => _localVisualOptions;
//
//   List<_BlsMediaOption> get _localVisualOptions {
//     return kBlsSelectableLocalVisuals
//         .map(
//           (visual) => _BlsMediaOption(
//             id: visual.id,
//             name: visual.label,
//             url: visual.id,
//             playbackUrl: visual.id,
//             type: _BlsMediaType.visual,
//             mediaType: visual.mediaType,
//             icon: Icons.auto_awesome_rounded,
//           ),
//         )
//         .toList();
//   }
//
//   List<_BlsMediaOption> get _soundOptions {
//     final apiSounds =
//         _apiOptions(_bilateralController?.sounds, _BlsMediaType.sound);
//     if (apiSounds.isNotEmpty) return apiSounds;
//     return _builtInSoundOptions;
//   }
//
//   List<_BlsMediaOption> get _builtInSoundOptions {
//     return BlsBuiltInSounds.entries
//         .map(
//           (entry) => _BlsMediaOption(
//             id: entry.key,
//             name: entry.value,
//             url: entry.key,
//             playbackUrl: entry.key,
//             type: _BlsMediaType.sound,
//             mediaType: 'tone',
//             icon: Icons.graphic_eq_rounded,
//           ),
//         )
//         .toList(growable: false);
//   }
//
//   bool get _hasRequiredApiSelections =>
//       _sceneOptions.isNotEmpty &&
//       _visualOptions.isNotEmpty &&
//       _soundOptions.isNotEmpty &&
//       _sceneOptions.contains(_selectedScene) &&
//       _visualOptions.contains(_selectedVisual) &&
//       _soundOptions.contains(_selectedSound);
//
//   List<_BlsMediaOption> _apiOptions(
//     List<dynamic>? rawOptions,
//     _BlsMediaType type,
//   ) {
//     final seen = <String>{};
//     final options = <_BlsMediaOption>[];
//     final rawItems = rawOptions ?? const <dynamic>[];
//
//     for (final raw in rawItems) {
//       final option = _optionFromBackend(raw, type);
//       if (option == null) continue;
//       if (seen.add(option.identityKey)) options.add(option);
//     }
//
//     return options;
//   }
//
//   _BlsMediaOption? _optionFromBackend(dynamic raw, _BlsMediaType type) {
//     if (raw is! Map) return null;
//     final map = Map<String, dynamic>.from(raw);
//     final id = _firstString(map, const [
//       'id',
//       '_id',
//       'uuid',
//       'key',
//       'slug',
//       'value',
//     ]);
//     final label = _firstString(map, const [
//       'name',
//       'title',
//       'label',
//       'displayName',
//       'display_name',
//     ]);
//     final transparentUrl = _firstString(map, const [
//       'transparentUrl',
//       'transparent_url',
//       'transparentMedia',
//       'transparent_media',
//       'alphaUrl',
//       'alpha_url',
//     ]);
//     final rawMedia = _firstString(map, const [
//       'url',
//       'videoUrl',
//       'video_url',
//       'fileUrl',
//       'file_url',
//       'mediaUrl',
//       'media_url',
//       'img',
//       'imageUrl',
//       'image_url',
//       'image',
//     ]);
//     final media = _firstString(map, const [
//       'transparentUrl',
//       'transparent_url',
//       'transparentMedia',
//       'transparent_media',
//       'alphaUrl',
//       'alpha_url',
//       'objectUrl',
//       'object_url',
//       'animationUrl',
//       'animation_url',
//       'webpUrl',
//       'webp_url',
//       'gifUrl',
//       'gif_url',
//       'url',
//       'img',
//       'imageUrl',
//       'image_url',
//       'image',
//       'videoUrl',
//       'video_url',
//       'fileUrl',
//       'file_url',
//       'mediaUrl',
//       'media_url',
//       'poster',
//       'thumbnail',
//       'iconUrl',
//       'icon_url',
//       'audioUrl',
//       'audio_url',
//       'soundUrl',
//       'sound_url',
//       'path',
//       'asset',
//     ]);
//
//     final name = label ?? id ?? media;
//     if (name == null || name.trim().isEmpty) return null;
//
//     var mediaType =
//         _firstString(map, const ['mediaType', 'media_type', 'type']) ??
//         _mediaTypeFromSource(media ?? '');
//     final poster = _posterFromBackend(map);
//     final sourceId = _normaliseSourceId(id ?? label ?? media ?? name);
//     var url = media?.trim() ?? '';
//     var playbackUrl = url;
//     var resolvedTransparentUrl = transparentUrl?.trim() ?? '';
//     var audioAsset = '';
//     var icon = _iconForMediaType(type);
//
//     switch (type) {
//       case _BlsMediaType.scene:
//         if (url.isEmpty || !_isRenderableMediaSource(url)) {
//           url = '$blsScenePrefix$sourceId';
//         }
//         break;
//       case _BlsMediaType.visual:
//         // API visuals skipped — see [_localVisualOptions] for bundled assets.
//         return null;
//         /*
//         final hasRemoteMedia = url.isNotEmpty && _isRenderableMediaSource(url);
//         if (hasRemoteMedia) {
//           final isVideo = mediaType == 'video' || _isVideoSource(url);
//           if (isVideo) {
//             final rawPlaybackSource = rawMedia?.trim().isNotEmpty == true
//                 ? rawMedia!.trim()
//                 : url;
//             playbackUrl = resolveVisualPlaybackUrl(
//               rawPlaybackSource,
//               mediaType: mediaType,
//             );
//           } else {
//             url = resolveTransparentVisualUrl(
//               url,
//               label: _visualLabelFromBackend(map, fallback: name.trim()),
//               mediaType: mediaType,
//             );
//             mediaType = _mediaTypeFromSource(url);
//             playbackUrl = url;
//           }
//         } else {
//           final mappedObject = bilateralObjectFromSource(
//             url.isEmpty ? sourceId : url,
//           );
//           if (mappedObject != null) {
//             url = '$blsObjectPrefix${mappedObject.key}';
//           } else if (url.isEmpty || !_isRenderableMediaSource(url)) {
//             url = '$blsObjectPrefix$sourceId';
//           }
//         }
//         break;
//         */
//       case _BlsMediaType.sound:
//         audioAsset =
//             _firstString(map, const [
//               'url',
//               'audioUrl',
//               'audio_url',
//               'soundUrl',
//               'sound_url',
//               'fileUrl',
//               'file_url',
//             ]) ??
//             media?.trim() ??
//             '';
//         final soundKeySource = audioAsset.isNotEmpty
//             ? audioAsset
//             : (media?.trim().isNotEmpty == true ? media!.trim() : name);
//         url = id?.trim().isNotEmpty == true
//             ? id!.trim()
//             : _normaliseSoundKey(label ?? soundKeySource);
//         if (audioAsset.isEmpty && _isRenderableMediaSource(url)) {
//           audioAsset = url;
//         }
//         icon = _iconForSoundName(name);
//         break;
//     }
//
//     return _BlsMediaOption(
//       id: id,
//       name: name.trim(),
//       url: url,
//       playbackUrl: playbackUrl,
//       transparentUrl: resolvedTransparentUrl.isEmpty
//           ? null
//           : resolvedTransparentUrl,
//       type: type,
//       icon: icon,
//       audioAsset: audioAsset,
//       mediaType: mediaType,
//       poster: poster,
//       isRemote: true,
//     );
//   }
//
//   String? _posterFromBackend(Map<String, dynamic> map) {
//     final poster = _firstString(map, const [
//       'poster',
//       'image',
//       'musicProfile',
//       'music_profile',
//       'imageProfile',
//       'image_profile',
//       'thumbnail',
//       'imageUrl',
//       'image_url',
//       'videoProfile',
//       'video_profile',
//     ]);
//     if (poster != null) return poster;
//
//     final source = map['source'];
//     if (source is Map) {
//       return _firstString(Map<String, dynamic>.from(source), const [
//         'musicProfile',
//         'music_profile',
//         'imageProfile',
//         'image_profile',
//         'image',
//         'poster',
//         'thumbnail',
//         'imageUrl',
//         'image_url',
//         'videoProfile',
//         'video_profile',
//       ]);
//     }
//
//     return null;
//   }
//
//   String _visualLabelFromBackend(
//     Map<String, dynamic> map, {
//     required String fallback,
//   }) {
//     final pieces = <String>[fallback];
//     for (final key in const [
//       'originalName',
//       'original_name',
//       'fileName',
//       'file_name',
//       'filename',
//       'title',
//       'label',
//     ]) {
//       final value = map[key]?.toString().trim();
//       if (value != null && value.isNotEmpty) pieces.add(value);
//     }
//     final source = map['source'];
//     if (source is Map) {
//       final nested = _visualLabelFromBackend(
//         Map<String, dynamic>.from(source),
//         fallback: '',
//       );
//       if (nested.isNotEmpty) pieces.add(nested);
//     }
//     return pieces.join(' ').trim();
//   }
//
//   String _mediaTypeFromSource(String source) {
//     final value = _mediaPath(source);
//     if (value.endsWith('.png') ||
//         value.endsWith('.jpg') ||
//         value.endsWith('.jpeg') ||
//         value.endsWith('.webp') ||
//         value.endsWith('.gif')) {
//       return 'image';
//     }
//     if (value.endsWith('.mp4') ||
//         value.endsWith('.mov') ||
//         value.endsWith('.webm') ||
//         value.contains('video')) {
//       return 'video';
//     }
//     if (value.endsWith('.mp3') ||
//         value.endsWith('.wav') ||
//         value.endsWith('.m4a') ||
//         value.endsWith('.aac') ||
//         value.endsWith('.ogg')) {
//       return 'audio';
//     }
//     return 'image';
//   }
//
//   String? _firstString(Map<String, dynamic> map, List<String> keys) {
//     for (final key in keys) {
//       final value = _stringFromValue(map[key]);
//       if (value != null) return value;
//     }
//     return null;
//   }
//
//   String? _stringFromValue(dynamic value) {
//     if (value == null) return null;
//     if (value is String && value.trim().isNotEmpty) return value.trim();
//     if (value is num || value is bool) return value.toString();
//     if (value is Map) {
//       final nested = Map<String, dynamic>.from(value);
//       return _firstString(nested, const [
//         'url',
//         'secure_url',
//         'path',
//         'src',
//         'mediaUrl',
//         'media_url',
//         'imageUrl',
//         'image_url',
//         'transparentUrl',
//         'transparent_url',
//         r'$oid',
//         '_id',
//         'id',
//         'image',
//         'imageUrl',
//         'image_url',
//         'thumbnail',
//         'poster',
//       ]);
//     }
//     return null;
//   }
//
//   String _normaliseSourceId(String value) => value
//       .trim()
//       .toLowerCase()
//       .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
//       .replaceAll(RegExp(r'^-+|-+$'), '');
//
//   String _normaliseSoundKey(String value) => BlsBuiltInSounds.normalizeKey(value);
//
//   IconData _iconForMediaType(_BlsMediaType type) {
//     switch (type) {
//       case _BlsMediaType.scene:
//         return Icons.landscape_outlined;
//       case _BlsMediaType.visual:
//         return Icons.auto_awesome_rounded;
//       case _BlsMediaType.sound:
//         return Icons.volume_up_outlined;
//     }
//   }
//
//   IconData _iconForSoundName(String name) {
//     final key = name.toLowerCase();
//     if (key.contains('water') ||
//         key.contains('rain') ||
//         key.contains('ocean')) {
//       return Icons.water_drop_outlined;
//     }
//     if (key.contains('breath') || key.contains('air')) {
//       return Icons.air_rounded;
//     }
//     if (key.contains('bowl') || key.contains('calm')) {
//       return Icons.spa_outlined;
//     }
//     if (key.contains('tap')) return Icons.touch_app_outlined;
//     if (key.contains('chime') || key.contains('bell')) {
//       return Icons.notifications_none_rounded;
//     }
//     return Icons.graphic_eq_rounded;
//   }
//
//   void _loadPreferences() {
//     final raw = _storage.read(_storageKey);
//     if (raw is! Map) return;
//
//     final sceneOptions = _sceneOptions;
//     if (sceneOptions.isNotEmpty) {
//       _selectedScene =
//           _optionBySourceId(sceneOptions, raw['background']?.toString()) ??
//           sceneOptions.first;
//     }
//
//     final visualOptions = _visualOptions;
//     if (visualOptions.isNotEmpty) {
//       _selectedVisual =
//           _optionBySourceId(visualOptions, raw['object']?.toString()) ??
//           visualOptions.first;
//     }
//
//     final soundOptions = _soundOptions;
//     if (soundOptions.isNotEmpty) {
//       _selectedSound = soundOptions.firstWhere(
//         (option) =>
//             option.url == raw['sound']?.toString() ||
//             option.id == raw['sound']?.toString(),
//         orElse: () => soundOptions.first,
//       );
//     }
//     _selectedSpeed = _blsSpeedFromKey(raw['speed']?.toString());
//     _selectedDirection = _blsDirectionFromKey(raw['direction']?.toString());
//     _selectedDuration = _blsSessionDurationFromMinutes(raw['durationMinutes']);
//   }
//
//   Future<void> _checkSessionAccess() async {
//     if (!widget.showBeginSession) return;
//     final journeyId = SessionCompletionService.activeJourneyId();
//     if (journeyId.isEmpty || !Get.isRegistered<AuthController>()) return;
//
//     final token = Get.find<AuthController>().token;
//     if (token == null || token.isEmpty) return;
//
//     final result = await SessionProgressService.getProgressById(
//       token,
//       journeyId,
//     );
//     if (!mounted || result['success'] != true || result['data'] is! Map) {
//       return;
//     }
//
//     final data = Map<String, dynamic>.from(result['data']);
//     final completed = _completedSessionCount(data);
//     if (completed > 0 && completed < 5) {
//       Get.snackbar(
//         'Session locked',
//         'Please complete the previous sessions first.',
//         backgroundColor: Colors.redAccent,
//         colorText: Colors.white,
//       );
//       Navigator.of(context).maybePop();
//     }
//   }
//
//   int _completedSessionCount(Map<String, dynamic> data) {
//     for (final key in [
//       'compledSession',
//       'completedSession',
//       'completedSessions',
//       'currentSession',
//     ]) {
//       final value = data[key];
//       if (value is num) return value.toInt();
//       final parsed = int.tryParse(value?.toString() ?? '');
//       if (parsed != null) return parsed;
//     }
//     return 0;
//   }
//
//   _BlsMediaOption? _optionBySourceId(
//     List<_BlsMediaOption> options,
//     String? sourceId,
//   ) {
//     if (sourceId == null || sourceId.isEmpty) return null;
//     for (final option in options) {
//       if (option.url == sourceId ||
//           option.id == sourceId ||
//           option.audioAsset == sourceId ||
//           blsSourceId(option.url) == sourceId) {
//         return option;
//       }
//     }
//
//     final mappedObject = bilateralObjectFromSource('$blsObjectPrefix$sourceId');
//     if (mappedObject != null) {
//       for (final option in options) {
//         if (blsSourceId(option.url) == mappedObject.key) return option;
//       }
//     }
//
//     return null;
//   }
//
//   Future<void> _saveSettings() async {
//     if (!_hasRequiredApiSelections) {
//       Get.snackbar(
//         'Media not ready',
//         'Please wait for scene, visual, and sound media to load from API.',
//       );
//       return;
//     }
//
//     _storage.write(_storageKey, {
//       'background': _localStorageValue(_selectedScene),
//       'object': _localStorageValue(_selectedVisual),
//       'sound': _selectedSound.url,
//       'soundAsset': _selectedSound.audioAsset,
//       'soundKey': BlsBuiltInSounds.normalizeKey(_selectedSound.url),
//       'soundName': _selectedSound.name,
//       'visualMediaType': _selectedVisual.mediaType,
//       'visualPoster': _selectedVisual.poster,
//       'speed': _selectedSpeed.key,
//       'direction': _selectedDirection.key,
//       'durationMinutes': _selectedDuration.minutes,
//     });
//
//     setState(() => _showSavedIndicator = true);
//     _savedTimer?.cancel();
//     _savedTimer = Timer(const Duration(seconds: 2), () {
//       if (mounted) setState(() => _showSavedIndicator = false);
//     });
//
//     final controller = _bilateralController;
//     if (controller == null) return;
//     await controller.saveSettings(
//       environmentUrl: _selectedScene.apiMediaValue,
//       iconUrl: _selectedVisual.apiMediaValue,
//       soundUrl: _selectedSound.apiMediaValue,
//       speed: _selectedSpeed.backendKey,
//       direction: _selectedDirection.backendKey,
//     );
//   }
//
//   String _localStorageValue(_BlsMediaOption option) {
//     if (option.type == _BlsMediaType.scene) {
//       if (isBlsSceneSource(option.url)) return option.url;
//       if (option.url.trim().isNotEmpty) return option.url.trim();
//       final id = option.id?.trim();
//       if (id != null && id.isNotEmpty) return '$blsScenePrefix$id';
//     }
//     if (option.type == _BlsMediaType.visual &&
//         option.id?.trim().isNotEmpty == true) {
//       return option.id!.trim();
//     }
//     if (isBlsSceneSource(option.url) || isBlsObjectSource(option.url)) {
//       return blsSourceId(option.url);
//     }
//     return option.url;
//   }
//
//   Future<void> _selectSound(_BlsMediaOption option) async {
//     setState(() => _selectedSound = option);
//     await _stopSoundPreview();
//
//     if (option.url == 'none') return;
//
//     try {
//       final audio = option.audioAsset.trim();
//       if (audio.isNotEmpty) {
//         if (_isNetworkUrl(audio)) {
//           await _soundPreviewPlayer.play(UrlSource(audio));
//         } else if (_isAssetPath(audio)) {
//           var assetPath = audio;
//           if (assetPath.startsWith('assets/')) {
//             assetPath = assetPath.substring(7);
//           }
//           await _soundPreviewPlayer.play(AssetSource(assetPath));
//         }
//         return;
//       }
//
//       final profile = resolveBlsToneProfile(option.url);
//       if (profile == null) return;
//
//       final bytes = buildBlsToneWav(profile: profile, isRight: false);
//       await _soundPreviewPlayer.play(BytesSource(bytes, mimeType: 'audio/wav'));
//     } catch (_) {
//       // Preview is best-effort; the actual session still handles playback.
//     }
//   }
//
//   Future<void> _startSimulation() async {
//     if (!_hasRequiredApiSelections) {
//       Get.snackbar(
//         'Selection incomplete',
//         'Please choose a scene, visual, and sound.',
//       );
//       return;
//     }
//
//     if (widget.showBeginSession) {
//       final ready = await _showPreparationDialog();
//       if (!ready || !mounted) return;
//     }
//
//     if (!mounted) return;
//
//     await _stopSoundPreview();
//
//     final phaseTwoReady = await Navigator.push<bool>(
//       context,
//       MaterialPageRoute(
//         builder: (_) => SimulationScreen(
//           settings: SimulationSettings(
//             environmentImage: _selectedScene.url,
//             visualObject: _selectedVisual.url,
//             visualPlaybackUrl: _selectedVisual.playbackUrl,
//             visualTransparentUrl: _selectedVisual.transparentUrl,
//             visualLabel: _selectedVisual.name,
//             speed: _selectedSpeed.seconds,
//             audioAsset: _selectedSound.audioAsset,
//             soundKey: BlsBuiltInSounds.normalizeKey(_selectedSound.url),
//             visualMediaType: _selectedVisual.mediaType,
//             visualPoster: _selectedVisual.poster,
//             direction: _selectedDirection.animationDirection,
//             showCompletionQuestions: true,
//             totalSets: 34,
//             maxDurationMinutes: _selectedDuration.minutes,
//             roadmapSummary: _roadmapSummary,
//           ),
//         ),
//       ),
//     );
//
//     await _stopSoundPreview();
//
//     if (phaseTwoReady == true && mounted && widget.showBeginSession) {
//       await Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (_) => const SessionSeven(
//             initialPhase: S7Phase.phase2,
//             sessionNumber: 6,
//           ),
//         ),
//       );
//     }
//   }
//
//   Future<bool> _showPreparationDialog() async {
//     final roadmapSummary = _roadmapSummary;
//     final script = [
//       'The bilateral stimulation will start now.',
//       if (roadmapSummary.isNotEmpty) 'Your roadmap summary is: $roadmapSummary',
//       'When you have the image and feeling in mind, press start.',
//       'When it starts, let your mind wander. Your thoughts may go forward or backward in time. Simply notice what comes up.',
//     ].join(' ');
//
//     unawaited(_voice.speak(script));
//
//     final result = await showDialog<bool>(
//       context: context,
//       barrierDismissible: true,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//         title: const Text('Before bilateral stimulation'),
//         content: Text(
//           [
//             '1. The bilateral stimulation will start now.',
//             if (roadmapSummary.isNotEmpty)
//               '2. Roadmap summary: $roadmapSummary',
//             '3. Bring your roadmap image and feeling into mind.',
//             '4. When you are ready, press start and let your mind wander. Thoughts may move forward or backward in time; simply notice what comes up.',
//           ].join('\n\n'),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               unawaited(_voice.stop());
//               Navigator.pop(context, false);
//             },
//             child: const Text('Not yet'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               unawaited(_voice.stop());
//               Navigator.pop(context, true);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Color(0xFF6A8A5A),
//               foregroundColor: Colors.white,
//             ),
//             child: const Text('Start'),
//           ),
//         ],
//       ),
//     );
//
//     return result == true;
//   }
//
//   String get _roadmapSummary {
//     final raw = _storage.read('cbt_answers');
//     if (raw is! Map) return '';
//     final answers = Map<String, dynamic>.from(raw);
//     final pieces = <String>[];
//
//     void addAnswer(String label, String key) {
//       final value = answers[key]?.toString().trim();
//       if (value != null && value.isNotEmpty) {
//         pieces.add('$label: $value');
//       }
//     }
//
//     addAnswer('Original image or recent happening', 'A Recent Happening');
//     addAnswer('Trigger', 'Triggers');
//     addAnswer('Feelings', 'My Feelings');
//     addAnswer('Positive belief', 'Your Superpowers');
//     return pieces.join('. ');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           Positioned.fill(
//             child: _SelectionBackdrop(source: _selectedScene.url),
//           ),
//           SafeArea(child: _buildResponsiveShell()),
//           Positioned(
//             top: MediaQuery.of(context).padding.top + 8,
//             left: 12,
//             child: _buildBackHeader(context),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildResponsiveShell() {
//     final controller = _bilateralController;
//     if (controller == null) return _buildResponsiveLayout();
//
//     return Obx(() {
//       _scheduleRemoteSettingsApply();
//       return _buildResponsiveLayout();
//     });
//   }
//
//   Widget _buildResponsiveLayout() {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final maxWidth = constraints.maxWidth;
//         final isWide = maxWidth > 900;
//
//         return SingleChildScrollView(
//           padding: const EdgeInsets.fromLTRB(16, 68, 16, 28),
//           child: Center(
//             child: ConstrainedBox(
//               constraints: const BoxConstraints(maxWidth: 1620),
//               child: Column(
//                 children: [
//                   _buildHeader(),
//                   const SizedBox(height: 20),
//                   _buildSection(
//                     title: 'Scene',
//                     child: _buildSceneGrid(maxWidth),
//                   ),
//                   const SizedBox(height: 12),
//                   isWide
//                       ? Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Expanded(child: _buildVisualSection()),
//                             const SizedBox(width: 12),
//                             Expanded(child: _buildSoundSection()),
//                           ],
//                         )
//                       : Column(
//                           children: [
//                             _buildVisualSection(),
//                             const SizedBox(height: 12),
//                             _buildSoundSection(),
//                           ],
//                         ),
//                   const SizedBox(height: 12),
//                   _buildSettingsSection(isWide),
//                   const SizedBox(height: 22),
//                   _buildActions(),
//                   if (widget.showBeginSession) ...[
//                     const SizedBox(height: 12),
//                     Text(
//                       '34 sets \u00B7 up to ${_selectedDuration.label.toLowerCase()}',
//                       style: const TextStyle(
//                         color: Color(0xFFA09890),
//                         fontSize: 11,
//                         fontFamily: 'Serif',
//                         fontStyle: FontStyle.italic,
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   void _scheduleRemoteSettingsApply() {
//     if (_appliedRemoteSettings && _hasRequiredApiSelections) return;
//     final sceneOptions = _sceneOptions;
//     final visualOptions = _visualOptions;
//     final soundOptions = _soundOptions;
//     if (sceneOptions.isEmpty || visualOptions.isEmpty || soundOptions.isEmpty) {
//       return;
//     }
//     final settings = _bilateralController?.userSettings;
//     _appliedRemoteSettings = true;
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!mounted) return;
//       setState(() {
//         _selectedScene =
//             _optionBySourceId(
//               sceneOptions,
//               settings == null
//                   ? null
//                   : _settingsValue(settings, const [
//                       'environmentId',
//                       'environment',
//                       'environmentUrl',
//                       'background',
//                     ]),
//             ) ??
//             (sceneOptions.contains(_selectedScene)
//                 ? _selectedScene
//                 : sceneOptions.first);
//         _selectedVisual =
//             _optionBySourceId(
//               visualOptions,
//               settings == null
//                   ? null
//                   : _settingsValue(settings, const [
//                       'iconUrl',
//                       'object',
//                       'objectId',
//                       'visualObject',
//                     ]),
//             ) ??
//             (visualOptions.contains(_selectedVisual)
//                 ? _selectedVisual
//                 : visualOptions.first);
//         final soundValue = settings == null
//             ? null
//             : _settingsValue(settings, const [
//                 'soundId',
//                 'sound',
//                 'soundUrl',
//                 'audioUrl',
//               ]);
//         if (soundValue != null) {
//           _selectedSound = soundOptions.firstWhere(
//             (option) =>
//                 option.id == soundValue ||
//                 option.url == soundValue ||
//                 option.audioAsset == soundValue,
//             orElse: () => soundOptions.contains(_selectedSound)
//                 ? _selectedSound
//                 : soundOptions.first,
//           );
//         } else if (!soundOptions.contains(_selectedSound)) {
//           _selectedSound = soundOptions.first;
//         }
//         if (settings != null) {
//           _selectedSpeed = _blsSpeedFromKey(
//             _settingsValue(settings, const ['speed']),
//           );
//           _selectedDirection = _blsDirectionFromKey(
//             _settingsValue(settings, const ['direction']),
//           );
//         }
//       });
//     });
//   }
//
//   String? _settingsValue(Map<String, dynamic> settings, List<String> keys) {
//     for (final key in keys) {
//       final value = settings[key]?.toString().trim();
//       if (value != null && value.isNotEmpty) return value;
//     }
//     return null;
//   }
//
//   Widget _buildBackHeader(BuildContext context) {
//     return Material(
//       color: Colors.white.withValues(alpha: 0.88),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(24),
//         side: BorderSide(color: Colors.white.withValues(alpha: 0.8)),
//       ),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(24),
//         onTap: () => Navigator.of(context).maybePop(),
//         child: Padding(
//           padding: const EdgeInsets.only(left: 13, right: 18),
//           child: SizedBox(
//             height: 44,
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Icon(
//                   Icons.arrow_back_ios_new_rounded,
//                   size: 18,
//                   color: Color(0xFF5A5550),
//                 ),
//                 const SizedBox(width: 10),
//                 Text(
//                   widget.backTitle,
//                   style: const TextStyle(
//                     color: Color(0xFF5A5550),
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeader() {
//     return Column(
//       children: [
//         Text(
//           _brand.toUpperCase(),
//           textAlign: TextAlign.center,
//           style: const TextStyle(
//             color: Color(0xFFA09890),
//             fontSize: 9,
//             letterSpacing: 3,
//             fontFamily: 'Serif',
//           ),
//         ),
//         const SizedBox(height: 10),
//         ShaderMask(
//           shaderCallback: (bounds) => const LinearGradient(
//             colors: [Color(0xFF5A5550), Color(0xFF7A756D)],
//           ).createShader(bounds),
//           child: const Text(
//             'Bilateral Stimulation',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 32,
//               fontWeight: FontWeight.w300,
//               fontFamily: 'Serif',
//               fontStyle: FontStyle.italic,
//             ),
//           ),
//         ),
//         const SizedBox(height: 6),
//         const Text(
//           'Customise your calming experience',
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             color: Color(0xFF9A958D),
//             fontSize: 13,
//             fontFamily: 'Serif',
//             fontStyle: FontStyle.italic,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildSection({required String title, required Widget child}) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white.withValues(alpha: 0.88),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.08),
//             blurRadius: 18,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildSectionTitle(title),
//           const SizedBox(height: 8),
//           child,
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSectionTitle(String title) {
//     return Row(
//       children: [
//         Container(
//           width: 14,
//           height: 1,
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Color(0xFF6F756D), Color(0x006F756D)],
//             ),
//           ),
//         ),
//         const SizedBox(width: 8),
//         Text(
//           title.toUpperCase(),
//           style: const TextStyle(
//             color: Color(0xFF0F1912),
//             fontSize: 11,
//             letterSpacing: 1.4,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildApiMediaState({
//     required String loadingText,
//     required String emptyText,
//   }) {
//     final isLoading = _bilateralController?.isLoading.value ?? false;
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
//       decoration: BoxDecoration(
//         color: Colors.white.withValues(alpha: 0.58),
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: const Color(0xFFDCD7D0)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           if (isLoading) ...[
//             const SizedBox.square(
//               dimension: 16,
//               child: CircularProgressIndicator(strokeWidth: 2),
//             ),
//             const SizedBox(width: 10),
//           ],
//           Flexible(
//             child: Text(
//               isLoading ? loadingText : emptyText,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 color: Color(0xFF8A857D),
//                 fontSize: 12,
//                 fontFamily: 'Serif',
//                 fontStyle: FontStyle.italic,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSceneGrid(double width) {
//     final options = _sceneOptions;
//     if (options.isEmpty) {
//       return _buildApiMediaState(
//         loadingText: 'Loading scenes from server...',
//         emptyText: 'Using bundled watercolor scenes.',
//       );
//     }
//     final columns = _sceneGridColumns(width);
//     _ensureSelectedGridVisible(
//       options: options,
//       selected: _selectedScene,
//       columns: columns,
//       isExpanded: () => _sceneGridExpanded,
//       setExpanded: (value) => _sceneGridExpanded = value,
//     );
//
//     return _buildCollapsibleGrid(
//       columns: columns,
//       totalCount: options.length,
//       expanded: _sceneGridExpanded,
//       onToggleExpanded: () =>
//           setState(() => _sceneGridExpanded = !_sceneGridExpanded),
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: columns,
//         crossAxisSpacing: 6,
//         mainAxisSpacing: 6,
//         childAspectRatio: 1.55,
//       ),
//       itemBuilder: (context, index) {
//         final option = options[index];
//         final selected = option == _selectedScene;
//
//         return GestureDetector(
//           onTap: () => setState(() => _selectedScene = option),
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 250),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(
//                 color: selected ? const Color(0xFF7A9A6A) : Colors.transparent,
//                 width: 2,
//               ),
//               boxShadow: [
//                 if (selected)
//                   BoxShadow(
//                     color: const Color(0xFF7A9A6A).withValues(alpha: 0.2),
//                     blurRadius: 0,
//                     spreadRadius: 3,
//                   ),
//                 BoxShadow(
//                   color: Colors.black.withValues(alpha: selected ? 0.1 : 0.08),
//                   blurRadius: selected ? 15 : 12,
//                   offset: Offset(0, selected ? 4 : 3),
//                 ),
//               ],
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(6),
//               child: Stack(
//                 fit: StackFit.expand,
//                 children: [
//                   _buildScenePreview(option.url),
//                   Positioned(
//                     left: 0,
//                     right: 0,
//                     bottom: 0,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 4,
//                         vertical: 3,
//                       ),
//                       color: Colors.black.withValues(alpha: 0.45),
//                       child: Text(
//                         option.name,
//                         textAlign: TextAlign.center,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 8,
//                           fontFamily: 'Serif',
//                         ),
//                       ),
//                     ),
//                   ),
//                   if (selected) _buildSelectionCheck(top: 4, right: 4),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   int _sceneGridColumns(double width) {
//     if (width <= 480) return 3;
//     if (width <= 720) return 4;
//     if (width <= 960) return 5;
//     if (width <= 1200) return 6;
//     return 8;
//   }
//
//   int _visualGridColumns(double width) {
//     if (width < 260) return 3;
//     if (width < 360) return 4;
//     if (width < 480) return 5;
//     return 6;
//   }
//
//   int _soundGridColumns(double width) {
//     if (width >= 980) return 4;
//     if (width >= 720) return 3;
//     return 2;
//   }
//
//   void _ensureSelectedGridVisible({
//     required List<_BlsMediaOption> options,
//     required _BlsMediaOption selected,
//     required int columns,
//     required bool Function() isExpanded,
//     required void Function(bool value) setExpanded,
//   }) {
//     if (isExpanded()) return;
//     final index = options.indexOf(selected);
//     if (index < 0 || index < columns * _gridPreviewRows) return;
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!mounted || isExpanded()) return;
//       setState(() => setExpanded(true));
//     });
//   }
//
//   Widget _buildCollapsibleGrid({
//     required int columns,
//     required int totalCount,
//     required bool expanded,
//     required VoidCallback onToggleExpanded,
//     required SliverGridDelegate gridDelegate,
//     required IndexedWidgetBuilder itemBuilder,
//   }) {
//     final previewCount = columns * _gridPreviewRows;
//     final hasOverflow = totalCount > previewCount;
//     final itemCount = expanded || !hasOverflow ? totalCount : previewCount;
//     final hiddenCount = totalCount - previewCount;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         AnimatedSize(
//           duration: const Duration(milliseconds: 240),
//           curve: Curves.easeInOut,
//           alignment: Alignment.topCenter,
//           child: GridView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: itemCount,
//             gridDelegate: gridDelegate,
//             itemBuilder: itemBuilder,
//           ),
//         ),
//         if (hasOverflow)
//           _buildSeeMoreToggle(
//             expanded: expanded,
//             hiddenCount: hiddenCount,
//             onTap: onToggleExpanded,
//           ),
//       ],
//     );
//   }
//
//   Widget _buildSeeMoreToggle({
//     required bool expanded,
//     required int hiddenCount,
//     required VoidCallback onTap,
//   }) {
//     return Align(
//       alignment: Alignment.center,
//       child: TextButton.icon(
//         onPressed: onTap,
//         icon: Icon(
//           expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
//           size: 16,
//         ),
//         label: Text(expanded ? 'See less' : 'See more ($hiddenCount)'),
//         style: TextButton.styleFrom(
//           foregroundColor: const Color(0xFF7A9A6A),
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//           minimumSize: Size.zero,
//           tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//           textStyle: const TextStyle(
//             fontSize: 11,
//             fontFamily: 'Serif',
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSelectionCheck({double top = 4, double right = 4}) {
//     return Positioned(
//       top: top,
//       right: right,
//       child: Container(
//         width: 18,
//         height: 18,
//         decoration: const BoxDecoration(
//           color: Color(0xFF7A9A6A),
//           shape: BoxShape.circle,
//         ),
//         child: const Icon(Icons.check_rounded, color: Colors.white, size: 12),
//       ),
//     );
//   }
//
//   Widget _buildScenePreview(String source) {
//     if (isBlsSceneSource(source)) return BlsSceneCanvas(source: source);
//
//     if (_isNetworkUrl(source)) {
//       return CachedNetworkImage(
//         imageUrl: source,
//         fit: BoxFit.cover,
//         memCacheWidth: 720,
//         placeholder: (context, url) => const ColoredBox(
//           color: Color(0xFFEDE7DE),
//           child: Center(
//             child: SizedBox.square(
//               dimension: 18,
//               child: CircularProgressIndicator(strokeWidth: 2),
//             ),
//           ),
//         ),
//         errorWidget: (context, url, error) =>
//             const ColoredBox(color: Color(0xFFEDE7DE)),
//       );
//     }
//
//     if (_isAssetPath(source)) return Image.asset(source, fit: BoxFit.cover);
//
//     return const ColoredBox(color: Color(0xFFEDE7DE));
//   }
//
//   bool _isRenderableMediaSource(String value) =>
//       isBlsSceneSource(value) ||
//       isBlsObjectSource(value) ||
//       _isNetworkUrl(value) ||
//       _isAssetPath(value);
//
//   bool _isNetworkUrl(String value) {
//     final uri = Uri.tryParse(value.trim());
//     return uri != null &&
//         (uri.scheme == 'http' || uri.scheme == 'https') &&
//         uri.host.isNotEmpty;
//   }
//
//   String _mediaPath(String value) {
//     final trimmed = value.trim();
//     final uri = Uri.tryParse(trimmed);
//     return (uri?.path.isNotEmpty == true ? uri!.path : trimmed).toLowerCase();
//   }
//
//   bool _isImageSource(String value) {
//     final path = _mediaPath(value);
//     return path.endsWith('.png') ||
//         path.endsWith('.jpg') ||
//         path.endsWith('.jpeg') ||
//         path.endsWith('.webp') ||
//         path.endsWith('.gif');
//   }
//
//   bool _isAssetPath(String value) {
//     final path = value.trim();
//     return path.startsWith('assets/') ||
//         path.startsWith('asset/') ||
//         path.endsWith('.png') ||
//         path.endsWith('.jpg') ||
//         path.endsWith('.jpeg') ||
//         path.endsWith('.webp') ||
//         path.endsWith('.gif') ||
//         path.endsWith('.mp4') ||
//         path.endsWith('.mov') ||
//         path.endsWith('.webm') ||
//         path.endsWith('.mp3') ||
//         path.endsWith('.wav') ||
//         path.endsWith('.m4a');
//   }
//
//   bool _isVideoSource(String value) {
//     if (_isImageSource(value)) return false;
//     final source = _mediaPath(value);
//     return source.endsWith('.mp4') ||
//         source.endsWith('.mov') ||
//         source.endsWith('.webm') ||
//         source.contains('video');
//   }
//
//   Widget _buildVisualSection() {
//     final options = _visualOptions;
//     return _buildSection(
//       title: 'Visual',
//       child: options.isEmpty
//           ? const Text(
//               'No local visuals found in assets/icons/.',
//               style: TextStyle(color: Color(0xFF8A8278), fontSize: 12),
//             )
//           : LayoutBuilder(
//               builder: (context, constraints) {
//                 final width = constraints.maxWidth;
//                 final columns = _visualGridColumns(width);
//                 _ensureSelectedGridVisible(
//                   options: options,
//                   selected: _selectedVisual,
//                   columns: columns,
//                   isExpanded: () => _visualGridExpanded,
//                   setExpanded: (value) => _visualGridExpanded = value,
//                 );
//
//                 return _buildCollapsibleGrid(
//                   columns: columns,
//                   totalCount: options.length,
//                   expanded: _visualGridExpanded,
//                   onToggleExpanded: () =>
//                       setState(() => _visualGridExpanded = !_visualGridExpanded),
//                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: columns,
//                     crossAxisSpacing: 6,
//                     mainAxisSpacing: 6,
//                     childAspectRatio: 1.08,
//                   ),
//                   itemBuilder: (context, index) {
//                     final option = options[index];
//                     return _buildObjectOption(option);
//                   },
//                 );
//               },
//             ),
//     );
//   }
//
//   Widget _buildObjectOption(_BlsMediaOption option) {
//     final selected = option == _selectedVisual;
//
//     return GestureDetector(
//       onTap: () => setState(() => _selectedVisual = option),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 220),
//         decoration: BoxDecoration(
//           color: selected
//               ? const Color(0xFF7A9A6A).withValues(alpha: 0.16)
//               : Colors.white.withValues(alpha: 0.7),
//           borderRadius: BorderRadius.circular(6),
//           border: Border.all(
//             color: selected
//                 ? const Color(0xFF7A9A6A)
//                 : const Color(0xFFDCD7D0).withValues(alpha: 0.8),
//             width: 1.5,
//           ),
//           boxShadow: [
//             if (selected)
//               BoxShadow(
//                 color: const Color(0xFF7A9A6A).withValues(alpha: 0.07),
//                 blurRadius: 14,
//                 offset: const Offset(0, 4),
//               ),
//           ],
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(6),
//           child: Stack(
//             fit: StackFit.expand,
//             children: [
//               Positioned.fill(child: _buildVisualPreview(option)),
//               Positioned(
//                 left: 0,
//                 right: 0,
//                 bottom: 0,
//                 child: Container(
//                   alignment: Alignment.center,
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 4,
//                     vertical: 3,
//                   ),
//                   color: Colors.black.withValues(alpha: 0.42),
//                   child: Text(
//                     option.name,
//                     textAlign: TextAlign.center,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 8,
//                       fontFamily: 'Serif',
//                     ),
//                   ),
//                 ),
//               ),
//               if (selected) _buildSelectionCheck(top: 5, right: 5),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildVisualPreview(_BlsMediaOption option, {double? size}) {
//     final source = option.id ?? option.url;
//     final visual = resolveLocalVisual(source);
//     if (visual != null) {
//       return LayoutBuilder(
//         builder: (context, constraints) {
//           final dimension = size ??
//               (constraints.maxWidth.isFinite && constraints.maxHeight.isFinite
//                   ? constraints.biggest.shortestSide
//                   : 80.0);
//           return Center(
//             child: AssetAnimatedVisual(
//               assetPath: resolveLocalVisualAsset(source),
//               size: dimension,
//               playing: true,
//               stripWhiteBackground: !visual.usesSpriteFrames,
//             ),
//           );
//         },
//       );
//     }
//
//     final assetSource = resolveLocalVisualAsset(option.url);
//     if (_isAssetPath(assetSource)) {
//       return WhiteKeyAssetImage(
//         assetPath: assetSource,
//         fit: BoxFit.contain,
//         width: double.infinity,
//         height: double.infinity,
//       );
//     }
//
//     return Icon(
//       Icons.auto_awesome_rounded,
//       size: size ?? 44,
//       color: const Color(0xFF6A655D),
//     );
//   }
//
//   /*
//   // API/network visual preview — disabled while using local assets/icons GIF/WebP.
//   Widget _buildVisualPreviewApi(_BlsMediaOption option, {double? size}) {
//     final source = option.url;
//     if (_isVideoSource(source)) {
//       return _buildAnimatedVideoPreview(option);
//     }
//     ...
//   }
//
//   Widget _buildAnimatedVideoPreview(_BlsMediaOption option) { ... }
//
//   Widget _buildStaticVideoPreview(_BlsMediaOption option) { ... }
//   */
//
//   Widget _buildSoundSection() {
//     final options = _soundOptions;
//
//     return _buildSection(
//       title: 'Sound',
//       child: options.isEmpty
//           ? _buildApiMediaState(
//               loadingText: 'Loading API sounds...',
//               emptyText: 'No API sounds found.',
//             )
//           : LayoutBuilder(
//               builder: (context, constraints) {
//                 final panelWidth = constraints.maxWidth;
//                 final columns = _soundGridColumns(panelWidth);
//                 _ensureSelectedGridVisible(
//                   options: options,
//                   selected: _selectedSound,
//                   columns: columns,
//                   isExpanded: () => _soundGridExpanded,
//                   setExpanded: (value) => _soundGridExpanded = value,
//                 );
//
//                 return _buildCollapsibleGrid(
//                   columns: columns,
//                   totalCount: options.length,
//                   expanded: _soundGridExpanded,
//                   onToggleExpanded: () =>
//                       setState(() => _soundGridExpanded = !_soundGridExpanded),
//                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: columns,
//                     crossAxisSpacing: 8,
//                     mainAxisSpacing: 8,
//                     mainAxisExtent: 72,
//                   ),
//                   itemBuilder: (context, index) {
//                     final option = options[index];
//                     return _buildSoundOption(option);
//                   },
//                 );
//               },
//             ),
//     );
//   }
//
//   Widget _buildSoundOption(_BlsMediaOption option) {
//     final selected = option == _selectedSound;
//
//     return GestureDetector(
//       onTap: () => unawaited(_selectSound(option)),
//       child: AnimatedScale(
//         scale: selected ? 0.98 : 1,
//         duration: const Duration(milliseconds: 180),
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 220),
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//           decoration: BoxDecoration(
//             color: selected
//                 ? Colors.white
//                 : Colors.white.withValues(alpha: 0.72),
//             borderRadius: BorderRadius.circular(14),
//             border: Border.all(
//               color: selected
//                   ? const Color(0xFF7A9A6A)
//                   : const Color(0xFFDCD7D0).withValues(alpha: 0.55),
//               width: selected ? 1.5 : 1,
//             ),
//             boxShadow: selected
//                 ? [
//                     BoxShadow(
//                       color: Colors.black.withValues(alpha: 0.08),
//                       blurRadius: 10,
//                       offset: const Offset(0, 3),
//                     ),
//                   ]
//                 : null,
//           ),
//           child: Row(
//             children: [
//               _buildSoundArtwork(option, size: 40),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       option.name,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                         color: selected
//                             ? const Color(0xFF1C1917)
//                             : const Color(0xFF44403C),
//                         fontSize: 12,
//                         height: 1.2,
//                         fontWeight:
//                             selected ? FontWeight.w700 : FontWeight.w500,
//                         fontFamily: 'Serif',
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Icon(
//                 Icons.volume_up_rounded,
//                 size: 16,
//                 color: selected
//                     ? const Color(0xFF7A9A6A)
//                     : const Color(0xFFB8B3AC),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSoundArtwork(_BlsMediaOption option, {double size = 40}) {
//     final id = option.id?.trim();
//     final poster = option.poster?.trim().isNotEmpty == true
//         ? option.poster!.trim()
//         : 'https://picsum.photos/seed/soundimg${id ?? option.name}/150/150';
//
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(10),
//       child: SizedBox.square(
//         dimension: size,
//         child: CachedNetworkImage(
//           imageUrl: poster,
//           fit: BoxFit.cover,
//           memCacheWidth: 160,
//           placeholder: (context, url) => ColoredBox(
//             color: const Color(0xFFF5F5F4),
//             child: Center(
//               child: Icon(
//                 option.icon ?? Icons.music_note_rounded,
//                 size: 18,
//                 color: const Color(0xFF9A958D),
//               ),
//             ),
//           ),
//           errorWidget: (context, url, error) =>
//               _SoundArtworkFallback(option: option),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSettingsSection(bool isWide) {
//     return _buildBareSection(
//       child: isWide
//           ? Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(child: _buildSpeedGroup()),
//                 const SizedBox(width: 12),
//                 Expanded(child: _buildDirectionGroup(isWide)),
//                 const SizedBox(width: 12),
//                 Expanded(child: _buildDurationGroup()),
//               ],
//             )
//           : Column(
//               children: [
//                 _buildSpeedGroup(),
//                 const SizedBox(height: 12),
//                 _buildDirectionGroup(isWide),
//                 const SizedBox(height: 12),
//                 _buildDurationGroup(),
//               ],
//             ),
//     );
//   }
//
//   Widget _buildBareSection({required Widget child}) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white.withValues(alpha: 0.88),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.08),
//             blurRadius: 18,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: child,
//     );
//   }
//
//   Widget _buildSpeedGroup() {
//     return _buildSettingGroup(
//       label: 'Speed',
//       child: LayoutBuilder(
//         builder: (context, constraints) {
//           final columns = constraints.maxWidth < 280 ? 2 : 3;
//           return GridView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: _BlsSpeed.values.length,
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: columns,
//               crossAxisSpacing: 6,
//               mainAxisSpacing: 6,
//               childAspectRatio: columns == 3 ? 1.75 : 1.55,
//             ),
//             itemBuilder: (context, index) {
//               final speed = _BlsSpeed.values[index];
//               final selected = speed == _selectedSpeed;
//               return GestureDetector(
//                 onTap: () => setState(() => _selectedSpeed = speed),
//                 child: AnimatedContainer(
//                   duration: const Duration(milliseconds: 220),
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 4,
//                     vertical: 4,
//                   ),
//                   decoration: _optionDecoration(selected, radius: 8),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         speed.icon,
//                         size: 14,
//                         color: const Color(0xFF6A655D),
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         speed.label,
//                         textAlign: TextAlign.center,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: const TextStyle(
//                           color: Color(0xFF5A5550),
//                           fontSize: 9,
//                           fontFamily: 'Serif',
//                           fontStyle: FontStyle.italic,
//                         ),
//                       ),
//                       Text(
//                         '${speed.milliseconds}ms',
//                         style: const TextStyle(
//                           color: Color(0xFF9A958D),
//                           fontSize: 7,
//                           fontFamily: 'Serif',
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildDirectionGroup(bool isWide) {
//     return _buildSettingGroup(
//       label: 'Direction',
//       dense: true,
//       child: LayoutBuilder(
//         builder: (context, constraints) {
//           final columns = constraints.maxWidth < 280 ? 2 : 4;
//           const cellHeight = 50.0;
//
//           return GridView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: _BlsDirection.values.length,
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: columns,
//               crossAxisSpacing: 4,
//               mainAxisSpacing: 4,
//               mainAxisExtent: cellHeight,
//             ),
//             itemBuilder: (context, index) {
//               final direction = _BlsDirection.values[index];
//               final selected = direction == _selectedDirection;
//               return GestureDetector(
//                 onTap: () => setState(() => _selectedDirection = direction),
//                 child: AnimatedContainer(
//                   duration: const Duration(milliseconds: 220),
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 4,
//                     vertical: 2,
//                   ),
//                   decoration: _optionDecoration(selected, radius: 8),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       SizedBox(
//                         width: 22,
//                         height: 22,
//                         child: CustomPaint(
//                           painter: _DirectionIconPainter(direction),
//                         ),
//                       ),
//                       const SizedBox(height: 2),
//                       Flexible(
//                         child: Text(
//                           direction.gridLabel,
//                           textAlign: TextAlign.center,
//                           maxLines: 2,
//                           overflow: TextOverflow.clip,
//                           style: const TextStyle(
//                             color: Color(0xFF5A5550),
//                             fontSize: 7,
//                             height: 1.1,
//                             fontFamily: 'Serif',
//                             fontStyle: FontStyle.italic,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildDurationGroup() {
//     return _buildSettingGroup(
//       label: 'Session Length',
//       child: Row(
//         children: _BlsSessionDuration.values.map((duration) {
//           final selected = duration == _selectedDuration;
//           return Expanded(
//             child: Padding(
//               padding: EdgeInsets.only(
//                 right: duration == _BlsSessionDuration.values.last ? 0 : 6,
//               ),
//               child: GestureDetector(
//                 onTap: () => setState(() => _selectedDuration = duration),
//                 child: AnimatedContainer(
//                   duration: const Duration(milliseconds: 220),
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 6,
//                     vertical: 6,
//                   ),
//                   decoration: _optionDecoration(selected, radius: 8),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(
//                         duration.icon,
//                         size: 14,
//                         color: const Color(0xFF6A655D),
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         duration.label,
//                         textAlign: TextAlign.center,
//                         style: const TextStyle(
//                           color: Color(0xFF5A5550),
//                           fontSize: 9,
//                           fontFamily: 'Serif',
//                           fontStyle: FontStyle.italic,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
//
//   Widget _buildSettingGroup({
//     required String label,
//     required Widget child,
//     bool dense = false,
//   }) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(dense ? 8 : 10),
//       decoration: BoxDecoration(
//         color: Colors.white.withValues(alpha: 0.55),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label.toUpperCase(),
//             style: TextStyle(
//               color: const Color(0xFF8A857D),
//               fontSize: dense ? 8 : 9,
//               letterSpacing: dense ? 1.2 : 1.4,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           SizedBox(height: dense ? 4 : 6),
//           child,
//         ],
//       ),
//     );
//   }
//
//   BoxDecoration _optionDecoration(bool selected, {required double radius}) {
//     return BoxDecoration(
//       color: selected
//           ? const Color(0xFF7A9A6A).withValues(alpha: 0.15)
//           : Colors.white.withValues(alpha: 0.75),
//       borderRadius: BorderRadius.circular(radius),
//       border: Border.all(
//         color: selected
//             ? const Color(0xFF7A9A6A)
//             : const Color(0xFFDCD7D0).withValues(alpha: 0.8),
//         width: 1.5,
//       ),
//     );
//   }
//
//   Widget _buildActions() {
//     final canUseApiMedia = _hasRequiredApiSelections;
//     final children = <Widget>[
//       if (widget.showSaveSettings) ...[
//         OutlinedButton.icon(
//           onPressed: canUseApiMedia ? _saveSettings : null,
//           icon: const Icon(Icons.save_outlined, size: 16),
//           label: const Text('Save Settings'),
//           style: OutlinedButton.styleFrom(
//             foregroundColor: const Color(0xFF6A655D),
//             backgroundColor: Colors.white.withValues(alpha: 0.7),
//             side: BorderSide(
//               color: const Color(0xFFC8C3BC).withValues(alpha: 0.8),
//               width: 2,
//             ),
//             padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 14),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(30),
//             ),
//             textStyle: const TextStyle(fontSize: 13, fontFamily: 'Serif'),
//           ),
//         ),
//         AnimatedOpacity(
//           duration: const Duration(milliseconds: 250),
//           opacity: _showSavedIndicator ? 1 : 0,
//           child: const Text(
//             '\u2713 Saved',
//             style: TextStyle(
//               color: Color(0xFF7A9A6A),
//               fontSize: 12,
//               fontFamily: 'Serif',
//               fontStyle: FontStyle.italic,
//             ),
//           ),
//         ),
//       ],
//       if (widget.showBeginSession)
//         GestureDetector(
//           onTap: canUseApiMedia ? _startSimulation : null,
//           child: AnimatedOpacity(
//             duration: const Duration(milliseconds: 200),
//             opacity: canUseApiMedia ? 1 : 0.45,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 55, vertical: 16),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(35),
//                 gradient: const LinearGradient(
//                   colors: [Color(0xFF7A9A6A), Color(0xFF6A8A5A)],
//                 ),
//                 boxShadow: [
//                   if (canUseApiMedia)
//                     BoxShadow(
//                       color: const Color(0xFF6A8A5A).withValues(alpha: 0.35),
//                       blurRadius: 25,
//                       offset: const Offset(0, 5),
//                     ),
//                 ],
//               ),
//               child: const Text(
//                 'Begin Session',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 15,
//                   fontFamily: 'Serif',
//                 ),
//               ),
//             ),
//           ),
//         ),
//     ];
//
//     if (children.isEmpty) return const SizedBox.shrink();
//
//     return Wrap(
//       alignment: WrapAlignment.center,
//       crossAxisAlignment: WrapCrossAlignment.center,
//       spacing: 20,
//       runSpacing: 14,
//       children: children,
//     );
//   }
// }
//
// class _SelectionBackdrop extends StatelessWidget {
//   const _SelectionBackdrop({required this.source});
//
//   final String source;
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         _buildBackgroundMedia(),
//         DecoratedBox(
//           decoration: BoxDecoration(
//             color: const Color(0xFFF4F0E7).withValues(alpha: 0.72),
//           ),
//         ),
//         CustomPaint(painter: _SelectionGlowPainter()),
//       ],
//     );
//   }
//
//   Widget _buildBackgroundMedia() {
//     if (isBlsSceneSource(source)) {
//       return BlsSceneCanvas(source: source);
//     }
//
//     final uri = Uri.tryParse(source.trim());
//     if (uri != null &&
//         (uri.scheme == 'http' || uri.scheme == 'https') &&
//         uri.host.isNotEmpty) {
//       return Image.network(
//         source,
//         fit: BoxFit.cover,
//         errorBuilder: (context, error, stackTrace) => _buildFallbackGradient(),
//       );
//     }
//
//     if (source.startsWith('assets/') ||
//         source.endsWith('.png') ||
//         source.endsWith('.jpg') ||
//         source.endsWith('.jpeg') ||
//         source.endsWith('.webp')) {
//       return Image.asset(
//         source,
//         fit: BoxFit.cover,
//         errorBuilder: (context, error, stackTrace) => _buildFallbackGradient(),
//       );
//     }
//
//     return _buildFallbackGradient();
//   }
//
//   Widget _buildFallbackGradient() {
//     return const DecoratedBox(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [Color(0xFFF8F5F0), Color(0xFFEBE5DC)],
//         ),
//       ),
//     );
//   }
// }
//
// class _SelectionGlowPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     void drawGlow(Offset center, Size glowSize, Color color) {
//       final rect = Rect.fromCenter(
//         center: center,
//         width: glowSize.width,
//         height: glowSize.height,
//       );
//       final paint = Paint()
//         ..shader = RadialGradient(
//           colors: [color, color.withValues(alpha: 0)],
//         ).createShader(rect);
//       canvas.drawOval(rect, paint);
//     }
//
//     drawGlow(
//       Offset(size.width * 0.2, size.height * 0.2),
//       Size(size.width * 0.65, size.height * 0.5),
//       const Color(0xFFC8B4A0).withValues(alpha: 0.15),
//     );
//     drawGlow(
//       Offset(size.width * 0.8, size.height * 0.8),
//       Size(size.width * 0.65, size.height * 0.5),
//       const Color(0xFFA0B4A0).withValues(alpha: 0.12),
//     );
//     drawGlow(
//       Offset(size.width * 0.5, size.height * 0.5),
//       Size(size.width * 0.9, size.height * 0.7),
//       const Color(0xFFB4AAA0).withValues(alpha: 0.08),
//     );
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
//
// class _DirectionIconPainter extends CustomPainter {
//   const _DirectionIconPainter(this.direction);
//
//   final _BlsDirection direction;
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = const Color(0xFF5A5550)
//       ..strokeWidth = 2.5
//       ..strokeCap = StrokeCap.round
//       ..style = PaintingStyle.stroke;
//
//     Offset p(double x, double y) => Offset(size.width * x, size.height * y);
//
//     switch (direction) {
//       case _BlsDirection.horizontal:
//         _drawTwoHeadedLine(canvas, paint, p(0.13, 0.5), p(0.87, 0.5));
//         break;
//       case _BlsDirection.vertical:
//         _drawTwoHeadedLine(canvas, paint, p(0.5, 0.13), p(0.5, 0.87));
//         break;
//       case _BlsDirection.diagonalUp:
//         _drawTwoHeadedLine(canvas, paint, p(0.2, 0.8), p(0.8, 0.2));
//         break;
//       case _BlsDirection.diagonalDown:
//         _drawTwoHeadedLine(canvas, paint, p(0.2, 0.2), p(0.8, 0.8));
//         break;
//     }
//   }
//
//   void _drawTwoHeadedLine(
//     Canvas canvas,
//     Paint paint,
//     Offset start,
//     Offset end,
//   ) {
//     canvas.drawLine(start, end, paint);
//     _drawArrowHead(canvas, paint, start, end);
//     _drawArrowHead(canvas, paint, end, start);
//   }
//
//   void _drawArrowHead(Canvas canvas, Paint paint, Offset tip, Offset tail) {
//     final vector = tip - tail;
//     final angle = vector.direction;
//     const length = 8.0;
//     const spread = 0.7;
//     final a = Offset.fromDirection(angle + mathPi - spread, length);
//     final b = Offset.fromDirection(angle + mathPi + spread, length);
//     canvas.drawLine(tip, tip + a, paint);
//     canvas.drawLine(tip, tip + b, paint);
//   }
//
//   @override
//   bool shouldRepaint(covariant _DirectionIconPainter oldDelegate) =>
//       oldDelegate.direction != direction;
// }
//
// const double mathPi = 3.1415926535897932;
//
// enum _BlsMediaType { scene, visual, sound }
//
// class _BlsMediaOption {
//   const _BlsMediaOption({
//     this.id,
//     required this.name,
//     required this.url,
//     this.playbackUrl = '',
//     this.transparentUrl,
//     required this.type,
//     this.icon,
//     this.audioAsset = '',
//     this.mediaType = 'image',
//     this.poster,
//     this.isRemote = false,
//   });
//
//   final String? id;
//   final String name;
//   final String url;
//   final String playbackUrl;
//   final String? transparentUrl;
//   final _BlsMediaType type;
//   final IconData? icon;
//   final String audioAsset;
//   final String mediaType;
//   final String? poster;
//   final bool isRemote;
//
//   String get identityKey => '$type:${id ?? url}:$audioAsset';
//
//   String get apiMediaValue {
//     if (type == _BlsMediaType.sound && audioAsset.trim().isNotEmpty) {
//       return audioAsset.trim();
//     }
//     if (type == _BlsMediaType.visual && isBlsLocalVisualAsset(url)) {
//       final value = id?.trim();
//       if (value != null && value.isNotEmpty) return value;
//     }
//     if (!isBlsSceneSource(url) && !isBlsObjectSource(url)) {
//       return url.trim();
//     }
//     final value = id?.trim();
//     if (value != null && value.isNotEmpty) {
//       return value;
//     }
//     if (isBlsSceneSource(url) || isBlsObjectSource(url)) {
//       return blsSourceId(url);
//     }
//     return url;
//   }
//
//   @override
//   bool operator ==(Object other) =>
//       other is _BlsMediaOption && other.identityKey == identityKey;
//
//   @override
//   int get hashCode => identityKey.hashCode;
// }
//
// class _SoundArtworkFallback extends StatelessWidget {
//   const _SoundArtworkFallback({required this.option});
//
//   final _BlsMediaOption option;
//
//   static const _palette = [
//     [Color(0xFF7A9A6A), Color(0xFFE7D9A8)],
//     [Color(0xFF4F7D8A), Color(0xFFCFE5E7)],
//     [Color(0xFF9A746A), Color(0xFFF1D7C4)],
//     [Color(0xFF6F6A9A), Color(0xFFDAD7F0)],
//     [Color(0xFF8A7A4F), Color(0xFFEFE6BF)],
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     final colors =
//         _palette[option.identityKey.hashCode.abs() % _palette.length];
//     return DecoratedBox(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: colors,
//         ),
//       ),
//       child: Stack(
//         fit: StackFit.expand,
//         children: [
//           Positioned(
//             right: -7,
//             bottom: -7,
//             child: Container(
//               width: 24,
//               height: 24,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.white.withValues(alpha: 0.22),
//               ),
//             ),
//           ),
//           Center(
//             child: Icon(
//               option.icon ?? Icons.graphic_eq_rounded,
//               color: Colors.white,
//               size: 18,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// enum _BlsSpeed { slow, medium, fast }
//
// extension _BlsSpeedDetails on _BlsSpeed {
//   String get key {
//     switch (this) {
//       case _BlsSpeed.slow:
//         return 'slow';
//       case _BlsSpeed.medium:
//         return 'medium';
//       case _BlsSpeed.fast:
//         return 'fast';
//     }
//   }
//
//   String get backendKey => key;
//
//   String get label {
//     switch (this) {
//       case _BlsSpeed.slow:
//         return 'Slow';
//       case _BlsSpeed.medium:
//         return 'Medium';
//       case _BlsSpeed.fast:
//         return 'Fast';
//     }
//   }
//
//   IconData get icon {
//     switch (this) {
//       case _BlsSpeed.slow:
//         return Icons.remove_rounded;
//       case _BlsSpeed.medium:
//         return Icons.keyboard_arrow_right_rounded;
//       case _BlsSpeed.fast:
//         return Icons.double_arrow_rounded;
//     }
//   }
//
//   int get milliseconds {
//     switch (this) {
//       case _BlsSpeed.slow:
//         return (BlsSpeedPresets.slow * 1000).round();
//       case _BlsSpeed.medium:
//         return (BlsSpeedPresets.medium * 1000).round();
//       case _BlsSpeed.fast:
//         return (BlsSpeedPresets.fast * 1000).round();
//     }
//   }
//
//   double get seconds => milliseconds / 1000;
// }
//
// _BlsSpeed _blsSpeedFromKey(String? key) {
//   for (final speed in _BlsSpeed.values) {
//     if (speed.key == key) return speed;
//   }
//   return _BlsSpeed.medium;
// }
//
// enum _BlsDirection { horizontal, vertical, diagonalUp, diagonalDown }
//
// extension _BlsDirectionDetails on _BlsDirection {
//   String get key {
//     switch (this) {
//       case _BlsDirection.horizontal:
//         return 'horizontal';
//       case _BlsDirection.vertical:
//         return 'vertical';
//       case _BlsDirection.diagonalUp:
//         return 'diagonal-up';
//       case _BlsDirection.diagonalDown:
//         return 'diagonal-down';
//     }
//   }
//
//   String get label {
//     switch (this) {
//       case _BlsDirection.horizontal:
//         return 'Horizontal';
//       case _BlsDirection.vertical:
//         return 'Vertical';
//       case _BlsDirection.diagonalUp:
//         return 'Diagonal Up';
//       case _BlsDirection.diagonalDown:
//         return 'Diagonal Down';
//     }
//   }
//
//   /// Compact two-line labels for the direction picker grid.
//   String get gridLabel {
//     switch (this) {
//       case _BlsDirection.horizontal:
//         return 'Horizontal';
//       case _BlsDirection.vertical:
//         return 'Vertical';
//       case _BlsDirection.diagonalUp:
//         return 'Diagonal\nUp';
//       case _BlsDirection.diagonalDown:
//         return 'Diagonal\nDown';
//     }
//   }
//
//   AnimationDirection get animationDirection {
//     switch (this) {
//       case _BlsDirection.horizontal:
//         return AnimationDirection.horizontal;
//       case _BlsDirection.vertical:
//         return AnimationDirection.vertical;
//       case _BlsDirection.diagonalUp:
//         return AnimationDirection.diagonalReverse;
//       case _BlsDirection.diagonalDown:
//         return AnimationDirection.diagonal;
//     }
//   }
//
//   String get backendKey {
//     switch (this) {
//       case _BlsDirection.horizontal:
//         return 'horizontal';
//       case _BlsDirection.vertical:
//         return 'vertical';
//       case _BlsDirection.diagonalUp:
//         return 'diagonal-up';
//       case _BlsDirection.diagonalDown:
//         return 'diagonal-down';
//     }
//   }
// }
//
// _BlsDirection _blsDirectionFromKey(String? key) {
//   if (key == 'left-right') return _BlsDirection.horizontal;
//   if (key == 'top-bottom') return _BlsDirection.vertical;
//   for (final direction in _BlsDirection.values) {
//     if (direction.key == key) return direction;
//   }
//   return _BlsDirection.horizontal;
// }
//
// enum _BlsSessionDuration { sixty, ninety }
//
// extension _BlsSessionDurationDetails on _BlsSessionDuration {
//   int get minutes {
//     switch (this) {
//       case _BlsSessionDuration.sixty:
//         return 60;
//       case _BlsSessionDuration.ninety:
//         return 90;
//     }
//   }
//
//   String get label {
//     switch (this) {
//       case _BlsSessionDuration.sixty:
//         return '1 Hour';
//       case _BlsSessionDuration.ninety:
//         return '1.5 Hours';
//     }
//   }
//
//   IconData get icon {
//     switch (this) {
//       case _BlsSessionDuration.sixty:
//         return Icons.schedule_rounded;
//       case _BlsSessionDuration.ninety:
//         return Icons.more_time_rounded;
//     }
//   }
// }
//
// _BlsSessionDuration _blsSessionDurationFromMinutes(dynamic value) {
//   final minutes = int.tryParse(value?.toString() ?? '');
//   return minutes == 90 ? _BlsSessionDuration.ninety : _BlsSessionDuration.sixty;
// }
//
// class BilateralAudioSync {
//   BilateralAudioSync({this.profile, this.audioAsset = ''});
//
//   final BlsToneProfile? profile;
//   final String audioAsset;
//
//   final AudioPlayer _left = AudioPlayer();
//   final AudioPlayer _right = AudioPlayer();
//
//   Future<void> init() async {
//     await _left.setReleaseMode(ReleaseMode.stop);
//     await _right.setReleaseMode(ReleaseMode.stop);
//     await _left.setBalance(-1.0);  // full left channel
//     await _right.setBalance(1.0);  // full right channel
//
//     if (audioAsset.trim().isNotEmpty) {
//       var path = audioAsset.trim();
//       if (path.startsWith('assets/')) path = path.substring(7);
//       await _left.setSource(AssetSource(path));
//       await _right.setSource(AssetSource(path));
//     }
//   }
//
//   Future<void> tick({required bool isRight}) async {
//     final player = isRight ? _right : _left;
//
//     if (audioAsset.trim().isNotEmpty) {
//       await player.seek(Duration.zero);
//       await player.resume();
//       return;
//     }
//
//     if (profile == null) return;
//     final bytes = buildBlsToneWav(profile: profile!, isRight: isRight);
//     await player.play(BytesSource(bytes, mimeType: 'audio/wav'));
//   }
//
//   Future<void> dispose() async {
//     await _left.dispose();
//     await _right.dispose();
//   }
// }

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jonssony/controller/auth_controller.dart';
import 'package:jonssony/controller/bilateral_controller.dart';
import 'package:jonssony/models/app_theme.dart';
import 'package:jonssony/services/session_completion_service.dart';
import 'package:jonssony/services/session_progress_service.dart';
import 'package:jonssony/services/voice_service.dart';
import 'package:jonssony/data/bls_built_in_sounds.dart';
import 'package:jonssony/data/bls_local_visuals.dart';
import 'package:jonssony/data/bls_tone_profiles.dart';
import 'package:jonssony/data/bls_speed_presets.dart';
import 'package:jonssony/widgets/asset_animated_visual.dart';
import 'package:jonssony/widgets/white_key_asset_image.dart';
import 'package:jonssony/views/Library/bls_pdf_visuals.dart';
import 'package:jonssony/views/Library/simulation_screen.dart';
import 'package:jonssony/views/Library/simulation_settings.dart';
import 'package:jonssony/views/sessions/session_seven.dart';

class SessionBilateralSimulation extends StatefulWidget {
  const SessionBilateralSimulation({
    super.key,
    this.showSaveSettings = true,
    this.showBeginSession = true,
    this.backTitle = 'Session 6',
  });

  final bool showSaveSettings;
  final bool showBeginSession;
  final String backTitle;

  @override
  State<SessionBilateralSimulation> createState() =>
      _SessionBilateralSimulationState();
}

class _SessionBilateralSimulationState
    extends State<SessionBilateralSimulation> {
  static const _storageKey = 'bls_html_config';
  static const _brand = 'The UK InKind Psychology Clinic';

  final GetStorage _storage = GetStorage();
  final VoiceService _voice = VoiceService();
  final AudioPlayer _soundPreviewPlayer = AudioPlayer();
  Timer? _savedTimer;
  BilateralController? _bilateralController;
  bool _appliedRemoteSettings = false;

  late _BlsMediaOption _selectedScene;
  late _BlsMediaOption _selectedVisual;
  late _BlsMediaOption _selectedSound;
  _BlsSpeed _selectedSpeed = _BlsSpeed.medium;
  _BlsDirection _selectedDirection = _BlsDirection.horizontal;
  _BlsSessionDuration _selectedDuration = _BlsSessionDuration.sixty;
  bool _showSavedIndicator = false;
  bool _sceneGridExpanded = false;
  bool _visualGridExpanded = false;
  bool _soundGridExpanded = false;
  static const _gridPreviewRows = 2;

  static const _emptySceneOption = _BlsMediaOption(
    name: '',
    url: '',
    type: _BlsMediaType.scene,
  );
  static const _emptyVisualOption = _BlsMediaOption(
    name: '',
    url: '',
    type: _BlsMediaType.visual,
  );
  static const _emptySoundOption = _BlsMediaOption(
    name: '',
    url: '',
    type: _BlsMediaType.sound,
  );

  @override
  void initState() {
    super.initState();
    _selectedScene = _emptySceneOption;
    _selectedVisual = _emptyVisualOption;
    _selectedSound = _emptySoundOption;
    if (Get.isRegistered<BilateralController>()) {
      _bilateralController = Get.find<BilateralController>();
      if (_bilateralController!.environments.isEmpty &&
          !_bilateralController!.isLoading.value) {
        unawaited(_bilateralController!.fetchConfig());
      }
    }
    _loadPreferences();
    if (_selectedVisual == _emptyVisualOption && kBlsLocalVisuals.isNotEmpty) {
      _selectedVisual = _localVisualOptions.first;
    }
    if (_selectedScene.url.isEmpty && _sceneOptions.isNotEmpty) {
      _selectedScene = _sceneOptions.first;
    }
    if (_selectedSound.url.isEmpty && _soundOptions.isNotEmpty) {
      _selectedSound = _soundOptions.first;
    }
    unawaited(_configureSoundPreviewPlayer());
    unawaited(_checkSessionAccess());
  }

  Future<void> _configureSoundPreviewPlayer() async {
    await _soundPreviewPlayer.setReleaseMode(ReleaseMode.release);
    await _soundPreviewPlayer.setVolume(0.5);
  }

  Future<void> _stopSoundPreview() async {
    try {
      await _soundPreviewPlayer.stop();
    } catch (_) {
      // Preview stop is best-effort.
    }
  }

  @override
  void dispose() {
    _savedTimer?.cancel();
    unawaited(_stopSoundPreview());
    _soundPreviewPlayer.dispose();
    _voice.dispose();
    super.dispose();
  }

  List<_BlsMediaOption> get _sceneOptions {
    final apiScenes = _apiOptions(
      _bilateralController?.environments,
      _BlsMediaType.scene,
    );
    if (apiScenes.isNotEmpty) return apiScenes;
    return _localSceneOptions;
  }

  List<_BlsMediaOption> get _localSceneOptions {
    return kBlsLocalScenes
        .map(
          (scene) => _BlsMediaOption(
            id: scene.key,
            name: scene.value,
            url: '$blsScenePrefix${scene.key}',
            playbackUrl: '$blsScenePrefix${scene.key}',
            type: _BlsMediaType.scene,
            mediaType: 'scene',
            icon: Icons.landscape_rounded,
          ),
        )
        .toList(growable: false);
  }

  // API visuals disabled — local GIF/WebP from assets/icons/ are used instead.
  // List<_BlsMediaOption> get _apiVisualOptions =>
  //     _apiOptions(_bilateralController?.objects, _BlsMediaType.visual);

  List<_BlsMediaOption> get _visualOptions => _localVisualOptions;

  List<_BlsMediaOption> get _localVisualOptions {
    return kBlsSelectableLocalVisuals
        .map(
          (visual) => _BlsMediaOption(
            id: visual.id,
            name: visual.label,
            url: visual.id,
            playbackUrl: visual.id,
            type: _BlsMediaType.visual,
            mediaType: visual.mediaType,
            icon: Icons.auto_awesome_rounded,
          ),
        )
        .toList();
  }

  List<_BlsMediaOption> get _soundOptions {
    final apiSounds = _apiOptions(
      _bilateralController?.sounds,
      _BlsMediaType.sound,
    );
    if (apiSounds.isNotEmpty) return apiSounds;
    return _builtInSoundOptions;
  }

  List<_BlsMediaOption> get _builtInSoundOptions {
    return BlsBuiltInSounds.entries
        .map(
          (entry) => _BlsMediaOption(
            id: entry.key,
            name: entry.value,
            url: entry.key,
            playbackUrl: entry.key,
            type: _BlsMediaType.sound,
            mediaType: 'tone',
            icon: Icons.graphic_eq_rounded,
          ),
        )
        .toList(growable: false);
  }

  bool get _hasRequiredApiSelections =>
      _sceneOptions.isNotEmpty &&
      _visualOptions.isNotEmpty &&
      _soundOptions.isNotEmpty &&
      _sceneOptions.contains(_selectedScene) &&
      _visualOptions.contains(_selectedVisual) &&
      _soundOptions.contains(_selectedSound);

  List<_BlsMediaOption> _apiOptions(
    List<dynamic>? rawOptions,
    _BlsMediaType type,
  ) {
    final seen = <String>{};
    final options = <_BlsMediaOption>[];
    final rawItems = rawOptions ?? const <dynamic>[];

    for (final raw in rawItems) {
      final option = _optionFromBackend(raw, type);
      if (option == null) continue;
      if (seen.add(option.identityKey)) options.add(option);
    }

    return options;
  }

  _BlsMediaOption? _optionFromBackend(dynamic raw, _BlsMediaType type) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final id = _firstString(map, const [
      'id',
      '_id',
      'uuid',
      'key',
      'slug',
      'value',
    ]);
    final label = _firstString(map, const [
      'name',
      'title',
      'label',
      'displayName',
      'display_name',
    ]);
    final transparentUrl = _firstString(map, const [
      'transparentUrl',
      'transparent_url',
      'transparentMedia',
      'transparent_media',
      'alphaUrl',
      'alpha_url',
    ]);
    final rawMedia = _firstString(map, const [
      'url',
      'videoUrl',
      'video_url',
      'fileUrl',
      'file_url',
      'mediaUrl',
      'media_url',
      'img',
      'imageUrl',
      'image_url',
      'image',
    ]);
    final media = _firstString(map, const [
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
      'url',
      'img',
      'imageUrl',
      'image_url',
      'image',
      'videoUrl',
      'video_url',
      'fileUrl',
      'file_url',
      'mediaUrl',
      'media_url',
      'poster',
      'thumbnail',
      'iconUrl',
      'icon_url',
      'audioUrl',
      'audio_url',
      'soundUrl',
      'sound_url',
      'path',
      'asset',
    ]);

    final name = label ?? id ?? media;
    if (name == null || name.trim().isEmpty) return null;

    var mediaType =
        _firstString(map, const ['mediaType', 'media_type', 'type']) ??
        _mediaTypeFromSource(media ?? '');
    final poster = _posterFromBackend(map);
    final sourceId = _normaliseSourceId(id ?? label ?? media ?? name);
    var url = media?.trim() ?? '';
    var playbackUrl = url;
    var resolvedTransparentUrl = transparentUrl?.trim() ?? '';
    var audioAsset = '';
    var icon = _iconForMediaType(type);

    switch (type) {
      case _BlsMediaType.scene:
        if (url.isEmpty || !_isRenderableMediaSource(url)) {
          url = '$blsScenePrefix$sourceId';
        }
        break;
      case _BlsMediaType.visual:
        // API visuals skipped — see [_localVisualOptions] for bundled assets.
        return null;
      /*
        final hasRemoteMedia = url.isNotEmpty && _isRenderableMediaSource(url);
        if (hasRemoteMedia) {
          final isVideo = mediaType == 'video' || _isVideoSource(url);
          if (isVideo) {
            final rawPlaybackSource = rawMedia?.trim().isNotEmpty == true
                ? rawMedia!.trim()
                : url;
            playbackUrl = resolveVisualPlaybackUrl(
              rawPlaybackSource,
              mediaType: mediaType,
            );
          } else {
            url = resolveTransparentVisualUrl(
              url,
              label: _visualLabelFromBackend(map, fallback: name.trim()),
              mediaType: mediaType,
            );
            mediaType = _mediaTypeFromSource(url);
            playbackUrl = url;
          }
        } else {
          final mappedObject = bilateralObjectFromSource(
            url.isEmpty ? sourceId : url,
          );
          if (mappedObject != null) {
            url = '$blsObjectPrefix${mappedObject.key}';
          } else if (url.isEmpty || !_isRenderableMediaSource(url)) {
            url = '$blsObjectPrefix$sourceId';
          }
        }
        break;
        */
      case _BlsMediaType.sound:
        audioAsset =
            _firstString(map, const [
              'url',
              'audioUrl',
              'audio_url',
              'soundUrl',
              'sound_url',
              'fileUrl',
              'file_url',
            ]) ??
            media?.trim() ??
            '';
        final soundKeySource = audioAsset.isNotEmpty
            ? audioAsset
            : (media?.trim().isNotEmpty == true ? media!.trim() : name);
        url = id?.trim().isNotEmpty == true
            ? id!.trim()
            : _normaliseSoundKey(label ?? soundKeySource);
        if (audioAsset.isEmpty && _isRenderableMediaSource(url)) {
          audioAsset = url;
        }
        icon = _iconForSoundName(name);
        break;
    }

    return _BlsMediaOption(
      id: id,
      name: name.trim(),
      url: url,
      playbackUrl: playbackUrl,
      transparentUrl: resolvedTransparentUrl.isEmpty
          ? null
          : resolvedTransparentUrl,
      type: type,
      icon: icon,
      audioAsset: audioAsset,
      mediaType: mediaType,
      poster: poster,
      isRemote: true,
    );
  }

  String? _posterFromBackend(Map<String, dynamic> map) {
    final poster = _firstString(map, const [
      'poster',
      'image',
      'musicProfile',
      'music_profile',
      'imageProfile',
      'image_profile',
      'thumbnail',
      'imageUrl',
      'image_url',
      'videoProfile',
      'video_profile',
    ]);
    if (poster != null) return poster;

    final source = map['source'];
    if (source is Map) {
      return _firstString(Map<String, dynamic>.from(source), const [
        'musicProfile',
        'music_profile',
        'imageProfile',
        'image_profile',
        'image',
        'poster',
        'thumbnail',
        'imageUrl',
        'image_url',
        'videoProfile',
        'video_profile',
      ]);
    }

    return null;
  }

  String _visualLabelFromBackend(
    Map<String, dynamic> map, {
    required String fallback,
  }) {
    final pieces = <String>[fallback];
    for (final key in const [
      'originalName',
      'original_name',
      'fileName',
      'file_name',
      'filename',
      'title',
      'label',
    ]) {
      final value = map[key]?.toString().trim();
      if (value != null && value.isNotEmpty) pieces.add(value);
    }
    final source = map['source'];
    if (source is Map) {
      final nested = _visualLabelFromBackend(
        Map<String, dynamic>.from(source),
        fallback: '',
      );
      if (nested.isNotEmpty) pieces.add(nested);
    }
    return pieces.join(' ').trim();
  }

  String _mediaTypeFromSource(String source) {
    final value = _mediaPath(source);
    if (value.endsWith('.png') ||
        value.endsWith('.jpg') ||
        value.endsWith('.jpeg') ||
        value.endsWith('.webp') ||
        value.endsWith('.gif')) {
      return 'image';
    }
    if (value.endsWith('.mp4') ||
        value.endsWith('.mov') ||
        value.endsWith('.webm') ||
        value.contains('video')) {
      return 'video';
    }
    if (value.endsWith('.mp3') ||
        value.endsWith('.wav') ||
        value.endsWith('.m4a') ||
        value.endsWith('.aac') ||
        value.endsWith('.ogg')) {
      return 'audio';
    }
    return 'image';
  }

  String? _firstString(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = _stringFromValue(map[key]);
      if (value != null) return value;
    }
    return null;
  }

  String? _stringFromValue(dynamic value) {
    if (value == null) return null;
    if (value is String && value.trim().isNotEmpty) return value.trim();
    if (value is num || value is bool) return value.toString();
    if (value is Map) {
      final nested = Map<String, dynamic>.from(value);
      return _firstString(nested, const [
        'url',
        'secure_url',
        'path',
        'src',
        'mediaUrl',
        'media_url',
        'imageUrl',
        'image_url',
        'transparentUrl',
        'transparent_url',
        r'$oid',
        '_id',
        'id',
        'image',
        'imageUrl',
        'image_url',
        'thumbnail',
        'poster',
      ]);
    }
    return null;
  }

  String _normaliseSourceId(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');

  String _normaliseSoundKey(String value) =>
      BlsBuiltInSounds.normalizeKey(value);

  IconData _iconForMediaType(_BlsMediaType type) {
    switch (type) {
      case _BlsMediaType.scene:
        return Icons.landscape_outlined;
      case _BlsMediaType.visual:
        return Icons.auto_awesome_rounded;
      case _BlsMediaType.sound:
        return Icons.volume_up_outlined;
    }
  }

  IconData _iconForSoundName(String name) {
    final key = name.toLowerCase();
    if (key.contains('water') ||
        key.contains('rain') ||
        key.contains('ocean')) {
      return Icons.water_drop_outlined;
    }
    if (key.contains('breath') || key.contains('air')) {
      return Icons.air_rounded;
    }
    if (key.contains('bowl') || key.contains('calm')) {
      return Icons.spa_outlined;
    }
    if (key.contains('tap')) return Icons.touch_app_outlined;
    if (key.contains('chime') || key.contains('bell')) {
      return Icons.notifications_none_rounded;
    }
    return Icons.graphic_eq_rounded;
  }

  void _loadPreferences() {
    final raw = _storage.read(_storageKey);
    if (raw is! Map) return;

    final sceneOptions = _sceneOptions;
    if (sceneOptions.isNotEmpty) {
      _selectedScene =
          _optionBySourceId(sceneOptions, raw['background']?.toString()) ??
          sceneOptions.first;
    }

    final visualOptions = _visualOptions;
    if (visualOptions.isNotEmpty) {
      _selectedVisual =
          _optionBySourceId(visualOptions, raw['object']?.toString()) ??
          visualOptions.first;
    }

    final soundOptions = _soundOptions;
    if (soundOptions.isNotEmpty) {
      _selectedSound = soundOptions.firstWhere(
        (option) =>
            option.url == raw['sound']?.toString() ||
            option.id == raw['sound']?.toString(),
        orElse: () => soundOptions.first,
      );
    }
    _selectedSpeed = _blsSpeedFromKey(raw['speed']?.toString());
    _selectedDirection = _blsDirectionFromKey(raw['direction']?.toString());
    _selectedDuration = _blsSessionDurationFromMinutes(raw['durationMinutes']);
  }

  Future<void> _checkSessionAccess() async {
    if (!widget.showBeginSession) return;
    final journeyId = SessionCompletionService.activeJourneyId();
    if (journeyId.isEmpty || !Get.isRegistered<AuthController>()) return;

    final token = Get.find<AuthController>().token;
    if (token == null || token.isEmpty) return;

    final result = await SessionProgressService.getProgressById(
      token,
      journeyId,
    );
    if (!mounted || result['success'] != true || result['data'] is! Map) {
      return;
    }

    final data = Map<String, dynamic>.from(result['data']);
    final completed = _completedSessionCount(data);
    if (completed > 0 && completed < 5) {
      Get.snackbar(
        'Session locked',
        'Please complete the previous sessions first.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      Navigator.of(context).maybePop();
    }
  }

  int _completedSessionCount(Map<String, dynamic> data) {
    for (final key in [
      'compledSession',
      'completedSession',
      'completedSessions',
      'currentSession',
    ]) {
      final value = data[key];
      if (value is num) return value.toInt();
      final parsed = int.tryParse(value?.toString() ?? '');
      if (parsed != null) return parsed;
    }
    return 0;
  }

  _BlsMediaOption? _optionBySourceId(
    List<_BlsMediaOption> options,
    String? sourceId,
  ) {
    if (sourceId == null || sourceId.isEmpty) return null;
    for (final option in options) {
      if (option.url == sourceId ||
          option.id == sourceId ||
          option.audioAsset == sourceId ||
          blsSourceId(option.url) == sourceId) {
        return option;
      }
    }

    final mappedObject = bilateralObjectFromSource('$blsObjectPrefix$sourceId');
    if (mappedObject != null) {
      for (final option in options) {
        if (blsSourceId(option.url) == mappedObject.key) return option;
      }
    }

    return null;
  }

  Future<void> _saveSettings() async {
    if (!_hasRequiredApiSelections) {
      Get.snackbar(
        'Media not ready',
        'Please wait for scene, visual, and sound media to load from API.',
      );
      return;
    }

    _storage.write(_storageKey, {
      'background': _localStorageValue(_selectedScene),
      'object': _localStorageValue(_selectedVisual),
      'sound': _selectedSound.url,
      'soundAsset': _selectedSound.audioAsset,
      'soundKey': _isNetworkUrl(_selectedSound.url) ? _selectedSound.url : BlsBuiltInSounds.normalizeKey(_selectedSound.url),
      'soundName': _selectedSound.name,
      'visualMediaType': _selectedVisual.mediaType,
      'visualPoster': _selectedVisual.poster,
      'speed': _selectedSpeed.key,
      'direction': _selectedDirection.key,
      'durationMinutes': _selectedDuration.minutes,
    });

    setState(() => _showSavedIndicator = true);
    _savedTimer?.cancel();
    _savedTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showSavedIndicator = false);
    });

    final controller = _bilateralController;
    if (controller == null) return;
    await controller.saveSettings(
      environmentUrl: _selectedScene.apiMediaValue,
      iconUrl: _selectedVisual.apiMediaValue,
      soundUrl: _selectedSound.apiMediaValue,
      speed: _selectedSpeed.backendKey,
      direction: _selectedDirection.backendKey,
    );
  }

  String _localStorageValue(_BlsMediaOption option) {
    if (option.type == _BlsMediaType.scene) {
      if (isBlsSceneSource(option.url)) return option.url;
      if (option.url.trim().isNotEmpty) return option.url.trim();
      final id = option.id?.trim();
      if (id != null && id.isNotEmpty) return '$blsScenePrefix$id';
    }
    if (option.type == _BlsMediaType.visual &&
        option.id?.trim().isNotEmpty == true) {
      return option.id!.trim();
    }
    if (isBlsSceneSource(option.url) || isBlsObjectSource(option.url)) {
      return blsSourceId(option.url);
    }
    return option.url;
  }

  Future<void> _selectSound(_BlsMediaOption option) async {
    setState(() => _selectedSound = option);
    await _stopSoundPreview();

    if (option.url == 'none') return;

    try {
      final audio = option.audioAsset.trim();
      if (audio.isNotEmpty) {
        if (_isNetworkUrl(audio)) {
          await _soundPreviewPlayer.play(UrlSource(audio));
        } else if (_isAssetPath(audio)) {
          var assetPath = audio;
          if (assetPath.startsWith('assets/')) {
            assetPath = assetPath.substring(7);
          }
          await _soundPreviewPlayer.play(AssetSource(assetPath));
        }
        return;
      }

      final profile = resolveBlsToneProfile(option.url);
      if (profile == null) return;

      final bytes = buildBlsToneWav(profile: profile, isRight: false);
      await _soundPreviewPlayer.play(BytesSource(bytes, mimeType: 'audio/wav'));
    } catch (_) {
      // Preview is best-effort; the actual session still handles playback.
    }
  }

  Future<void> _startSimulation() async {
    if (!_hasRequiredApiSelections) {
      Get.snackbar(
        'Selection incomplete',
        'Please choose a scene, visual, and sound.',
      );
      return;
    }

    if (widget.showBeginSession) {
      final ready = await _showPreparationDialog();
      if (!ready || !mounted) return;
    }

    if (!mounted) return;

    await _stopSoundPreview();

    final phaseTwoReady = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => SimulationScreen(
          settings: SimulationSettings(
            environmentImage: _selectedScene.url,
            visualObject: _selectedVisual.url,
            visualPlaybackUrl: _selectedVisual.playbackUrl,
            visualTransparentUrl: _selectedVisual.transparentUrl,
            visualLabel: _selectedVisual.name,
            speed: _selectedSpeed.seconds,
            audioAsset: _selectedSound.audioAsset,
            soundKey: _isNetworkUrl(_selectedSound.url) ? _selectedSound.url : BlsBuiltInSounds.normalizeKey(_selectedSound.url),
            visualMediaType: _selectedVisual.mediaType,
            visualPoster: _selectedVisual.poster,
            direction: _selectedDirection.animationDirection,
            showCompletionQuestions: true,
            totalSets: 34,
            maxDurationMinutes: _selectedDuration.minutes,
            roadmapSummary: _roadmapSummary,
          ),
        ),
      ),
    );

    await _stopSoundPreview();

    if (phaseTwoReady == true && mounted && widget.showBeginSession) {
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const SessionSeven(
            initialPhase: S7Phase.phase2,
            sessionNumber: 6,
          ),
        ),
      );
    }
  }

  Future<bool> _showPreparationDialog() async {
    final roadmapSummary = _roadmapSummary;
    final script = [
      'The bilateral stimulation will start now.',
      if (roadmapSummary.isNotEmpty) 'Your roadmap summary is: $roadmapSummary',
      'When you have the image and feeling in mind, press start.',
      'When it starts, let your mind wander. Your thoughts may go forward or backward in time. Simply notice what comes up.',
    ].join(' ');

    unawaited(_voice.speak(script));

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Before bilateral stimulation'),
        content: Text(
          [
            '1. The bilateral stimulation will start now.',
            if (roadmapSummary.isNotEmpty)
              '2. Roadmap summary: $roadmapSummary',
            '3. Bring your roadmap image and feeling into mind.',
            '4. When you are ready, press start and let your mind wander. Thoughts may move forward or backward in time; simply notice what comes up.',
          ].join('\n\n'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              unawaited(_voice.stop());
              Navigator.pop(context, false);
            },
            child: const Text('Not yet'),
          ),
          ElevatedButton(
            onPressed: () {
              unawaited(_voice.stop());
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF6A8A5A),
              foregroundColor: Colors.white,
            ),
            child: const Text('Start'),
          ),
        ],
      ),
    );

    return result == true;
  }

  String get _roadmapSummary {
    final raw = _storage.read('cbt_answers');
    if (raw is! Map) return '';
    final answers = Map<String, dynamic>.from(raw);
    final pieces = <String>[];

    void addAnswer(String label, String key) {
      final value = answers[key]?.toString().trim();
      if (value != null && value.isNotEmpty) {
        pieces.add('$label: $value');
      }
    }

    addAnswer('Original image or recent happening', 'A Recent Happening');
    addAnswer('Trigger', 'Triggers');
    addAnswer('Feelings', 'My Feelings');
    addAnswer('Positive belief', 'Your Superpowers');
    return pieces.join('. ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: _SelectionBackdrop(source: _selectedScene.url),
          ),
          SafeArea(child: _buildResponsiveShell()),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            child: _buildBackHeader(context),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveShell() {
    final controller = _bilateralController;
    if (controller == null) return _buildResponsiveLayout();

    return Obx(() {
      _scheduleRemoteSettingsApply();
      return _buildResponsiveLayout();
    });
  }

  Widget _buildResponsiveLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final isWide = maxWidth > 900;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 68, 16, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1620),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildSection(
                    title: 'Scene',
                    child: _buildSceneGrid(maxWidth),
                  ),
                  const SizedBox(height: 12),
                  isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildVisualSection()),
                            const SizedBox(width: 12),
                            Expanded(child: _buildSoundSection()),
                          ],
                        )
                      : Column(
                          children: [
                            _buildVisualSection(),
                            const SizedBox(height: 12),
                            _buildSoundSection(),
                          ],
                        ),
                  const SizedBox(height: 12),
                  _buildSettingsSection(isWide),
                  const SizedBox(height: 22),
                  _buildActions(),
                  if (widget.showBeginSession) ...[
                    const SizedBox(height: 12),
                    Text(
                      '34 sets \u00B7 up to ${_selectedDuration.label.toLowerCase()}',
                      style: const TextStyle(
                        color: Color(0xFFA09890),
                        fontSize: 11,
                        fontFamily: 'Serif',
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _scheduleRemoteSettingsApply() {
    if (_appliedRemoteSettings && _hasRequiredApiSelections) return;
    final sceneOptions = _sceneOptions;
    final visualOptions = _visualOptions;
    final soundOptions = _soundOptions;
    if (sceneOptions.isEmpty || visualOptions.isEmpty || soundOptions.isEmpty) {
      return;
    }
    final settings = _bilateralController?.userSettings;
    _appliedRemoteSettings = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _selectedScene =
            _optionBySourceId(
              sceneOptions,
              settings == null
                  ? null
                  : _settingsValue(settings, const [
                      'environmentId',
                      'environment',
                      'environmentUrl',
                      'background',
                    ]),
            ) ??
            (sceneOptions.contains(_selectedScene)
                ? _selectedScene
                : sceneOptions.first);
        _selectedVisual =
            _optionBySourceId(
              visualOptions,
              settings == null
                  ? null
                  : _settingsValue(settings, const [
                      'iconUrl',
                      'object',
                      'objectId',
                      'visualObject',
                    ]),
            ) ??
            (visualOptions.contains(_selectedVisual)
                ? _selectedVisual
                : visualOptions.first);
        final soundValue = settings == null
            ? null
            : _settingsValue(settings, const [
                'soundId',
                'sound',
                'soundUrl',
                'audioUrl',
              ]);
        if (soundValue != null) {
          _selectedSound = soundOptions.firstWhere(
            (option) =>
                option.id == soundValue ||
                option.url == soundValue ||
                option.audioAsset == soundValue,
            orElse: () => soundOptions.contains(_selectedSound)
                ? _selectedSound
                : soundOptions.first,
          );
        } else if (!soundOptions.contains(_selectedSound)) {
          _selectedSound = soundOptions.first;
        }
        if (settings != null) {
          _selectedSpeed = _blsSpeedFromKey(
            _settingsValue(settings, const ['speed']),
          );
          _selectedDirection = _blsDirectionFromKey(
            _settingsValue(settings, const ['direction']),
          );
        }
      });
    });
  }

  String? _settingsValue(Map<String, dynamic> settings, List<String> keys) {
    for (final key in keys) {
      final value = settings[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  Widget _buildBackHeader(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.88),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.8)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => Navigator.of(context).maybePop(),
        child: Padding(
          padding: const EdgeInsets.only(left: 13, right: 18),
          child: SizedBox(
            height: 44,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: Color(0xFF5A5550),
                ),
                const SizedBox(width: 10),
                Text(
                  widget.backTitle,
                  style: const TextStyle(
                    color: Color(0xFF5A5550),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          _brand.toUpperCase(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFA09890),
            fontSize: 9,
            letterSpacing: 3,
            fontFamily: 'Serif',
          ),
        ),
        const SizedBox(height: 10),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF5A5550), Color(0xFF7A756D)],
          ).createShader(bounds),
          child: const Text(
            'Bilateral Stimulation',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w300,
              fontFamily: 'Serif',
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Customise your calming experience',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF9A958D),
            fontSize: 13,
            fontFamily: 'Serif',
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildSectionTitle(title), const SizedBox(height: 8), child],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 1,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6F756D), Color(0x006F756D)],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF0F1912),
            fontSize: 11,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildApiMediaState({
    required String loadingText,
    required String emptyText,
  }) {
    final isLoading = _bilateralController?.isLoading.value ?? false;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDCD7D0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading) ...[
            const SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Text(
              isLoading ? loadingText : emptyText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF8A857D),
                fontSize: 12,
                fontFamily: 'Serif',
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSceneGrid(double width) {
    final options = _sceneOptions;
    if (options.isEmpty) {
      return _buildApiMediaState(
        loadingText: 'Loading scenes from server...',
        emptyText: 'Using bundled watercolor scenes.',
      );
    }
    final columns = _sceneGridColumns(width);
    _ensureSelectedGridVisible(
      options: options,
      selected: _selectedScene,
      columns: columns,
      isExpanded: () => _sceneGridExpanded,
      setExpanded: (value) => _sceneGridExpanded = value,
    );

    return _buildCollapsibleGrid(
      columns: columns,
      totalCount: options.length,
      expanded: _sceneGridExpanded,
      onToggleExpanded: () =>
          setState(() => _sceneGridExpanded = !_sceneGridExpanded),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 1.55,
      ),
      itemBuilder: (context, index) {
        final option = options[index];
        final selected = option == _selectedScene;

        return GestureDetector(
          onTap: () => setState(() => _selectedScene = option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected ? const Color(0xFF7A9A6A) : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                if (selected)
                  BoxShadow(
                    color: const Color(0xFF7A9A6A).withValues(alpha: 0.2),
                    blurRadius: 0,
                    spreadRadius: 3,
                  ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: selected ? 0.1 : 0.08),
                  blurRadius: selected ? 15 : 12,
                  offset: Offset(0, selected ? 4 : 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildScenePreview(option.url),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 3,
                      ),
                      color: Colors.black.withValues(alpha: 0.45),
                      child: Text(
                        option.name,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontFamily: 'Serif',
                        ),
                      ),
                    ),
                  ),
                  if (selected) _buildSelectionCheck(top: 4, right: 4),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  int _sceneGridColumns(double width) {
    if (width <= 480) return 3;
    if (width <= 720) return 4;
    if (width <= 960) return 5;
    if (width <= 1200) return 6;
    return 8;
  }

  int _visualGridColumns(double width) {
    if (width < 260) return 3;
    if (width < 360) return 4;
    if (width < 480) return 5;
    return 6;
  }

  int _soundGridColumns(double width) {
    if (width >= 980) return 4;
    if (width >= 720) return 3;
    return 2;
  }

  void _ensureSelectedGridVisible({
    required List<_BlsMediaOption> options,
    required _BlsMediaOption selected,
    required int columns,
    required bool Function() isExpanded,
    required void Function(bool value) setExpanded,
  }) {
    if (isExpanded()) return;
    final index = options.indexOf(selected);
    if (index < 0 || index < columns * _gridPreviewRows) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || isExpanded()) return;
      setState(() => setExpanded(true));
    });
  }

  Widget _buildCollapsibleGrid({
    required int columns,
    required int totalCount,
    required bool expanded,
    required VoidCallback onToggleExpanded,
    required SliverGridDelegate gridDelegate,
    required IndexedWidgetBuilder itemBuilder,
  }) {
    final previewCount = columns * _gridPreviewRows;
    final hasOverflow = totalCount > previewCount;
    final itemCount = expanded || !hasOverflow ? totalCount : previewCount;
    final hiddenCount = totalCount - previewCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: itemCount,
            gridDelegate: gridDelegate,
            itemBuilder: itemBuilder,
          ),
        ),
        if (hasOverflow)
          _buildSeeMoreToggle(
            expanded: expanded,
            hiddenCount: hiddenCount,
            onTap: onToggleExpanded,
          ),
      ],
    );
  }

  Widget _buildSeeMoreToggle({
    required bool expanded,
    required int hiddenCount,
    required VoidCallback onTap,
  }) {
    return Align(
      alignment: Alignment.center,
      child: TextButton.icon(
        onPressed: onTap,
        icon: Icon(
          expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
          size: 16,
        ),
        label: Text(expanded ? 'See less' : 'See more ($hiddenCount)'),
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF7A9A6A),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: const TextStyle(
            fontSize: 11,
            fontFamily: 'Serif',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionCheck({double top = 4, double right = 4}) {
    return Positioned(
      top: top,
      right: right,
      child: Container(
        width: 18,
        height: 18,
        decoration: const BoxDecoration(
          color: Color(0xFF7A9A6A),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 12),
      ),
    );
  }

  Widget _buildScenePreview(String source) {
    if (isBlsSceneSource(source)) return BlsSceneCanvas(source: source);

    if (_isNetworkUrl(source)) {
      return CachedNetworkImage(
        imageUrl: source,
        fit: BoxFit.cover,
        memCacheWidth: 720,
        placeholder: (context, url) => const ColoredBox(
          color: Color(0xFFEDE7DE),
          child: Center(
            child: SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        errorWidget: (context, url, error) =>
            const ColoredBox(color: Color(0xFFEDE7DE)),
      );
    }

    if (_isAssetPath(source)) return Image.asset(source, fit: BoxFit.cover);

    return const ColoredBox(color: Color(0xFFEDE7DE));
  }

  bool _isRenderableMediaSource(String value) =>
      isBlsSceneSource(value) ||
      isBlsObjectSource(value) ||
      _isNetworkUrl(value) ||
      _isAssetPath(value);

  bool _isNetworkUrl(String value) {
    final uri = Uri.tryParse(value.trim());
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  String _mediaPath(String value) {
    final trimmed = value.trim();
    final uri = Uri.tryParse(trimmed);
    return (uri?.path.isNotEmpty == true ? uri!.path : trimmed).toLowerCase();
  }

  bool _isImageSource(String value) {
    final path = _mediaPath(value);
    return path.endsWith('.png') ||
        path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.webp') ||
        path.endsWith('.gif');
  }

  bool _isAssetPath(String value) {
    final path = value.trim();
    return path.startsWith('assets/') ||
        path.startsWith('asset/') ||
        path.endsWith('.png') ||
        path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.webp') ||
        path.endsWith('.gif') ||
        path.endsWith('.mp4') ||
        path.endsWith('.mov') ||
        path.endsWith('.webm') ||
        path.endsWith('.mp3') ||
        path.endsWith('.wav') ||
        path.endsWith('.m4a');
  }

  bool _isVideoSource(String value) {
    if (_isImageSource(value)) return false;
    final source = _mediaPath(value);
    return source.endsWith('.mp4') ||
        source.endsWith('.mov') ||
        source.endsWith('.webm') ||
        source.contains('video');
  }

  Widget _buildVisualSection() {
    final options = _visualOptions;
    return _buildSection(
      title: 'Visual',
      child: options.isEmpty
          ? const Text(
              'No local visuals found in assets/icons/.',
              style: TextStyle(color: Color(0xFF8A8278), fontSize: 12),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final columns = _visualGridColumns(width);
                _ensureSelectedGridVisible(
                  options: options,
                  selected: _selectedVisual,
                  columns: columns,
                  isExpanded: () => _visualGridExpanded,
                  setExpanded: (value) => _visualGridExpanded = value,
                );

                return _buildCollapsibleGrid(
                  columns: columns,
                  totalCount: options.length,
                  expanded: _visualGridExpanded,
                  onToggleExpanded: () => setState(
                    () => _visualGridExpanded = !_visualGridExpanded,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                    childAspectRatio: 1.08,
                  ),
                  itemBuilder: (context, index) {
                    final option = options[index];
                    return _buildObjectOption(option);
                  },
                );
              },
            ),
    );
  }

  Widget _buildObjectOption(_BlsMediaOption option) {
    final selected = option == _selectedVisual;

    return GestureDetector(
      onTap: () => setState(() => _selectedVisual = option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF7A9A6A).withValues(alpha: 0.16)
              : Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected
                ? const Color(0xFF7A9A6A)
                : const Color(0xFFDCD7D0).withValues(alpha: 0.8),
            width: 1.5,
          ),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: const Color(0xFF7A9A6A).withValues(alpha: 0.07),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(child: _buildVisualPreview(option)),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 3,
                  ),
                  color: Colors.black.withValues(alpha: 0.42),
                  child: Text(
                    option.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontFamily: 'Serif',
                    ),
                  ),
                ),
              ),
              if (selected) _buildSelectionCheck(top: 5, right: 5),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisualPreview(_BlsMediaOption option, {double? size}) {
    final source = option.id ?? option.url;
    final visual = resolveLocalVisual(source);
    if (visual != null) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final dimension =
              size ??
              (constraints.maxWidth.isFinite && constraints.maxHeight.isFinite
                  ? constraints.biggest.shortestSide
                  : 80.0);
          return Center(
            child: AssetAnimatedVisual(
              assetPath: resolveLocalVisualAsset(source),
              size: dimension,
              playing: true,
              stripWhiteBackground: !visual.usesSpriteFrames,
            ),
          );
        },
      );
    }

    final assetSource = resolveLocalVisualAsset(option.url);
    if (_isAssetPath(assetSource)) {
      return WhiteKeyAssetImage(
        assetPath: assetSource,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
      );
    }

    return Icon(
      Icons.auto_awesome_rounded,
      size: size ?? 44,
      color: const Color(0xFF6A655D),
    );
  }

  /*
  // API/network visual preview — disabled while using local assets/icons GIF/WebP.
  Widget _buildVisualPreviewApi(_BlsMediaOption option, {double? size}) {
    final source = option.url;
    if (_isVideoSource(source)) {
      return _buildAnimatedVideoPreview(option);
    }
    ...
  }

  Widget _buildAnimatedVideoPreview(_BlsMediaOption option) { ... }

  Widget _buildStaticVideoPreview(_BlsMediaOption option) { ... }
  */

  Widget _buildSoundSection() {
    final options = _soundOptions;

    return _buildSection(
      title: 'Sound',
      child: options.isEmpty
          ? _buildApiMediaState(
              loadingText: 'Loading API sounds...',
              emptyText: 'No API sounds found.',
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final panelWidth = constraints.maxWidth;
                final columns = _soundGridColumns(panelWidth);
                _ensureSelectedGridVisible(
                  options: options,
                  selected: _selectedSound,
                  columns: columns,
                  isExpanded: () => _soundGridExpanded,
                  setExpanded: (value) => _soundGridExpanded = value,
                );

                return _buildCollapsibleGrid(
                  columns: columns,
                  totalCount: options.length,
                  expanded: _soundGridExpanded,
                  onToggleExpanded: () =>
                      setState(() => _soundGridExpanded = !_soundGridExpanded),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    mainAxisExtent: 72,
                  ),
                  itemBuilder: (context, index) {
                    final option = options[index];
                    return _buildSoundOption(option);
                  },
                );
              },
            ),
    );
  }

  Widget _buildSoundOption(_BlsMediaOption option) {
    final selected = option == _selectedSound;

    return GestureDetector(
      onTap: () => unawaited(_selectSound(option)),
      child: AnimatedScale(
        scale: selected ? 0.98 : 1,
        duration: const Duration(milliseconds: 180),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: selected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? const Color(0xFF7A9A6A)
                  : const Color(0xFFDCD7D0).withValues(alpha: 0.55),
              width: selected ? 1.5 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              _buildSoundArtwork(option, size: 40),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      option.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected
                            ? const Color(0xFF1C1917)
                            : const Color(0xFF44403C),
                        fontSize: 12,
                        height: 1.2,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        fontFamily: 'Serif',
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.volume_up_rounded,
                size: 16,
                color: selected
                    ? const Color(0xFF7A9A6A)
                    : const Color(0xFFB8B3AC),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSoundArtwork(_BlsMediaOption option, {double size = 40}) {
    final id = option.id?.trim();
    final poster = option.poster?.trim().isNotEmpty == true
        ? option.poster!.trim()
        : 'https://picsum.photos/seed/soundimg${id ?? option.name}/150/150';

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox.square(
        dimension: size,
        child: CachedNetworkImage(
          imageUrl: poster,
          fit: BoxFit.cover,
          memCacheWidth: 160,
          placeholder: (context, url) => ColoredBox(
            color: const Color(0xFFF5F5F4),
            child: Center(
              child: Icon(
                option.icon ?? Icons.music_note_rounded,
                size: 18,
                color: const Color(0xFF9A958D),
              ),
            ),
          ),
          errorWidget: (context, url, error) =>
              _SoundArtworkFallback(option: option),
        ),
      ),
    );
  }

  Widget _buildSettingsSection(bool isWide) {
    return _buildBareSection(
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildSpeedGroup()),
                const SizedBox(width: 12),
                Expanded(child: _buildDirectionGroup(isWide)),
                const SizedBox(width: 12),
                Expanded(child: _buildDurationGroup()),
              ],
            )
          : Column(
              children: [
                _buildSpeedGroup(),
                const SizedBox(height: 12),
                _buildDirectionGroup(isWide),
                const SizedBox(height: 12),
                _buildDurationGroup(),
              ],
            ),
    );
  }

  Widget _buildBareSection({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSpeedGroup() {
    return _buildSettingGroup(
      label: 'Speed',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth < 280 ? 2 : 3;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _BlsSpeed.values.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              childAspectRatio: columns == 3 ? 1.75 : 1.55,
            ),
            itemBuilder: (context, index) {
              final speed = _BlsSpeed.values[index];
              final selected = speed == _selectedSpeed;
              return GestureDetector(
                onTap: () => setState(() => _selectedSpeed = speed),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  decoration: _optionDecoration(selected, radius: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        speed.icon,
                        size: 14,
                        color: const Color(0xFF6A655D),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        speed.label,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF5A5550),
                          fontSize: 9,
                          fontFamily: 'Serif',
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Text(
                        '${speed.milliseconds}ms',
                        style: const TextStyle(
                          color: Color(0xFF9A958D),
                          fontSize: 7,
                          fontFamily: 'Serif',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDirectionGroup(bool isWide) {
    return _buildSettingGroup(
      label: 'Direction',
      dense: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth < 280 ? 2 : 4;
          const cellHeight = 50.0;

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _BlsDirection.values.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              mainAxisExtent: cellHeight,
            ),
            itemBuilder: (context, index) {
              final direction = _BlsDirection.values[index];
              final selected = direction == _selectedDirection;
              return GestureDetector(
                onTap: () => setState(() => _selectedDirection = direction),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: _optionDecoration(selected, radius: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: CustomPaint(
                          painter: _DirectionIconPainter(direction),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Flexible(
                        child: Text(
                          direction.gridLabel,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.clip,
                          style: const TextStyle(
                            color: Color(0xFF5A5550),
                            fontSize: 7,
                            height: 1.1,
                            fontFamily: 'Serif',
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDurationGroup() {
    return _buildSettingGroup(
      label: 'Session Length',
      child: Row(
        children: _BlsSessionDuration.values.map((duration) {
          final selected = duration == _selectedDuration;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: duration == _BlsSessionDuration.values.last ? 0 : 6,
              ),
              child: GestureDetector(
                onTap: () => setState(() => _selectedDuration = duration),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 6,
                  ),
                  decoration: _optionDecoration(selected, radius: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        duration.icon,
                        size: 14,
                        color: const Color(0xFF6A655D),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        duration.label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF5A5550),
                          fontSize: 9,
                          fontFamily: 'Serif',
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSettingGroup({
    required String label,
    required Widget child,
    bool dense = false,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(dense ? 8 : 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: const Color(0xFF8A857D),
              fontSize: dense ? 8 : 9,
              letterSpacing: dense ? 1.2 : 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: dense ? 4 : 6),
          child,
        ],
      ),
    );
  }

  BoxDecoration _optionDecoration(bool selected, {required double radius}) {
    return BoxDecoration(
      color: selected
          ? const Color(0xFF7A9A6A).withValues(alpha: 0.15)
          : Colors.white.withValues(alpha: 0.75),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: selected
            ? const Color(0xFF7A9A6A)
            : const Color(0xFFDCD7D0).withValues(alpha: 0.8),
        width: 1.5,
      ),
    );
  }

  Widget _buildActions() {
    final canUseApiMedia = _hasRequiredApiSelections;
    final children = <Widget>[
      if (widget.showSaveSettings) ...[
        OutlinedButton.icon(
          onPressed: canUseApiMedia ? _saveSettings : null,
          icon: const Icon(Icons.save_outlined, size: 16),
          label: const Text('Save Settings'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF6A655D),
            backgroundColor: Colors.white.withValues(alpha: 0.7),
            side: BorderSide(
              color: const Color(0xFFC8C3BC).withValues(alpha: 0.8),
              width: 2,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            textStyle: const TextStyle(fontSize: 13, fontFamily: 'Serif'),
          ),
        ),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: _showSavedIndicator ? 1 : 0,
          child: const Text(
            '\u2713 Saved',
            style: TextStyle(
              color: Color(0xFF7A9A6A),
              fontSize: 12,
              fontFamily: 'Serif',
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
      if (widget.showBeginSession)
        GestureDetector(
          onTap: canUseApiMedia ? _startSimulation : null,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: canUseApiMedia ? 1 : 0.45,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 55, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(35),
                gradient: const LinearGradient(
                  colors: [Color(0xFF7A9A6A), Color(0xFF6A8A5A)],
                ),
                boxShadow: [
                  if (canUseApiMedia)
                    BoxShadow(
                      color: const Color(0xFF6A8A5A).withValues(alpha: 0.35),
                      blurRadius: 25,
                      offset: const Offset(0, 5),
                    ),
                ],
              ),
              child: const Text(
                'Begin Session',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontFamily: 'Serif',
                ),
              ),
            ),
          ),
        ),
    ];

    if (children.isEmpty) return const SizedBox.shrink();

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 20,
      runSpacing: 14,
      children: children,
    );
  }
}

class _SelectionBackdrop extends StatelessWidget {
  const _SelectionBackdrop({required this.source});

  final String source;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildBackgroundMedia(),
        DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFF4F0E7).withValues(alpha: 0.72),
          ),
        ),
        CustomPaint(painter: _SelectionGlowPainter()),
      ],
    );
  }

  Widget _buildBackgroundMedia() {
    if (isBlsSceneSource(source)) {
      return BlsSceneCanvas(source: source);
    }

    final uri = Uri.tryParse(source.trim());
    if (uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty) {
      return Image.network(
        source,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackGradient(),
      );
    }

    if (source.startsWith('assets/') ||
        source.endsWith('.png') ||
        source.endsWith('.jpg') ||
        source.endsWith('.jpeg') ||
        source.endsWith('.webp')) {
      return Image.asset(
        source,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackGradient(),
      );
    }

    return _buildFallbackGradient();
  }

  Widget _buildFallbackGradient() {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF8F5F0), Color(0xFFEBE5DC)],
        ),
      ),
    );
  }
}

class _SelectionGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    void drawGlow(Offset center, Size glowSize, Color color) {
      final rect = Rect.fromCenter(
        center: center,
        width: glowSize.width,
        height: glowSize.height,
      );
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ).createShader(rect);
      canvas.drawOval(rect, paint);
    }

    drawGlow(
      Offset(size.width * 0.2, size.height * 0.2),
      Size(size.width * 0.65, size.height * 0.5),
      const Color(0xFFC8B4A0).withValues(alpha: 0.15),
    );
    drawGlow(
      Offset(size.width * 0.8, size.height * 0.8),
      Size(size.width * 0.65, size.height * 0.5),
      const Color(0xFFA0B4A0).withValues(alpha: 0.12),
    );
    drawGlow(
      Offset(size.width * 0.5, size.height * 0.5),
      Size(size.width * 0.9, size.height * 0.7),
      const Color(0xFFB4AAA0).withValues(alpha: 0.08),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DirectionIconPainter extends CustomPainter {
  const _DirectionIconPainter(this.direction);

  final _BlsDirection direction;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF5A5550)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    Offset p(double x, double y) => Offset(size.width * x, size.height * y);

    switch (direction) {
      case _BlsDirection.horizontal:
        _drawTwoHeadedLine(canvas, paint, p(0.13, 0.5), p(0.87, 0.5));
        break;
      case _BlsDirection.vertical:
        _drawTwoHeadedLine(canvas, paint, p(0.5, 0.13), p(0.5, 0.87));
        break;
      case _BlsDirection.diagonalUp:
        _drawTwoHeadedLine(canvas, paint, p(0.2, 0.8), p(0.8, 0.2));
        break;
      case _BlsDirection.diagonalDown:
        _drawTwoHeadedLine(canvas, paint, p(0.2, 0.2), p(0.8, 0.8));
        break;
    }
  }

  void _drawTwoHeadedLine(
    Canvas canvas,
    Paint paint,
    Offset start,
    Offset end,
  ) {
    canvas.drawLine(start, end, paint);
    _drawArrowHead(canvas, paint, start, end);
    _drawArrowHead(canvas, paint, end, start);
  }

  void _drawArrowHead(Canvas canvas, Paint paint, Offset tip, Offset tail) {
    final vector = tip - tail;
    final angle = vector.direction;
    const length = 8.0;
    const spread = 0.7;
    final a = Offset.fromDirection(angle + mathPi - spread, length);
    final b = Offset.fromDirection(angle + mathPi + spread, length);
    canvas.drawLine(tip, tip + a, paint);
    canvas.drawLine(tip, tip + b, paint);
  }

  @override
  bool shouldRepaint(covariant _DirectionIconPainter oldDelegate) =>
      oldDelegate.direction != direction;
}

const double mathPi = 3.1415926535897932;

enum _BlsMediaType { scene, visual, sound }

class _BlsMediaOption {
  const _BlsMediaOption({
    this.id,
    required this.name,
    required this.url,
    this.playbackUrl = '',
    this.transparentUrl,
    required this.type,
    this.icon,
    this.audioAsset = '',
    this.mediaType = 'image',
    this.poster,
    this.isRemote = false,
  });

  final String? id;
  final String name;
  final String url;
  final String playbackUrl;
  final String? transparentUrl;
  final _BlsMediaType type;
  final IconData? icon;
  final String audioAsset;
  final String mediaType;
  final String? poster;
  final bool isRemote;

  String get identityKey => '$type:${id ?? url}:$audioAsset';

  String get apiMediaValue {
    if (type == _BlsMediaType.sound && audioAsset.trim().isNotEmpty) {
      return audioAsset.trim();
    }
    if (type == _BlsMediaType.visual && isBlsLocalVisualAsset(url)) {
      final value = id?.trim();
      if (value != null && value.isNotEmpty) return value;
    }
    if (!isBlsSceneSource(url) && !isBlsObjectSource(url)) {
      return url.trim();
    }
    final value = id?.trim();
    if (value != null && value.isNotEmpty) {
      return value;
    }
    if (isBlsSceneSource(url) || isBlsObjectSource(url)) {
      return blsSourceId(url);
    }
    return url;
  }

  @override
  bool operator ==(Object other) =>
      other is _BlsMediaOption && other.identityKey == identityKey;

  @override
  int get hashCode => identityKey.hashCode;
}

class _SoundArtworkFallback extends StatelessWidget {
  const _SoundArtworkFallback({required this.option});

  final _BlsMediaOption option;

  static const _palette = [
    [Color(0xFF7A9A6A), Color(0xFFE7D9A8)],
    [Color(0xFF4F7D8A), Color(0xFFCFE5E7)],
    [Color(0xFF9A746A), Color(0xFFF1D7C4)],
    [Color(0xFF6F6A9A), Color(0xFFDAD7F0)],
    [Color(0xFF8A7A4F), Color(0xFFEFE6BF)],
  ];

  @override
  Widget build(BuildContext context) {
    final colors =
        _palette[option.identityKey.hashCode.abs() % _palette.length];
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            right: -7,
            bottom: -7,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.22),
              ),
            ),
          ),
          Center(
            child: Icon(
              option.icon ?? Icons.graphic_eq_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

enum _BlsSpeed { slow, medium, fast,}

extension _BlsSpeedDetails on _BlsSpeed {
  String get key {
    switch (this) {
      case _BlsSpeed.slow:
        return 'slow';
      case _BlsSpeed.medium:
        return 'medium';
      case _BlsSpeed.fast:
        return 'fast';
    }
  }

  String get backendKey => key;

  String get label {
    switch (this) {
      case _BlsSpeed.slow:
        return 'Slow';
      case _BlsSpeed.medium:
        return 'Medium';
      case _BlsSpeed.fast:
        return 'Fast';
    }
  }

  IconData get icon {
    switch (this) {
      case _BlsSpeed.slow:
        return Icons.remove_rounded;
      case _BlsSpeed.medium:
        return Icons.keyboard_arrow_right_rounded;
      case _BlsSpeed.fast:
        return Icons.double_arrow_rounded;
    }
  }

  int get milliseconds {
    switch (this) {
      case _BlsSpeed.slow:
        return (BlsSpeedPresets.slow * 1000).round();
      case _BlsSpeed.medium:
        return (BlsSpeedPresets.medium * 1000).round();
      case _BlsSpeed.fast:
        return (BlsSpeedPresets.fast * 1000).round();
    }
  }

  double get seconds => milliseconds / 1000;
}

_BlsSpeed _blsSpeedFromKey(String? key) {
  for (final speed in _BlsSpeed.values) {
    if (speed.key == key) return speed;
  }
  return _BlsSpeed.medium;
}

enum _BlsDirection { horizontal, vertical, diagonalUp, diagonalDown }

extension _BlsDirectionDetails on _BlsDirection {
  String get key {
    switch (this) {
      case _BlsDirection.horizontal:
        return 'horizontal';
      case _BlsDirection.vertical:
        return 'vertical';
      case _BlsDirection.diagonalUp:
        return 'diagonal-up';
      case _BlsDirection.diagonalDown:
        return 'diagonal-down';
    }
  }

  String get label {
    switch (this) {
      case _BlsDirection.horizontal:
        return 'Horizontal';
      case _BlsDirection.vertical:
        return 'Vertical';
      case _BlsDirection.diagonalUp:
        return 'Diagonal Up';
      case _BlsDirection.diagonalDown:
        return 'Diagonal Down';
    }
  }

  /// Compact two-line labels for the direction picker grid.
  String get gridLabel {
    switch (this) {
      case _BlsDirection.horizontal:
        return 'Horizontal';
      case _BlsDirection.vertical:
        return 'Vertical';
      case _BlsDirection.diagonalUp:
        return 'Diagonal\nUp';
      case _BlsDirection.diagonalDown:
        return 'Diagonal\nDown';
    }
  }

  AnimationDirection get animationDirection {
    switch (this) {
      case _BlsDirection.horizontal:
        return AnimationDirection.horizontal;
      case _BlsDirection.vertical:
        return AnimationDirection.vertical;
      case _BlsDirection.diagonalUp:
        return AnimationDirection.diagonalReverse;
      case _BlsDirection.diagonalDown:
        return AnimationDirection.diagonal;
    }
  }

  String get backendKey {
    switch (this) {
      case _BlsDirection.horizontal:
        return 'horizontal';
      case _BlsDirection.vertical:
        return 'vertical';
      case _BlsDirection.diagonalUp:
        return 'diagonal-up';
      case _BlsDirection.diagonalDown:
        return 'diagonal-down';
    }
  }
}

_BlsDirection _blsDirectionFromKey(String? key) {
  if (key == 'left-right') return _BlsDirection.horizontal;
  if (key == 'top-bottom') return _BlsDirection.vertical;
  for (final direction in _BlsDirection.values) {
    if (direction.key == key) return direction;
  }
  return _BlsDirection.horizontal;
}

enum _BlsSessionDuration { sixty, ninety }

extension _BlsSessionDurationDetails on _BlsSessionDuration {
  int get minutes {
    switch (this) {
      case _BlsSessionDuration.sixty:
        return 60;
      case _BlsSessionDuration.ninety:
        return 90;
    }
  }

  String get label {
    switch (this) {
      case _BlsSessionDuration.sixty:
        return '1 Hour';
      case _BlsSessionDuration.ninety:
        return '1.5 Hours';
    }
  }

  IconData get icon {
    switch (this) {
      case _BlsSessionDuration.sixty:
        return Icons.schedule_rounded;
      case _BlsSessionDuration.ninety:
        return Icons.more_time_rounded;
    }
  }
}

_BlsSessionDuration _blsSessionDurationFromMinutes(dynamic value) {
  final minutes = int.tryParse(value?.toString() ?? '');
  return minutes == 90 ? _BlsSessionDuration.ninety : _BlsSessionDuration.sixty;
}

class BilateralAudioSync {
  BilateralAudioSync({this.profile, this.audioAsset = ''});

  final BlsToneProfile? profile;
  final String audioAsset;

  final AudioPlayer _left = AudioPlayer();
  final AudioPlayer _right = AudioPlayer();

  Future<void> init() async {
    await _left.setReleaseMode(ReleaseMode.stop);
    await _right.setReleaseMode(ReleaseMode.stop);
    await _left.setBalance(-1.0); // full left channel
    await _right.setBalance(1.0); // full right channel

    if (audioAsset.trim().isNotEmpty) {
      var path = audioAsset.trim();
      if (path.startsWith('assets/')) path = path.substring(7);
      await _left.setSource(AssetSource(path));
      await _right.setSource(AssetSource(path));
    }
  }

  Future<void> tick({required bool isRight}) async {
    final player = isRight ? _right : _left;

    if (audioAsset.trim().isNotEmpty) {
      await player.seek(Duration.zero);
      await player.resume();
      return;
    }

    if (profile == null) return;
    final bytes = buildBlsToneWav(profile: profile!, isRight: isRight);
    await player.play(BytesSource(bytes, mimeType: 'audio/wav'));
  }

  Future<void> dispose() async {
    await _left.dispose();
    await _right.dispose();
  }
}
