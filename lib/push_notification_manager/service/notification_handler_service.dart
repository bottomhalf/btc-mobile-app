import 'package:conference/core/storage/storage.dart';
import 'package:conference/push_notification_manager/push_notification_init.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationHandlerService extends GetxService with WidgetsBindingObserver {
  static NotificationHandlerService get instance {
    if (!Get.isRegistered<NotificationHandlerService>()) {
      return Get.put(NotificationHandlerService(), permanent: true);
    }
    return Get.find<NotificationHandlerService>();
  }

  String? _deviceId;

  String? get deviceId => _deviceId;

  set setDeviceId(String deviceId) {
    _deviceId = deviceId;
    StorageService.instance.setValue('fcm_device_token', deviceId);
  }

  final RxBool isNotificationsEnabled = false.obs;
  final RxBool isPermissionBlocked = false.obs;
  final RxBool isConfiguring = false.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    final savedToken =
        StorageService.instance.getValue<String>('fcm_device_token');
    if (savedToken != null && savedToken.isNotEmpty) {
      _deviceId = savedToken;
    }
    _syncPermissionAndState();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  /// Automatically re-check permission when user returns to app from OS Settings
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncPermissionAndState();
    }
  }

  /// Sync reactive state with actual OS permission and stored preference
  Future<void> _syncPermissionAndState() async {
    try {
      final status = await Permission.notification.status;
      isPermissionBlocked.value = status.isPermanentlyDenied;

      final saved = StorageService.instance.getValue<bool>('notification_service_enabled');
      if (saved == false) {
        isNotificationsEnabled.value = false;
      } else if (saved == true) {
        isNotificationsEnabled.value = status.isGranted || status.isProvisional;
      } else {
        // If never set before, enable only if OS permission is already granted
        isNotificationsEnabled.value = status.isGranted || status.isProvisional;
      }

      // If user enabled it in device settings while app was backgrounded, initialize Firebase
      if ((status.isGranted || status.isProvisional) && isNotificationsEnabled.value) {
        await _executeNotificationInit();
      }
    } catch (e) {
      debugPrint("Error syncing notification permission status: $e");
    }
  }

  /// Check whether OS-level notification permission is permanently blocked
  Future<void> checkPermissionStatus() async {
    try {
      final status = await Permission.notification.status;
      isPermissionBlocked.value = status.isPermanentlyDenied;
      if (status.isGranted || status.isProvisional) {
        isPermissionBlocked.value = false;
      }
    } catch (e) {
      debugPrint("Error checking notification permission status: $e");
    }
  }

  String getPostedTime(DateTime dateTime) {
    DateTime localDateTime = DateTime.utc(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
      dateTime.second,
    ).toLocal();

    final now = DateTime.now();
    final difference = now.difference(localDateTime);

    if (difference.inMinutes < 60) {
      return "${difference.inMinutes}m";
    } else if (difference.inHours < 24) {
      return "${difference.inHours}h";
    } else if (difference.inDays < 30) {
      return "${difference.inDays}d";
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return "${months}mo";
    } else {
      final years = (difference.inDays / 365).floor();
      return "${years}y";
    }
  }

  void setPortraitMode() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  /// Initialize notifications after authentication:
  /// - On fresh install: Prompts the OS notification permission popup ("Allow Confeet to send you notifications?").
  /// - On returning sessions: Initializes silently without showing any popup if already granted.
  /// - If user explicitly disabled notifications in Settings (saved == false): Does nothing.
  Future<void> initNotificationIfGranted() async {
    try {
      final saved = StorageService.instance.getValue<bool>('notification_service_enabled');
      // If user explicitly disabled notifications in Settings, do nothing
      if (saved == false) {
        isNotificationsEnabled.value = false;
        return;
      }

      final status = await Permission.notification.status;
      if (status.isGranted || status.isProvisional) {
        // Permission is already granted — initialize silently
        isNotificationsEnabled.value = true;
        await _executeNotificationInit();
      } else if (!status.isPermanentlyDenied) {
        // First install / permission not yet determined:
        // Request permission now, which triggers the native OS popup!
        final reqStatus = await Permission.notification.request();
        if (reqStatus.isGranted || reqStatus.isProvisional) {
          isNotificationsEnabled.value = true;
          await StorageService.instance.setValue('notification_service_enabled', true);
          await _executeNotificationInit();
        } else {
          isNotificationsEnabled.value = false;
          await StorageService.instance.setValue('notification_service_enabled', false);
          if (reqStatus.isPermanentlyDenied) {
            isPermissionBlocked.value = true;
          }
        }
      } else {
        isPermissionBlocked.value = true;
        isNotificationsEnabled.value = false;
      }
    } catch (e) {
      debugPrint("initNotificationIfGranted error: $e");
    }
  }

  /// Alias for readability in login and splash flows
  Future<void> initNotificationAfterLogin() => initNotificationIfGranted();

  /// Internal helper to execute Firebase and local notification configuration
  Future<void> _executeNotificationInit() async {
    if (isConfiguring.value) return;
    isConfiguring.value = true;

    try {
      await PushNotificationInit.init();
      await checkPermissionStatus();
    } catch (e, stack) {
      debugPrint("Notification initialization error: $e\n$stack");
    } finally {
      isConfiguring.value = false;
    }
  }

  /// Public method to configure notifications if enabled
  Future<void> initNotificationConfigure() async {
    if (!isNotificationsEnabled.value) {
      debugPrint("NotificationHandlerService: notifications are disabled, skipping configuration.");
      return;
    }
    await _executeNotificationInit();
  }

  /// Toggle notification service on/off from Settings.
  /// When enabling, this immediately requests OS permission and triggers
  /// the native system popup: 'Allow Confeet to send you notifications?'
  Future<bool> setNotificationsEnabled(bool enable) async {
    if (enable) {
      // Check current permission status
      final status = await Permission.notification.status;
      if (status.isPermanentlyDenied) {
        isPermissionBlocked.value = true;
        isNotificationsEnabled.value = false;
        await StorageService.instance.setValue('notification_service_enabled', false);
        return false;
      }

      // Triggers the system popup: "Allow Confeet to send you notifications?"
      final reqStatus = await Permission.notification.request();

      if (reqStatus.isPermanentlyDenied) {
        isPermissionBlocked.value = true;
        isNotificationsEnabled.value = false;
        await StorageService.instance.setValue('notification_service_enabled', false);
        return false;
      }

      if (!reqStatus.isGranted && !reqStatus.isProvisional) {
        // User dismissed or chose "Don't allow" on the popup
        isNotificationsEnabled.value = false;
        await StorageService.instance.setValue('notification_service_enabled', false);
        return false;
      }

      // User chose "Allow" on the popup
      isPermissionBlocked.value = false;
      isNotificationsEnabled.value = true;
      await StorageService.instance.setValue('notification_service_enabled', true);

      try {
        await FirebaseMessaging.instance.setAutoInitEnabled(true);
      } catch (_) {}

      await _executeNotificationInit();
      return true;
    } else {
      isNotificationsEnabled.value = false;
      await StorageService.instance.setValue('notification_service_enabled', false);

      try {
        await FirebaseMessaging.instance.setAutoInitEnabled(false);
      } catch (_) {}

      try {
        await FlutterLocalNotificationsPlugin().cancelAll();
      } catch (_) {}

      return true;
    }
  }

  /// Open device app notification settings in OS
  Future<void> openSystemSettings() async {
    await openAppSettings();
    await _syncPermissionAndState();
  }
}
