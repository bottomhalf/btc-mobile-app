import 'dart:convert';
import 'package:get/get.dart';

class NotificationEvent {
  static final RxList<NotificationEvent> globalNotifications =
      <NotificationEvent>[].obs;

  static void addNotification(NotificationEvent notification) {
    notification.time ??= DateTime.now();

    final int index = globalNotifications.indexWhere((item) {
      if (notification.messageId != null &&
          notification.messageId!.isNotEmpty &&
          notification.messageId == item.messageId) {
        return true;
      }
      if (notification.type != null &&
          item.type != null &&
          notification.type == item.type) {
        return true;
      }
      return false;
    });

    if (index != -1) {
      final existing = globalNotifications.removeAt(index);
      notification.isRead = existing.isRead;
      globalNotifications.insert(0, notification);
    } else {
      globalNotifications.insert(0, notification);
    }
    globalNotifications.refresh();
  }

  // Push notification payload fields
  String? conversationType;
  String? createdAt;
  String? senderName;
  String? senderId;
  String? clientType;
  String? msgType;
  String? conversationName;
  String? conversationId;
  String? messageId;
  String? event;
  String? timestamp;

  // Additional & legacy fields
  String? type;
  String? imageUrl;
  String? content;
  bool isRead;
  DateTime? time;

  NotificationEvent({
    this.conversationType,
    this.createdAt,
    this.senderName,
    this.senderId,
    this.clientType,
    this.msgType,
    this.conversationName,
    this.conversationId,
    this.messageId,
    this.event,
    this.timestamp,
    this.type,
    this.imageUrl,
    this.content,
    this.time,
    this.isRead = false,
  });

  factory NotificationEvent.noArgs() {
    return NotificationEvent();
  }

  static String? _toString(dynamic val) {
    if (val == null) return null;
    final str = val.toString().trim();
    if (str.isEmpty) return null;
    if (str.toLowerCase() == 'hiringbell') return 'Confeet';
    if (str.toLowerCase().contains('hiringbell')) {
      return str.replaceAll(RegExp(r'hiringbell', caseSensitive: false), 'Confeet');
    }
    return str;
  }

  static DateTime? _parseTime(dynamic val) {
    if (val == null) return null;
    if (val is DateTime) return val;
    if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
    final str = val.toString().trim();
    if (str.isEmpty) return null;
    final ms = int.tryParse(str);
    if (ms != null) {
      return DateTime.fromMillisecondsSinceEpoch(ms);
    }
    return DateTime.tryParse(str);
  }

