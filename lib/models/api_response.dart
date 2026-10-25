/// Typed model matching the backend's standard `ResponseModel`.
///
/// Every API endpoint returns this wrapper. The actual payload lives
/// in [responseBody]. Optional error fields are populated on failure.
class ApiResponse {
  final String? accessToken;
  final int httpStatusCode;
  final String httpStatusMessage;
  final dynamic responseBody;
  final String? errorCode;
  final String? errorMessage;
  final bool? isSuccess;
  final String? message;
  final String? refreshToken;
  final String? refreshTokenCorelationId;

  ApiResponse({
    this.accessToken,
    required this.httpStatusCode,
    required this.httpStatusMessage,
    this.responseBody,
    this.errorCode,
    this.errorMessage,
    this.isSuccess,
    this.message,
    this.refreshToken,
    this.refreshTokenCorelationId,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    var statusCode = json['httpStatusCode'] as int?;
    int code = 0;
    try {
      code = statusCode != null && statusCode == 200 ? 200 : 400;
    } catch (e) {
      code = 400;
    }
    return ApiResponse(
      accessToken: json['accessToken'] as String?,
      httpStatusCode: code,
      httpStatusMessage: json['httpStatusMessage'] as String? ?? '',
      responseBody: json['responseBody'],
      errorCode: json['errorCode'] as String?,
      errorMessage: json['errorMessage'] as String?,
      isSuccess: code == 200,
      message: json['message'] as String?,
      refreshToken: json['refreshToken'] as String?,
      refreshTokenCorelationId: json['refreshTokenCorelationId'] as String?,
    );
  }

  /// Whether the API call was logically successful.
  bool get success => isSuccess == true;
  bool get isOk => isSuccess == true && httpStatusCode >= 200 && httpStatusCode < 300;

  /// Human-readable error string — prefers [errorMessage], falls back to
  /// [message], then [httpStatusMessage].
  String get error =>
      (errorMessage?.isNotEmpty == true ? errorMessage : null) ??
      (message?.isNotEmpty == true ? message : null) ??
      httpStatusMessage;
}
