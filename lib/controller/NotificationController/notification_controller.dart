import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jonssony/controller/auth_controller.dart';
import 'package:jonssony/services/notification_api_service.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime receivedAt;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.receivedAt,
    this.isRead = false,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id:
          json['_id']?.toString() ??
          json['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title']?.toString() ?? 'New Notification',
      body:
          json['body']?.toString() ??
          json['message']?.toString() ??
          json['description']?.toString() ??
          '',
      receivedAt: json['receivedAt'] != null
          ? DateTime.tryParse(json['receivedAt'].toString()) ?? DateTime.now()
          : json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isRead: json['isRead'] as bool? ?? json['read'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'receivedAt': receivedAt.toIso8601String(),
        'isRead': isRead,
      };
}

class NotificationController extends GetxController {
  static const String _storageKey = 'app_notifications';
  final _box = GetStorage();

  final RxList<AppNotification> notifications = <AppNotification>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt total = 0.obs;
  final RxInt serverUnreadCount = 0.obs;
  DateTime? _lastFetchedAt;

  /// Unread count — shown as badge on the bell icon
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    super.onInit();
    _loadFromStorage();
    fetchNotifications();
  }

  // ─── Load saved notifications from storage ──────────────────
  void _loadFromStorage() {
    reloadFromStorage();
  }

  void reloadFromStorage() {
    final raw = _box.read<String>(_storageKey);
    if (raw != null && raw.isNotEmpty) {

      try {
        final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
        notifications.assignAll(
          list.map((e) => AppNotification.fromJson(e as Map<String, dynamic>)),
        );
      } catch (e) {
        notifications.clear();
      }
    }
  }

  // ─── Persist to storage ─────────────────────────────────────
  void _saveToStorage() {
    _box.write(
      _storageKey,
      jsonEncode(notifications.map((n) => n.toJson()).toList()),
    );
  }

  // ─── Add a new incoming notification ────────────────────────
  void addNotification({required String title, required String body, String? id}) {
    final notification = AppNotification(
      id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      receivedAt: DateTime.now(),
    );
    notifications.insert(0, notification); // newest first
    _saveToStorage();
  }

  Future<void> fetchNotifications({int page = 1, int limit = 20}) async {
    if (isLoading.value) return;
    final lastFetchedAt = _lastFetchedAt;
    if (lastFetchedAt != null &&
        DateTime.now().difference(lastFetchedAt) < const Duration(seconds: 5)) {
      return;
    }

    final token = _authToken();
    if (token == null || token.isEmpty) return;

    isLoading.value = true;
    try {
      _lastFetchedAt = DateTime.now();
      final result = await NotificationApiService.getMyNotifications(
        token: token,
        page: page,
        limit: limit,
      );
      if (result['success'] == true && result['data'] is Map) {
        final data = Map<String, dynamic>.from(result['data'] as Map);
        final rawNotifications = data['notifications'] is List
            ? List<dynamic>.from(data['notifications'] as List)
            : <dynamic>[];
        notifications.assignAll(
          rawNotifications
              .whereType<Map>()
              .map((item) => AppNotification.fromJson(Map<String, dynamic>.from(item))),
        );
        total.value = int.tryParse(data['total']?.toString() ?? '') ?? notifications.length;
        serverUnreadCount.value =
            int.tryParse(data['unreadCount']?.toString() ?? '') ?? unreadCount;
        _saveToStorage();
      }
    } catch (e) {
      debugPrint('Notification fetch error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Mark a single notification as read ─────────────────────
  Future<void> markAsRead(String id) async {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      notifications[index].isRead = true;
      notifications.refresh();
      _saveToStorage();
    }

    final token = _authToken();
    if (token == null || token.isEmpty || id.isEmpty) return;

    try {
      await NotificationApiService.markAsRead(
        token: token,
        notificationId: id,
      );
    } catch (e) {
      debugPrint('Mark notification read error: $e');
    }
  }

  // ─── Mark all as read ────────────────────────────────────────
  Future<void> markAllAsRead() async {
    for (final n in notifications) {
      n.isRead = true;
    }
    notifications.refresh();
    _saveToStorage();

    final token = _authToken();
    if (token == null || token.isEmpty) return;

    try {
      await NotificationApiService.markAllAsRead(token: token);
    } catch (e) {
      debugPrint('Mark all notifications read error: $e');
    }
  }

  // ─── Delete a notification ───────────────────────────────────
  void deleteNotification(String id) {
    notifications.removeWhere((n) => n.id == id);
    _saveToStorage();
  }

  // ─── Clear all ───────────────────────────────────────────────
  void clearAll() {
    notifications.clear();
    _box.remove(_storageKey);
  }

  String? _authToken() {
    if (Get.isRegistered<AuthController>()) {
      return Get.find<AuthController>().token;
    }
    return _box.read<String>('auth_token');
  }

  // ─── Human-readable time ─────────────────────────────────────
  static String timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes} min ago';
    if (diff.inDays < 1) return '${diff.inHours} hr ago';
    if (diff.inDays == 1) return '1 day ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
