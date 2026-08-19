import 'package:conference/models/conversation.dart';
import 'package:conference_sdk/conference_sdk.dart' show Message;

class GlobalSearchResponse {
  final GroupedResults? results;
  final SearchMetadata? metadata;
  final ErrorInfo? error;

  GlobalSearchResponse({
    this.results,
    this.metadata,
    this.error,
  });

  factory GlobalSearchResponse.fromJson(Map<String, dynamic> json) {
    return GlobalSearchResponse(
      results: json['results'] != null
          ? GroupedResults.fromJson(json['results'] as Map<String, dynamic>)
          : null,
      metadata: json['metadata'] != null
          ? SearchMetadata.fromJson(json['metadata'] as Map<String, dynamic>)
          : null,
      error: json['error'] != null
          ? ErrorInfo.fromJson(json['error'] as Map<String, dynamic>)
          : null,
    );
  }

  bool get hasResults {
    if (results != null) {
      return (results!.users != null && results!.users!.isNotEmpty) ||
          (results!.conversations != null && results!.conversations!.isNotEmpty) ||
          (results!.messages != null && results!.messages!.isNotEmpty) ||
          (results!.files != null && results!.files!.isNotEmpty);
    }
    return false;
  }

  bool get hasError => error != null;
}

class GroupedResults {
  final List<Users>? users;
  final List<Conversation>? conversations;
  final List<Message>? messages;
  final List<SearchResultItem>? files;

  final int userCount;
  final int conversationCount;
  final int messageCount;
  final int fileCount;

  GroupedResults({
    this.users,
    this.conversations,
    this.messages,
    this.files,
    required this.userCount,
    required this.conversationCount,
    required this.messageCount,
    required this.fileCount,
  });

  factory GroupedResults.fromJson(Map<String, dynamic> json) {
    return GroupedResults(
      users: (json['users'] as List<dynamic>?)
          ?.map((e) => Users.fromJson(e as Map<String, dynamic>))
          .toList(),
      conversations: (json['conversations'] as List<dynamic>?)
          ?.map((e) => Conversation.fromJson(e as Map<String, dynamic>))
          .toList(),
      messages: (json['messages'] as List<dynamic>?)
          ?.map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList(),
      files: (json['files'] as List<dynamic>?)
          ?.map((e) => SearchResultItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      userCount: json['userCount'] as int? ?? json['user_count'] as int? ?? 0,
      conversationCount: json['conversationCount'] as int? ?? json['conversation_count'] as int? ?? 0,
      messageCount: json['messageCount'] as int? ?? json['message_count'] as int? ?? 0,
      fileCount: json['fileCount'] as int? ?? json['file_count'] as int? ?? 0,
    );
  }
}

class Users {
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String? imageUrl;
  final String? code;
  final String? role;

  Users({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.imageUrl,
    this.code,
    this.role,
  });

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      userId: json['userId'] as String? ?? json['id'] as String? ?? '',
      firstName: json['firstName'] as String? ?? json['first_name'] as String? ?? '',
      lastName: json['lastName'] as String? ?? json['last_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? json['image_url'] as String? ?? json['avatarUrl'] as String?,
      code: json['code'] as String?,
      role: json['role'] as String?,
    );
  }

  String get fullName => '$firstName $lastName'.trim().isNotEmpty 
      ? '$firstName $lastName'.trim() 
      : firstName.isNotEmpty ? firstName : email;
}

class SearchResultItem {
  final String id;
  final String name;
  final String? url;
  final String? type;
  final int? size;
  final String? uploadedBy;
  final DateTime? createdAt;

  SearchResultItem({
    required this.id,
    required this.name,
    this.url,
    this.type,
    this.size,
    this.uploadedBy,
    this.createdAt,
  });

  factory SearchResultItem.fromJson(Map<String, dynamic> json) {
    return SearchResultItem(
      id: json['id'] as String? ?? json['fileId'] as String? ?? '',
      name: json['name'] as String? ?? json['fileName'] as String? ?? json['title'] as String? ?? '',
      url: json['url'] as String? ?? json['fileUrl'] as String? ?? json['path'] as String?,
      type: json['type'] as String? ?? json['extension'] as String?,
      size: json['size'] as int?,
      uploadedBy: json['uploadedBy'] as String? ?? json['senderName'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
    );
  }
}

class SearchMetadata {
  final String? searchTerm;
  final int? totalCount;
  final int? page;
  final int? limit;
  final int? executionTimeMs;
  final bool? fromCache;
  final bool? isTypeahead;

  SearchMetadata({
    this.searchTerm,
    this.totalCount,
    this.page,
    this.limit,
    this.executionTimeMs,
    this.fromCache,
    this.isTypeahead,
  });

  factory SearchMetadata.fromJson(Map<String, dynamic> json) {
    return SearchMetadata(
      searchTerm: json['searchTerm'] as String? ?? json['search_term'] as String?,
      totalCount: json['totalCount'] as int? ?? json['total_count'] as int?,
      page: json['page'] as int?,
      limit: json['limit'] as int?,
      executionTimeMs: json['executionTimeMs'] as int? ?? json['execution_time_ms'] as int?,
      fromCache: json['fromCache'] as bool? ?? json['from_cache'] as bool?,
      isTypeahead: json['isTypeahead'] as bool? ?? json['is_typeahead'] as bool?,
    );
  }
}

class ErrorInfo {
  final String? code;
  final String? message;

  ErrorInfo({this.code, this.message});

  factory ErrorInfo.fromJson(Map<String, dynamic> json) {
    return ErrorInfo(
      code: json['code'] as String?,
      message: json['message'] as String?,
    );
  }
}
