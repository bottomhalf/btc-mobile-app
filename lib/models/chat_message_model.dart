import 'package:conference_sdk/conference_sdk.dart';

class ChatMessage {
  final String id;
  final String messageId;
  final String conversationId;
  final String senderId;
  final String recievedId;
  final String type;
  final String avatar;
  final String content;
  final String? fileUrl;
  final String? replyTo;
  final List<dynamic> mentions;
  final List<dynamic> reactions;
  final String clientType;
  final DateTime? createdAt;
  final DateTime? editedAt;
  final int status;
  final bool isNewConversation;
  final bool edited;
  final bool seen;
  final bool reply;
  final String idAsString;
  final String conversationIdAsString;
  final String? replyToAsString;
  final bool deleted;

  ChatMessage({
    required this.id,
    required this.messageId,
    required this.conversationId,
    required this.senderId,
    this.recievedId = '',
    required this.type,
    this.avatar = '',
    String? content,
    String? body,
    this.fileUrl,
    this.replyTo,
    this.mentions = const [],
    this.reactions = const [],
    this.clientType = 'mobile',
    this.createdAt,
    this.editedAt,
    this.status = 0,
    this.isNewConversation = false,
    this.edited = false,
    this.seen = false,
    this.reply = false,
    this.idAsString = '',
    this.conversationIdAsString = '',
    this.replyToAsString,
    this.deleted = false,
  }) : content = content ?? body ?? '';

  String get body => content;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String? ?? '',
      messageId: json['messageId'] as String? ?? '',
      conversationId: json['conversationId'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      recievedId: json['recievedId'] as String? ?? json['recieved_id'] as String? ?? '',
      type: json['type'] as String? ?? 'text',
      avatar: json['avatar'] as String? ?? '',
      content: json['content'] as String? ?? json['body'] as String? ?? '',
      fileUrl: json['fileUrl'] as String? ?? json['file_url'] as String?,
      replyTo: json['replyTo'] as String? ?? json['reply_to'] as String?,
      mentions: json['mentions'] as List<dynamic>? ?? const [],
      reactions: json['reactions'] as List<dynamic>? ?? const [],
      clientType: json['clientType'] as String? ?? json['client_type'] as String? ?? '',
      createdAt: _parseDateTime(json['createdAt'] ?? json['created_at']),
      editedAt: _parseDateTime(json['editedAt'] ?? json['edited_at']),
      status: json['status'] as int? ?? 0,
      isNewConversation: json['isNewConversation'] as bool? ?? json['is_new_conversation'] as bool? ?? false,
      edited: json['edited'] as bool? ?? false,
      seen: json['seen'] as bool? ?? false,
      reply: json['reply'] as bool? ?? false,
      idAsString: json['idAsString'] as String? ?? json['id_as_string'] as String? ?? '',
      conversationIdAsString: json['conversationIdAsString'] as String? ?? json['conversation_id_as_string'] as String? ?? '',
      replyToAsString: json['replyToAsString'] as String? ?? json['reply_to_as_string'] as String?,
      deleted: json['deleted'] as bool? ?? false,
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is int) {
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
}

class ChatMessageResponse {
  final List<Message> messages;
  final int totalCount;
  final int page;
  final int pageSize;
  final bool hasMore;
  final double searchTimeMs;
  final int totalPages;

  ChatMessageResponse({
    required this.messages,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.hasMore,
    required this.searchTimeMs,
    required this.totalPages,
  });

  factory ChatMessageResponse.fromJson(Map<String, dynamic> json) {
    return ChatMessageResponse(
      messages: (json['messages'] as List<dynamic>?)
              ?.map((e) => Message.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalCount: json['totalCount'] as int? ?? json['total_count'] as int? ?? 0,
      page: json['page'] as int? ?? 0,
      pageSize: json['pageSize'] as int? ?? json['page_size'] as int? ?? 0,
      hasMore: json['hasMore'] as bool? ?? json['has_more'] as bool? ?? false,
      searchTimeMs: (json['searchTimeMs'] as num?)?.toDouble() ?? (json['search_time_ms'] as num?)?.toDouble() ?? 0.0,
      totalPages: json['totalPages'] as int? ?? json['total_pages'] as int? ?? 0,
    );
  }
}
