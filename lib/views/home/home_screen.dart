import 'dart:ui';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF537E5D);

    return Scaffold(
      body: Stack(
        children: [
          // ১. মেইন ব্যাকগ্রাউন্ড ইমেজ
          Positioned.fill(
            child: Image.asset(
              'assets/images/home_bg1.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // ২. কন্টেন্ট এরিয়া
          SafeArea(
            child: Column(
              children: [
                // কাস্টম অ্যাপবার উইথ ব্যাকগ্রাউন্ড ইমেজ
                _buildCustomAppBar(),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Quick Access",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 15),

                        // ৩. কুইক অ্যাক্সেস কার্ডস (Glassmorphism)
                        Row(
                          children: [
                            Expanded(child: _buildGlassCard("Calm Space", "Find peace now", Icons.grid_view_rounded)),
                            const SizedBox(width: 15),
                            Expanded(child: _buildGlassCard("My Progress", "Track journey", Icons.show_chart_rounded)),
                          ],
                        ),

                        const SizedBox(height: 25),

                        // ৪. লিস্ট আইটেমস (Glassmorphism)
                        _buildJourneyCard("Anxiety Management Journey", "95/100", primaryGreen),
                        _buildJourneyCard("Anxiety Management Journey", "95/100", primaryGreen),
                        _buildJourneyCard("Anxiety Management Journey", "95/100", primaryGreen),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ৫. ফ্লোটিং বটম নেভিগেশন (Glassmorphism)
          _buildFloatingBottomNav(primaryGreen),
        ],
      ),
    );
  }

  // কাস্টম অ্যাপবার মেথড
  Widget _buildCustomAppBar() {
    return Container(
      height: 80,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/my_emdr.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundImage: AssetImage('assets/images/emdr_sun.jpg'), // প্রোফাইল/লোগো
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Good morning,", style: TextStyle(fontSize: 12, color: Colors.black54)),
                  Text("Shuvo Paul", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const CircleAvatar(
            backgroundColor: Color(0x33000000),
            child: Icon(Icons.notifications_none_rounded, color: Colors.brown),
          )
        ],
      ),
    );
  }

  // Glassmorphism কার্ড বিল্ডার
  Widget _buildGlassCard(String title, String subtitle, IconData icon) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 28, color: Colors.black87),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }

  // বড় জার্নি কার্ড (Glassmorphism)
  Widget _buildJourneyCard(String title, String progress, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.35),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Image.asset('assets/images/emdr_sun.jpg', height: 40, width: 40),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const Text("Something short here", style: TextStyle(fontSize: 11, color: Colors.black54)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: 0.95,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(progress, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    Row(
                      children: const [
                        Icon(Icons.calendar_today, size: 14, color: Colors.black45),
                        SizedBox(width: 4),
                        Text("Text", style: TextStyle(fontSize: 12)),
                        SizedBox(width: 12),
                        Icon(Icons.access_time, size: 14, color: Colors.black45),
                        SizedBox(width: 4),
                        Text("Text", style: TextStyle(fontSize: 12)),
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

  // ফ্লোটিং বটম নেভিগেশন বার
  Widget _buildFloatingBottomNav(Color primaryColor) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _navItem(Icons.home_rounded, "Home", true, primaryColor),
                      _navItem(Icons.explore_outlined, "", false, primaryColor),
                      _navItem(Icons.shopping_basket_outlined, "", false, primaryColor),
                      _navItem(Icons.person_outline_rounded, "", false, primaryColor),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isActive, Color activeColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: isActive ? BoxDecoration(
        color: activeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ) : null,
      child: Row(
        children: [
          Icon(icon, color: isActive ? activeColor : Colors.black54),
          if (isActive) const SizedBox(width: 4),
          if (isActive) Text(label, style: TextStyle(color: activeColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}