import 'dart:convert';
import 'dart:io';

import 'package:conference/models/user_model.dart';

import 'package:conference/core/storage/storage.dart';
import 'package:conference/pages/notification/notification_controller.dart';
import 'package:conference/pages/notification/notification_page.dart';
import 'package:conference/push_notification_manager/models/notification_event.dart';
import 'package:conference/push_notification_manager/push_notification.dart';
import 'package:conference/push_notification_manager/service/notification_handler_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:conference/models/api_response.dart';
import 'package:conference/services/http_service.dart';
import 'package:path_provider/path_provider.dart';

/// Common Push Notification Coordinator (Shared cross-platform logic)
class PushNotifications {
  static FirebaseMessaging get _firebaseMessaging =>
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Request cross-platform notification permission and fetch device token
  static Future<String?> init() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint("User granted notification permission");
    } else {
      debugPrint("User denied notification permission");
    }

    String? token = await fetchAndSaveToken();
    return token;
  }

  /// Saves device token to NotificationHandlerService and persistent local storage
  static Future<void> saveToken(String token) async {
    if (token.isNotEmpty) {
      if (Get.isRegistered<NotificationHandlerService>()) {
        Get.find<NotificationHandlerService>().setDeviceId = token;
      }
      await StorageService.instance.setValue('fcm_device_token', token);
      debugPrint("Device token successfully saved: $token");

      // Send deviceId and deviceType to backend
      await updateDeviceToken(token);
    }
  }

  /// Send device id and device type to the backend server
  /// Endpoint: /api/auth/v2/updateDeviceToken
  static Future<void> updateDeviceToken(String token) async {
    try {
      final user = UserModel.instance;
      final dynamic rawUser = StorageService.instance.getValue('user');
      final Map<String, dynamic> userMap =
          rawUser is Map ? Map<String, dynamic>.from(rawUser) : {};

      final String deviceType = Platform.isAndroid
          ? 'android'
          : Platform.isIOS
              ? 'ios'
              : (Platform.isWindows
                  ? 'windows'
                  : (Platform.isMacOS ? 'macos' : 'linux'));

      final Map<String, dynamic> payload = {
        'loginId': userMap['loginId']?.toString(),
        'email': user.email.isNotEmpty
            ? user.email
            : (userMap['email']?.toString() ?? ''),
        'password': userMap['password']?.toString(),
        'userId': user.userId.isNotEmpty
            ? user.userId
            : (userMap['userId']?.toString() ?? ''),
        'firstName': user.firstName.isNotEmpty
            ? user.firstName
            : (userMap['firstName']?.toString() ?? ''),
        'lastName': user.lastName.isNotEmpty
            ? user.lastName
            : (userMap['lastName']?.toString() ?? ''),
        'code': user.code.isNotEmpty
            ? user.code
            : (userMap['code']?.toString() ?? ''),
        'deviceId': token,
        'deviceType': deviceType,
        'isNotificationEnabled': true,
        'isActive': true,
      };

      debugPrint("Sending updateDeviceToken request to /api/auth/v2/updateDeviceToken: $payload");

      final dynamic response = await HttpService.instance.post(
        '/api/auth/v2/updateDeviceToken',
        body: payload,
      );

      final bool isSuccess = (response is ApiResponse && response.isOk) ||
          (response is Response && response.isOk) ||
          (response != null && response.isSuccess == true);

      if (isSuccess) {
        debugPrint("Device token successfully updated on backend.");
        Get.snackbar(
          'Success',
          'Push notifications enabled successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 3),
        );
      } else {
        debugPrint("Fail to enable the push notification.");
        Get.snackbar(
          'Error',
          'Failed to enable push notifications',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
          icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      debugPrint("Failed to update device token on backend: $e");
      Get.snackbar(
        'Error',
        'Failed to enable push notifications: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Explicitly retrieve and store the device token across Android/iOS
  static Future<String?> fetchAndSaveToken() async {
    String? token;
    try {
      if (Platform.isIOS) {
        token = await PushNotificationIOS.getToken();
      } else {
        token = await PushNotificationAndroid.getToken();
      }

      if (token != null && token.isNotEmpty) {
        await saveToken(token);
      }
    } catch (e) {
      debugPrint("Error fetching device token: $e");
    }
    return token;
  }

  /// Initialize local notification plugins with Android and iOS platform configurations
  static Future<void> localNotificationInit({
    bool requestPermission = true,
  }) async {
    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: PushNotificationAndroid.initializationSettings,
          iOS: PushNotificationIOS.initializationSettings,
        );

    if (Platform.isAndroid) {
      await PushNotificationAndroid.setupChannelAndPermission(
        _flutterLocalNotificationsPlugin,
        requestPermission: requestPermission,
      );
    }

    await _flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: onNotificationTap,
    );
  }

  /// Handles notification response when tapped by the user
  static void onNotificationTap(
    NotificationResponse notificationResponse,
  ) async {
    final payload = notificationResponse.payload;
    if (payload != null && payload.isNotEmpty) {
      final notification = NotificationEvent.fromJson(payload);

      // Add this notification in the global notification list
      notification.time ??= DateTime.now();
      NotificationEvent.addNotification(notification);

      if (!Get.isRegistered<NotificationController>()) {
        Get.put(NotificationController());
      }

      await Get.to(
        () => const NotificationPage(),
        arguments: {
          'postId': notification.type,
          'isApplied': false,
          'appliedOn': null,
        },
      );
    }
  }

  /// Download a remote file and save it locally for notification rich media
  static Future<String> _downloadAndSaveFile(
    String url,
    String fileName,
  ) async {
    final Directory directory = await getTemporaryDirectory();
    final String filePath = '${directory.path}/$fileName';
    final Uint8List bytes = await HttpService.instance.getBytes(url);
    final File file = File(filePath);
    await file.writeAsBytes(bytes);
    return filePath;
  }

  /// Display a custom local notification with Android and iOS specific builders
  static Future<void> showNotification(RemoteMessage message) async {
    if (Get.isRegistered<NotificationHandlerService>()) {
      final service = Get.find<NotificationHandlerService>();
      if (!service.isNotificationsEnabled.value) {
        debugPrint("Local notification suppressed because notifications are disabled.");
        return;
      }
    }

    final notification = message.notification;
    final data = message.data;

    // Detect event type (matches backend push notification builder)
    final String eventType = (data['event'] ?? data['type'] ?? '').toString();
    final bool isIncomingCall = eventType == 'call:incoming' ||
        eventType == 'call_incoming' ||
        eventType == 'call:invite';
    final bool isMissedCall = eventType == 'call:missed' ||
        eventType == 'call_missed' ||
        eventType == 'call:timed_out' ||
        eventType == 'call:timeout' ||
        eventType == 'call:cancelled' ||
        eventType == 'call_cancelled';

    // Resolve conversation / thread ID
    String? convId;
    if (data['conversationId'] != null &&
        data['conversationId'].toString().isNotEmpty) {
      convId = data['conversationId'].toString();
    } else if (data['conversation_id'] != null &&
        data['conversation_id'].toString().isNotEmpty) {
      convId = data['conversation_id'].toString();
    }

    // Determine notification tag matching backend logic
    String? tag;
    if (isIncomingCall) {
      tag = (convId != null && convId.isNotEmpty) ? 'call_$convId' : 'call_incoming';
    } else if (isMissedCall) {
      tag = (convId != null && convId.isNotEmpty) ? 'missed_$convId' : 'call_missed';
    } else if (convId != null && convId.isNotEmpty) {
      tag = convId;
    }

    final String? channelOverride =
        data['channelId']?.toString() ?? data['channel_id']?.toString();

    String title =
        notification?.title ??
        data['title'] ??
        data['conversationName'] ??
        data['senderName'] ??
        data['fullName'] ??
        'Confeet';
    if (title.trim().isEmpty || title.toLowerCase() == 'hiringbell') {
      title = 'Confeet';
    } else if (title.toLowerCase().contains('hiringbell')) {
      title = title.replaceAll(RegExp(r'hiringbell', caseSensitive: false), 'Confeet');
    }

    String body =
        notification?.body ??
        data['body'] ??
        data['description'] ??
        data['content'] ??
        '';
    if (body.toLowerCase().contains('hiringbell')) {
      body = body.replaceAll(RegExp(r'hiringbell', caseSensitive: false), 'Confeet');
    }
    final int notificationId =
        notification?.hashCode ?? message.messageId.hashCode;

    String? largeIconPath;
    String? imageUrl = "";
    if (imageUrl.isEmpty) {
      imageUrl = data['imageUrl'] ?? data['image'] ?? data['avatar'];
    }

    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final String fileName = 'notification_${notificationId}_img';
        largeIconPath = await _downloadAndSaveFile(imageUrl, fileName);
      } catch (e) {
        debugPrint("Error downloading notification icon: $e");
      }
    }

    // Platform-specific configurations
    final AndroidNotificationDetails androidDetails =
        PushNotificationAndroid.buildNotificationDetails(
          title: title,
          body: body,
          largeIconPath: largeIconPath,
          isIncomingCall: isIncomingCall,
          isMissedCall: isMissedCall,
          channelIdOverride: channelOverride,
          tag: tag,
        );

    final DarwinNotificationDetails iosDetails =
        PushNotificationIOS.buildNotificationDetails(
          attachmentPath: largeIconPath,
          categoryIdentifier: isIncomingCall
              ? 'INCOMING_CALL'
              : (isMissedCall ? 'MISSED_CALL' : 'MESSAGE_REPLY'),
          threadIdentifier: convId,
        );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final Map<String, dynamic> payloadData = Map<String, dynamic>.from(data);
    if ((payloadData['title'] == null ||
            payloadData['title'].toString().isEmpty) &&
        title.isNotEmpty) {
      payloadData['title'] = title;
    }
    if ((payloadData['description'] == null ||
            payloadData['description'].toString().isEmpty) &&
        body.isNotEmpty) {
      payloadData['description'] = body;
    }
    if ((payloadData['body'] == null ||
            payloadData['body'].toString().isEmpty) &&
        body.isNotEmpty) {
      payloadData['body'] = body;
    }
    if (!payloadData.containsKey('time')) {
      payloadData['time'] = DateTime.now().millisecondsSinceEpoch.toString();
    }

    await _flutterLocalNotificationsPlugin.show(
      id: notificationId,
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
      payload: jsonEncode(payloadData),
    );
  }
}
