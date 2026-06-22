import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../controller/journey_controller.dart';
import '../../controller/notification_controller.dart';
import '../../controller/profile_controller.dart';
import '../../controller/session_progress_controller.dart';
import '../../healper/route.dart';
import '../../services/session_completion_service.dart';
import '../../utils/AppIcons/app_icons.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text.dart';
import '../sessions/SessionFourPage.dart' hide AppText;
import '../sessions/session_five.dart';
import '../sessions/session_one.dart';
import '../sessions/session_seven.dart';
import '../sessions/session_six.dart';
import '../sessions/session_three.dart';
import '../sessions/session_two.dart';
import 'MyCalmSpace.dart';
import 'homework.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String _firstLoginIntroSeenKey = 'first_login_intro_seen';
  final GetStorage _storage = GetStorage();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showFirstLoginIntro();
    });
  }

  void _showFirstLoginIntro() {
    if (!mounted || _storage.read<bool>(_firstLoginIntroSeenKey) == true) {
      return;
    }

    _storage.write(_firstLoginIntroSeenKey, true);
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Start your EMDR roadmap'),
        content: const Text(
          'To begin your EMDR journey, tap the + button and create your roadmap. Then follow each session from My Space in order.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Got it')),
        ],
      ),
      barrierDismissible: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    Get.put(ProfileController());
    Get.put(NotificationController());
    final journeyController = Get.isRegistered<JourneyController>()
        ? Get.find<JourneyController>()
        : Get.put(JourneyController());
    final sessionProgressController =
        Get.isRegistered<SessionProgressController>()
        ? Get.find<SessionProgressController>()
        : Get.put(SessionProgressController());
    SessionCompletionService.syncFromStorage();

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
            child: Image.asset('assets/images/my_emdr.png', fit: BoxFit.fill),
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
                            ),
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
                            const AppText(
                              "My Space",
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E3E32),
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
                                          builder: (context) =>
                                              const MyCalmSpace(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: _buildQuickAccessCard(
                                    "My Homework",
                                    "Prime+",
                                    AppIcons.homework,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const MyHomework(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 25),

                            Obx(() {
                              if (journeyController.isLoading.value) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.mainAppColor,
                                  ),
                                );
                              }

                              final journeys = journeyController.journeys;
                              sessionProgressController.progressRevision.value;
                              if (journeys.isEmpty) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    child: AppText(
                                      "No journeys found",
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                );
                              }

                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                sessionProgressController
                                    .fetchProgressForJourneys(journeys);
                              });

                              return Column(
                                children: journeys.map((journey) {
                                  final item = journey is Map
                                      ? Map<String, dynamic>.from(journey)
                                      : <String, dynamic>{};
                                  final journeyId = _journeyIdFrom(item);
                                  final progressData = sessionProgressController
                                      .journeyProgresses[journeyId];
                                  final details =
                                      progressData?['details'] is Map
                                      ? Map<String, dynamic>.from(
                                          progressData!['details'] as Map,
                                        )
                                      : <String, dynamic>{};
                                  final totalFromApi = _firstInt([
                                    details['totalSession'],
                                    details['totalSessions'],
                                    details['total'],
                                    progressData?['totalSession'],
                                    progressData?['totalSessions'],
                                    progressData?['total'],
                                    item['totalSession'],
                                    item['totalSessions'],
                                    item['total'],
                                  ]);
                                  final total = totalFromApi > 0
                                      ? totalFromApi
                                      : SessionCompletionService.totalSessions;
                                  final localCompletedSessions =
                                      SessionCompletionService.completedSessions(
                                        journeyId: journeyId,
                                      );
                                  final apiCompleted = _firstSessionCount([
                                    details['compledSession'],
                                    details['compledSessions'],
                                    details['totalCompledSession'],
                                    details['totalCompletedSession'],
                                    details['totalCompletedSessions'],
                                    details['completedSessionCount'],
                                    details['completedSessions'],
                                    details['completedSession'],
                                    details['completed'],
                                    progressData?['compledSession'],
                                    progressData?['compledSessions'],
                                    progressData?['totalCompledSession'],
                                    progressData?['totalCompletedSession'],
                                    progressData?['totalCompletedSessions'],
                                    progressData?['completedSessionCount'],
                                    progressData?['completedSessions'],
                                    progressData?['completedSession'],
                                    progressData?['completed'],
                                    item['compledSession'],
                                    item['compledSessions'],
                                    item['totalCompledSession'],
                                    item['totalCompletedSession'],
                                    item['totalCompletedSessions'],
                                    item['completedSessionCount'],
                                    item['completedSessions'],
                                    item['completedSession'],
                                    item['completed'],
                                  ], total);
                                  final localCompleted = localCompletedSessions
                                      .length
                                      .clamp(0, total)
                                      .toInt();
                                  final apiPercent = _firstPercent([
                                    progressData?['totalCompledSession'],
                                    progressData?['totalCompletedSession'],
                                    progressData?['totalCompletedSessions'],
                                    progressData?['completionPercentage'],
                                    progressData?['completedPercentage'],
                                    progressData?['percentage'],
                                    progressData?['percent'],
                                    details['totalCompledSession'],
                                    details['totalCompletedSession'],
                                    details['totalCompletedSessions'],
                                    details['completionPercentage'],
                                    details['completedPercentage'],
                                    details['percentage'],
                                    details['percent'],
                                  ]);
                                  final completedFromPercent =
                                      apiPercent == null
                                      ? 0
                                      : (apiPercent * total)
                                            .round()
                                            .clamp(0, total)
                                            .toInt();
                                  final completed = math.max(
                                    math.max(apiCompleted, localCompleted),
                                    completedFromPercent,
                                  );
                                  final countPercent = total > 0
                                      ? completed / total
                                      : 0.0;
                                  final percent = math
                                      .max(apiPercent ?? 0.0, countPercent)
                                      .clamp(0.0, 1.0)
                                      .toDouble();
                                  final percentText =
                                      "${(percent * 100).round()}%";
                                  if (kDebugMode) {
                                    debugPrint(
                                      'JourneyCard journeyId=$journeyId '
                                      'progressData=$progressData '
                                      'details=$details '
                                      'completed=$completed total=$total '
                                      'percent=$percentText',
                                    );
                                  }
                                  final nextSessionNumber = _nextSessionNumber(
                                    completed: completed,
                                    apiCompleted: apiCompleted,
                                    localCompletedSessions:
                                        localCompletedSessions,
                                  );
                                  final journeyTitle =
                                      item['journeyName']?.toString() ??
                                      'EMDR Journey';

                                  return _buildJourneyCard(
                                    journeyTitle,
                                    "$total sessions",
                                    "$completed/$total completed ($percentText)",
                                    percent,
                                    AppColors.mainAppColor,
                                    imageUrl: item['imageUrl']?.toString(),
                                    dateText: _formatApiDate(item['createdAt']),
                                    onTap: () {
                                      _openSession(
                                        nextSessionNumber,
                                        journeyId: journeyId,
                                        journeyTitle: journeyTitle,
                                      );
                                    },
                                  );
                                }).toList(),
                              );
                            }),

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
        ],
      ),
    );
  }

  Widget _buildAppBarContent(BuildContext context) {
    final profileController = Get.find<ProfileController>();
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 5,
        left: 20,
        right: 10,
        bottom: 15,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Obx(() {
              final profile = profileController.userProfile;
              final name = profile['fullName']?.toString() ?? 'User';
              final avatarUrl = profile['avatar']?.toString();
              final hour = DateTime.now().hour;
              final greeting = hour < 12
                  ? 'Good morning,'
                  : (hour < 17 ? 'Good afternoon,' : 'Good evening,');

              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF81C784),
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                          ? NetworkImage(avatarUrl) as ImageProvider
                          : const AssetImage('assets/images/home_profile.png'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppText(
                          greeting,
                          fontSize: 13,
                          color: Colors.black87,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        AppText(
                          name,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2E3E32),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
          // ─── Notification Bell with Badge & Feedback ──────────
          Obx(() {
            final notifController = Get.find<NotificationController>();
            final unread = notifController.unreadCount;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  notifController.reloadFromStorage();

                  Get.toNamed(RouteHelper.notifications);

                  Future.delayed(const Duration(milliseconds: 500), () {
                    notifController.markAllAsRead();
                  });
                },
                borderRadius: BorderRadius.circular(30),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFAD8C63),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 5),
                          ],
                        ),
                        child: SvgPicture.asset(
                          AppIcons.notification,
                          height: 16,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      if (unread > 0)
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFE53935),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black26, blurRadius: 4),
                              ],
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              unread > 99 ? '99+' : '$unread',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuickAccessCard(
    String title,
    String subtitle,
    String iconPath, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            height: 132,
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.80),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.48),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.22),
                  blurRadius: 8,
                  offset: const Offset(-2, -2),
                ),
              ],
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(iconPath, height: 28),
                const SizedBox(height: 15),
                AppText(
                  title,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                AppText(
                  subtitle,
                  fontSize: 13,
                  color: AppColors.mainAppColor,
                  fontWeight: FontWeight.w600,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is Iterable) return value.length;

    final rawText = value?.toString().trim() ?? '';
    if (rawText.isEmpty) return 0;

    final countText = rawText.split('/').first.replaceAll('%', '').trim();
    final parsed = num.tryParse(countText);
    return parsed?.toInt() ?? 0;
  }

  String _journeyIdFrom(Map<String, dynamic> item) {
    for (final key in ['_id', 'id', 'journeyId']) {
      final value = _idValue(item[key]);
      if (value.isNotEmpty) return value;
    }

    return '';
  }

  String _idValue(dynamic value) {
    if (value == null) return '';

    if (value is Map) {
      for (final key in [r'$oid', 'oid', '_id', 'id']) {
        final nested = _idValue(value[key]);
        if (nested.isNotEmpty) return nested;
      }
      return '';
    }

    final text = value.toString();
    if (text.isEmpty || text == 'null') return '';

    return text;
  }

  int _firstInt(Iterable<dynamic> values) {
    for (final value in values) {
      final parsed = _asInt(value);
      if (parsed > 0) return parsed;
    }
    return 0;
  }

  int _firstSessionCount(Iterable<dynamic> values, int total) {
    for (final value in values) {
      if (value == null) continue;
      if (value is String && value.contains('%')) continue;
      final parsed = _asInt(value);
      if (parsed > 0 && parsed <= total) return parsed;
    }
    return 0;
  }

  double? _firstPercent(Iterable<dynamic> values) {
    for (final value in values) {
      final parsed = _asPercentFraction(value);
      if (parsed != null) return parsed;
    }
    return null;
  }

  double? _asPercentFraction(dynamic value) {
    if (value == null) return null;

    final rawText = value.toString().trim();
    if (rawText.isEmpty) return null;

    final hasPercentSymbol = rawText.contains('%');
    final numericText = rawText.replaceAll('%', '').trim();
    final parsed = double.tryParse(numericText);
    if (parsed == null) return null;

    final fraction = hasPercentSymbol || parsed > 1 ? parsed / 100 : parsed;
    return fraction.clamp(0.0, 1.0).toDouble();
  }

  int _nextSessionNumber({
    required int completed,
    required int apiCompleted,
    required List<int> localCompletedSessions,
  }) {
    const lastTrackedSession = SessionCompletionService.totalSessions;

    if (localCompletedSessions.isNotEmpty &&
        localCompletedSessions.length >= apiCompleted) {
      for (var session = 1; session <= lastTrackedSession; session++) {
        if (!localCompletedSessions.contains(session)) {
          return session;
        }
      }
      return lastTrackedSession + 1;
    }

    return (completed + 1).clamp(1, lastTrackedSession + 1).toInt();
  }

  void _openSession(
    int sessionNumber, {
    required String journeyId,
    required String journeyTitle,
  }) {
    SessionCompletionService.setActiveJourney(journeyId);
    final arguments = {
      'journeyId': journeyId,
      'title': journeyTitle,
      'sessionNumber': sessionNumber,
    };

    switch (sessionNumber) {
      case 1:
        Get.to(
          () => SessionOne(journeyId: journeyId, journeyTitle: journeyTitle),
          arguments: arguments,
        );
        break;
      case 2:
        Get.to(() => const CBTFormulationPage(), arguments: arguments);
        break;
      case 3:
        Get.to(() => const SessionThreePage(), arguments: arguments);
        break;
      case 4:
        Get.to(() => const Sessionfourpage(), arguments: arguments);
        break;
      case 5:
        Get.to(() => const SessionFive(), arguments: arguments);
        break;
      case 6:
        Get.to(() => const SessionSix(), arguments: arguments);
        break;
      default:
        Get.to(() => const SessionSix(), arguments: arguments);
    }
  }

  String _formatApiDate(dynamic value) {
    final parsed = DateTime.tryParse(value?.toString() ?? '');
    if (parsed == null) return '';

    final local = parsed.toLocal();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return "${months[local.month - 1]} ${local.day}, ${local.year}";
  }

  Widget _buildJourneyCard(
    String title,
    String subTitle,
    String progress,
    double percent,
    Color color, {
    String? imageUrl,
    String dateText = '',
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(35),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(35),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),

                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage:
                              imageUrl != null && imageUrl.isNotEmpty
                              ? NetworkImage(imageUrl) as ImageProvider
                              : const AssetImage('assets/images/emdr_sun.jpg'),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                title,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              AppText(
                                subTitle,
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: percent,
                        minHeight: 7,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),

                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppText(
                          progress,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        Row(
                          children: [
                            if (dateText.isNotEmpty)
                              _iconLabel(
                                Icons.calendar_today_outlined,
                                dateText,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
        AppText(label, fontSize: 13, color: Colors.black87),
      ],
    );
  }
}
