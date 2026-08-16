import 'package:get/get.dart';

class NotificationController extends GetxController {
  final RxList<Map<String, dynamic>> notifications = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockNotifications();
  }

  void _loadMockNotifications() {
    notifications.value = [
      {
        'id': '1',
        'title': 'New Meeting Invitation',
        'description': 'Md IstiyaQ invited you to "Daily standup meeting" at 5:59 PM today.',
        'time': '10 mins ago',
        'type': 'meeting',
        'isRead': false,
      },
      {
        'id': '2',
        'title': 'Vivek mentioned you in team sync',
        'description': '"@User please make sure the schedule page routes are updated before push."',
        'time': '1 hour ago',
        'type': 'mention',
        'isRead': false,
      },
      {
        'id': '3',
        'title': 'Project Update',
        'description': 'New features deployed: Meeting scheduling, responsive calendars and dark mode optimization.',
        'time': '4 hours ago',
        'type': 'system',
        'isRead': true,
      },
      {
        'id': '4',
        'title': 'Meeting Reminder',
        'description': 'Your meeting "Vite Refactor Review" is starting in 15 minutes.',
        'time': '1 day ago',
        'type': 'reminder',
        'isRead': true,
      },
    ];
  }

  void markAsRead(String id) {
    final index = notifications.indexWhere((n) => n['id'] == id);
    if (index != -1) {
      final updated = Map<String, dynamic>.from(notifications[index]);
      updated['isRead'] = true;
      notifications[index] = updated;
    }
  }

  void deleteNotification(String id) {
    notifications.removeWhere((n) => n['id'] == id);
  }

  void clearAll() {
    notifications.clear();
  }

  int get unreadCount => notifications.where((n) => !n['isRead']).length;
}
