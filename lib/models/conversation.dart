import 'package:conference/models/participant.dart';

class ConversationSettings {
  final bool allowReactions;
  final bool allowPinning;
  final bool adminOnlyPost;

  ConversationSettings({
    this.allowReactions = true,
    this.allowPinning = true,
    this.adminOnlyPost = false,
  });

  factory ConversationSettings.fromJson(Map<String, dynamic> json) {
    return ConversationSettings(
      allowReactions: json['allowReactions'] as bool? ?? true,
      allowPinning: json['allowPinning'] as bool? ?? true,
      adminOnlyPost: json['adminOnlyPost'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allowReactions': allowReactions,
      'allowPinning': allowPinning,
      'adminOnlyPost': adminOnlyPost,
    };
  }
}

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
  final String? avatar;
  final String? description;
  final bool isDeleted;
  final String? lastMessageId;
  final ConversationSettings? settings;
  final List<String> searchableMemberInfo;
  final List<String> participantIds;

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
    this.avatar,
    this.description,
    this.isDeleted = false,
    this.lastMessageId,
    this.settings,
    this.searchableMemberInfo = const [],
    this.participantIds = const [],
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    final parsedLastMessageAt = _parseDateTime(json['last_message_at'] ?? json['lastMessageAt']);
    final parsedCreatedAt = _parseDateTime(json['created_at'] ?? json['createdAt']) ??
        (parsedLastMessageAt != null
            ? parsedLastMessageAt.subtract(const Duration(days: 1))
            : DateTime.now().subtract(const Duration(days: 2)));

    ConversationSettings? parsedSettings;
    if (json['settings'] != null) {
      parsedSettings = ConversationSettings.fromJson(json['settings'] as Map<String, dynamic>);
    }

    return Conversation(
      conversationId: json['conversation_id'] as String? ?? json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      type: json['type'] as String? ?? "",
      memberCount: json['member_count'] as int? ?? json['memberCount'] as int? ?? 0,
      members: Participant.fromJsonList(json['members'] ?? json['participants']),
      lastMessage: json['lastMessage'] as String?,
      lastMessageAt: parsedLastMessageAt,
      createdAt: parsedCreatedAt,
      createdBy: json['created_by'] as String? ?? json['createdBy'] as String? ?? '',
      avatar: json['avatar'] as String?,
      description: json['description'] as String?,
      isDeleted: json['isDeleted'] as bool? ?? json['is_deleted'] as bool? ?? false,
      lastMessageId: json['lastMessageId'] as String? ?? json['last_message_id'] as String?,
      settings: parsedSettings,
      searchableMemberInfo: (json['searchableMemberInfo'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      participantIds: (json['participant_ids'] as List?)?.map((e) => e.toString()).toList() ??
                      (json['participantIds'] as List?)?.map((e) => e.toString()).toList() ?? const [],
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
