import 'package:conference/models/participant.dart';

class Conversation {
  final String conversationId;
  final String type;
  final String title;
  final DateTime? lastMessageAt;
  final int memberCount;
  final String? lastMessage;
  final List<Participant> members;
  final DateTime? createdAt;
  final String? createdBy;

  Conversation({
    required this.conversationId,
    required this.title,
    this.lastMessageAt,
    this.lastMessage,
    required this.memberCount,
    required this.members,
    required this.type,
    this.createdAt,
    this.createdBy,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    final parsedLastMessageAt = _parseDateTime(json['last_message_at']);
    final parsedCreatedAt = _parseDateTime(json['created_at']) ??
        (parsedLastMessageAt != null
            ? parsedLastMessageAt.subtract(const Duration(days: 1))
            : DateTime.now().subtract(const Duration(days: 2)));

    return Conversation(
      conversationId: json['conversation_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      type: json['type'] as String? ?? "",
      memberCount: json['member_count'] as int? ?? 0,
      members: Participant.fromJsonList(json['members']),
      lastMessage: json['lastMessage'],
      lastMessageAt: parsedLastMessageAt,
      createdAt: parsedCreatedAt,
      createdBy: json['created_by'] as String? ?? '',
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is int) {
      // 10 digits = seconds, 13 digits = milliseconds
      return DateTime.fromMillisecondsSinceEpoch(
        value < 10000000000 ? value * 1000 : value,
      );
    }
    if (value is double) {
      return DateTime.fromMillisecondsSinceEpoch(
        value < 10000000000 ? (value * 1000).toInt() : value.toInt(),
      );
    }
    if (value is String) {
      final intVal = int.tryParse(value);
      if (intVal != null) {
        return DateTime.fromMillisecondsSinceEpoch(
          intVal < 10000000000 ? intVal * 1000 : intVal,
        );
      }
      return DateTime.tryParse(value);
    }
    return null;
  }

  /// Formatted time-ago string for last activity.
  String get timeAgo {
    if (lastMessageAt == null) return '';
    final diff = DateTime.now().difference(lastMessageAt!);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${lastMessageAt!.day}/${lastMessageAt!.month}/${lastMessageAt!.year}';
  }
}

