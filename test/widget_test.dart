import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:conference/core/storage/storage.dart';
import 'package:conference/theme/theme_service.dart';

import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUp(() async {
    // Initialize Hive in a temporary directory for unit testing
    tempDir = Directory.systemTemp.createTempSync();
    
    // Mock the path_provider channel
    const MethodChannel channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return tempDir.path;
    });

    await StorageService.instance.initialize();
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
    Get.reset();
  });

  test('ThemeService changes theme and saves to storage', () async {
    final themeService = Get.put(ThemeService());
    
    // Check default theme is light
    expect(themeService.themeMode, ThemeMode.light);
    expect(themeService.isDarkMode, false);

    // Toggle theme to dark
    themeService.toggleTheme();
    expect(themeService.themeMode, ThemeMode.dark);
    expect(themeService.isDarkMode, true);

    // Check it saved to storage
    final saved = StorageService.instance.getValue<String>('theme_mode');
    expect(saved, 'dark');

    // Toggle theme back to light
    themeService.toggleTheme();
    expect(themeService.themeMode, ThemeMode.light);
    expect(themeService.isDarkMode, false);
    
    final savedLight = StorageService.instance.getValue<String>('theme_mode');
    expect(savedLight, 'light');
  });
}
