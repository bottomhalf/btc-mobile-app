// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
// import '../config/app_config.dart';
// import 'http_service.dart';
//
// /// Centralized WebSocket service — manages WebSocket connections.
// ///
// /// Populated automatically from [AppConfig] on first access.
// class WebSocketService {
//   // ─── Singleton ──────────────────────────────────────────────────
//   WebSocketService._();
//   static final WebSocketService _instance = WebSocketService._();
//   static WebSocketService get instance => _instance;
//
//   // ─── State ──────────────────────────────────────────────────────
//   WebSocketChannel? _channel;
//   final _messageController = StreamController<dynamic>.broadcast();
//   bool _isConnected = false;
//
//   /// Stream of incoming WebSocket messages.
//   Stream<dynamic> get messages => _messageController.stream;
//
//   /// Whether the WebSocket is currently connected.
//   bool get isConnected => _isConnected;
//
//   // ─── Helpers ────────────────────────────────────────────────────
//   String get _wsBaseUrl => AppConfig.instance.wsBaseUrl;
//
//   void _log(String message) {
//     if (AppConfig.instance.enableLogs) {
//       debugPrint('[WS] $message');
//     }
//   }
//
//   // ─── Public API ─────────────────────────────────────────────────
//
//   /// Connect to the WebSocket server at [path].
//   ///
//   /// The full URL is `wsBaseUrl + path`.
//   /// Includes the auth token as a query parameter if available.
//   Future<void> connect([String path = '']) async {
//     if (_isConnected) {
//       _log('Already connected — disconnect first.');
//       return;
//     }
//
//     final token = HttpService.instance.isAuthenticated
//         ? '?token=${Uri.encodeComponent(HttpService.instance.authToken!)}'
//         : '';
//
//     final uri = Uri.parse('$_wsBaseUrl$path$token');
//     _log('Connecting to $uri');
//
//     _channel = WebSocketChannel.connect(uri);
//
//     // Wait for the connection to be ready
//     try {
//       await _channel!.ready;
//       _isConnected = true;
//       _log('Connected');
//     } catch (e) {
//       _isConnected = false;
//       _log('Connection failed: $e');
//       rethrow;
//     }
//
//     // Forward incoming messages to the broadcast stream
//     _channel!.stream.listen(
//       (message) {
//         _log('← $message');
//         _messageController.add(message);
//       },
//       onError: (error) {
//         _log('Error: $error');
//         _isConnected = false;
//         _messageController.addError(error);
//       },
//       onDone: () {
//         _log('Disconnected');
//         _isConnected = false;
//       },
//     );
//   }
//
//   /// Send a JSON-encodable [data] object through the WebSocket.
//   void send(Object data) {
//     if (!_isConnected || _channel == null) {
//       _log('Cannot send — not connected.');
//       return;
//     }
//     final encoded = jsonEncode(data);
//     _log('→ $encoded');
//     _channel!.sink.add(encoded);
//   }
//
//   /// Send a raw string message through the WebSocket.
//   void sendRaw(String message) {
//     if (!_isConnected || _channel == null) {
//       _log('Cannot send — not connected.');
//       return;
//     }
//     _log('→ $message');
//     _channel!.sink.add(message);
//   }
//
//   /// Disconnect from the WebSocket server.
//   Future<void> disconnect() async {
//     if (!_isConnected) return;
//     _log('Disconnecting...');
//     await _channel?.sink.close();
//     _isConnected = false;
//   }
//
//   /// Dispose the service entirely.
//   void dispose() {
//     disconnect();
//     _messageController.close();
//   }
// }
