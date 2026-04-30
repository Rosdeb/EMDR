import 'package:flutter/material.dart';
import 'package:jonssony/services/tracker_storage_service.dart';

// ─── Data models ──────────────────────────────────────────────────────────────

class TrackerItem {
  final String text;
  final bool reverse;
  const TrackerItem({required this.text, required this.reverse});
}

class SeverityBand {
  final int max;
  final String label;
  final String description;
  const SeverityBand({required this.max, required this.label, required this.description});
}

class TrackerAlert {
  final int itemIndex;
  final String trigger;
  final String title;
  final String message;
  const TrackerAlert({required this.itemIndex, required this.trigger, required this.title, required this.message});
}

// ─── Tracker config ───────────────────────────────────────────────────────────

const _kName = 'Stress & Burnout';
const _kTrackerNum = '08';
const _kMaxScore = 40;

const _kItems = [
    TrackerItem(text: 'I have woken up still carrying yesterday\'s tiredness.', reverse: false),
    TrackerItem(text: 'The demands on me have outpaced what I have to give.', reverse: false),
    TrackerItem(text: 'The thought of facing the day has felt like a weight.', reverse: false),
    TrackerItem(text: 'I have gone numb or detached from things I used to care about.', reverse: false),
    TrackerItem(text: 'I have noticed myself doing less well, or with less heart, in my work or roles.', reverse: false),
    TrackerItem(text: 'I have moved through my days with a sense of meaning and engagement.', reverse: true),
    TrackerItem(text: 'Even off the clock, I have not really been off the clock.', reverse: false),
    TrackerItem(text: 'Small stressors have landed harder than they should.', reverse: false),
    TrackerItem(text: 'I have felt short-tempered, brittle, or close to overwhelm.', reverse: false),
    TrackerItem(text: 'I have wondered, somewhere in the back of my mind, how long I can keep this up.', reverse: false),
];

const _kBands = [
    SeverityBand(max: 9, label: 'Minimal', description: 'Few signs of significant stress or burnout over the past week. The demands and recovery seem broadly in balance.'),
    SeverityBand(max: 17, label: 'Mild', description: 'Some signs of cumulative stress. Worth noticing now, before the gap between demands and recovery widens.'),
    SeverityBand(max: 25, label: 'Moderate', description: 'A meaningful pattern of stress and exhaustion over the past week. The EMDR work can help with the underlying patterns, but burnout often also requires structural changes to demands and recovery.'),
    SeverityBand(max: 32, label: 'Marked', description: 'Substantial stress with features of burnout. This level often signals that something needs to change structurally, not just be coped with better. Worth examining what could shift in your circumstances alongside the programme.'),
    SeverityBand(max: 40, label: 'Severe', description: 'A high level of burnout with significant impact across multiple areas of life. At this level, please consider whether immediate adjustments to demands are needed, and whether speaking to your GP or a qualified mental health professional would be useful.'),
];

const _kAlerts = [

];

// ─── Screen ───────────────────────────────────────────────────────────────────

class StressBurnoutScreen extends StatefulWidget {
  const StressBurnoutScreen({super.key});

  @override
  State<StressBurnoutScreen> createState() => _StressBurnoutScreenState();
}

class _StressBurnoutScreenState extends State<StressBurnoutScreen> {
  final List<int?> _answers = List.filled(_kItems.length, null);
  bool _submitted = false;
  int _total = 0;
  List<int> _itemScores = [];

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
  void dispose() {
    super.dispose();
  }

  int get _answeredCount => _answers.where((a) => a != null).length;
  bool get _allAnswered => _answeredCount == _kItems.length;

  void _submit() async {
    if (!_allAnswered) return;
    int total = 0;
    final scores = <int>[];
    for (int i = 0; i < _kItems.length; i++) {
      final raw = _answers[i]!;
      final scored = _kItems[i].reverse ? (4 - raw) : raw;
      scores.add(scored);
      total += scored;
    }
    setState(() {
      _total = total;
      _itemScores = scores;
      _submitted = true;
    });
    await TrackerStorageService.instance.saveResult(
      trackerKey: 'stress-burnout',
      trackerName: _kName,
      score: total,
      maxScore: _kMaxScore,
      band: _band.label,
    );
  }

  void _reset() {
    setState(() {
      _answers.fillRange(0, _answers.length, null);
      _submitted = false;
      _total = 0;
      _itemScores = [];
    });
  }

  void _saveResult({bool showResultsTab = false}) {
    if (!_submitted) return;
    final result = {
      'title': _kName,
      'score': _total,
      'maxScore': _kMaxScore,
      'bandLabel': _band.label,
      'bandDescription': _band.description,
      'itemScores': _itemScores,
      'showResultsTab': showResultsTab,
    };
    Navigator.of(context).pop(result);
  }

  SeverityBand get _band => _kBands.firstWhere((b) => _total <= b.max, orElse: () => _kBands.last);

