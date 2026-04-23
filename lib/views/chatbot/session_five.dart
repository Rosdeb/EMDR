
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/images/chatbot_bg.jpg', fit: BoxFit.cover)),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                _buildTabButtons(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildGraphCard("Session 2", "March 16, 2026"),
                      const SizedBox(height: 20),
                      _buildGraphCard("Session 1", "March 16, 2026"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraphCard(String title, String date) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text(date, style: const TextStyle(color: Colors.black54)),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 150,
                child: LineChart(_sampleData()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          const BackButton(),
          const SizedBox(width: 10),
          const Text("Progress", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTabButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5D7E5D),
              foregroundColor: Colors.white,
            ),
            child: const Text("My Tests"),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
            ),
            child: const Text("My Results"),
          ),
        ],
      ),
    );
  }

  LineChartData _sampleData() {
    return LineChartData(
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 1),
            FlSpot(1, 3),
            FlSpot(2, 2),
            FlSpot(3, 5),
            FlSpot(4, 4),
          ],
          isCurved: true,
          color: const Color(0xFF537E5D),
          barWidth: 3,
          belowBarData: BarAreaData(
            show: true,
            color: const Color(0xFF537E5D).withOpacity(0.2),
          ),
        ),
      ],
    );
  }
}