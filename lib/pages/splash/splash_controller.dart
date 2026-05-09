import 'package:get/get.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    // Navigate to login after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      Get.offNamed('/login');
    });
  }
}
