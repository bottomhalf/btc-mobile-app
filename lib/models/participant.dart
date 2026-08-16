import 'package:conference/config/app_config.dart';

class Participant {
  final String userId;
  final String firstName;
  final String email;
  final String? avatar;
  final String role;
  final int status;
  final DateTime lastSeen;

  Participant({
    required this.userId,
    required this.firstName,
    required this.email,
    this.avatar,
    required this.role,
    required this.status,
    required this.lastSeen,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    final rawAvatar = json['avatar'] as String?;
    String? resolvedAvatar;
    if (rawAvatar != null && rawAvatar.isNotEmpty) {
      if (rawAvatar.startsWith('http://') || rawAvatar.startsWith('https://')) {
        resolvedAvatar = rawAvatar;
      } else {
        final cleanUrl = rawAvatar.startsWith('/') ? rawAvatar.substring(1) : rawAvatar;
        final cleanBase = AppConfig.instance.imageBaseUrl.endsWith('/')
            ? AppConfig.instance.imageBaseUrl
            : '${AppConfig.instance.imageBaseUrl}/';
        resolvedAvatar = cleanBase + cleanUrl;
      }
    }
    return Participant(
      userId: json['user_id'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatar: resolvedAvatar,
      role: json['role'] as String? ?? '',
      status: json['status'] as int? ?? 0,
      lastSeen: json['last_seen'] != null
          ? _parseDateTime(json['last_seen'])
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  static List<Participant> fromJsonList(dynamic jsonList) {
    if (jsonList == null || jsonList is! List) return [];
    return jsonList
        .map((e) => Participant.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'firstName': firstName,
      'email': email,
      'avatar': avatar,
      'role': role,
      'status': status,
      'lastSeen': lastSeen.millisecondsSinceEpoch ~/ 1000,
    };
  }

  @override
  String toString() {
    return 'Participant(userId: $userId, firstName: $firstName, email: $email, avatar: $avatar, role: $role, status: $status, lastSeen: $lastSeen)';
  }

  static DateTime _parseDateTime(dynamic value) {
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
      return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}
