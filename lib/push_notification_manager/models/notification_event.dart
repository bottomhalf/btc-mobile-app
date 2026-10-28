import 'dart:convert';
import 'package:get/get.dart';

class NotificationEvent {
  static final RxList<NotificationEvent> globalNotifications =
      <NotificationEvent>[].obs;

  static void addNotification(NotificationEvent notification) {
    notification.time ??= DateTime.now();

    final int index = globalNotifications.indexWhere((item) {
      if (notification.type != null) {
        return item.type == notification.type;
      }
      if (notification.messageId != null &&
          notification.messageId!.isNotEmpty &&
          notification.messageId == item.messageId &&
          notification.senderId == item.senderId) {
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

  String? type;
  String? imageUrl;
  String? conversationId;
  String? messageId;
  String? senderId;
  String? senderName;
  String? content;
  DateTime? time;
  bool isRead;

  NotificationEvent({
    this.type,
    this.imageUrl,
    this.conversationId,
    this.messageId,
    this.senderId,
    this.senderName,
    this.content,
    this.time,
    this.isRead = false,
  });

  factory NotificationEvent.noArgs() {
    return NotificationEvent();
  }

  static int _toInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    if (val is double) return val.toInt();
    if (val is String) return int.tryParse(val) ?? 0;
    return 0;
  }

  static String? _toString(dynamic val) {
    if (val == null) return null;
    return val.toString();
  }

  static DateTime? _parseTime(dynamic val) {
    if (val == null) return null;
    final ms = int.tryParse(val.toString());
    if (ms != null) {
      return DateTime.fromMillisecondsSinceEpoch(ms);
    }
    return null;
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
      'type',
      'imageUrl',
      'conversationId',
      'messageId',
      'senderId',
      'senderName',
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
      final startIdx = positions[i].value + currentKey.length + 2;
      final endIdx = (i + 1 < positions.length) ? positions[i + 1].value : clean.length;

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

    return NotificationEvent(
      type: _toString(jsonMap['type']),
      imageUrl: _toString(jsonMap['imageUrl']),
      conversationId: _toString(jsonMap['conversationId']),
      messageId: _toString(jsonMap['messageId']),
      senderId: _toString(jsonMap['senderId']),
      senderName: _toString(jsonMap['fullName']),
      content: _toString(jsonMap['deviceId']),
      time: _parseTime(jsonMap['time']),
      isRead: jsonMap['isRead'] == true || jsonMap['isRead'] == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'imageUrl': imageUrl,
      'conversationId': conversationId,
      'messageId': messageId,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'time': time?.millisecondsSinceEpoch.toString(),
      'isRead': isRead,
    };
  }
}