  Color _intensityColor(int score) {
    switch (score) {
      case 0: return _bgCard;
      case 1: return const Color(0xFFECF2F1);
      case 2: return _accentSoft;
      case 3: return const Color(0xFF8FA8A8);
      case 4: return _accent;
      default: return _bgCard;
    }
  }

  Color _intensityTextColor(int score) => score >= 3 ? _bg : _ink;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 48),
              _buildNotice(),
              const SizedBox(height: 40),
              _buildInstructions(),
              const SizedBox(height: 48),
              ...List.generate(_kItems.length, _buildItem),
              const SizedBox(height: 48),
              if (!_submitted) _buildSubmitSection() else _buildResults(),
              const SizedBox(height: 48),
              _buildFooter(),
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
        Row(children: [
          Container(width: 24, height: 1, color: _accent),
          const SizedBox(width: 12),
          Text('InKind EMDR · Symptom Tracker · $_kTrackerNum',
            style: const TextStyle(fontSize: 11, letterSpacing: 2.5, color: _inkMuted, fontWeight: FontWeight.w500)),
        ]),
        const SizedBox(height: 24),
        const Text(_kName,
          style: TextStyle(fontFamily: 'Fraunces', fontSize: 48, fontWeight: FontWeight.w400,
            letterSpacing: -0.96, color: _ink, height: 1.05)),
        const SizedBox(height: 24),
        Text(
          'A brief check-in on how $_kName has shown up in your body, mind, and daily life over the past week.',
          style: const TextStyle(fontFamily: 'Fraunces', fontSize: 19, fontWeight: FontWeight.w300,
            color: _inkSoft, height: 1.5)),
        const SizedBox(height: 32),
        const Divider(color: _rule, thickness: 1),
      ],
    );
  }

  Widget _buildNotice() {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
      decoration: const BoxDecoration(
        color: _bgCard,
        border: Border(left: BorderSide(color: _accent, width: 2)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Please read',
            style: TextStyle(fontFamily: 'Fraunces', fontSize: 16, fontWeight: FontWeight.w500, color: _ink)),
          SizedBox(height: 8),
          Text(
            "This is a symptom tracker designed to help you notice patterns in how you're feeling and to monitor changes as you work through the InKind EMDR programme. It is not a diagnostic instrument and cannot diagnose any condition.",
            style: TextStyle(fontSize: 14, color: _inkSoft, height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    const labels = [
      (n: '0', l: 'Never'), (n: '1', l: 'Rarely'), (n: '2', l: 'Sometimes'),
      (n: '3', l: 'Often'), (n: '4', l: 'Almost\nalways'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Instructions',
          style: TextStyle(fontFamily: 'Fraunces', fontSize: 22, fontWeight: FontWeight.w400,
            color: _ink, letterSpacing: -0.22)),
        const SizedBox(height: 16),
        const Text(
          'For each statement, please choose the response that best describes how true it has been for you over the past week. There are no right or wrong answers.',
          style: TextStyle(fontSize: 15, color: _inkSoft, height: 1.55)),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(border: Border.all(color: _rule)),
          child: Row(
            children: labels.map((e) => Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                color: _bgCard,
                child: Column(children: [
                  Text(e.n, style: const TextStyle(fontFamily: 'Fraunces', fontSize: 18, color: _accent, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(e.l, textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 9, color: _inkMuted, letterSpacing: 0.8)),
                ]),
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildItem(int index) {
    final item = _kItems[index];
    final num = (index + 1).toString().padLeft(2, '0');
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: _ruleSoft))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(num, style: const TextStyle(fontFamily: 'Fraunces', fontSize: 13, color: _accent, letterSpacing: 0.3)),
          const SizedBox(height: 12),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Text(item.text,
              style: const TextStyle(fontFamily: 'Fraunces', fontSize: 21, fontWeight: FontWeight.w400,
                color: _ink, height: 1.4, letterSpacing: -0.21))),
            if (item.reverse) const Text(' ↻', style: TextStyle(color: _inkMuted, fontSize: 14)),
          ]),
          const SizedBox(height: 24),
          _buildOptions(index),
        ],
      ),
    );
  }

  Widget _buildOptions(int itemIndex) {
    const optLabels = ['Never', 'Rarely', 'Sometimes', 'Often', 'Almost\nalways'];
    return Row(
      children: List.generate(5, (v) {
        final selected = _answers[itemIndex] == v;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _answers[itemIndex] = v),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 2),
              decoration: BoxDecoration(
                color: selected ? _accent : _bgCard,
                border: Border.all(color: selected ? _accent : _rule),
              ),
              child: Column(children: [
                Text('$v', style: TextStyle(fontFamily: 'Fraunces', fontSize: 18,
                  fontWeight: FontWeight.w500, color: selected ? _bg : _ink)),
                const SizedBox(height: 2),
                Text(optLabels[v], textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 8, letterSpacing: 0.4,
                    color: selected ? _accentSoft : _inkMuted)),
              ]),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSubmitSection() {
    return Column(
      children: [
        Text('$_answeredCount of ${_kItems.length} answered',
          style: const TextStyle(fontSize: 13, color: _inkMuted)),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _allAnswered ? _submit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _ink,
              foregroundColor: _bg,
              disabledBackgroundColor: Color(0x661A1814),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              elevation: 0,
            ),
            child: const Text('CALCULATE SCORE',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 1.0)),
          ),
        ),
      ],
    );
  }

  Widget _buildResults() {
    final band = _band;
    final bandIndex = _kBands.indexOf(band);
    const bandLabels = ['Minimal', 'Mild', 'Moderate', 'Marked', 'Severe'];
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(color: _bgCard, border: Border.all(color: _rule)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your tracker result',
            style: TextStyle(fontSize: 11, letterSpacing: 2.5, color: _inkMuted)),
          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('$_total', style: const TextStyle(fontFamily: 'Fraunces', fontSize: 88,
                fontWeight: FontWeight.w400, color: _accent, letterSpacing: -3.52, height: 1)),
              const SizedBox(width: 16),
              Text('/ $_kMaxScore', style: const TextStyle(fontFamily: 'Fraunces',
                fontSize: 28, color: _inkMuted, fontWeight: FontWeight.w300)),
            ],
          ),
          const SizedBox(height: 8),
          Text(band.label, style: const TextStyle(fontFamily: 'Fraunces', fontSize: 28,
            letterSpacing: -0.28, color: _ink)),
          const SizedBox(height: 16),
          Text(band.description, style: const TextStyle(fontSize: 15, color: _inkSoft, height: 1.6)),
          const SizedBox(height: 24),
          Row(children: List.generate(5, (i) => Expanded(
            child: Container(height: 6, margin: const EdgeInsets.symmetric(horizontal: 1),
              color: i <= bandIndex ? _accent : _rule)))),
          const SizedBox(height: 8),
          Row(children: bandLabels.map((l) => Expanded(
            child: Text(l, textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 9, color: _inkMuted, letterSpacing: 0.5)))).toList()),
          ..._buildAlerts(),
          const SizedBox(height: 40),
          const Divider(color: _rule),
          const SizedBox(height: 24),
          const Text('Item-by-item',
            style: TextStyle(fontFamily: 'Fraunces', fontSize: 18, fontWeight: FontWeight.w400, color: _inkSoft)),
          const SizedBox(height: 16),
          _buildBreakdown(),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveResult,
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: _bg,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                elevation: 0,
              ),
              child: const Text('SAVE RESULT', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 1.0)),
            ),
          ),
          const SizedBox(height: 16),
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
              child: const Text('TAKE AGAIN', style: TextStyle(fontSize: 12, letterSpacing: 0.8)),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _saveResult(showResultsTab: true),
              style: OutlinedButton.styleFrom(
                foregroundColor: _accent,
                side: const BorderSide(color: _accent),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              child: const Text('VIEW MY PROGRESS →', style: TextStyle(fontSize: 12, letterSpacing: 0.8)),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAlerts() {
    final widgets = <Widget>[];
    for (final alert in _kAlerts) {
      if (alert.itemIndex >= _itemScores.length) continue;
      final score = _itemScores[alert.itemIndex];
      final triggered = (alert.trigger == '>=1' && score >= 1) ||
          (alert.trigger == '>=2' && score >= 2) ||
          (alert.trigger == '>=3' && score >= 3);
      if (triggered) {
        widgets.add(const SizedBox(height: 24));
        widgets.add(Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          decoration: const BoxDecoration(
            color: _warnBg,
            border: Border(left: BorderSide(color: _warn, width: 2)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(alert.title, style: const TextStyle(fontFamily: 'Fraunces',
              fontSize: 16, color: _warn, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Text(alert.message, style: const TextStyle(fontSize: 14, color: _ink, height: 1.6)),
          ]),
        ));
      }
    }
    return widgets;
  }

  Widget _buildBreakdown() {
    return Wrap(
      spacing: 6, runSpacing: 6,
      children: List.generate(_itemScores.length, (i) {
        final score = _itemScores[i];
        final size = (MediaQuery.of(context).size.width - 80 - 24) / 5;
        return SizedBox(
          width: size, height: size,
          child: Stack(children: [
            Container(decoration: BoxDecoration(
              color: _intensityColor(score), border: Border.all(color: _rule))),
            Positioned(top: 4, left: 6,
              child: Text((i + 1).toString().padLeft(2, '0'),
                style: const TextStyle(fontSize: 9, color: _inkMuted, fontWeight: FontWeight.w500))),
            Center(child: Text('$score',
              style: TextStyle(fontFamily: 'Fraunces', fontSize: 18,
                color: _intensityTextColor(score)))),
          ]),
        );
      }),
    );
  }

  Widget _buildFooter() {
    return const Text('InKind EMDR · Symptom Tracker',
      style: TextStyle(fontSize: 12, color: _inkMuted, letterSpacing: 0.3));
  }
}
