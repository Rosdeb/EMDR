import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:jonssony/utils/AppIcons/app_icons.dart';
import 'package:jonssony/utils/app_colors.dart';
import 'package:jonssony/widets/navbar.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  bool isResultsTab = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [

          Positioned(
            top: 0, left: 0, right: 0, height: 170,
            child: Image.asset('assets/images/my_emdr.png', fit: BoxFit.fill),
          ),

          Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: Stack(
                  children: [

                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(35),
                              topRight: Radius.circular(35)
                          ),
                          image: DecorationImage(
                              image: AssetImage('assets/images/bg_progress.jpg'),
                              fit: BoxFit.cover
                          ),
                        ),
                      ),
                    ),

                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 30),
                          _buildPillToggle(),
                          const SizedBox(height: 30),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: isResultsTab ? _buildResultsList() : _buildTestsList(),
                          ),

                          const SizedBox(height: 150),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          CustomNavBar(
            currentIndex: 1,
            onTap: (index) => _handleNavigation(context, index),
            primaryColor: AppColors.mainAppColor,
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, left: 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF2E3E32)),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            "My Progress",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Serif',
                color: Color(0xFF2E3E32)
            ),
          ),
        ],
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    if (index == 1) return; // Already on Progress page

    switch (index) {
      case 0:
        // Go to Home - clear all and go to home
        Navigator.pushNamedAndRemoveUntil(context, '/home_screen', (route) => false);
        break;
      case 2:
        // Navigate to Library - replace current page
        Navigator.pushReplacementNamed(context, '/library');
        break;
      case 3:
        // Navigate to Profile - replace current page
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }


  Widget _buildPillToggle() {
    return Container(
      height: 55,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.35),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          _tabButton("My Tests", !isResultsTab),
          _tabButton("My Results", isResultsTab),
        ],
      ),
    );
  }

  Widget _tabButton(String label, bool active) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => isResultsTab = label == "My Results"),
        child: Container(
          decoration: BoxDecoration(
            color: active ? const Color(0xFF537E5D) : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
                color: active ? Colors.white : Colors.black54,
                fontWeight: FontWeight.bold,
                fontSize: 15
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildTestsList() {
    return Column(
      key: const ValueKey(1),
      children: [
        _testItemCard("PHQ-9 Depression Scale (Session 1)"),
        _testItemCard("GAD-7 Anxiety Scale (Session 2)"),
        _testItemCard("Well-being Assessment"),
      ],
    );
  }

  Widget _testItemCard(String title) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.white,
                radius: 20,
                child: Icon(Icons.description_outlined, color: Colors.black87, size: 20),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
              const Text("Today", style: TextStyle(fontSize: 12, color: Colors.black45)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    return Column(
      key: const ValueKey(2),
      children: [
        _resultGraphCard("Session 2", "March 16, 2026", [1, 4, 3, 5, 2 ]),
        const SizedBox(height: 20),
        _resultGraphCard("Session 1", "March 09, 2026", [1, 4, 3, 5, 2]),
      ],
    );
  }

  Widget _resultGraphCard(String session, String date, List<double> data) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.45),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(session, style: const TextStyle(fontSize: 16, color: Color(0xFF404446 ),fontWeight: FontWeight.bold, fontFamily: 'Serif')),
                  Text(date, style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w500, color: Color(0xFF404446 ))),
                ],
              ),
              const SizedBox(height: 25),

              SizedBox(
                height: 180,
                child: LineChart(_buildChartData(data)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  LineChartData _buildChartData(List<double> data) {
    return LineChartData(
      gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 1,
          getDrawingHorizontalLine: (v) => FlLine(color: Colors.black12, strokeWidth: 1)),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 1, reservedSize: 28,
            getTitlesWidget: (v, m) => Text('${v.toInt()}h', style: const TextStyle(fontSize: 11, color:AppColors.mainAppColor)))),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30,
            getTitlesWidget: (v, m) {
              const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
              return Padding(padding: const EdgeInsets.only(top: 8), child: Text(days[v.toInt()], style: const TextStyle(fontSize: 11, color: AppColors.mainAppColor)));
            })),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: List.generate(data.length, (i) => FlSpot(i.toDouble(), data[i])),
          isCurved: true,
          color: const Color(0xFF537E5D),
          barWidth: 3,
          dotData: FlDotData(show: true, getDotPainter: (s, p, b, i) => i == 3 ? FlDotCirclePainter(radius: 4, color: Colors.white, strokeWidth: 2, strokeColor: const Color(0xFF537E5D)) : FlDotCirclePainter(radius: 0)),
          belowBarData: BarAreaData(show: false),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (spot) => Colors.white,
          getTooltipItems: (spots) => spots.map((s) => LineTooltipItem("3h 14min", const TextStyle(fontWeight: FontWeight.bold, fontSize: 11))).toList(),
        ),
      ),
    );
  }
}