import 'package:conference/config/app_config.dart';

/// Represents an authenticated user returned from the login API as a Singleton.
class UserModel {
  // ─── Singleton ──────────────────────────────────────────────────
  UserModel._();

  static final UserModel _instance = UserModel._();

  static UserModel get instance => _instance;

  // 4. Mutable fields
  String email = '';
  String userId = '';
  String firstName = '';
  String lastName = '';
  String token = '';
  String code = '';
  String imageUrl = '';

  // 5. Update user data from json
  void updateFromJson(Map<String, dynamic> json) {
    email = json['email'] as String? ?? '';
    userId = json['userId'] as String? ?? '';
    firstName = json['firstName'] as String? ?? '';
    lastName = json['lastName'] as String? ?? '';
    token = json['token'] as String? ?? '';
    code = json['code'] as String? ?? '';
    
    final rawImageUrl = json['imageUrl'] as String? ?? '';
    if (rawImageUrl.isNotEmpty) {
      if (rawImageUrl.startsWith('http://') || rawImageUrl.startsWith('https://')) {
        imageUrl = rawImageUrl;
      } else {
        final cleanUrl = rawImageUrl.startsWith('/') ? rawImageUrl.substring(1) : rawImageUrl;
        final cleanBase = AppConfig.instance.imageBaseUrl.endsWith('/')
            ? AppConfig.instance.imageBaseUrl
            : '${AppConfig.instance.imageBaseUrl}/';
        imageUrl = cleanBase + cleanUrl;
      }
    } else {
      imageUrl = '';
    }
  }

  // Preserve fromJson factory for compatibility
  factory UserModel.fromJson(Map<String, dynamic> json) {
    _instance.updateFromJson(json);
    return _instance;
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'token': token,
      'code': code,
      'imageUrl': imageUrl,
    };
  }

  /// Full display name.
  String get fullName => '$firstName $lastName';

  @override
  String toString() => 'UserModel($userId, $fullName, $email)';

  /// Clear user data on logout
  void clear() {
    email = '';
    userId = '';
    firstName = '';
    lastName = '';
    token = '';
    code = '';
    imageUrl = '';
  }
}