  static Map<String, dynamic> _parsePayloadString(String payload) {
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      } else if (decoded is Map) {
        return decoded.cast<String, dynamic>();
      }
    } catch (_) {}

    final Map<String, dynamic> result = {};
    String clean = payload.trim();
    if (clean.startsWith('{') && clean.endsWith('}')) {
      clean = clean.substring(1, clean.length - 1);
    }

    final keys = [
      'conversationType',
      'createdAt',
      'senderName',
      'senderId',
      'clientType',
      'msgType',
      'conversationName',
      'conversationId',
      'messageId',
      'event',
      'timestamp',
      'type',
      'imageUrl',
      'content',
      'time',
      'isRead',
    ];

    final List<MapEntry<String, int>> positions = [];
    for (final key in keys) {
      int idx = clean.indexOf('$key: ');
      if (idx == -1) {
        idx = clean.indexOf('$key:');
      }
      if (idx != -1) {
        positions.add(MapEntry(key, idx));
      }
    }

    positions.sort((a, b) => a.value.compareTo(b.value));

    for (int i = 0; i < positions.length; i++) {
      final currentKey = positions[i].key;
      final matchPrefix = clean.indexOf('$currentKey: ', positions[i].value) != -1
          ? '$currentKey: '
          : '$currentKey:';
      final startIdx = positions[i].value + matchPrefix.length;
      final endIdx =
          (i + 1 < positions.length) ? positions[i + 1].value : clean.length;

      String val = clean.substring(startIdx, endIdx).trim();
      if (val.endsWith(',')) {
        val = val.substring(0, val.length - 1).trim();
      }
      result[currentKey] = val;
    }
    return result;
  }

  factory NotificationEvent.fromJson(dynamic json) {
    if (json == null) return NotificationEvent.noArgs();

    Map<String, dynamic> jsonMap;
    if (json is Map<String, dynamic>) {
      jsonMap = json;
    } else if (json is Map) {
      jsonMap = json.cast<String, dynamic>();
    } else if (json is String) {
      jsonMap = _parsePayloadString(json);
    } else {
      return NotificationEvent.noArgs();
    }

    final evt = _toString(jsonMap['event']);

    return NotificationEvent(
      conversationType: _toString(
        jsonMap['conversationType'] ?? jsonMap['conversation_type'],
      ),
      createdAt: _toString(
        jsonMap['createdAt'] ?? jsonMap['created_at'],
      ),
      senderName: _toString(
        jsonMap['senderName'] ??
            jsonMap['sender_name'] ??
            jsonMap['fullName'] ??
            jsonMap['name'],
      ),
      senderId: _toString(
        jsonMap['senderId'] ?? jsonMap['sender_id'],
      ),
      clientType: _toString(
        jsonMap['clientType'] ?? jsonMap['client_type'],
      ),
      msgType: _toString(
        jsonMap['msgType'] ?? jsonMap['msg_type'],
      ),
      conversationName: _toString(
        jsonMap['conversationName'] ?? jsonMap['conversation_name'],
      ),
      conversationId: _toString(
        jsonMap['conversationId'] ?? jsonMap['conversation_id'],
      ),
      messageId: _toString(
        jsonMap['messageId'] ?? jsonMap['message_id'],
      ),
      event: evt,
      timestamp: _toString(jsonMap['timestamp']),
      type: _toString(
        jsonMap['type'] ?? jsonMap['eventType'] ?? evt,
      ),
      imageUrl: _toString(
        jsonMap['imageUrl'] ??
            jsonMap['image_url'] ??
            jsonMap['image'] ??
            jsonMap['avatar'] ??
            jsonMap['fileUrl'],
      ),
      content: _toString(
        jsonMap['content'] ??
            jsonMap['body'] ??
            jsonMap['description'] ??
            jsonMap['text'] ??
            jsonMap['message'],
      ),
      time: _parseTime(
        jsonMap['time'] ?? jsonMap['timestamp'] ?? jsonMap['createdAt'],
      ),
      isRead: jsonMap['isRead'] == true || jsonMap['isRead'] == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversationType': conversationType,
      'createdAt': createdAt,
      'senderName': senderName,
      'senderId': senderId,
      'clientType': clientType,
      'msgType': msgType,
      'conversationName': conversationName,
      'conversationId': conversationId,
      'messageId': messageId,
      'event': event,
      'timestamp': timestamp,
      'type': type,
      'imageUrl': imageUrl,
      'content': content,
      'time': time?.millisecondsSinceEpoch.toString(),
      'isRead': isRead,
    };
  }

  NotificationEvent copyWith({
    String? conversationType,
    String? createdAt,
    String? senderName,
    String? senderId,
    String? clientType,
    String? msgType,
    String? conversationName,
    String? conversationId,
    String? messageId,
    String? event,
    String? timestamp,
    String? type,
    String? imageUrl,
    String? content,
    DateTime? time,
    bool? isRead,
  }) {
    return NotificationEvent(
      conversationType: conversationType ?? this.conversationType,
      createdAt: createdAt ?? this.createdAt,
      senderName: senderName ?? this.senderName,
      senderId: senderId ?? this.senderId,
      clientType: clientType ?? this.clientType,
      msgType: msgType ?? this.msgType,
      conversationName: conversationName ?? this.conversationName,
      conversationId: conversationId ?? this.conversationId,
      messageId: messageId ?? this.messageId,
      event: event ?? this.event,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      content: content ?? this.content,
      time: time ?? this.time,
      isRead: isRead ?? this.isRead,
    );
  }
}
