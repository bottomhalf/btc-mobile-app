import 'package:conference_sdk/conference_sdk.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import 'config/app_config.dart';
import 'core/storage/storage.dart';
import 'services/http_service.dart';
import 'services/meeting_service.dart';
import 'pages/splash/splash_page.dart';
import 'pages/splash/splash_controller.dart';
import 'pages/team/team_controller.dart';
import 'pages/team/service/chat_service.dart';
import 'pages/team/chat_detail_controller.dart';
import 'pages/team/chat_detail_page.dart';
import 'pages/meet/meet_controller.dart';
import 'pages/meet/sub_pages/schedule_meeting/schedule_meeting_controller.dart';
import 'pages/meet/sub_pages/schedule_meeting/schedule_meeting_page.dart';
import 'pages/calendar/sub_pages/meet_calendar/meet_calendar_controller.dart';
import 'pages/calendar/sub_pages/meet_calendar/meet_calendar_page.dart';
import 'pages/calendar/calendar_controller.dart';
import 'pages/notification/notification_controller.dart';
import 'pages/notification/notification_page.dart';
import 'pages/profile/profile_controller.dart';
import 'pages/profile/profile_page.dart';
import 'pages/search/team_search_controller.dart';
import 'pages/search/team_search_page.dart';
import 'pages/login/login_controller.dart';
import 'pages/login/login_page.dart';
import 'pages/main/main_controller.dart';
import 'pages/main/main_page.dart';
import 'theme/app_theme.dart';
import 'theme/theme_service.dart';
import 'widgets/meeting_overlay_manager.dart';

Future<void> _checkPermissions() async {
  var status = await Permission.bluetooth.request();
  if (status.isPermanentlyDenied) {
    debugPrint('Bluetooth Permission disabled');
  }
  status = await Permission.bluetoothConnect.request();
  if (status.isPermanentlyDenied) {
    debugPrint('Bluetooth Connect Permission disabled');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _checkPermissions();
  await AppConfig.initialize();
  await StorageService.instance.initialize();
  await HttpService.instance.initialize();

  // Register MeetingService as a permanent GetxService
  Get.put(MeetingService(), permanent: true);

  // Register ChatService as a permanent GetxService
  Get.put(ChatService(), permanent: true);

  // Register ThemeService
  Get.put(ThemeService(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GetMaterialApp(
        title: 'Conference',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeService.instance.themeMode,
        initialRoute: '/splash',
      getPages: [
        GetPage(
          name: '/splash',
          page: () => const SplashPage(),
          binding: BindingsBuilder(() {
            Get.put(SplashController());
          }),
        ),
        GetPage(
          name: '/login',
          page: () => const LoginPage(),
          binding: BindingsBuilder(() {
            Get.lazyPut(() => LoginController());
          }),
        ),
        GetPage(
          name: '/main',
          page: () => const MainPage(),
          binding: BindingsBuilder(() {
            Get.lazyPut(() => MainController());
            Get.lazyPut(() => TeamController());
            Get.lazyPut(() => MeetController());
            Get.lazyPut(() => CalendarController());
          }),
        ),
        GetPage(
          name: '/chat-detail',
          page: () => const ChatDetailPage(),
          binding: BindingsBuilder(() {
            // MainController needed for desktop side menu
            if (!Get.isRegistered<MainController>()) {
              Get.lazyPut(() => MainController());
            }
            Get.lazyPut(() => ChatDetailController());
          }),
        ),
        GetPage(
          name: '/schedule-meeting',
          page: () => const ScheduleMeetingPage(),
          binding: BindingsBuilder(() {
            Get.lazyPut(() => ScheduleMeetingController());
          }),
        ),
        GetPage(
          name: '/meet-calendar',
          page: () => const MeetCalendarPage(),
          binding: BindingsBuilder(() {
            Get.lazyPut(() => MeetCalendarController());
          }),
        ),
        GetPage(
          name: '/notifications',
          page: () => const NotificationPage(),
          binding: BindingsBuilder(() {
            Get.lazyPut(() => NotificationController());
          }),
        ),
        GetPage(
          name: '/profile',
          page: () => const ProfilePage(),
          binding: BindingsBuilder(() {
            Get.lazyPut(() => ProfileController());
          }),
        ),
        GetPage(
          name: '/search',
          page: () => const TeamSearchPage(),
          binding: BindingsBuilder(() {
            Get.lazyPut(() => TeamSearchController());
          }),
        ),
      ],
      // Wrap entire app with the overlay manager
      builder: (context, child) {
        return MeetingOverlayManager(child: child ?? const SizedBox.shrink());
      },
    ),);
  }
}
