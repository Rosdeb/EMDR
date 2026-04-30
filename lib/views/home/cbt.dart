import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jonssony/controller/auth_controller.dart';
import 'package:jonssony/services/cbt_service.dart';
import 'package:jonssony/utils/app_text.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jonssony/views/sessions/session_two.dart'; // For BubbleConfig, custom painters, etc.

class cbt extends StatefulWidget {
  const cbt({super.key});

  @override
  State<cbt> createState() => _cbtState();
}

class _cbtState extends State<cbt> {
  final box = GetStorage();
  bool _isLoading = false;

  final Map<String, String> _bubbleAnswers = {};

  @override
  void initState() {
    super.initState();
    _loadFromApi();
  }

  Future<void> _loadFromApi() async {
    setState(() => _isLoading = true);

    // First load from local storage for instant feedback
    _loadAnswersFromLocal();

    try {
      final token = Get.isRegistered<AuthController>()
          ? Get.find<AuthController>().token
          : box.read<String>('auth_token');
      if (token != null) {
        final result = await CbtService.getAllFormulations(token);
        if (result['success'] == true && result['data'] != null) {
          final data = result['data'];
          if (data is Map<String, dynamic>) {
            _updateSectionsFromData(data);
          } else if (data is List && data.isNotEmpty) {
            // API returns newest first — pick index 0 for the latest
            final latest = data.first;
            if (latest is Map<String, dynamic>) {
              _updateSectionsFromData(latest);
            } else if (latest is Map) {
              _updateSectionsFromData(Map<String, dynamic>.from(latest));
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading CBT from API: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _updateSectionsFromData(Map<String, dynamic> data) {
    setState(() {
      _bubbleAnswers['childhood'] = _asAnswer(data['childhood']);
      _bubbleAnswers['deep-beliefs'] = _asAnswer(data['deepBeliefs']);
      _bubbleAnswers['rules'] = _asAnswer(data['rules']);
      _bubbleAnswers['triggers'] = _asAnswer(data['triggers']);
      _bubbleAnswers['recent-happening'] = _asAnswer(data['recentHappening']);
      _bubbleAnswers['thoughts'] = _asAnswer(data['thoughts']);
      _bubbleAnswers['feelings'] = _asAnswer(data['feelings']);
      _bubbleAnswers['behaviors'] = _asAnswer(data['behaviors']);
      
      final cons = data['consequences'];
      final other = data['consequencesOther'];
      List<String> all = [];
      if (cons is List) all.addAll(cons.map((e) => e.toString()));
      if (other != null && other.toString().trim().isNotEmpty) all.add(other.toString().trim());
      _bubbleAnswers['consequences'] = all.isNotEmpty ? all.join('; ') : '';
      
      _bubbleAnswers['superpowers'] = _asAnswer(data['superpowers']);
    });
  }

  String _asAnswer(dynamic value) {
    if (value is List) {
      final text = value.map((item) => item.toString()).where((item) => item.trim().isNotEmpty).join(', ');
      return text;
    }
    return value?.toString().trim() ?? '';
  }

  void _loadAnswersFromLocal() {
    final savedAnswers = box.read('cbt_answers');
    if (savedAnswers != null && savedAnswers is Map) {
      setState(() {
        _bubbleAnswers['childhood'] = savedAnswers['When I Was Little'] ?? '';
        _bubbleAnswers['deep-beliefs'] = savedAnswers['Deep-Down Beliefs'] ?? '';
        _bubbleAnswers['rules'] = savedAnswers['The Rules'] ?? '';
        _bubbleAnswers['triggers'] = savedAnswers['Triggers'] ?? '';
        _bubbleAnswers['recent-happening'] = savedAnswers['A Recent Happening'] ?? '';
        _bubbleAnswers['thoughts'] = savedAnswers['My Thoughts'] ?? '';
        _bubbleAnswers['feelings'] = savedAnswers['My Feelings'] ?? '';
        _bubbleAnswers['behaviors'] = savedAnswers['What I Did'] ?? '';
        _bubbleAnswers['consequences'] = savedAnswers['The Consequences'] ?? '';
        _bubbleAnswers['superpowers'] = savedAnswers['Your Superpowers'] ?? '';
      });
    }
  }

  String _getBubbleDisplay(String id) {
    return _bubbleAnswers[id] ?? '';
  }

  bool _isFilled(String id) => _getBubbleDisplay(id).isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          _buildLinedBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: _isLoading 
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          child: Column(
                            children: [
                              // Main flow bubbles
                              ...mainBubbles.map((cfg) => Column(
                                children: [
                                  _buildSectionLabel(cfg.sectionTitle),
                                  const SizedBox(height: 12),
                                  _buildMainBubble(cfg),
                                  const SizedBox(height: 8),
                                  _buildWavyArrow(),
                                ],
                              )),
                              // Response section
                              _buildSectionLabel('How I React'),
                              const SizedBox(height: 12),
                              _buildResponseRow(),
                              const SizedBox(height: 12),
                              _buildCycleIndicator(),
                              _buildWavyArrow(),
                              // Bottom bubbles
                              ...bottomBubbles.map((cfg) => Column(
                                children: [
                                  _buildSectionLabel(cfg.sectionTitle),
                                  const SizedBox(height: 12),
                                  _buildMainBubble(cfg),
                                  if (cfg != bottomBubbles.last) ...[
                                    const SizedBox(height: 8),
                                    _buildWavyArrow(),
                                  ],
                                ],
                              )),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
          // Doodle decorations
          const DoodleDecorations(),
        ],
      ),
    );
  }

  Widget _buildLinedBackground() {
    return CustomPaint(
      painter: LinedPaperPainter(),
      size: Size.infinite,
    );
  }

  Widget _buildSectionLabel(String label) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Transform.rotate(
      angle: -0.02,
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2E7D32),
          letterSpacing: 1.5,
          fontFamily: 'Kalam',
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMainBubble(BubbleConfig cfg) {
    final filled = _isFilled(cfg.id);
    final display = _getBubbleDisplay(cfg.id);
    final isEven = mainBubbles.indexOf(cfg) % 2 == 1;

    return Transform.rotate(
      angle: isEven ? 0.035 : -0.035,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          gradient: filled
              ? const LinearGradient(
            colors: [Color(0xFFD4EDDA), Color(0xFFC3E6CB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : LinearGradient(
            colors: [cfg.bgColor1, cfg.bgColor2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: cfg.borderColor, width: 3),
          borderRadius: isEven
              ? const BorderRadius.only(
            topLeft: Radius.circular(60),
            topRight: Radius.circular(40),
            bottomLeft: Radius.circular(60),
            bottomRight: Radius.circular(40),
          )
              : const BorderRadius.only(
            topLeft: Radius.circular(50),
            topRight: Radius.circular(60),
            bottomLeft: Radius.circular(40),
            bottomRight: Radius.circular(50),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            Text(
              cfg.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D3436),
                fontFamily: 'Kalam',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              filled
                  ? display // Show full answer here as it's for display
                  : 'No answer provided yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16, // slightly bigger since it's displaying the full text
                color: filled ? const Color(0xFF2D3436) : const Color(0xFF636E72),
                fontStyle: filled ? FontStyle.italic : FontStyle.normal,
                fontWeight: filled ? FontWeight.w600 : FontWeight.normal,
                fontFamily: 'Caveat',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponseRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: responseBubbles.asMap().entries.map((entry) {
        final i = entry.key;
        final cfg = entry.value;
        final filled = _isFilled(cfg.id);
        final display = _getBubbleDisplay(cfg.id);
        final angle = [-0.05, 0.05, -0.03][i];

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Transform.rotate(
              angle: angle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  gradient: filled
                      ? const LinearGradient(
                    colors: [Color(0xFFD4EDDA), Color(0xFFC3E6CB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                      : LinearGradient(
                    colors: [cfg.bgColor1, cfg.bgColor2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: cfg.borderColor, width: 3),
                  borderRadius: [
                    const BorderRadius.only(
                      topLeft: Radius.circular(55),
                      topRight: Radius.circular(45),
                      bottomLeft: Radius.circular(45),
                      bottomRight: Radius.circular(55),
                    ),
                    const BorderRadius.only(
                      topLeft: Radius.circular(45),
                      topRight: Radius.circular(55),
                      bottomLeft: Radius.circular(55),
                      bottomRight: Radius.circular(45),
                    ),
                    const BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                      bottomLeft: Radius.circular(45),
                      bottomRight: Radius.circular(55),
                    ),
                  ][i],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: const Offset(3, 3),
                      blurRadius: 0,
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      cfg.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2D3436),
                        fontFamily: 'Kalam',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      filled
                          ? display
                          : 'No answer',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: filled ? const Color(0xFF2D3436) : const Color(0xFF636E72),
                        fontStyle: filled ? FontStyle.italic : FontStyle.normal,
                        fontWeight: filled ? FontWeight.w600 : FontWeight.normal,
                        fontFamily: 'Caveat',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCycleIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        '↻  goes round and round  ↺',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          color: const Color(0xFFA29BFE).withOpacity(0.7),
          fontFamily: 'Caveat',
        ),
      ),
    );
  }

  Widget _buildWavyArrow() {
    return SizedBox(
      height: 40,
      child: CustomPaint(
        painter: WavyArrowPainter(color: const Color(0xFF4CAF50)),
        size: const Size(60, 40),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 10, left: 10, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF2E7D32)),
                onPressed: () => Get.back()
              ),
              const AppText(
                'CBT Formulation',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
