import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Android-specific Push Notification Configuration
class PushNotificationAndroid {
  // Texts & Chat Channel (chats, reminders, general notifications)
  static const String channelId = 'confeet_texts';
  static const String channelName = 'Confeet Texts';
  static const String channelDescription =
      'This channel is used for confeet messages and chat notifications.';

  // Calls Channel (matches backend "confeet_calls" for incoming/missed calls)
  static const String callsChannelId = 'confeet_calls';
  static const String callsChannelName = 'Confeet Calls';
  static const String callsChannelDescription =
      'This channel is used for incoming, active, and missed call notifications.';

  static const String iconResource = '@drawable/ic_notification';
  static const String largeIconResource = '@drawable/ic_confeet_logo';
  static const Color accentColor = Color(0xFF2B3B7D);

  /// Android initialization settings for local notifications
  static const AndroidInitializationSettings initializationSettings =
      AndroidInitializationSettings(iconResource);

  /// Default notification channel for messages and app notifications (Android 8.0+)
  static const AndroidNotificationChannel notificationChannel =
      AndroidNotificationChannel(
    channelId,
    channelName,
    description: channelDescription,
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  /// Dedicated notification channel for calls (heads-up / max priority)
  static const AndroidNotificationChannel callsNotificationChannel =
      AndroidNotificationChannel(
    callsChannelId,
    callsChannelName,
    description: callsChannelDescription,
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  /// Setup all notification channels and request permission if needed
  static Future<void> setupChannelAndPermission(
    FlutterLocalNotificationsPlugin plugin, {
    bool requestPermission = true,
  }) async {
    final androidPlugin = plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (requestPermission) {
      await androidPlugin?.requestNotificationsPermission();
    }

    // Register all channels with the Android OS
    await androidPlugin?.createNotificationChannel(notificationChannel);
    await androidPlugin?.createNotificationChannel(callsNotificationChannel);
  }

  /// Build Android-specific notification details supporting multiple channels
  static AndroidNotificationDetails buildNotificationDetails({
    required String title,
    required String body,
    String? largeIconPath,
    bool isIncomingCall = false,
    bool isMissedCall = false,
    String? channelIdOverride,
    String? tag,
  }) {
    final bool isCall =
        isIncomingCall || isMissedCall || channelIdOverride == callsChannelId;
    final String activeChannelId =
        channelIdOverride ?? (isCall ? callsChannelId : channelId);
    final String activeChannelName =
        isCall ? callsChannelName : channelName;
    final String activeChannelDescription =
        isCall ? callsChannelDescription : channelDescription;

    return AndroidNotificationDetails(
      activeChannelId,
      activeChannelName,
      channelDescription: activeChannelDescription,
      importance: isCall ? Importance.max : Importance.high,
      priority: isCall ? Priority.max : Priority.high,
      playSound: true,
      enableVibration: true,
      fullScreenIntent: isIncomingCall,
      category: isIncomingCall
          ? AndroidNotificationCategory.call
          : (isMissedCall
              ? AndroidNotificationCategory.missedCall
              : AndroidNotificationCategory.message),
      tag: tag,
      icon: iconResource,
      color: accentColor,
      largeIcon: largeIconPath != null
          ? FilePathAndroidBitmap(largeIconPath)
          : const DrawableResourceAndroidBitmap(largeIconResource),
      styleInformation: BigTextStyleInformation(
        body,
        htmlFormatBigText: true,
        contentTitle: title,
        htmlFormatContentTitle: true,
      ),
    );
  }

  /// Retrieve Android FCM device token
  static Future<String?> getToken() async {
    return await FirebaseMessaging.instance.getToken();
  }
}
