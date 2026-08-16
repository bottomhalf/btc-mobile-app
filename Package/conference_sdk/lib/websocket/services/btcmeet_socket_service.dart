import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/call_model.dart';
import 'messages/incoming/incoming_message_streams.dart';
import 'messages/outgoing/outgoing_message_streams.dart';

class LocalUserInfo {
  final String userId;
  final String fullName;
  final String email;
  final String avatar;

  LocalUserInfo({
    required this.userId,
    required this.fullName,
    required this.email,
    this.avatar = '',
  });
}

class SdkNotification {
  final String id;
  final String type; // 'info' | 'warning' | 'success'
  final String title;
  final String content;
  final String conversationId;
  final DateTime timestamp;
  final bool read;

  SdkNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.conversationId,
    required this.timestamp,
    required this.read,
  });
}

class BtcMeetSocketService {
  // ─── Singleton Pattern ──────────────────────────────────────────
  BtcMeetSocketService._();
  static final BtcMeetSocketService _instance = BtcMeetSocketService._();
  static BtcMeetSocketService get instance => _instance;

  // ─── Low-Level Socket state ─────────────────────────────────────
  WebSocket? _ws;
  StreamSubscription? _wsSubscription;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  bool _isConnecting = false;

  late String _url;
  late String _senderId;
  LocalUserInfo? _localUser;
  LocalUserInfo? get localUser => _localUser;

  // ─── Observables / Streams ──────────────────────────────────────
  final StreamController<WsEvent> _messageSubject = StreamController<WsEvent>.broadcast();
  final StreamController<bool> _isConnectedSubject = StreamController<bool>.broadcast();
  final StreamController<SdkNotification> _notificationController = StreamController<SdkNotification>.broadcast();

  // Exposed observables
  Stream<WsEvent> get messages$ => _messageSubject.stream;
  Stream<bool> get isConnected$ => _isConnectedSubject.stream;
  Stream<SdkNotification> get notifications$ => _notificationController.stream;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  // ─── Angular Signals equivalents (ValueNotifiers) ───────────────
  final ValueNotifier<dynamic> currentConversation = ValueNotifier<dynamic>(null);
  final ValueNotifier<String?> currentConversationId = ValueNotifier<String?>(null);

  // ─── Event-specific Streams ─────────────────────────────────────
  late final Stream<Message> incomingMessage$;
  late final Stream<Message> outgoingMessage$;
  late final Stream<MessageDelivered> delivered$;
  late final Stream<MessageSeen> seen$;
  late final Stream<TypingIndicator> userTyping$;
  late final Stream<ErrorPayload> error$;
  late final Stream<PongPayload> pong$;
  late final Stream<Map<String, dynamic>> initUserList$;
  late final Stream<dynamic> messageReacted$;
  late final Stream<dynamic> userStatus$;

  // ─── Configuration ──────────────────────────────────────────────
  final int _reconnectIntervalMs = 3000;
  final int _heartbeatIntervalMs = 30000; // 30 seconds default

  void initStreams() {
    incomingMessage$ = buildIncomingMessageStream(this);
    outgoingMessage$ = buildOutgoingMessageStream(this);
    delivered$ = buildDeliveredStream(this);
    seen$ = buildSeenStream(this);
    userTyping$ = buildUserTypingStream(this);
    error$ = buildErrorStream(this);
    pong$ = buildPongStream(this);
    initUserList$ = buildInitUserListStream(this);
    messageReacted$ = buildMessageReactedStream(this);
    userStatus$ = buildUserStatusStream(this);
  }

  void connect(String url, LocalUserInfo localUser) {
    _url = url;
    _localUser = localUser;
    _senderId = localUser.userId;
    initStreams();

    if (_ws != null || _isConnecting) return;

    _initSocket();
  }

  Future<void> _initSocket() async {
    _isConnecting = true;
    final connectionUrl = '$_url/ws?userId=$_senderId';
    debugPrint('[BtcMeetSocketService] Connecting to: $connectionUrl');

    try {
      _ws = await WebSocket.connect(connectionUrl).timeout(const Duration(seconds: 10));
      _isConnected = true;
      _isConnecting = false;
      _isConnectedSubject.add(true);

      debugPrint('[BtcMeetSocketService] WS connected');
      _sendPing(_senderId);
      _startHeartbeat(_senderId);

      _wsSubscription = _ws!.listen(
        (data) {
          try {
            final Map<String, dynamic> json = jsonDecode(data as String);
            final event = WsEvent.fromJson(json);
            _messageSubject.add(event);
          } catch (e) {
            debugPrint('[BtcMeetSocketService] Error parsing message: $e');
          }
        },
        onError: (error) {
          debugPrint('[BtcMeetSocketService] WS error: $error');
          _handleDisconnect();
        },
        onDone: () {
          debugPrint('[BtcMeetSocketService] WS closed by server');
          _handleDisconnect();
        },
        cancelOnError: true,
      );
    } catch (error) {
      debugPrint('[BtcMeetSocketService] Connection failed: $error');
      _isConnecting = false;
      _handleDisconnect();
    }
  }

