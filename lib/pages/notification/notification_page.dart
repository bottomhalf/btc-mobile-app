import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import 'notification_controller.dart';

class NotificationPage extends GetView<NotificationController> {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface(context),
      appBar: AppBar(
        backgroundColor: AppTheme.card(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textPrimary(context),
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            color: AppTheme.textPrimary(context),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(() {
            if (controller.notifications.isEmpty) return const SizedBox();
            return TextButton(
              onPressed: controller.clearAll,
              child: const Text(
                'Clear All',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            );
          }),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: AppTheme.divider(context).withValues(alpha: 0.5),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: Theme.of(context).brightness == Brightness.dark
                ? const [Color(0xFF131224), Color(0xFF1B1A2E)]
                : const [Color(0xFFF3F5FA), Color(0xFFE8ECF5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Obx(() {
          if (controller.notifications.isEmpty) {
            return _buildEmptyState(context);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: controller.notifications.length,
            itemBuilder: (context, index) {
              final item = controller.notifications[index];
              return _buildNotificationCard(context, item);
            },
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.accentPurple.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppTheme.accentGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentPurple.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.notifications_off_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'All caught up! 🎉',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You do not have any new notifications.',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, Map<String, dynamic> item) {
    final bool isRead = item['isRead'] ?? false;
    final String type = item['type'] ?? 'system';
    
    IconData iconData;
    Color iconColor;
    Color bgIconColor;

    switch (type) {
      case 'meeting':
        iconData = Icons.videocam_rounded;
        iconColor = const Color(0xFF00B894);
        bgIconColor = const Color(0xFF00B894).withValues(alpha: 0.15);
        break;
      case 'mention':
        iconData = Icons.alternate_email_rounded;
        iconColor = const Color(0xFF6C5CE7);
        bgIconColor = const Color(0xFF6C5CE7).withValues(alpha: 0.15);
        break;
      case 'reminder':
        iconData = Icons.alarm_rounded;
        iconColor = const Color(0xFF0984E3);
        bgIconColor = const Color(0xFF0984E3).withValues(alpha: 0.15);
        break;
      default:
        iconData = Icons.rocket_launch_rounded;
        iconColor = const Color(0xFFFDCB6E);
        bgIconColor = const Color(0xFFFDCB6E).withValues(alpha: 0.15);
    }

    return Dismissible(
      key: Key(item['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(
          Icons.delete_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
      onDismissed: (direction) {
        controller.deleteNotification(item['id']);
      },
      child: GestureDetector(
        onTap: () {
          controller.markAsRead(item['id']);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isRead 
                ? AppTheme.card(context).withValues(alpha: 0.8) 
                : AppTheme.card(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isRead
                  ? AppTheme.divider(context).withValues(alpha: 0.3)
                  : AppTheme.accentPurple.withValues(alpha: 0.25),
              width: isRead ? 1 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon with circle background
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bgIconColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  iconData,
                  color: iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),

              // Title and Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item['title'] ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                              color: AppTheme.textPrimary(context),
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.accentPurple,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.accentPurple.withValues(alpha: 0.6),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item['description'] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary(context),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['time'] ?? '',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.textSecondary(context).withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
