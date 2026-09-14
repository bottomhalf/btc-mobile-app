import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/http_service.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _attemptAutoLogin();
  }

  Future<void> _attemptAutoLogin() async {
    // Run auto-login and a minimum splash duration in parallel
    final results = await Future.wait([
      HttpService.instance.tryAutoLogin(),
      Future.delayed(const Duration(seconds: 2), () => true),
    ]);

    final isAuthenticated = results[0];

    if (isAuthenticated) {
      debugPrint('Auto-login successful — navigating to home');
      Get.offNamed('/main');
    } else {
      debugPrint('Auto-login failed — navigating to login');
      Get.offNamed('/login');
    }
  }
}
