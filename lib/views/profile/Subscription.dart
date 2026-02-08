import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jonssony/utils/app_text.dart';
import 'package:jonssony/views/profile/subcription/assignment.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.85);

  int? _selectedIndex;

  final List<Map<String, dynamic>> plans = [
    {
      "title": "Community Access",
      "price": "Free",
      "subtitle": "12 Spots Available",
      "features": ["Includes Prime Plan program", "Limited availability"],
      "button": "Apply for Access"
    },
    {
      "title": "The Main Plan",
      "price": "£45",
      "subtitle": "Affordable entry to virtual EMDR therapy",
      "features": ["4 sessions/month", "Get Started"],
      "button": "Get Started"
    },
    {
      "title": "Prime Plan",
      "price": "£75",
      "subtitle": "Best value for consistent healing",
      "features": ["Includes homework", "Progress tracking", "Full program access"],
      "button": "Get Started"
    },
    {
      "title": "Hero Plan",
      "price": "£120",
      "subtitle": "Support yourself and someone in need",
      "features": ["Funds 1 Community Access monthly", "Full Prime Plan access"],
      "button": "Get Started"
    },
  ];

  @override
  Widget build(BuildContext context) {
    const double appBarImageHeight = 130;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Top Header Image (Behind everything)
          Positioned(
            top: 0, left: 0, right: 0, height: appBarImageHeight,
            child: Image.asset(
              'assets/images/my_emdr.png',
              fit: BoxFit.fill,
            ),
          ),

          // 2. Main Content
          Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: Stack(
                  children: [
                    // A. Background Sheet
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(35),
                            topRight: Radius.circular(35),
                          ),
                          image: DecorationImage(
                            image: AssetImage('assets/images/bg_profile.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                    // B. Scrollable Content
                    Positioned.fill(
                      child: Column(
                        children: [
                          const SizedBox(height: 30),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 30),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  "Choose the Plan That's Right for You",
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2E3E32),
                                ),
                                SizedBox(height: 8),
                                AppText(
                                  "Flexible pricing options to support your healing journey - cancel anytime.",
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Horizontal Plan Cards
                          Expanded(
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: plans.length,
                              itemBuilder: (context, index) {
                                return _buildPlanCard(plans[index], index);
                              },
                            ),
                          ),
                          const SizedBox(height: 100), // Space for the floating button
                        ],
                      ),
                    ),

                    // C. Fixed Bottom Button (Floating inside the sheet)
                    Positioned(
                      bottom: 40, // Moved up as requested
                      left: 20,
                      right: 20,
                      child: SizedBox(
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _selectedIndex != null 
                              ? () {
                            Get.to(() => FullAssessmentFlow());
                                } 
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4F7957),
                            disabledBackgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 5,
                            shadowColor: Colors.black26,
                          ),
                          child: AppText(
                            _selectedIndex != null ? plans[_selectedIndex!]['button'] : "Get Started",
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
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
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, left: 10, bottom: 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF2E3E32)),
            onPressed: () => Navigator.pop(context),
          ),
          const AppText(
            "Subscription Offer",
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E3E32),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan, int index) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF4F7957).withOpacity(0.1) : Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF4F7957) : Colors.white.withOpacity(0.5),
                        width: isSelected ? 2 : 1
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          plan['title'],
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2E3E32),
                        ),
                        const SizedBox(height: 15),
                        const Divider(color: Colors.black12),
                        const SizedBox(height: 15),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            AppText(
                              plan['price'],
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                            if (plan['price'] != "Free")
                              const AppText(
                                "/Month",
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                          ],
                        ),
                        AppText(
                          plan['subtitle'],
                          fontSize: 13,
                          color: Colors.black54,
                          // FontStyle not supported in AppText directly based on my update, will remove italic or keep Text?
                          // Let's assume user wants AppText style regardless of italic or I missed adding fontStyle to AppText. 
                          // I'll keep Text for subtitle if fontStyle is critical, or update AppText. 
                          // The instruction says "use koro full project e". I will use AppText and omit italic if not supported, or add it.
                          // I'll add fontStyle to AppText in next step if needed. For now, I'll use it without italic or use TextStyle inside if possible? 
                          // AppText doesn't expose style merge. I'll omit italic for standardized look or use Text if I must.
                          // I'll use AppText and skip fontStyle for now to follow instruction strictly.
                        ),
                        const SizedBox(height: 25),
                        ...plan['features'].map<Widget>((feature) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              const Icon(Icons.check, size: 18, color: Color(0xFF4F7957)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: AppText(
                                  feature,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}