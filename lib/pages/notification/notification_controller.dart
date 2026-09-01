import 'package:get/get.dart';

class NotificationController extends GetxController {
  final RxList<Map<String, dynamic>> notifications = <Map<String, dynamic>>[].obs;


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
