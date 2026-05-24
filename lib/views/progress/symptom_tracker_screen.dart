import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jonssony/controller/auth_controller.dart';
import 'package:jonssony/services/symptom_tracker_service.dart';
import 'package:jonssony/services/tracker_storage_service.dart';

class SymptomTrackerScreen extends StatefulWidget {
  final String trackerType;
  final Map<String, dynamic>? initialConfig;

  const SymptomTrackerScreen({
    super.key,
    required this.trackerType,
    this.initialConfig,
  });

  @override
  State<SymptomTrackerScreen> createState() => _SymptomTrackerScreenState();
}

class _SymptomTrackerScreenState extends State<SymptomTrackerScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController _stemController = TextEditingController();

  Map<String, dynamic>? _config;
  Map<String, dynamic>? _result;
  List<int?> _answers = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  static const _bg = Color(0xFFF5F1EA);
  static const _bgCard = Color(0xFFFBF8F2);
  static const _ink = Color(0xFF1A1814);
  static const _inkSoft = Color(0xFF4A4540);
  static const _inkMuted = Color(0xFF8A8278);
  static const _rule = Color(0xFFDDD5C5);
  static const _ruleSoft = Color(0xFFEAE3D3);
  static const _accent = Color(0xFF4A7373);
  static const _accentSoft = Color(0xFFC9D6D6);
  static const _warn = Color(0xFFA8553D);
  static const _warnBg = Color(0xFFF4E4DD);

  @override
  void initState() {
    super.initState();
    if (widget.initialConfig != null) {
      _setConfig(widget.initialConfig!);
      _isLoading = false;
    } else {
      _loadConfig();
    }
  }

  @override
  void dispose() {
    _stemController.dispose();
    super.dispose();
  }

  void _setConfig(Map<String, dynamic> config) {
    _config = config;
    final itemCount = (_items).length;
    _answers = List<int?>.filled(itemCount, null);
  }

  Future<void> _loadConfig() async {
    final token = _authController.token;
    if (token == null || token.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please log in again.';
      });
      return;
    }

    final result = await SymptomTrackerService.getConfig(
      token,
      widget.trackerType,
    );
    if (!mounted) return;

    if (result['success'] == true && result['data'] is Map) {
      setState(() {
        _setConfig(Map<String, dynamic>.from(result['data']));
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = result['message'] ?? 'Failed to load tracker.';
      });
    }
  }

  List<dynamic> get _items => (_config?['items'] as List?) ?? [];
  List<dynamic> get _options => (_config?['options'] as List?) ?? [];
  List<dynamic> get _alerts => (_config?['alerts'] as List?) ?? [];
  String get _name => _config?['name']?.toString() ?? widget.trackerType;
  String get _description => _config?['description']?.toString() ?? '';
  String? get _stemKey => _config?['stemKey']?.toString();
  int get _answeredCount => _answers.where((answer) => answer != null).length;
  bool get _allAnswered => _answers.isNotEmpty && _answeredCount == _answers.length;
  int get _maxOptionValue {
    var max = 0;
    for (final option in _options) {
      if (option is Map && option['value'] is num) {
        final value = (option['value'] as num).toInt();
        if (value > max) max = value;
      }
    }
    return max == 0 ? 4 : max;
  }

  Future<void> _submit() async {
    if (!_allAnswered || _isSubmitting) return;

    final token = _authController.token;
    if (token == null || token.isEmpty) {
      Get.snackbar('Error', 'Please log in again.');
      return;
    }

    setState(() => _isSubmitting = true);
    final result = await SymptomTrackerService.submit(
      token: token,
      trackerType: widget.trackerType,
      answers: _answers.map((answer) => answer!).toList(),
      stemValue: _stemController.text,
    );
    if (!mounted) return;

    setState(() => _isSubmitting = false);
    if (result['success'] != true || result['data'] is! Map) {
      Get.snackbar('Error', result['message'] ?? 'Failed to submit tracker.');
      return;
    }

    final data = Map<String, dynamic>.from(result['data']);
    setState(() => _result = data);

    await TrackerStorageService.instance.saveResult(
      trackerKey: widget.trackerType,
      trackerName: _name,
      score: (data['totalScore'] as num?)?.toInt() ?? 0,
      maxScore: (data['maxScore'] as num?)?.toInt() ?? 40,
      band: data['severityBand']?.toString() ?? '',
    );
  }

  void _reset() {
    setState(() {
      _answers = List<int?>.filled(_items.length, null);
      _result = null;
    });
  }

  void _closeWithResult({bool showResultsTab = false}) {
    final result = _result;
    if (result == null) return;
    Navigator.of(context).pop({
      'title': _name,
      'trackerType': widget.trackerType,
      'score': (result['totalScore'] as num?)?.toInt() ?? 0,
      'maxScore': (result['maxScore'] as num?)?.toInt() ?? 40,
      'bandLabel': result['severityBand']?.toString() ?? '',
      'bandDescription': result['description']?.toString() ?? '',
      'itemScores': result['itemScores'] ?? [],
      'showResultsTab': showResultsTab,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: _accent))
            : _errorMessage != null
                ? _buildError()
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 36),
                        _buildNotice(),
                        const SizedBox(height: 32),
                        if (_stemKey != null && _stemKey!.isNotEmpty) ...[
                          _buildStemField(),
                          const SizedBox(height: 32),
                        ],
                        _buildInstructions(),
                        const SizedBox(height: 36),
                        ...List.generate(_items.length, _buildItem),
                        const SizedBox(height: 36),
                        _result == null ? _buildSubmitSection() : _buildResults(),
                        const SizedBox(height: 40),
                        const Text(
                          'InKind EMDR - Symptom Tracker',
                          style: TextStyle(
                            fontSize: 12,
                            color: _inkMuted,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadConfig, child: const Text('Retry')),
          ],
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
                'InKind EMDR - Symptom Tracker',
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
          _name,
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
          _description,
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
        "This tracker helps you notice patterns and monitor changes over time. It is not a diagnostic instrument.",
        style: TextStyle(fontSize: 14, color: _inkSoft, height: 1.6),
      ),
    );
  }

  Widget _buildStemField() {
    return TextField(
      controller: _stemController,
      decoration: InputDecoration(
        labelText: 'Focus',
        hintText: 'Name the focus for this tracker',
        filled: true,
        fillColor: _bgCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: const BorderSide(color: _rule),
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Instructions',
          style: TextStyle(
            fontFamily: 'Fraunces',
            fontSize: 22,
            fontWeight: FontWeight.w400,
            color: _ink,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'For each statement, choose the response that best describes the past week.',
          style: TextStyle(fontSize: 15, color: _inkSoft, height: 1.55),
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(border: Border.all(color: _rule)),
          child: Row(
            children: _options.map((option) {
              final value = option is Map ? option['value']?.toString() ?? '' : '';
              final label = option is Map ? option['label']?.toString() ?? '' : '';
              return Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                  color: _bgCard,
                  child: Column(
                    children: [
                      Text(
                        value,
                        style: const TextStyle(
                          fontFamily: 'Fraunces',
                          fontSize: 18,
                          color: _accent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 9, color: _inkMuted),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildItem(int index) {
    final item = _items[index] as Map;
    final reverse = item['reverse'] == true;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _ruleSoft)),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item['text']?.toString() ?? '',
                  style: const TextStyle(
                    fontFamily: 'Fraunces',
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: _ink,
                    height: 1.4,
                  ),
                ),
              ),
              if (reverse)
                const Text(' reverse', style: TextStyle(color: _inkMuted, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 22),
          _buildOptions(index),
        ],
      ),
    );
  }

  Widget _buildOptions(int itemIndex) {
    return Row(
      children: _options.map((option) {
        final value = option is Map ? (option['value'] as num?)?.toInt() ?? 0 : 0;
        final label = option is Map ? option['label']?.toString() ?? '' : '';
        final selected = _answers[itemIndex] == value;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _answers[itemIndex] = value),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
              decoration: BoxDecoration(
                color: selected ? _accent : _bgCard,
                border: Border.all(color: selected ? _accent : _rule),
              ),
              child: Column(
                children: [
                  Text(
                    '$value',
                    style: TextStyle(
                      fontFamily: 'Fraunces',
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: selected ? _bg : _ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 8,
                      color: selected ? _accentSoft : _inkMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSubmitSection() {
    return Column(
      children: [
        Text(
          '$_answeredCount of ${_items.length} answered',
          style: const TextStyle(fontSize: 13, color: _inkMuted),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _allAnswered && !_isSubmitting ? _submit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _ink,
              foregroundColor: _bg,
              disabledBackgroundColor: const Color(0x661A1814),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              elevation: 0,
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('SUBMIT TRACKER'),
          ),
        ),
      ],
    );
  }

  Widget _buildResults() {
    final result = _result!;
    final total = (result['totalScore'] as num?)?.toInt() ?? 0;
    final maxScore = (result['maxScore'] as num?)?.toInt() ?? 40;
    final band = result['severityBand']?.toString() ?? '';
    final description = result['description']?.toString() ?? '';

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
            'Your tracker result',
            style: TextStyle(fontSize: 11, letterSpacing: 2.0, color: _inkMuted),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$total',
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
            description,
            style: const TextStyle(fontSize: 15, color: _inkSoft, height: 1.6),
          ),
          ..._buildAlerts(),
          const SizedBox(height: 28),
          _buildBreakdown(result['itemScores'] as List? ?? []),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _closeWithResult,
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: _bg,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
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
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
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
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              child: const Text('VIEW MY PROGRESS'),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAlerts() {
    final widgets = <Widget>[];
    for (final alert in _alerts) {
      if (alert is! Map) continue;
      final itemNumber = (alert['item'] as num?)?.toInt();
      if (itemNumber == null || itemNumber < 1 || itemNumber > _answers.length) {
        continue;
      }
      final raw = _answers[itemNumber - 1] ?? 0;
      final trigger = alert['trigger']?.toString() ?? '';
      final triggered =
          (trigger == '>=1' && raw >= 1) ||
          (trigger == '>=2' && raw >= 2) ||
          (trigger == '>=3' && raw >= 3);
      if (!triggered) continue;

      widgets.add(const SizedBox(height: 22));
      widgets.add(
        Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          decoration: const BoxDecoration(
            color: _warnBg,
            border: Border(left: BorderSide(color: _warn, width: 2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                alert['title']?.toString() ?? 'Important',
                style: const TextStyle(
                  fontFamily: 'Fraunces',
                  fontSize: 16,
                  color: _warn,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                alert['message']?.toString() ?? '',
                style: const TextStyle(fontSize: 14, color: _ink, height: 1.6),
              ),
            ],
          ),
        ),
      );
    }
    return widgets;
  }

  Widget _buildBreakdown(List<dynamic> itemScores) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: List.generate(itemScores.length, (index) {
        final scoreData = itemScores[index];
        final scored = scoreData is Map
            ? (scoreData['scored'] as num?)?.toInt() ?? 0
            : 0;
        final selectedColor = _intensityColor(scored);
        return Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: selectedColor,
            border: Border.all(color: _rule),
          ),
          child: Center(
            child: Text(
              '$scored',
              style: TextStyle(
                fontFamily: 'Fraunces',
                fontSize: 18,
                color: scored >= (_maxOptionValue - 1) ? _bg : _ink,
              ),
            ),
          ),
        );
      }),
    );
  }

  Color _intensityColor(int score) {
    if (score <= 0) return _bgCard;
    if (score == 1) return const Color(0xFFECF2F1);
    if (score == 2) return _accentSoft;
    if (score == 3) return const Color(0xFF8FA8A8);
    return _accent;
  }
}
