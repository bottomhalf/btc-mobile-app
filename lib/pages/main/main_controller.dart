import 'package:get/get.dart';

class MainController extends GetxController {
  final currentIndex = 0.obs;
  final isSidebarCollapsed = true.obs;

  void changePage(int index) {
    currentIndex.value = index;
  }

  void toggleSidebar() {
    isSidebarCollapsed.value = !isSidebarCollapsed.value;
  }
}
