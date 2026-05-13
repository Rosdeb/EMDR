import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jonssony/controller/auth_controller.dart';
import 'package:jonssony/services/questionnaire_service.dart';
import 'package:jonssony/services/tracker_storage_service.dart';

class LocalAssessmentConfig {
  final String title;
  final String trackerType;
  final String description;
  final List<String> questions;
  final List<String> optionLabels;
  final int maxOptionValue;
  final bool usePercentageSlider;
  final int maxScore;
  final String Function(int score) bandForScore;

  const LocalAssessmentConfig({
    required this.title,
    required this.trackerType,
    required this.description,
    required this.questions,
    required this.optionLabels,
    required this.maxOptionValue,
    required this.usePercentageSlider,
    required this.maxScore,
    required this.bandForScore,
  });
}

class LocalAssessmentScreen extends StatefulWidget {
  final LocalAssessmentConfig config;

  const LocalAssessmentScreen({super.key, required this.config});

  @override
  State<LocalAssessmentScreen> createState() => _LocalAssessmentScreenState();
}

class _LocalAssessmentScreenState extends State<LocalAssessmentScreen> {
  late final List<int?> _answers;
  bool _isSaving = false;
  Map<String, dynamic>? _result;

  static const _bg = Color(0xFFF5F1EA);
  static const _bgCard = Color(0xFFFBF8F2);
  static const _ink = Color(0xFF1A1814);
  static const _inkSoft = Color(0xFF4A4540);
  static const _inkMuted = Color(0xFF8A8278);
  static const _rule = Color(0xFFDDD5C5);
  static const _accent = Color(0xFF4A7373);

  @override
  void initState() {
    super.initState();
    _answers = List<int?>.filled(widget.config.questions.length, null);
  }

  int get _answeredCount => _answers.whereType<int>().length;
  bool get _allAnswered => _answeredCount == _answers.length;

  int get _score {
    final total = _answers.whereType<int>().fold<int>(
      0,
      (sum, value) => sum + value,
    );
    if (!widget.config.usePercentageSlider) return total;
    if (_answers.isEmpty) return 0;
    return (total / _answers.length).round();
  }

  Future<void> _submit() async {
    if (!_allAnswered || _isSaving) return;

    final token = Get.find<AuthController>().token;
    if (token == null || token.isEmpty) {
      Get.snackbar('Error', 'Please log in again.');
      return;
    }

    setState(() => _isSaving = true);
    final answers = _answers.map((answer) => answer ?? 0).toList();
    final apiResult = await QuestionnaireService.submit(
      token: token,
      type: widget.config.trackerType,
      answers: answers,
    );
    if (!mounted) return;

    if (apiResult['success'] != true || apiResult['data'] is! Map) {
      setState(() => _isSaving = false);
      Get.snackbar(
        'Error',
        apiResult['message']?.toString() ?? 'Failed to submit assessment.',
      );
      return;
    }

    final data = Map<String, dynamic>.from(apiResult['data'] as Map);
    final score = _score;
    final apiScore = (data['score'] as num?) ?? score;
    final scoreText = widget.config.usePercentageSlider
        ? apiScore.toStringAsFixed(apiScore % 1 == 0 ? 0 : 1)
        : apiScore.toInt().toString();
    final band =
        data['severity']?.toString() ?? widget.config.bandForScore(score);
    setState(() {
      _result = {
        'id': data['id'],
        'title': widget.config.title,
        'trackerType': widget.config.trackerType,
        'score': apiScore,
        'scoreText': scoreText,
        'maxScore': widget.config.maxScore,
        'bandLabel': _formatBand(band),
        'bandDescription': _descriptionForResult(scoreText, _formatBand(band)),
        'submittedAt': data['submittedAt'],
        'showResultsTab': false,
      };
    });

    await TrackerStorageService.instance.saveResult(
      trackerKey: widget.config.trackerType,
      trackerName: widget.config.title,
      score: apiScore.round(),
      maxScore: widget.config.maxScore,
      band: _formatBand(band),
    );

    if (mounted) setState(() => _isSaving = false);
  }

  void _closeWithResult({bool showResultsTab = false}) {
    final result = _result;
    if (result == null) return;
    Navigator.of(context).pop({...result, 'showResultsTab': showResultsTab});
  }

  void _reset() {
    setState(() {
      for (var i = 0; i < _answers.length; i++) {
        _answers[i] = null;
      }
      _result = null;
    });
  }

