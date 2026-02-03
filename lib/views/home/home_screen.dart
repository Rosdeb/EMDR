import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jonssony/utils/AppIcons/app_icons.dart';
import 'package:jonssony/utils/app_colors.dart';
import 'package:jonssony/widets/navbar.dart';
import 'MyCalmSpace.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    const double appBarImageHeight = 170;
    const double overlapAmount = 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: appBarImageHeight,
            child: Image.asset(
              'assets/images/my_emdr.png',
              fit: BoxFit.fill,
            ),
          ),


          Column(
            children: [

              _buildAppBarContent(context),

              Expanded(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [

                    Positioned.fill(
                      top: -overlapAmount,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 15,
                              offset: Offset(0, -5),
                            )
                          ],
                          image: DecorationImage(
                            image: AssetImage('assets/images/home_bg1.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),


                    Positioned.fill(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 35),
                            const Text(
                              "Quick Access",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E3E32),
                                fontFamily: 'Serif',
                              ),
                            ),
                            const SizedBox(height: 20),


                            Row(
                              children: [
                                Expanded(
                                  child: _buildQuickAccessCard(
                                    "Calm Space",
                                    "Find peace now",
                                    AppIcons.calm,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => const MyCalmSpace()),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(child: _buildQuickAccessCard("My Progress", "Track journey", AppIcons.progress)),
                              ],
                            ),

                            const SizedBox(height: 25),


                            _buildJourneyCard("Anxiety Management Journey", "20 sessions", "95/100", AppColors.mainAppColor),
                            _buildJourneyCard("Mindfulness Practice", "15 sessions", "80/100", AppColors.mainAppColor),
                            _buildJourneyCard("Focus Training", "10 sessions", "60/100", AppColors.mainAppColor),

                            const SizedBox(height: 150),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),


          // Custom NavBar
          CustomNavBar(
            currentIndex: 0,
            onTap: (index) => _handleNavigation(context, index),
            primaryColor: AppColors.mainAppColor,
          ),
        ],
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    if (index == 0) return; // Already on Home page
    
    switch (index) {
      case 1:
        Navigator.pushNamed(context, '/progress');
        break;
      case 2:
        Navigator.pushNamed(context, '/library');
        break;
      case 3:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  Widget _buildAppBarContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 5,
        left: 20,
        right: 20,
        bottom: 15,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF81C784), width: 2),
                ),
                child: const CircleAvatar(
                  radius: 25,
                  backgroundImage: AssetImage('assets/images/home_profile.png'),
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Good morning,", style: TextStyle(fontSize: 13, color: Colors.black87)),
                  Text("Shuvo Paul", style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xFF2E3E32), fontFamily: 'Serif')),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFAD8C63),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
            ),
            child: SvgPicture.asset(AppIcons.notification, height: 20, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessCard(String title, String subtitle, String iconPath, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(iconPath, height: 28),
                const SizedBox(height: 15),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Serif')),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJourneyCard(String title, String subTitle, String progress, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.35),
              borderRadius: BorderRadius.circular(35),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundImage: AssetImage('assets/images/emdr_sun.jpg'),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'Serif')),
                          Text(subTitle, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: 0.95,
                    minHeight: 7,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(progress, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                    Row(
                      children: [
                        _iconLabel(Icons.calendar_today_outlined, "Daily"),
                        const SizedBox(width: 15),
                        _iconLabel(Icons.access_time_rounded, "10m"),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconLabel(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF537E5D)),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.black87)),
      ],
    );
  }
}