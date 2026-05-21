import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jonssony/views/Library/bls_pdf_visuals.dart';
import 'package:jonssony/views/Library/simulation_screen.dart';
import 'package:jonssony/views/Library/simulation_settings.dart';

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
  Timer? _savedTimer;

  late _BlsMediaOption _selectedScene;
  late _BlsMediaOption _selectedVisual;
  late _BlsMediaOption _selectedSound;
  _BlsSpeed _selectedSpeed = _BlsSpeed.medium;
  _BlsDirection _selectedDirection = _BlsDirection.horizontal;
  bool _showSavedIndicator = false;

  static const _sceneOptions = [
    _BlsMediaOption(
      name: 'Mountain Sanctuary',
      url: '${blsScenePrefix}mountains',
      type: _BlsMediaType.scene,
    ),
    _BlsMediaOption(
      name: 'Ocean Horizon',
      url: '${blsScenePrefix}ocean',
      type: _BlsMediaType.scene,
    ),
    _BlsMediaOption(
      name: 'Starlit Lake',
      url: '${blsScenePrefix}night',
      type: _BlsMediaType.scene,
    ),
    _BlsMediaOption(
      name: 'Enchanted Forest',
      url: '${blsScenePrefix}forest',
      type: _BlsMediaType.scene,
    ),
    _BlsMediaOption(
      name: 'Wildflower Meadow',
      url: '${blsScenePrefix}meadow',
      type: _BlsMediaType.scene,
    ),
    _BlsMediaOption(
      name: 'Autumn Valley',
      url: '${blsScenePrefix}autumn',
      type: _BlsMediaType.scene,
    ),
  ];

  static const _visualOptions = [
    _BlsMediaOption(
      name: 'Sun',
      url: '${blsObjectPrefix}sun',
      type: _BlsMediaType.visual,
    ),
    _BlsMediaOption(
      name: 'Moon',
      url: '${blsObjectPrefix}moon',
      type: _BlsMediaType.visual,
    ),
    _BlsMediaOption(
      name: 'Butterfly',
      url: '${blsObjectPrefix}butterfly',
      type: _BlsMediaType.visual,
    ),
    _BlsMediaOption(
      name: 'Bird',
      url: '${blsObjectPrefix}bird',
      type: _BlsMediaType.visual,
    ),
    _BlsMediaOption(
      name: 'Leaf',
      url: '${blsObjectPrefix}leaf',
      type: _BlsMediaType.visual,
    ),
    _BlsMediaOption(
      name: 'Feather',
      url: '${blsObjectPrefix}feather',
      type: _BlsMediaType.visual,
    ),
    _BlsMediaOption(
      name: 'Star',
      url: '${blsObjectPrefix}star',
      type: _BlsMediaType.visual,
    ),
    _BlsMediaOption(
      name: 'Dragonfly',
      url: '${blsObjectPrefix}dragonfly',
      type: _BlsMediaType.visual,
    ),
  ];

  static const _soundOptions = [
    _BlsMediaOption(
      name: 'Gentle Tone',
      url: 'gentle-tone',
      type: _BlsMediaType.sound,
      glyph: '\u{1F514}',
    ),
    _BlsMediaOption(
      name: 'Soft Chime',
      url: 'soft-chime',
      type: _BlsMediaType.sound,
      glyph: '\u{1F390}',
    ),
    _BlsMediaOption(
      name: 'Water Drop',
      url: 'water',
      type: _BlsMediaType.sound,
      glyph: '\u{1F4A7}',
    ),
    _BlsMediaOption(
      name: 'Soft Breath',
      url: 'breath',
      type: _BlsMediaType.sound,
      glyph: '\u{1F32C}',
    ),
    _BlsMediaOption(
      name: 'Singing Bowl',
      url: 'bowl',
      type: _BlsMediaType.sound,
      glyph: '\u{1F3B5}',
    ),
    _BlsMediaOption(
      name: 'Silent',
      url: 'none',
      type: _BlsMediaType.sound,
      glyph: '\u{1F507}',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedScene = _sceneOptions.first;
    _selectedVisual = _visualOptions.first;
    _selectedSound = _soundOptions.first;
    _loadPreferences();
  }

  @override
  void dispose() {
    _savedTimer?.cancel();
    super.dispose();
  }

  void _loadPreferences() {
    final raw = _storage.read(_storageKey);
    if (raw is! Map) return;

    _selectedScene =
        _optionBySourceId(_sceneOptions, raw['background']?.toString()) ??
        _sceneOptions.first;
    _selectedVisual =
        _optionBySourceId(_visualOptions, raw['object']?.toString()) ??
        _visualOptions.first;
    _selectedSound = _soundOptions.firstWhere(
      (option) => option.url == raw['sound']?.toString(),
      orElse: () => _soundOptions.first,
    );
    _selectedSpeed = _blsSpeedFromKey(raw['speed']?.toString());
    _selectedDirection = _blsDirectionFromKey(raw['direction']?.toString());
  }

  _BlsMediaOption? _optionBySourceId(
    List<_BlsMediaOption> options,
    String? sourceId,
  ) {
    if (sourceId == null || sourceId.isEmpty) return null;
    for (final option in options) {
      if (blsSourceId(option.url) == sourceId) return option;
    }
    return null;
  }

  void _saveSettings() {
    _storage.write(_storageKey, {
      'background': blsSourceId(_selectedScene.url),
      'object': blsSourceId(_selectedVisual.url),
      'sound': _selectedSound.url,
      'speed': _selectedSpeed.key,
      'direction': _selectedDirection.key,
    });

    setState(() => _showSavedIndicator = true);
    _savedTimer?.cancel();
    _savedTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showSavedIndicator = false);
    });
  }

  Future<void> _startSimulation() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SimulationScreen(
          settings: SimulationSettings(
            environmentImage: _selectedScene.url,
            visualObject: _selectedVisual.url,
            speed: _selectedSpeed.seconds,
            audioAsset: '',
            soundKey: _selectedSound.url,
            direction: _selectedDirection.animationDirection,
            showCompletionQuestions: true,
            totalSets: 34,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _SelectionBackdrop()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth;
                final isWide = maxWidth > 900;

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 76, 20, 40),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Column(
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 28),
                          _buildSection(
                            title: 'Scene',
                            child: _buildSceneGrid(maxWidth),
                          ),
                          const SizedBox(height: 18),
                          isWide
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: _buildVisualSection()),
                                    const SizedBox(width: 18),
                                    Expanded(
                                      child: _buildSoundSection(maxWidth),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    _buildVisualSection(),
                                    const SizedBox(height: 18),
                                    _buildSoundSection(maxWidth),
                                  ],
                                ),
                          const SizedBox(height: 18),
                          _buildSettingsSection(isWide),
                          const SizedBox(height: 22),
                          _buildActions(),
                          if (widget.showBeginSession) ...[
                            const SizedBox(height: 12),
                            const Text(
                              '34 sets \u00B7 approximately 3 minutes',
                              style: TextStyle(
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
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            child: _buildBackHeader(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBackHeader(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: Colors.white.withValues(alpha: 0.55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.65)),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(title),
              const SizedBox(height: 14),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 1,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFB5B0A5), Color(0x00B5B0A5)],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF8A857D),
            fontSize: 10,
            letterSpacing: 2,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSceneGrid(double width) {
    final columns = width <= 600
        ? 2
        : width <= 900
        ? 3
        : 6;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _sceneOptions.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 16 / 11,
      ),
      itemBuilder: (context, index) {
        final option = _sceneOptions[index];
        final selected = option == _selectedScene;

        return GestureDetector(
          onTap: () => setState(() => _selectedScene = option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
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
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  BlsSceneCanvas(source: option.url),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 8,
                      ),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0x8C000000)],
                        ),
                      ),
                      child: Text(
                        option.name,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontFamily: 'Serif',
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVisualSection() {
    return _buildSection(
      title: 'Visual',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _visualOptions.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          final option = _visualOptions[index];
          return _buildObjectOption(option);
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
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF7A9A6A).withValues(alpha: 0.14)
              : Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? const Color(0xFF7A9A6A)
                : const Color(0xFFDCD7D0).withValues(alpha: 0.8),
            width: 2,
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 76;
            final inset = compact ? 5.0 : 8.0;
            final objectSize = compact ? 32.0 : 42.0;
            final gap = compact ? 3.0 : 5.0;
            final fontSize = compact ? 8.0 : 9.0;

            return Padding(
              padding: EdgeInsets.all(inset),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BlsObjectCanvas(source: option.url, size: objectSize),
                  SizedBox(height: gap),
                  Flexible(
                    child: Text(
                      option.name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF6A655D),
                        fontSize: fontSize,
                        fontFamily: 'Serif',
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSoundSection(double width) {
    final columns = width <= 600 ? 2 : 3;

    return _buildSection(
      title: 'Sound',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _soundOptions.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 2.45,
        ),
        itemBuilder: (context, index) {
          final option = _soundOptions[index];
          return _buildSoundOption(option);
        },
      ),
    );
  }

  Widget _buildSoundOption(_BlsMediaOption option) {
    final selected = option == _selectedSound;

    return GestureDetector(
      onTap: () => setState(() => _selectedSound = option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: _optionDecoration(selected, radius: 12),
        child: Row(
          children: [
            Text(option.glyph ?? '', style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                option.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF5A5550),
                  fontSize: 10,
                  fontFamily: 'Serif',
                ),
              ),
            ),
          ],
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
                const SizedBox(width: 20),
                Expanded(child: _buildDirectionGroup(isWide)),
              ],
            )
          : Column(
              children: [
                _buildSpeedGroup(),
                const SizedBox(height: 20),
                _buildDirectionGroup(isWide),
              ],
            ),
    );
  }

  Widget _buildBareSection({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildSpeedGroup() {
    return _buildSettingGroup(
      label: 'Speed',
      child: Row(
        children: _BlsSpeed.values.map((speed) {
          final selected = speed == _selectedSpeed;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: speed == _BlsSpeed.values.last ? 0 : 10,
              ),
              child: GestureDetector(
                onTap: () => setState(() => _selectedSpeed = speed),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 13,
                  ),
                  decoration: _optionDecoration(selected, radius: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(speed.glyph, style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 4),
                      Text(
                        speed.label,
                        style: const TextStyle(
                          color: Color(0xFF5A5550),
                          fontSize: 11,
                          fontFamily: 'Serif',
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${speed.milliseconds}ms',
                        style: const TextStyle(
                          color: Color(0xFF9A958D),
                          fontSize: 8,
                          fontFamily: 'Serif',
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

  Widget _buildDirectionGroup(bool isWide) {
    return _buildSettingGroup(
      label: 'Direction',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _BlsDirection.values.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isWide ? 4 : 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.12,
        ),
        itemBuilder: (context, index) {
          final direction = _BlsDirection.values[index];
          final selected = direction == _selectedDirection;
          return GestureDetector(
            onTap: () => setState(() => _selectedDirection = direction),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              decoration: _optionDecoration(selected, radius: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: CustomPaint(
                      painter: _DirectionIconPainter(direction),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    direction.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF5A5550),
                      fontSize: 11,
                      fontFamily: 'Serif',
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingGroup({required String label, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF8A857D),
              fontSize: 10,
              letterSpacing: 1.8,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
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
        width: 2,
      ),
    );
  }

  Widget _buildActions() {
    final children = <Widget>[
      if (widget.showSaveSettings) ...[
        OutlinedButton.icon(
          onPressed: _saveSettings,
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
          onTap: _startSimulation,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 55, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(35),
              gradient: const LinearGradient(
                colors: [Color(0xFF7A9A6A), Color(0xFF6A8A5A)],
              ),
              boxShadow: [
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
  const _SelectionBackdrop();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF8F5F0), Color(0xFFEBE5DC)],
        ),
      ),
      child: CustomPaint(painter: _SelectionGlowPainter()),
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
    required this.name,
    required this.url,
    required this.type,
    this.glyph,
  });

  final String name;
  final String url;
  final _BlsMediaType type;
  final String? glyph;
}

enum _BlsSpeed { slow, medium, fast }

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

  String get glyph {
    switch (this) {
      case _BlsSpeed.slow:
        return '\u{1F422}';
      case _BlsSpeed.medium:
        return '\u{1F343}';
      case _BlsSpeed.fast:
        return '\u26A1';
    }
  }

  int get milliseconds {
    switch (this) {
      case _BlsSpeed.slow:
        return 850;
      case _BlsSpeed.medium:
        return 600;
      case _BlsSpeed.fast:
        return 400;
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
}

_BlsDirection _blsDirectionFromKey(String? key) {
  for (final direction in _BlsDirection.values) {
    if (direction.key == key) return direction;
  }
  return _BlsDirection.horizontal;
}
