import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Holds all configuration values for the current environment.
///
/// Call [AppConfig.initialize] once before `runApp` — it reads the correct
/// JSON asset based on `--dart-define=ENV=<env>` (defaults to `development`).
///
/// Usage:
/// ```dart
/// await AppConfig.initialize();
/// final baseUrl = AppConfig.instance.apiBaseUrl;
/// ```
class AppConfig {
  // ─── Singleton ──────────────────────────────────────────────────
  static AppConfig? _instance;

  static AppConfig get instance {
    assert(_instance != null, 'AppConfig.initialize() must be called first.');
    return _instance!;
  }

  // ─── Fields ─────────────────────────────────────────────────────
  final String env;
  final String apiBaseUrl;
  final String wsBaseUrl;
  final String livekitUrl;
  final int port;
  final int connectionTimeout;
  final bool enableLogs;
  final String socketHandshakEndpoint;

  AppConfig._({
    required this.env,
    required this.apiBaseUrl,
    required this.wsBaseUrl,
    required this.livekitUrl,
    required this.port,
    required this.connectionTimeout,
    required this.enableLogs,
    required this.socketHandshakEndpoint,
  });

  // ─── Initializer ───────────────────────────────────────────────
  static Future<void> initialize() async {
    const env = String.fromEnvironment('ENV', defaultValue: 'production');
    final jsonStr = await rootBundle.loadString('assets/config/$env.json');
    final Map<String, dynamic> json = jsonDecode(jsonStr);

    _instance = AppConfig._(
      env: json['env'] as String,
      apiBaseUrl: json['apiBaseUrl'] as String,
      wsBaseUrl: json['wsBaseUrl'] as String,
      livekitUrl: json['livekitUrl'] as String,
      port: json['port'] as int,
      connectionTimeout: json['connectionTimeout'] as int,
      enableLogs: json['enableLogs'] as bool,
      socketHandshakEndpoint: json['socketHandshakEndpoint'] as String,
    );

    if (_instance!.enableLogs) {
      debugPrint('┌─ AppConfig ────────────────────────');
      debugPrint('│ env             : ${_instance!.env}');
      debugPrint('│ apiBaseUrl      : ${_instance!.apiBaseUrl}');
      debugPrint('│ wsBaseUrl       : ${_instance!.wsBaseUrl}');
      debugPrint('│ livekitUrl      : ${_instance!.livekitUrl}');
      debugPrint('│ port            : ${_instance!.port}');
      debugPrint('│ connectionTimeout: ${_instance!.connectionTimeout}s');
      debugPrint(
        '│ socketHandshakeEndpoint: ${_instance!.socketHandshakEndpoint}',
      );
      debugPrint('└────────────────────────────────────');
    }
  }

  /// Whether we are running in the development environment.
  bool get isDevelopment => env == 'development';

  /// Whether we are running in the staging environment.
  bool get isStaging => env == 'staging';

  /// Whether we are running in the production environment.
  bool get isProduction => env == 'production';
}
