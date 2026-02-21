import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:jonssony/utils/app_colors.dart';
import 'package:jonssony/utils/app_text.dart';

class ResultStepScreen extends StatelessWidget {
  final String title;

  const ResultStepScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Header image
          Positioned(
            top: 0, left: 0, right: 0, height: 150,
            child: Image.asset('assets/images/my_emdr.png', fit: BoxFit.fill),
          ),

          Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: Stack(
                  children: [
                    // Background
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(35),
                            topRight: Radius.circular(35),
                          ),
                          image: DecorationImage(
                            image: AssetImage('assets/images/bg_progress.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 30),
                          _buildResultStep(context),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 5,
        right: 15,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF2E3E32), size: 22),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: AppText(
              title,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2E3E32),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Score summary card
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText(
                    'Assessment Result',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E3E32),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _scoreBadge('Score', '12/27'),
                      _scoreBadge('Level', 'Moderate'),
                      _scoreBadge('Date', 'Today'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // // Graph card
        // ClipRRect(
        //   borderRadius: BorderRadius.circular(20),
        //   child: BackdropFilter(
        //     filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        //     child: Container(
        //       padding: const EdgeInsets.all(20),
        //       decoration: BoxDecoration(
        //         color: Colors.white.withOpacity(0.5),
        //         borderRadius: BorderRadius.circular(20),
        //         border: Border.all(color: Colors.white.withOpacity(0.3)),
        //       ),
        //       // child: Column(
        //       //   crossAxisAlignment: CrossAxisAlignment.start,
        //       //   children: [
        //       //     const AppText(
        //       //       'Progress Over Time',
        //       //       fontSize: 16,
        //       //       fontWeight: FontWeight.bold,
        //       //       color: Color(0xFF2E3E32),
        //       //     ),
        //       //     // const SizedBox(height: 20),
        //       //     // SizedBox(
        //       //     //   height: 200,
        //       //     //   child: LineChart(_buildChartData([2, 4, 3, 5, 3, 4, 2])),
        //       //     // ),
        //       //   ],
        //       // ),
        //     ),
        //   ),
        // ),

        const SizedBox(height: 20),

        // Interpretation card
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText(
                    'What This Means',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E3E32),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Your score indicates a moderate level. It is recommended to continue with your current therapy sessions and monitor your progress over the coming weeks.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _recommendationTile(Icons.self_improvement, 'Continue EMDR sessions'),
                  _recommendationTile(Icons.bedtime, 'Maintain healthy sleep routine'),
                  _recommendationTile(Icons.favorite_border, 'Practice daily mindfulness'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _scoreBadge(String label, String value) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF537E5D).withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF537E5D).withOpacity(0.3)),
          ),
          child: AppText(value, fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF537E5D)),
        ),
        const SizedBox(height: 6),
        AppText(label, fontSize: 12, color: Colors.black45),
      ],
    );
  }

  Widget _recommendationTile(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF537E5D)),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 13, color: Colors.black87)),
        ],
      ),
    );
  }

  // LineChartData _buildChartData(List<double> data) {
  //   return LineChartData(
  //     gridData: FlGridData(
  //       show: true,
  //       getDrawingHorizontalLine: (v) => FlLine(color: Colors.black12, strokeWidth: 1),
  //       getDrawingVerticalLine: (v) => FlLine(color: Colors.black12, strokeWidth: 1),
  //     ),
  //     titlesData: FlTitlesData(
  //       rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
  //       topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
  //       leftTitles: AxisTitles(
  //         sideTitles: SideTitles(
  //           showTitles: true,
  //           interval: 1,
  //           reservedSize: 28,
  //           getTitlesWidget: (v, m) =>
  //               AppText('${v.toInt()}', fontSize: 11, color: AppColors.mainAppColor),
  //         ),
  //       ),
  //       bottomTitles: AxisTitles(
  //         sideTitles: SideTitles(
  //           showTitles: true,
  //           reservedSize: 28,
  //           getTitlesWidget: (v, m) {
  //             const labels = ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7'];
  //             final index = v.toInt();
  //             if (index < 0 || index >= labels.length) return const SizedBox.shrink();
  //             return Padding(
  //               padding: const EdgeInsets.only(top: 6),
  //               child: AppText(labels[index], fontSize: 11, color: AppColors.mainAppColor),
  //             );
  //           },
  //         ),
  //       ),
  //     ),
  //     // borderData: FlBorderData(
  //     //   show: true,
  //     //   border: const Border(
  //     //     bottom: BorderSide(color: Colors.black12, width: 1),
  //     //     left: BorderSide(color: Colors.black12, width: 1),
  //     //   ),
  //     // ),
  //     // lineBarsData: [
  //     //   LineChartBarData(
  //     //     spots: List.generate(data.length, (i) => FlSpot(i.toDouble(), data[i])),
  //     //     isCurved: true,
  //     //     color: const Color(0xFF537E5D),
  //     //     barWidth: 3,
  //     //     dotData: const FlDotData(show: true),
  //     //     belowBarData: BarAreaData(
  //     //       show: true,
  //     //       color: const Color(0xFF537E5D).withOpacity(0.1),
  //     //     ),
  //     //   ),
  //     // ],
  //   );
  // }
}
