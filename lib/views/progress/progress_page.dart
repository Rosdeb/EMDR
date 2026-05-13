import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';

import 'package:jonssony/utils/app_colors.dart';

import 'package:jonssony/utils/app_text.dart';

import 'package:jonssony/controller/auth_controller.dart';
import 'package:jonssony/controller/my_tests_controller.dart';
import 'package:jonssony/services/questionnaire_service.dart';
import 'package:jonssony/services/symptom_tracker_service.dart';
import 'package:jonssony/services/tracker_storage_service.dart';
import 'package:jonssony/views/progress/category_items_screen.dart';
import 'package:jonssony/views/progress/local_assessment_screen.dart';
import 'package:jonssony/views/progress/symptom_tracker_screen.dart';
import 'package:get/get.dart';
import 'result_step_screen.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressChartPoint {
  final double score;
  final DateTime? date;

  const _ProgressChartPoint({required this.score, this.date});
}

class _ProgressPageState extends State<ProgressPage> {
  bool isResultsTab = false;
  String? _selectedResultTrackerTitle;
  final Map<String, Map<String, dynamic>> _testResults = {};
  final Map<String, Map<String, dynamic>> _latestTrackerResults = {};
  final Map<String, List<dynamic>> _trackerTrends = {};
  final Map<String, List<dynamic>> _questionnaireSubmissions = {};
  Map<String, List<TrackerResult>> _storedTrackerResults = {};
  List<Map<String, dynamic>> _trackerConfigs = [];
  bool _isTrackerLoading = false;
  String? _trackerError;

  static final List<LocalAssessmentConfig> _localAssessmentConfigs = [
    LocalAssessmentConfig(
      title: 'PHQ-9',
      trackerType: 'phq9',
      description:
          'Over the last 2 weeks, how often have you been bothered by the following problems?',
      questions: const [
        'Little interest or pleasure in doing things',
        'Feeling down, depressed, or hopeless',
        'Trouble falling or staying asleep, or sleeping too much',
        'Feeling tired or having little energy',
        'Poor appetite or overeating',
        'Feeling bad about yourself or that you are a failure',
        'Trouble concentrating on things, such as reading or watching TV',
        'Moving or speaking so slowly that other people could have noticed, or being so fidgety/restless that you moved around more than usual',
        'Thoughts that you would be better off dead, or of hurting yourself',
      ],
      optionLabels: const [
        'Not at all',
        'Several days',
        'More than half the days',
        'Nearly every day',
      ],
      maxOptionValue: 3,
      usePercentageSlider: false,
      maxScore: 27,
      bandForScore: _phqBand,
    ),
    LocalAssessmentConfig(
      title: 'GAD-7',
      trackerType: 'gad7',
      description:
          'Over the last 2 weeks, how often have you been bothered by the following problems?',
      questions: const [
        'Feeling nervous, anxious or on edge',
        'Not being able to stop or control worrying',
        'Worrying too much about different things',
        'Trouble relaxing',
        'Being so restless that it is hard to sit still',
        'Becoming easily annoyed or irritable',
        'Feeling afraid as if something awful might happen',
      ],
      optionLabels: const [
        'Not at all',
        'Several days',
        'More than half the days',
        'Nearly every day',
      ],
      maxOptionValue: 3,
      usePercentageSlider: false,
      maxScore: 21,
      bandForScore: _gadBand,
    ),
    LocalAssessmentConfig(
      title: 'DES-11',
      trackerType: 'des11',
      description:
          'Indicate what percentage of the time each experience happens to you.',
      questions: const [
        "Driving or riding in a car and realizing you do not remember part of the trip.",
        'Realizing you did not hear part or all of what was said during a conversation.',
        'Finding yourself in a place and having no idea how you got there.',
        "Finding yourself dressed in clothes that you do not remember putting on.",
        "Finding new things among your belongings that you do not remember buying.",
        'Being approached by people you do not know who call you by another name.',
        'Feeling as though you are standing next to yourself or watching yourself do something.',
        "Finding that you sometimes do not recognize friends or family members.",
      ],
      optionLabels: const [],
      maxOptionValue: 100,
      usePercentageSlider: true,
      maxScore: 100,
      bandForScore: _desBand,
    ),
  ];

