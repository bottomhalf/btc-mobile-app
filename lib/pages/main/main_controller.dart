import 'dart:async';
import 'package:conference/config/app_config.dart';
import 'package:conference/models/conversation.dart';
import 'package:conference/models/user_model.dart';
import 'package:conference_sdk/conference_sdk.dart';
import 'package:flutter/cupertino.dart';
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