  String _formatBand(String value) {
    if (value.isEmpty) return widget.config.bandForScore(_score);
    return value
        .split(RegExp(r'[\s_-]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1).toLowerCase())
        .join(' ');
  }

  String _descriptionForResult(String score, String band) {
    return 'Your latest ${widget.config.title} score is $score/${widget.config.maxScore}, which falls in the $band range. Keep tracking weekly to notice changes over time.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 36),
              _buildNotice(),
              const SizedBox(height: 32),
              _buildInstructions(),
              const SizedBox(height: 24),
              ...List.generate(widget.config.questions.length, _buildQuestion),
              const SizedBox(height: 36),
              _result == null ? _buildSubmitSection() : _buildResults(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 12),
            Container(width: 24, height: 1, color: _accent),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'InKind EMDR - Assessment',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.8,
                  color: _inkMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          widget.config.title,
          style: const TextStyle(
            fontFamily: 'Fraunces',
            fontSize: 44,
            fontWeight: FontWeight.w400,
            color: _ink,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          widget.config.description,
          style: const TextStyle(
            fontFamily: 'Fraunces',
            fontSize: 18,
            fontWeight: FontWeight.w300,
            color: _inkSoft,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 28),
        const Divider(color: _rule, thickness: 1),
      ],
    );
  }

  Widget _buildNotice() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      decoration: const BoxDecoration(
        color: _bgCard,
        border: Border(left: BorderSide(color: _accent, width: 2)),
      ),
      child: const Text(
        'This assessment helps you monitor changes over time. It is not a diagnostic instrument.',
        style: TextStyle(fontSize: 14, color: _inkSoft, height: 1.6),
      ),
    );
  }

  Widget _buildInstructions() {
    final text = widget.config.usePercentageSlider
        ? 'For each statement, choose the percentage that best describes how often it happens to you.'
        : 'For each statement, choose the response that best describes the last 2 weeks.';
    return Text(
      text,
      style: const TextStyle(fontSize: 15, color: _inkSoft, height: 1.55),
    );
  }

  Widget _buildQuestion(int index) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFEAE3D3))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (index + 1).toString().padLeft(2, '0'),
            style: const TextStyle(
              fontFamily: 'Fraunces',
              fontSize: 13,
              color: _accent,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.config.questions[index],
            style: const TextStyle(
              fontFamily: 'Fraunces',
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: _ink,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 22),
          widget.config.usePercentageSlider
              ? _buildSlider(index)
              : _buildOptions(index),
        ],
      ),
    );
  }

  Widget _buildOptions(int questionIndex) {
    return Column(
      children: List.generate(widget.config.optionLabels.length, (value) {
        final selected = _answers[questionIndex] == value;
        return GestureDetector(
          onTap: () => setState(() => _answers[questionIndex] = value),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: selected ? _accent : _bgCard,
              border: Border.all(color: selected ? _accent : _rule),
            ),
            child: Row(
              children: [
                Text(
                  '$value',
                  style: TextStyle(
                    fontFamily: 'Fraunces',
                    fontSize: 18,
                    color: selected ? _bg : _ink,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    widget.config.optionLabels[value],
                    style: TextStyle(
                      fontSize: 13,
                      color: selected ? const Color(0xFFC9D6D6) : _inkSoft,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSlider(int questionIndex) {
    final value = (_answers[questionIndex] ?? 0).toDouble();
    return Column(
      children: [
        Text(
          '${value.toInt()}%',
          style: const TextStyle(
            fontFamily: 'Fraunces',
            fontSize: 44,
            color: _accent,
          ),
        ),
        Slider(
          value: value,
          min: 0,
          max: 100,
          divisions: 10,
          activeColor: _accent,
          onChanged: (next) => setState(() {
            _answers[questionIndex] = next.round();
          }),
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0% never', style: TextStyle(fontSize: 11, color: _inkMuted)),
            Text(
              '100% always',
              style: TextStyle(fontSize: 11, color: _inkMuted),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubmitSection() {
    return Column(
      children: [
        Text(
          '$_answeredCount of ${_answers.length} answered',
          style: const TextStyle(fontSize: 13, color: _inkMuted),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _allAnswered && !_isSaving ? _submit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _ink,
              foregroundColor: _bg,
              disabledBackgroundColor: const Color(0x661A1814),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              elevation: 0,
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('SUBMIT ASSESSMENT'),
          ),
        ),
      ],
    );
  }

  Widget _buildResults() {
    final score =
        _result?['scoreText']?.toString() ??
        ((_result?['score'] as num?)?.toString() ?? '0');
    final maxScore = (_result?['maxScore'] as num?)?.toInt() ?? 0;
    final band = _result?['bandLabel']?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: _bgCard,
        border: Border.all(color: _rule),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your assessment result',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 2.0,
              color: _inkMuted,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                score,
                style: const TextStyle(
                  fontFamily: 'Fraunces',
                  fontSize: 76,
                  fontWeight: FontWeight.w400,
                  color: _accent,
                  height: 1,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '/ $maxScore',
                style: const TextStyle(
                  fontFamily: 'Fraunces',
                  fontSize: 26,
                  color: _inkMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            band,
            style: const TextStyle(
              fontFamily: 'Fraunces',
              fontSize: 28,
              color: _ink,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _descriptionForResult(score, band),
            style: const TextStyle(fontSize: 15, color: _inkSoft, height: 1.6),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _closeWithResult,
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: _bg,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: const Text('SAVE RESULT'),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _reset,
              style: OutlinedButton.styleFrom(
                foregroundColor: _inkSoft,
                side: const BorderSide(color: _rule),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: const Text('TAKE AGAIN'),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _closeWithResult(showResultsTab: true),
              style: OutlinedButton.styleFrom(
                foregroundColor: _accent,
                side: const BorderSide(color: _accent),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: const Text('VIEW MY PROGRESS'),
            ),
          ),
        ],
      ),
    );
  }
}
