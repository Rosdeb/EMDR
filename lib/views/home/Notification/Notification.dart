import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jonssony/controller/NotificationController/notification_controller.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationController controller = Get.find<NotificationController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchNotifications();
    });

    const Color bgColor = Color(0xFFFFF9F2);
    const Color iconBgColor = Color(0xFFC69C6D);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4A4A4A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Notification",
          style: TextStyle(
            color: Color(0xFF4A4A4A),
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        titleSpacing: 0,
        actions: [
          TextButton(
            onPressed: () => controller.clearAll(),
            child: const Text("Clear All", style: TextStyle(color: Color(0xFFC69C6D))),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.notifications.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_none_rounded, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text("No notifications yet", style: TextStyle(color: Colors.grey, fontSize: 16)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: controller.notifications.length,
          itemBuilder: (context, index) {
            final notification = controller.notifications[index];
            return _buildNotificationItem(
              context,
              controller,
              notification,
              iconBgColor,
            );
          },
        );
      }),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    NotificationController controller,
    AppNotification notification,
    Color iconBgColor,
  ) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => controller.deleteNotification(notification.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red.withValues(alpha: 0.1),

        child: const Icon(Icons.delete, color: Colors.red),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 25.0),
        child: InkWell(
          onTap: () {
            if (!notification.isRead) {
              controller.markAsRead(notification.id);
            }
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: notification.isRead
                      ? iconBgColor.withValues(alpha: 0.9)
                      : iconBgColor,

                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (notification.title.isNotEmpty) ...[
                      Text(
                        notification.title,
                        style: TextStyle(
                          fontSize: 16,
                          color: notification.isRead ?  Colors.black : const Color(0xFF4A4A4A),
                          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    if (notification.body.isNotEmpty) ...[
                      Text(
                        notification.body,
                        style: TextStyle(
                          fontSize: 14,
                          color: notification.isRead ? Colors.black : const Color(0xFF6D6D6D),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                    Text(
                      NotificationController.timeAgo(notification.receivedAt),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF60655C),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFC69C6D),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