  void _handleDisconnect() {
    _isConnected = false;
    _isConnectedSubject.add(false);
    _stopHeartbeat();
    _wsSubscription?.cancel();
    _wsSubscription = null;
    _ws = null;

    // Schedule reconnection
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(milliseconds: _reconnectIntervalMs), () {
      if (!_isConnected && !_isConnecting) {
        debugPrint('[BtcMeetSocketService] Reconnecting...');
        _initSocket();
      }
    });
  }


  // ─── Public Send APIs ───────────────────────────────────────────

  void sendMessage(Message message) {
    _send(WsEvents.sendMessage, message.toJson());
  }

  void sendMessageReaction(Map<String, dynamic> payload) {
    _send(WsEvents.reactMessage, payload);
  }

  void getInitUser() {
    _send(WsEvents.initUserlist, {});
  }

  void updateStatus(String status) {
    _send(WsEvents.updateStatus, {'status': status});
  }

  void markDelivered(String id, String userId, String conversationId) {
    _send(WsEvents.markDelivered, {
      'id': id,
      'conversationId': conversationId,
      'userId': userId,
      'deliveredAt': DateTime.now().toUtc().toIso8601String(),
    });
  }

  void markSeen(String messageId, String userId, String conversationId) {
    _send(WsEvents.markSeen, {
      'messageId': messageId,
      'conversationId': conversationId,
      'userId': userId,
      'seenAt': DateTime.now().toUtc().toIso8601String(),
    });
  }

  void sendTyping(String conversationId, bool isTyping) {
    _send(WsEvents.typing, {
      'conversationId': conversationId,
      'isTyping': isTyping,
    });
  }

  void sendEvent<T>(String event, T payload) {
    _send(event, payload);
  }

  // ─── Private Low-Level Send ─────────────────────────────────────
  void _send(String event, dynamic payload) {
    if (_ws != null && _ws!.readyState == WebSocket.open) {
      final wsEvent = WsEvent(event: event, payload: payload);
      final jsonStr = jsonEncode(wsEvent.toJson());
      _ws!.add(jsonStr);
    } else {
      debugPrint('[BtcMeetSocketService] Cannot send event "$event": WS not open');
    }
  }

  // ─── Connection Lifecycle ───────────────────────────────────────
  void disconnect() {
    _stopHeartbeat();
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _isConnected = false;
    _isConnectedSubject.add(false);
    _wsSubscription?.cancel();
    _wsSubscription = null;
    _ws?.close();
    _ws = null;
    debugPrint('[BtcMeetSocketService] WS disconnected manually');
  }

  // ─── Heartbeat Mechanism ────────────────────────────────────────
  void _startHeartbeat(String userId) {
    _stopHeartbeat();
    debugPrint('[BtcMeetSocketService] Starting heartbeat with interval: $_heartbeatIntervalMs ms');

    _heartbeatTimer = Timer.periodic(Duration(milliseconds: _heartbeatIntervalMs), (timer) {
      _sendPing(userId);
    });
  }

  void _stopHeartbeat() {
    if (_heartbeatTimer != null) {
      debugPrint('[BtcMeetSocketService] Stopping heartbeat');
      _heartbeatTimer!.cancel();
      _heartbeatTimer = null;
    }
  }

  void _sendPing(String userId) {
    debugPrint('[BtcMeetSocketService] Sending heartbeat ping');
    _send(WsEvents.heartbeat, {'userId': userId});
  }

  void showNotification(SdkNotification notification) {
    _notificationController.add(notification);
  }

  // Expose message subject stream (equivalent to getMessageSubject)
  StreamController<WsEvent> getMessageSubject() {
    return _messageSubject;
  }

  void dispose() {
    disconnect();
    _messageSubject.close();
    _isConnectedSubject.close();
    _notificationController.close();
  }
}
