import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:jonssony/services/tracker_storage_service.dart';
import 'package:google_fonts/google_fonts.dart';

class ResultsDashboardScreen extends StatefulWidget {
  const ResultsDashboardScreen({super.key});

  @override
  State<ResultsDashboardScreen> createState() => _ResultsDashboardScreenState();
}

class _ResultsDashboardScreenState extends State<ResultsDashboardScreen> {
  Map<String, List<TrackerResult>> _allResults = {};
  String? _selectedTrackerKey;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final results = await TrackerStorageService.instance.getAllResults();
    setState(() {
      _allResults = results;
      _selectedTrackerKey = results.isNotEmpty ? results.keys.first : null;
      _isLoading = false;
    });
  }

  List<TrackerResult> _getSelectedResults() {
    if (_selectedTrackerKey == null) return [];
    return _allResults[_selectedTrackerKey!] ?? [];
  }

  TrackerResult? _getLatestResult(String trackerKey) {
    final results = _allResults[trackerKey];
    if (results == null || results.isEmpty) return null;
    return results.last;
  }

  String _getChangeText(TrackerResult? latest, TrackerResult? previous) {
    if (latest == null) return '';
    if (previous == null) return 'First entry';
    final change = latest.score - previous.score;
    if (change > 0) return '+${change.abs()} since last week';
    if (change < 0) return '−${change.abs()} since last week';
    return 'No change';
  }

  Color _getChangeColor(int change) {
    if (change > 0) return Colors.green;
    if (change < 0) return const Color(0xFF4A7373);
    return const Color(0xFF8A8278);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_allResults.isEmpty) {
      return _buildEmptyState();
    }

    final selectedResults = _getSelectedResults();
    final latest = _getLatestResult(_selectedTrackerKey!);
    final previous = selectedResults.length > 1
        ? selectedResults[selectedResults.length - 2]
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 30),
            _buildTrackerSelector(),
            const SizedBox(height: 30),
            _buildChart(selectedResults),
            const SizedBox(height: 30),
            _buildSummaryCard(latest, previous),
            const SizedBox(height: 40),
            _buildAllResultsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'InKind EMDR · Progress Dashboard',
          style: GoogleFonts.instrumentSans(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.1,
            color: const Color(0xFF8A8278),
          ).copyWith(textBaseline: TextBaseline.alphabetic),
        ),
        const SizedBox(height: 10),
        Text(
          'Your Progress',
          style: GoogleFonts.fraunces(
            fontSize: 48,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF1A1814),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Scores week by week across all trackers.',
          style: GoogleFonts.fraunces(
            fontSize: 19,
            fontWeight: FontWeight.w300,
            color: const Color(0xFF8A8278),
          ),
        ),
        const SizedBox(height: 20),
        Container(height: 1, color: const Color(0xFFDDD5C5)),
      ],
    );
  }

  Widget _buildTrackerSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _allResults.keys.map((key) {
          final isSelected = key == _selectedTrackerKey;
          final trackerName = _allResults[key]?.first.trackerName ?? key;
          return GestureDetector(
            onTap: () => setState(() => _selectedTrackerKey = key),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF4A7373) : Colors.white,
                border: Border.all(color: const Color(0xFF4A7373)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                trackerName,
                style: GoogleFonts.instrumentSans(
                  color: isSelected ? Colors.white : const Color(0xFF4A7373),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChart(List<TrackerResult> results) {
    if (results.isEmpty) {
      return _buildChartEmptyState();
    }

    final data = results.take(8).toList(); // Last 8 weeks
    final maxScore = data.isNotEmpty ? data.first.maxScore : 40;

    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF8F2),
        border: Border.all(color: const Color(0xFFDDD5C5)),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            horizontalInterval: 10,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: const Color(0xFFDDD5C5), strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < data.length) {
                    return Text(
                      data[index].weekLabel.split('-').last, // W18
                      style: GoogleFonts.instrumentSans(
                        fontSize: 12,
                        color: const Color(0xFF8A8278),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 10,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: GoogleFonts.instrumentSans(
                    fontSize: 12,
                    color: const Color(0xFF8A8278),
                  ),
                ),
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: data.length.toDouble() - 1,
          minY: 0,
          maxY: maxScore.toDouble(),
          lineBarsData: [
            LineChartBarData(
              spots: data
                  .asMap()
                  .entries
                  .map(
                    (e) => FlSpot(e.key.toDouble(), e.value.score.toDouble()),
                  )
                  .toList(),
              isCurved: false,
              color: const Color(0xFF4A7373),
              barWidth: 2.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                      radius: 4,
                      color: const Color(0xFF4A7373),
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) => Colors.white,
              getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
                final index = spot.spotIndex;
                final result = data[index];
                return LineTooltipItem(
                  'Week ${result.weekLabel.split('-').last} · Score ${result.score} / ${result.maxScore} · ${result.band}',
                  GoogleFonts.instrumentSans(
                    color: const Color(0xFF1A1814),
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
          ),
          backgroundColor: Colors.transparent,
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: 9,
                color: const Color(0xFF4A7373).withOpacity(0.1),
                strokeWidth: double.infinity,
              ),
              HorizontalLine(
                y: 17,
                color: const Color(0xFF4A7373).withOpacity(0.2),
                strokeWidth: double.infinity,
              ),
              HorizontalLine(
                y: 25,
                color: const Color(0xFF4A7373).withOpacity(0.3),
                strokeWidth: double.infinity,
              ),
              HorizontalLine(
                y: 32,
                color: const Color(0xFFFFD700).withOpacity(0.3),
                strokeWidth: double.infinity,
              ),
              HorizontalLine(
                y: 40,
                color: const Color(0xFFFF6B6B).withOpacity(0.3),
                strokeWidth: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartEmptyState() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF8F2),
        border: Border.all(color: const Color(0xFFDDD5C5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.show_chart, size: 48, color: const Color(0xFF8A8278)),
          const SizedBox(height: 16),
          Text(
            'No results yet for this tracker.',
            style: GoogleFonts.fraunces(
              fontSize: 24,
              color: const Color(0xFF1A1814),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete the tracker to start building your history.',
            style: GoogleFonts.instrumentSans(
              fontSize: 16,
              color: const Color(0xFF8A8278),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(TrackerResult? latest, TrackerResult? previous) {
    if (latest == null) return const SizedBox.shrink();

    final change = previous != null ? latest.score - previous.score : 0;
    final changeText = _getChangeText(latest, previous);
    final changeColor = _getChangeColor(change);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF8F2),
        border: Border.all(color: const Color(0xFFDDD5C5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${latest.score}',
                style: GoogleFonts.fraunces(
                  fontSize: 64,
                  color: const Color(0xFF4A7373),
                ),
              ),
              Text(
                ' / ${latest.maxScore}',
                style: GoogleFonts.instrumentSans(
                  fontSize: 24,
                  color: const Color(0xFF8A8278),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            latest.band,
            style: GoogleFonts.fraunces(
              fontSize: 24,
              color: const Color(0xFF1A1814),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            changeText,
            style: GoogleFonts.instrumentSans(fontSize: 16, color: changeColor),
          ),
        ],
      ),
    );
  }

  Widget _buildAllResultsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All trackers · Latest scores',
          style: GoogleFonts.fraunces(
            fontSize: 24,
            color: const Color(0xFF1A1814),
          ),
        ),
        const SizedBox(height: 20),
        ..._allResults.entries.map((entry) {
          final latest = entry.value.last;
          return GestureDetector(
            onTap: () => setState(() => _selectedTrackerKey = entry.key),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFBF8F2),
                border: Border.all(color: const Color(0xFFDDD5C5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    latest.trackerName,
                    style: GoogleFonts.instrumentSans(
                      fontSize: 16,
                      color: const Color(0xFF1A1814),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${latest.score} / ${latest.maxScore}',
                        style: GoogleFonts.fraunces(
                          fontSize: 20,
                          color: const Color(0xFF4A7373),
                        ),
                      ),
                      Text(
                        latest.band,
                        style: GoogleFonts.instrumentSans(
                          fontSize: 14,
                          color: const Color(0xFF8A8278),
                        ),
                      ),
                      Text(
                        '${latest.savedAt.month}/${latest.savedAt.day}/${latest.savedAt.year}',
                        style: GoogleFonts.instrumentSans(
                          fontSize: 12,
                          color: const Color(0xFF8A8278),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No results yet',
              style: GoogleFonts.fraunces(
                fontSize: 36,
                color: const Color(0xFF1A1814),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Complete any tracker to start seeing your progress here.',
              style: GoogleFonts.instrumentSans(
                fontSize: 18,
                color: const Color(0xFF8A8278),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF4A7373)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: Text(
                'Go to trackers',
                style: GoogleFonts.instrumentSans(
                  color: const Color(0xFF4A7373),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