  final List<Map<String, dynamic>> _trackers = [
    {
      'name': 'Anxiety',
      'trackerType': 'anxiety',
      'image': 'assets/images/stress.jpg',
    },
    {
      'name': 'Anger',
      'trackerType': 'anger',
      'image': 'assets/images/anger.jpg',
    },
    {
      'name': 'Addiction',
      'trackerType': 'addiction',
      'image': 'assets/images/addiction.jpg',
    },
    {
      'name': 'Depression',
      'trackerType': 'depression',
      'image': 'assets/images/depression.jpg',
    },
    {'name': 'OCD', 'trackerType': 'ocd', 'image': 'assets/images/ocd.jpg'},
    {'name': 'Pain', 'trackerType': 'pain', 'image': 'assets/images/fire.jpg'},
    {
      'name': 'Self-Esteem',
      'trackerType': 'self-esteem',
      'image': 'assets/images/selfesteem.jpg',
    },
    {
      'name': 'Social Phobia',
      'trackerType': 'social-phobia',
      'image': 'assets/images/Phobia questionnaire.jpg',
    },
    {
      'name': 'Specific Phobia',
      'trackerType': 'specific-phobia',
      'image': 'assets/images/Phobia questionnaire.jpg',
    },
    {
      'name': 'Stress & Burnout',
      'trackerType': 'stress-burnout',
      'image': 'assets/images/burnout.jpg',
    },
    {
      'name': 'Trauma',
      'trackerType': 'trauma',
      'image': 'assets/images/trauma.jpg',
    },
    {
      'name': 'Worry',
      'trackerType': 'worry',
      'image': 'assets/images/worry.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    final controller = Get.find<MyTestsController>();
    controller.fetchCategories();
    _loadBackendTrackers();
    _loadQuestionnaireResults();
    _loadTrackerResults();
  }

  String _trackerKeyForTitle(String title) =>
      title.toLowerCase().replaceAll(' & ', '-').replaceAll(' ', '-');

  static String _phqBand(int score) {
    if (score <= 4) return 'Minimal';
    if (score <= 9) return 'Mild';
    if (score <= 14) return 'Moderate';
    if (score <= 19) return 'Moderately Severe';
    return 'Severe';
  }

  static String _gadBand(int score) {
    if (score <= 4) return 'Minimal';
    if (score <= 9) return 'Mild';
    if (score <= 14) return 'Moderate';
    return 'Severe';
  }

  static String _desBand(int score) {
    if (score >= 30) return 'Consultation Advised';
    return 'Normal Range';
  }

  bool _isLocalAssessmentType(String trackerType) {
    return _localAssessmentConfigs.any(
      (config) => config.trackerType == trackerType,
    );
  }

  LocalAssessmentConfig? _localAssessmentConfig(String trackerType) {
    for (final config in _localAssessmentConfigs) {
      if (config.trackerType == trackerType) return config;
    }
    return null;
  }

  Map<String, dynamic>? _latestQuestionnaireSubmission(String trackerType) {
    final submissions = _questionnaireSubmissions[trackerType];
    if (submissions == null || submissions.isEmpty) return null;
    final first = submissions.first;
    if (first is Map) return Map<String, dynamic>.from(first);
    return null;
  }

  String _questionnaireBandLabel(
    String trackerType,
    Map<String, dynamic> submission,
  ) {
    final severity = submission['severity']?.toString();
    if (severity != null && severity.isNotEmpty && severity != 'null') {
      return severity
          .split(RegExp(r'[\s_-]+'))
          .where((part) => part.isNotEmpty)
          .map(
            (part) => part[0].toUpperCase() + part.substring(1).toLowerCase(),
          )
          .join(' ');
    }

    final score = (submission['score'] as num?)?.round() ?? 0;
    return _localAssessmentConfig(trackerType)?.bandForScore(score) ?? '-';
  }

  Future<void> _loadTrackerResults() async {
    final results = await TrackerStorageService.instance.getAllResults();
    if (!mounted) return;
    setState(() {
      _storedTrackerResults = results;
    });
  }

  Future<void> _loadQuestionnaireResults() async {
    final token = Get.find<AuthController>().token;
    if (token == null || token.isEmpty) return;

    final next = <String, List<dynamic>>{};
    for (final config in _localAssessmentConfigs) {
      final result = await QuestionnaireService.getAll(
        token: token,
        type: config.trackerType,
      );
      if (result['success'] == true && result['data'] is Map) {
        final data = Map<String, dynamic>.from(result['data'] as Map);
        final submissions = data['submissions'];
        if (submissions is List) {
          next[config.trackerType] = List<dynamic>.from(submissions);
        }
      }
    }

    if (!mounted) return;
    setState(() {
      _questionnaireSubmissions
        ..clear()
        ..addAll(next);
    });
  }

  List<Map<String, dynamic>> get _visibleTrackers {
    final visible = _trackerConfigs.map((config) {
      final trackerType = config['trackerType']?.toString() ?? '';
      return <String, dynamic>{
        'name': config['name']?.toString() ?? trackerType,
        'trackerType': trackerType,
        'image': _imageForTracker(trackerType),
        'config': config,
      };
    }).toList();

    for (final tracker in _trackers) {
      final trackerType = tracker['trackerType']?.toString();
      final exists = visible.any(
        (item) => item['trackerType']?.toString() == trackerType,
      );
      if (!exists) {
        visible.add(Map<String, dynamic>.from(tracker));
      }
    }

    for (final config in _localAssessmentConfigs) {
      final exists = visible.any(
        (tracker) => tracker['trackerType']?.toString() == config.trackerType,
      );
      if (!exists) {
        visible.add({
          'name': config.title,
          'trackerType': config.trackerType,
          'image': _imageForTracker(config.trackerType),
        });
      }
    }

    return visible;
  }

  String _imageForTracker(String trackerType) {
    const images = {
      'anxiety': 'assets/images/stress.jpg',
      'anger': 'assets/images/anger.jpg',
      'addiction': 'assets/images/addiction.jpg',
      'depression': 'assets/images/depression.jpg',
      'ocd': 'assets/images/ocd.jpg',
      'pain': 'assets/images/fire.jpg',
      'self-esteem': 'assets/images/selfesteem.jpg',
      'social-phobia': 'assets/images/Phobia questionnaire.jpg',
      'specific-phobia': 'assets/images/Phobia questionnaire.jpg',
      'stress-burnout': 'assets/images/burnout.jpg',
      'trauma': 'assets/images/trauma.jpg',
      'worry': 'assets/images/worry.jpg',
      'phq9': 'assets/images/depression.jpg',
      'gad7': 'assets/images/stress.jpg',
      'des11': 'assets/images/trauma.jpg',
    };
    return images[trackerType] ?? 'assets/images/bg_progress.jpg';
  }

  Future<void> _loadBackendTrackers() async {
    final token = Get.find<AuthController>().token;
    if (token == null || token.isEmpty) return;

    setState(() {
      _isTrackerLoading = true;
      _trackerError = null;
    });

    final configsResult = await SymptomTrackerService.getConfigs(token);
    if (!mounted) return;

    if (configsResult['success'] == true && configsResult['data'] is List) {
      final configs = List<Map<String, dynamic>>.from(
        (configsResult['data'] as List).map(
          (item) => Map<String, dynamic>.from(item as Map),
        ),
      );
      setState(() {
        _trackerConfigs = configs;
      });
      await _loadLatestAndTrends(configs);
    } else {
      setState(() {
        _trackerError = configsResult['message'] ?? 'Failed to load trackers';
      });
    }

    if (mounted) {
      setState(() => _isTrackerLoading = false);
    }
  }

  Future<void> _loadLatestAndTrends(List<Map<String, dynamic>> configs) async {
    final token = Get.find<AuthController>().token;
    if (token == null || token.isEmpty) return;

    final latestResult = await SymptomTrackerService.getLatest(token);
    if (mounted && latestResult['success'] == true) {
      final latestData = latestResult['data'];
      final latestMap = <String, Map<String, dynamic>>{};
      for (final item in _dataList(latestData)) {
        if (item is Map) {
          final map = Map<String, dynamic>.from(item);
          final type = map['trackerType']?.toString();
          if (type != null && type.isNotEmpty) latestMap[type] = map;
        }
      }
      if (latestMap.isEmpty && latestData is Map) {
        final map = Map<String, dynamic>.from(latestData);
        final type = map['trackerType']?.toString();
        if (type != null && type.isNotEmpty) latestMap[type] = map;
      }
      setState(() {
        _latestTrackerResults
          ..clear()
          ..addAll(latestMap);
      });
    }

    final trendMap = <String, List<dynamic>>{};
    for (final config in configs) {
      final type = config['trackerType']?.toString();
      if (type == null || type.isEmpty) continue;
      final trendResult = await SymptomTrackerService.getTrend(
        token,
        trackerType: type,
        limit: 10,
      );
      if (trendResult['success'] == true) {
        final trendItems = _dataList(trendResult['data']);
        if (trendItems.isNotEmpty) {
          trendMap[type] = trendItems;
        }
      }
    }

    if (mounted) {
      setState(() {
        _trackerTrends
          ..clear()
          ..addAll(trendMap);
      });
    }
  }

  List<dynamic> _dataList(dynamic value) {
    if (value is List) return List<dynamic>.from(value);
    if (value is Map) {
      for (final key in [
        'results',
        'submissions',
        'history',
        'items',
        'data',
      ]) {
        final nested = value[key];
        if (nested is List) return List<dynamic>.from(nested);
      }
    }
    return const [];
  }

  Map<String, dynamic>? _getTrackerResultData(String title) {
    final currentResult = _testResults[title];
    if (currentResult != null) return currentResult;

    final tracker = _trackerByTitle(title);
    final trackerType = tracker?['trackerType']?.toString();
    final latestBackend = trackerType != null
        ? _latestTrackerResults[trackerType]
        : null;
    if (latestBackend != null) {
      return {
        'score': latestBackend['totalScore'],
        'maxScore': _maxScoreForTracker(trackerType!),
        'bandLabel': latestBackend['severityBand'],
      };
    }

    final questionnaireLatest = trackerType != null
        ? _latestQuestionnaireSubmission(trackerType)
        : null;
    if (questionnaireLatest != null) {
      return {
        'score': questionnaireLatest['score'],
        'maxScore': _maxScoreForTracker(trackerType!),
        'bandLabel': _questionnaireBandLabel(trackerType, questionnaireLatest),
      };
    }

    final storedResults =
        _storedTrackerResults[trackerType] ??
        _storedTrackerResults[_trackerKeyForTitle(title)];
    if (storedResults == null || storedResults.isEmpty) return null;

    final latestStored = storedResults.last;
    return {
      'score': latestStored.score,
      'maxScore': latestStored.maxScore,
      'bandLabel': latestStored.band,
    };
  }

  int _maxScoreForTracker(String trackerType) {
    final localConfig = _localAssessmentConfig(trackerType);
    if (localConfig != null) return localConfig.maxScore;

    Map<String, dynamic>? config;
    for (final item in _trackerConfigs) {
      if (item['trackerType']?.toString() == trackerType) {
        config = item;
        break;
      }
    }
    final items = config?['items'];
    final options = config?['options'];
    if (items is List && options is List && options.isNotEmpty) {
      var maxOption = 0;
      for (final option in options) {
        if (option is Map && option['value'] is num) {
          final value = (option['value'] as num).toInt();
          if (value > maxOption) maxOption = value;
        }
      }
      return items.length * maxOption;
    }
    return 40;
  }

  Map<String, dynamic>? _trackerByTitle(String title) {
    for (final tracker in _visibleTrackers) {
      if (tracker['name'] == title) return tracker;
    }
    return null;
  }

  Future<void> _loadCategoryStats() async {
    final controller = Get.find<MyTestsController>();
    for (final cat in controller.categories) {
      final id = cat['_id']?.toString();
      if (id != null && !controller.categoryStats.containsKey(id)) {
        await controller.fetchCategoryStats(id);
      }
    }
  }

  Future<void> _refreshCategories() async {
    final controller = Get.find<MyTestsController>();
    await _loadBackendTrackers();
    await _loadQuestionnaireResults();
    await controller.fetchCategories();
    await _loadTrackerResults();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 150,

            child: Image.asset('assets/images/my_emdr.png', fit: BoxFit.fill),
          ),

          Column(
            children: [
              _buildAppBar(context),
              SizedBox(height: 20),
              Expanded(
                child: Stack(
                  children: [
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

                    RefreshIndicator(
                      onRefresh: _refreshCategories,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            const SizedBox(height: 30),

                            _buildPillToggle(),

                            const SizedBox(height: 30),

                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: isResultsTab
                                  ? _buildResultsList()
                                  : _buildTestsList(),
                            ),

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

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 10,
      ),

      child: Row(
        children: [
          const AppText(
            "My Progress",

            fontSize: 20,

            fontWeight: FontWeight.bold,

            color: Color(0xFF2E3E32),
          ),
        ],
      ),
    );
  }

  Widget _buildPillToggle() {
    return Container(
      height: 55,

      padding: const EdgeInsets.all(5),

      decoration: BoxDecoration(
        color: Color(0xff0c326347),

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
        onTap: () async {
          setState(() => isResultsTab = label == "My Results");
          if (label == "My Results") {
            await _loadTrackerResults();
            await _loadBackendTrackers();
            await _loadQuestionnaireResults();
          }
        },

        child: Container(
          decoration: BoxDecoration(
            color: active ? const Color(0xFF537E5D) : Colors.transparent,

            borderRadius: BorderRadius.circular(25),
          ),

          alignment: Alignment.center,

          child: AppText(
            label,

            color: active ? Colors.white : Colors.black54,

            fontWeight: FontWeight.bold,

            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildTestsList() {
    if (_isTrackerLoading && _trackerConfigs.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_trackerError != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppText(
              _trackerError!,
              fontSize: 13,
              color: Colors.redAccent,
            ),
          ),
        ..._visibleTrackers.map(
          (tracker) => _trackerCard(
            tracker['name'] as String,
            tracker['trackerType'] as String,
            tracker['image'] as String,
            config: tracker['config'] is Map<String, dynamic>
                ? tracker['config'] as Map<String, dynamic>
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildAddCategoryBtn() {
    return GestureDetector(
      onTap: _showAddCategoryDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF537E5D).withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFF537E5D).withOpacity(0.5)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: Color(0xFF537E5D), size: 20),
            SizedBox(width: 8),
            AppText(
              "Add Category",
              fontSize: 14,
              color: Color(0xFF537E5D),
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final controller = Get.find<MyTestsController>();

    Get.dialog(
      AlertDialog(
        title: const AppText(
          "Add Category",
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Category Name"),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: "Description"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) return;
              await controller.createCategory(
                nameController.text,
                descController.text,
              );
              Get.back();
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }

  Widget _testItemCard(
    String title, {
    String? id,
    bool isDynamic = false,
    bool openAnxiety = false,
    String? subtitle,
  }) {
    return GestureDetector(
      onTap: () async {
        if (openAnxiety) {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const SymptomTrackerScreen(trackerType: 'anxiety'),
            ),
          );
          if (result is Map<String, dynamic>) {
            if (!mounted) return;
            setState(() {
              _testResults[title] = result;
              if (result['showResultsTab'] == true) {
                isResultsTab = true;
                _selectedResultTrackerTitle = title;
              }
            });
            if (result['showResultsTab'] == true) {
              await _loadTrackerResults();
            }
            return;
          }
        }

        if (!mounted) return;
        if (isDynamic && id != null) {
          Get.to(
            () => CategoryItemsScreen(categoryId: id, categoryName: title),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultStepScreen(title: title),
            ),
          );
        }
      },
      child: ClipRRect(
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

                  child: Icon(
                    Icons.description_outlined,
                    color: Colors.black87,
                    size: 20,
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(title, fontSize: 14, fontWeight: FontWeight.w600),
                      if (subtitle != null && subtitle.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: AppText(
                            subtitle,
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.black45,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _trackerCard(
    String title,
    String trackerType,
    String imagePath, {
    Map<String, dynamic>? config,
  }) {
    return GestureDetector(
      onTap: () async {
        if (_isLocalAssessmentType(trackerType)) {
          final config = _localAssessmentConfig(trackerType);
          if (config == null) return;

          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LocalAssessmentScreen(config: config),
            ),
          );
          if (result is Map<String, dynamic>) {
            if (!mounted) return;
            setState(() {
              _testResults[title] = result;
              if (result['showResultsTab'] == true) {
                isResultsTab = true;
                _selectedResultTrackerTitle = title;
              }
            });
            await _loadTrackerResults();
            await _loadQuestionnaireResults();
          }
          return;
        }

        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SymptomTrackerScreen(
              trackerType: trackerType,
              initialConfig: config,
            ),
          ),
        );
        if (result is Map<String, dynamic>) {
          if (!mounted) return;
          setState(() {
            _testResults[title] = result;
            if (result['showResultsTab'] == true) {
              isResultsTab = true;
              _selectedResultTrackerTitle = title;
            }
          });
          await _loadTrackerResults();
          await _loadBackendTrackers();
        }
      },
      child: ClipRRect(
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    imagePath,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 48,
                      height: 48,
                      color: Colors.white,
                      child: const Icon(
                        Icons.description_outlined,
                        color: Colors.black87,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: AppText(
                    title,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.black45,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statLabel(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, fontSize: 10, color: const Color(0xFF404446)),
        const SizedBox(height: 4),
        AppText(
          value,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2E3E32),
        ),
      ],
    );
  }

  Widget _buildTrackerResultCard(String name, Map<String, dynamic>? result) {
    return GestureDetector(
      onTap: () => setState(() => _selectedResultTrackerTitle = name),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.45),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(name, fontSize: 16, fontWeight: FontWeight.bold),
                const SizedBox(height: 10),
                SizedBox(
                  height: 100,
                  child: BarChart(
                    BarChartData(
                      barGroups: [
                        BarChartGroupData(
                          x: 0,
                          barRods: [
                            BarChartRodData(
                              toY: result != null
                                  ? (result['score'] as num?)?.toDouble() ?? 0.0
                                  : 0.0,
                              color: result != null
                                  ? const Color(0xFF4A7373)
                                  : Colors.grey,
                              width: 30,
                            ),
                          ],
                        ),
                      ],
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.black,
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: false),
                    ),
                  ),
                ),
                if (result != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _statLabel(
                        'Score',
                        '${result['score'] ?? '-'} / ${result['maxScore'] ?? ''}',
                      ),
                      _statLabel('Level', '${result['bandLabel'] ?? '-'}'),
                    ],
                  ),
                  if (result['bandDescription'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: AppText(
                        result['bandDescription'].toString(),
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                ] else
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: AppText(
                      'No result saved yet.',
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsChart() {
    if (_testResults.length < 2) return const SizedBox.shrink();

    final barGroups = _testResults.entries.map((entry) {
      final index = _testResults.keys.toList().indexOf(entry.key);
      final result = entry.value;
      final score = (result['score'] as num?)?.toDouble() ?? 0.0;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: score,
            color: const Color(0xFF4A7373),
            width: 20,
          ),
        ],
      );
    }).toList();

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: BarChart(
        BarChartData(
          barGroups: barGroups,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < _testResults.keys.length) {
                    final title = _testResults.keys.elementAt(index);
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        title.length > 10
                            ? '${title.substring(0, 10)}...'
                            : title,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black,
                        ),
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
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10, color: Colors.black),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
        ),
      ),
    );
  }

  String? _defaultResultTrackerTitle() {
    if (_selectedResultTrackerTitle != null) {
      final selectedTracker = _trackerByTitle(_selectedResultTrackerTitle!);
      final selectedType = selectedTracker?['trackerType']?.toString();
      final selectedKey =
          selectedType ?? _trackerKeyForTitle(_selectedResultTrackerTitle!);
      if ((_storedTrackerResults[selectedKey]?.isNotEmpty ?? false) ||
          (_questionnaireSubmissions[selectedKey]?.isNotEmpty ?? false) ||
          (selectedType != null &&
              _latestTrackerResults[selectedType] != null) ||
          _testResults.containsKey(_selectedResultTrackerTitle)) {
        return _selectedResultTrackerTitle;
      }
    }

    for (final tracker in _visibleTrackers) {
      final title = tracker['name'] as String;
      final trackerType = tracker['trackerType']?.toString();
      final key = trackerType ?? _trackerKeyForTitle(title);
      if ((_storedTrackerResults[key]?.isNotEmpty ?? false) ||
          (_questionnaireSubmissions[key]?.isNotEmpty ?? false) ||
          (trackerType != null && _latestTrackerResults[trackerType] != null) ||
          _testResults.containsKey(title)) {
        return title;
      }
    }

    return null;
  }

  List<String> _allResultTrackerTitles() {
    final titles = <String>[];

    for (final tracker in _visibleTrackers) {
      final title = tracker['name'] as String;
      final trackerType = tracker['trackerType']?.toString();
      final key = trackerType ?? _trackerKeyForTitle(title);
      final hasResult =
          _testResults.containsKey(title) ||
          (_storedTrackerResults[key]?.isNotEmpty ?? false) ||
          (_questionnaireSubmissions[key]?.isNotEmpty ?? false) ||
          (trackerType != null && _latestTrackerResults[trackerType] != null);

      if (hasResult && !titles.contains(title)) {
        titles.add(title);
      }
    }

    for (final title in _testResults.keys) {
      if (!titles.contains(title)) {
        titles.add(title);
      }
    }

    return titles;
  }

  Widget _buildInlineProgressView(String title) {
    final localResult = _testResults[title];
    final tracker = _trackerByTitle(title);
    final trackerType = tracker?['trackerType']?.toString();
    final key = trackerType ?? _trackerKeyForTitle(title);
    final storedResults = _storedTrackerResults[key] ?? [];
    final latestStored = storedResults.isNotEmpty ? storedResults.last : null;
    final latestBackend = trackerType != null
        ? _latestTrackerResults[trackerType]
        : null;
    final latestQuestionnaire = trackerType != null
        ? _latestQuestionnaireSubmission(trackerType)
        : null;

    final rawScore =
        (localResult?['score'] as num?) ??
        (latestBackend?['totalScore'] as num?) ??
        (latestQuestionnaire?['score'] as num?) ??
        latestStored?.score ??
        0;
    final scoreLabel = rawScore % 1 == 0
        ? rawScore.toInt().toString()
        : rawScore.toStringAsFixed(1);
    final maxScore =
        (localResult?['maxScore'] as num?)?.toInt() ??
        (trackerType != null ? _maxScoreForTracker(trackerType) : null) ??
        latestStored?.maxScore ??
        40;
    final band =
        localResult?['bandLabel']?.toString() ??
        latestBackend?['severityBand']?.toString() ??
        (trackerType != null && latestQuestionnaire != null
            ? _questionnaireBandLabel(trackerType, latestQuestionnaire)
            : null) ??
        latestStored?.band ??
        '-';
    final description =
        localResult?['bandDescription']?.toString() ??
        'Your latest $title score is $scoreLabel/$maxScore, which falls in the $band range. Keep tracking weekly to notice changes over time.';
    final backendTrend = trackerType != null
        ? _trackerTrends[trackerType]
        : null;
    final questionnaireTrend = trackerType != null
        ? _questionnaireSubmissions[trackerType]
        : null;
    final chartPoints = _buildProgressChartPoints(
      backendTrend: backendTrend,
      questionnaireTrend: questionnaireTrend,
      storedResults: storedResults,
      fallbackScore: rawScore.toDouble(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _progressGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                '$title Result',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2E3E32),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    child: _progressBadge('Score', '$scoreLabel/$maxScore'),
                  ),
                  Flexible(child: _progressBadge('Level', band)),
                  Flexible(
                    child: _progressBadge(
                      'Date',
                      latestQuestionnaire?['submittedAt'] != null
                          ? _formatDate(
                              DateTime.parse(
                                latestQuestionnaire!['submittedAt'].toString(),
                              ),
                            )
                          : latestBackend?['submittedAt'] != null
                          ? _formatDate(
                              DateTime.parse(
                                latestBackend!['submittedAt'].toString(),
                              ),
                            )
                          : latestStored != null
                          ? _formatDate(latestStored.savedAt)
                          : 'Today',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _progressGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppText(
                'Progress Over Time',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E3E32),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 200,
                child: LineChart(
                  _buildTrackerProgressChartData(
                    chartPoints,
                    maxScoreOverride: maxScore,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _progressGlassCard(
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
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _progressGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _progressBadge(String label, String value) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF537E5D).withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF537E5D).withOpacity(0.3)),
          ),
          child: AppText(
            value,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF537E5D),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 6),
        AppText(label, fontSize: 12, color: Colors.black45),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  List<_ProgressChartPoint> _buildProgressChartPoints({
    required List<dynamic>? backendTrend,
    required List<dynamic>? questionnaireTrend,
    required List<TrackerResult> storedResults,
    required double fallbackScore,
  }) {
    if (backendTrend != null && backendTrend.isNotEmpty) {
      final points = backendTrend.whereType<Map>().map((item) {
        final rawScore =
            (item['totalScore'] as num?) ?? (item['score'] as num?) ?? 0;
        return _ProgressChartPoint(
          score: rawScore.toDouble(),
          date: _parseDate(item['submittedAt'] ?? item['createdAt']),
        );
      }).toList();
      return _sortChartPoints(points);
    }

    if (questionnaireTrend != null && questionnaireTrend.isNotEmpty) {
      final points = questionnaireTrend.whereType<Map>().map((item) {
        return _ProgressChartPoint(
          score: ((item['score'] as num?) ?? 0).toDouble(),
          date: _parseDate(item['submittedAt'] ?? item['createdAt']),
        );
      }).toList();
      return _sortChartPoints(points);
    }

    if (storedResults.isNotEmpty) {
      return storedResults
          .map(
            (result) => _ProgressChartPoint(
              score: result.score.toDouble(),
              date: result.savedAt,
            ),
          )
          .toList();
    }

    return [_ProgressChartPoint(score: fallbackScore, date: DateTime.now())];
  }

  List<_ProgressChartPoint> _sortChartPoints(List<_ProgressChartPoint> points) {
    points.sort((a, b) {
      final aDate = a.date;
      final bDate = b.date;
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return aDate.compareTo(bDate);
    });

    final collapsed = <_ProgressChartPoint>[];
    for (final point in points) {
      final date = point.date;
      if (date == null || collapsed.isEmpty) {
        collapsed.add(point);
        continue;
      }

      final last = collapsed.last.date;
      final isSameDay =
          last != null &&
          last.year == date.year &&
          last.month == date.month &&
          last.day == date.day;

      if (isSameDay) {
        collapsed[collapsed.length - 1] = point;
      } else {
        collapsed.add(point);
      }
    }

    return collapsed;
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  String _chartDateLabel(DateTime? date, int index) {
    if (date == null) return '${index + 1}';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month';
  }

  LineChartData _buildTrackerProgressChartData(
    List<_ProgressChartPoint> data, {
    int? maxScoreOverride,
  }) {
    final safeData = data.isEmpty
        ? [_ProgressChartPoint(score: 0, date: DateTime.now())]
        : data;
    final maxScore =
        maxScoreOverride?.toDouble() ??
        (safeData
                    .map((point) => point.score)
                    .reduce((a, b) => a > b ? a : b)
                    .clamp(1.0, 40.0)
                as num)
            .toDouble();
    final maxX = safeData.length > 1 ? (safeData.length - 1).toDouble() : 1.0;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        getDrawingHorizontalLine: (v) =>
            FlLine(color: Colors.black12, strokeWidth: 1),
        getDrawingVerticalLine: (v) =>
            FlLine(color: Colors.black12, strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: maxScore > 20 ? 10 : 5,
            reservedSize: 28,
            getTitlesWidget: (v, m) => AppText(
              '${v.toInt()}',
              fontSize: 11,
              color: AppColors.mainAppColor,
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 34,
            getTitlesWidget: (v, m) {
              final index = v.toInt();
              if (index < 0 ||
                  index >= safeData.length ||
                  v != index.toDouble()) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: AppText(
                  _chartDateLabel(safeData[index].date, index),
                  fontSize: 11,
                  color: AppColors.mainAppColor,
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(color: Colors.black12, width: 1),
          left: BorderSide(color: Colors.black12, width: 1),
        ),
      ),
      minX: 0,
      maxX: maxX,
      minY: 0,
      maxY: maxScore,
      lineBarsData: [
        LineChartBarData(
          spots: List.generate(
            safeData.length,
            (index) => FlSpot(index.toDouble(), safeData[index].score),
          ),
          isCurved: true,
          color: const Color(0xFF537E5D),
          barWidth: 3,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            color: const Color(0xFF537E5D).withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsList() {
    final resultTrackerTitles = _allResultTrackerTitles();

    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          'View My Progress',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2E3E32),
        ),
        const SizedBox(height: 6),
        const AppText(
          'Your saved test progress is shown below.',
          fontSize: 13,
          color: Colors.black54,
        ),
        const SizedBox(height: 18),
        if (resultTrackerTitles.isNotEmpty)
          ...resultTrackerTitles.expand(
            (title) => [
              _buildInlineProgressView(title),
              const SizedBox(height: 24),
            ],
          )
        else
          const AppText(
            "No saved progress found yet.",
            fontSize: 14,
            color: Colors.black54,
          ),
      ],
    );
  }

  Widget _resultGraphCard(
    String session,
    String date,
    List<double> data, {
    int? totalCount,
    int? activeCount,
    int? inactiveCount,
  }) {
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
                  AppText(
                    session,
                    fontSize: 16,
                    color: const Color(0xFF404446),
                    fontWeight: FontWeight.bold,
                  ),

                  AppText(
                    date,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF404446),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              if (totalCount != null ||
                  activeCount != null ||
                  inactiveCount != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (totalCount != null)
                      Flexible(
                        child: _statLabel('Total', totalCount.toString()),
                      ),
                    if (activeCount != null)
                      Flexible(
                        child: _statLabel('Active', activeCount.toString()),
                      ),
                    if (inactiveCount != null)
                      Flexible(
                        child: _statLabel('Inactive', inactiveCount.toString()),
                      ),
                  ],
                ),

              if (totalCount != null ||
                  activeCount != null ||
                  inactiveCount != null)
                const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
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
      gridData: FlGridData(
        show: true,

        drawVerticalLine: true,

        horizontalInterval: 1,

        verticalInterval: 1,

        getDrawingHorizontalLine: (v) =>
            FlLine(color: Colors.black12, strokeWidth: 1.5),

        getDrawingVerticalLine: (v) =>
            FlLine(color: Colors.black12, strokeWidth: 1.5),
      ),

      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),

        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),

        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            reservedSize: 28,

            getTitlesWidget: (v, m) => AppText(
              '${v.toInt()}h',
              fontSize: 11,
              color: AppColors.mainAppColor,
            ),
          ),
        ),

        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,

            getTitlesWidget: (v, m) {
              const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: AppText(
                  days[v.toInt()],
                  fontSize: 11,
                  color: AppColors.mainAppColor,
                ),
              );
            },
          ),
        ),
      ),

      borderData: FlBorderData(
        show: true,

        border: Border(
          bottom: BorderSide(color: Colors.black12, width: 1.5),

          left: BorderSide(color: Colors.black12, width: 1.5),
        ),
      ),

      lineBarsData: [
        LineChartBarData(
          spots: List.generate(
            data.length,
            (i) => FlSpot(i.toDouble(), data[i]),
          ),

          isCurved: true,

          color: const Color(0xFF537E5D),

          barWidth: 3,

          dotData: FlDotData(
            show: true,
            getDotPainter: (s, p, b, i) => i == 3
                ? FlDotCirclePainter(
                    radius: 4,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: const Color(0xFF537E5D),
                  )
                : FlDotCirclePainter(radius: 0),
          ),

          belowBarData: BarAreaData(
            show: true,
            color: const Color(0xFF537E5D).withOpacity(0.1),
          ),
        ),
      ],

      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (spot) => Colors.white,

          getTooltipItems: (spots) => spots
              .map(
                (s) => LineTooltipItem(
                  "3h 14min",
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
