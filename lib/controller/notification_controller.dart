import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

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
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title']?.toString() ?? 'New Notification',
      body: json['body']?.toString() ?? '',
      receivedAt: json['receivedAt'] != null 
          ? DateTime.tryParse(json['receivedAt'].toString()) ?? DateTime.now() 
          : DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
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

  /// Unread count — shown as badge on the bell icon
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    super.onInit();
    _loadFromStorage();
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
  void addNotification({required String title, required String body}) {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      receivedAt: DateTime.now(),
    );
    notifications.insert(0, notification); // newest first
    _saveToStorage();
  }

  // ─── Mark a single notification as read ─────────────────────
  void markAsRead(String id) {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      notifications[index].isRead = true;
      notifications.refresh();
      _saveToStorage();
    }
  }

  // ─── Mark all as read ────────────────────────────────────────
  void markAllAsRead() {
    for (final n in notifications) {
      n.isRead = true;
    }
    notifications.refresh();
    _saveToStorage();
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
