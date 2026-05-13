import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jonssony/controller/subscription_controller.dart';
import 'package:jonssony/utils/app_text.dart';
import 'package:jonssony/views/profile/subcription/EMDRConsentForm.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  final SubscriptionController _controller = Get.put(SubscriptionController());

  int? _selectedIndex;

  // Static plans removed, data now comes from SubscriptionController

  @override
  Widget build(BuildContext context) {
    const double appBarImageHeight = 130;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Top Header Image (Behind everything)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: appBarImageHeight,
            child: Image.asset('assets/images/my_emdr.png', fit: BoxFit.fill),
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
                                  color: Color(0xFF2E3E32),
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
                            child: Obx(() {
                              if (_controller.isLoadingPlans.value) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF4F7957),
                                  ),
                                );
                              }

                              if (_controller.plans.isEmpty) {
                                return const Center(
                                  child: AppText("No plans available."),
                                );
                              }

                              return PageView.builder(
                                controller: _pageController,
                                itemCount: _controller.plans.length,
                                itemBuilder: (context, index) {
                                  return _buildPlanCard(
                                    _controller.plans[index],
                                    index,
                                  );
                                },
                              );
                            }),
                          ),
                          const SizedBox(
                            height: 100,
                          ), // Space for the floating button
                        ],
                      ),
                    ),

                    // C. Fixed Bottom Button (Floating inside the sheet)
                    Positioned(
                      bottom: 40, // Moved up as requested
                      left: 20,
                      right: 20,
                      child: Obx(() {
                        String buttonText = "Get Started";
                        bool isFree = false;
                        bool isCurrentPlan = false;

                        if (_selectedIndex != null &&
                            _selectedIndex! < _controller.plans.length) {
                          final selectedPlan =
                              _controller.plans[_selectedIndex!];
                          isFree =
                              selectedPlan['price'] == 0 ||
                              selectedPlan['price'] == "0" ||
                              selectedPlan['price'].toString().toLowerCase() ==
                                  "free";

                          // Check if this plan matches the user's active subscription
                          if (_controller.mySubscription.isNotEmpty) {
                            final activePlan =
                                _controller.mySubscription['plan'];
                            final activePlanId =
                                _controller.mySubscription['planId'];
                            final planId = selectedPlan['_id'];

                            if (planId != null &&
                                (activePlan?['_id'] == planId ||
                                    activePlanId == planId ||
                                    _controller.mySubscription['_id'] ==
                                        planId)) {
                              isCurrentPlan = true;
                            }
                          }

                          if (isCurrentPlan) {
                            buttonText = "Current Plan";
                          } else {
                            buttonText = isFree
                                ? "Apply for Access"
                                : "Subscribe Now";
                          }
                        }

                        return SizedBox(
                          height: 55,
                          child: ElevatedButton(
                            onPressed:
                                (_selectedIndex != null &&
                                    !_controller.isSubscribing.value &&
                                    !isCurrentPlan)
                                ? () => _handleSubscriptionAction()
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4F7957),
                              disabledBackgroundColor: Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 5,
                              shadowColor: Colors.black26,
                            ),
                            child: _controller.isSubscribing.value
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : AppText(
                                    buttonText,
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                          ),
                        );
                      }),
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

  void _handleSubscriptionAction() {
    if (_selectedIndex == null || _selectedIndex! >= _controller.plans.length) {
      return;
    }

    final selectedPlan = _controller.plans[_selectedIndex!];

    if (selectedPlan['name']?.toString().toLowerCase().contains('hero') ==
        true) {
      _showHeroPlanConfirmation(selectedPlan);
    } else {
      _controller.selectedPlanForCheckout.value = selectedPlan;
      Get.to(() => const ConsentFormScreen());
    }
  }

  void _showHeroPlanConfirmation(Map<String, dynamic> plan) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const AppText(
            "Confirm Subscription",
            fontWeight: FontWeight.bold,
          ),
          content: AppText(
            "You are about to subscribe to the ${plan['name']} for ${plan['currency'] ?? '£'}${plan['price']}/month. Do you wish to proceed?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const AppText("Cancel", color: Colors.grey),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _controller.selectedPlanForCheckout.value = plan;
                Get.to(() => const ConsentFormScreen());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F7957),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const AppText("Confirm", color: Colors.white),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 10,
        bottom: 10,
      ),
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
    final String name = plan['name'] ?? "Unknown Plan";
    final String tagline = plan['tagline'] ?? "";
    final List<dynamic> features = plan['features'] ?? [];

    // Formatting price
    final dynamic rawPrice = plan['price'];
    final String currency = plan['currency'] ?? "£";
    String priceDisplay = "Community Access";
    bool isFree = false;

    if (rawPrice == 0 ||
        rawPrice == "0" ||
        rawPrice.toString().toLowerCase() == "free") {
      isFree = true;
    } else {
      priceDisplay = "$currency$rawPrice";
    }

    bool isCurrentPlan = false;
    if (_controller.mySubscription.isNotEmpty) {
      final activePlan = _controller.mySubscription['plan'];
      final activePlanId = _controller.mySubscription['planId'];
      final planId = plan['_id'];

      if (planId != null &&
          (activePlan?['_id'] == planId ||
              activePlanId == planId ||
              _controller.mySubscription['_id'] == planId)) {
        isCurrentPlan = true;
      }
    }

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
                      color: isSelected
                          ? const Color(0xFF4F7957).withOpacity(0.1)
                          : Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF4F7957)
                            : Colors.white.withOpacity(0.5),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: AppText(
                                name,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2E3E32),
                              ),
                            ),
                            if (isCurrentPlan)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4F7957),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const AppText(
                                  "Active",
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        const Divider(color: Colors.black12),
                        const SizedBox(height: 15),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            AppText(
                              priceDisplay,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                            if (!isFree)
                              const AppText(
                                "/Month",
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                          ],
                        ),
                        AppText(tagline, fontSize: 13, color: Colors.black54),
                        const SizedBox(height: 25),
                        ...features.map<Widget>(
                          (feature) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check,
                                  size: 18,
                                  color: Color(0xFF4F7957),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: AppText(
                                    feature.toString(),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
