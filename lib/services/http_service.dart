import 'dart:async';
import 'dart:convert';
import 'package:conference/core/storage/secure_storage_service.dart';
import 'package:conference/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/api_exception.dart';
import '../models/api_response.dart';

/// Centralized HTTP service — all REST calls go through here.
///
/// Every public method (`get`, `post`, `put`, `delete`) automatically:
/// 1. Prepends [AppConfig.apiBaseUrl]
/// 2. Attaches JSON headers + auth token
/// 3. Parses the response through [ApiResponse]
/// 4. Returns only [ApiResponse.responseBody] on success
/// 5. Throws [ApiException] on failure
class HttpService {
  // ─── Singleton ──────────────────────────────────────────────────
  HttpService._();
  static final HttpService _instance = HttpService._();
  static HttpService get instance => _instance;

  // ─── State ──────────────────────────────────────────────────────
  String? _authToken;
  bool _isRefreshing = false;
  late final http.Client _client = http.Client();
  final SecureStorageService _secureStorage = SecureStorageService.instance;

  /// Load token from secure storage into memory.
  /// Call once at app startup (in `main()`).
  Future<void> initialize() async {
    _authToken = await _secureStorage.getToken();
  }

  /// Store the auth token — saves to both memory and secure storage.
  Future<void> setAuthToken(String token) async {
    _authToken = token;
    await _secureStorage.setToken(token);
  }

  /// Store the refresh token — saves to secure storage.
  Future<void> setRefreshToken(String token) async {
    await _secureStorage.setRefreshToken(token);
  }

  /// Store the auth token — saves to both memory and secure storage.
  Future<void> setTokenDetail(ApiResponse apiResponse) async {
    setAuthToken(apiResponse.accessToken!);
    setRefreshToken(apiResponse.refreshToken!);
  }

  /// Update & Store the user detail — saves to memory.
  Future<void> updateUserDetail(ApiResponse apiResponse) async {
    var user = UserModel.instance;
    user.userId = apiResponse.responseBody["userId"];
    user.email = apiResponse.responseBody["email"];
    user.firstName = apiResponse.responseBody["firstName"];
    user.lastName = apiResponse.responseBody["lastName"];
    user.code = apiResponse.responseBody["code"] ?? "";
    user.imageUrl = apiResponse.responseBody["imageUrl"] ?? "";
  }

  /// Clear the auth token (on logout).
  Future<void> clearAuthToken() async {
    _authToken = null;
    await _secureStorage.deleteToken();
  }

  /// Whether the user is currently authenticated.
  bool get isAuthenticated => _authToken != null;

  /// Current auth token (read-only, synchronous).
  String? get authToken => _authToken;

  // ─── Helpers ────────────────────────────────────────────────────
  String get _baseUrl => AppConfig.instance.apiBaseUrl;

  Duration get _timeout =>
      Duration(seconds: AppConfig.instance.connectionTimeout);

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  Uri _uri(String path, [Map<String, String>? queryParams]) =>
      Uri.parse('$_baseUrl$path').replace(queryParameters: queryParams);

  void _log(String method, String path, int statusCode) {
    if (AppConfig.instance.enableLogs) {
      debugPrint('[$method] $path → $statusCode');
    }
  }

  /// Parse the raw [http.Response] into an [ApiResponse], validate success,
  /// and return only the `ResponseBody`.
  ///
  /// Throws [ApiException] if the HTTP status is not 200 or if
  /// `IsSuccess` is explicitly `false`.
  ApiResponse _processResponse(
    http.Response response,
    String method,
    String path,
  ) {
    _log(method, path, response.statusCode);

    // Non-200 HTTP status — network / server error
    if (response.statusCode != 200) {
      // Try to parse the body for error details
      try {
        final apiResponse = ApiResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
        throw ApiException(
          message: apiResponse.error,
          statusCode: response.statusCode,
          errorCode: apiResponse.errorCode,
          apiResponse: apiResponse,
        );
      } catch (e) {
        if (e is ApiException) rethrow;
        throw ApiException(
          message: 'Server error (${response.statusCode})',
          statusCode: response.statusCode,
        );
      }
    }

    // 200 — parse the standard response envelope
    final Map<String, dynamic> json =
        jsonDecode(response.body) as Map<String, dynamic>;
    final apiResponse = ApiResponse.fromJson(json);

    // If the backend explicitly says it's not successful
    if (apiResponse.isSuccess == false) {
      throw ApiException(
        message: apiResponse.error,
        statusCode: apiResponse.httpStatusCode,
        errorCode: apiResponse.errorCode,
        apiResponse: apiResponse,
      );
    }

    return apiResponse;
  }

  // ─── Token Refresh on 401 ────────────────────────────────────────

  /// Maximum number of retry attempts for token regeneration.
  static const int _maxRetryAttempts = 3;

  /// Calls `auth/v2/generateAccessToken` with the refresh token
  /// retrieved from [FlutterSecureStorage] passed in the header.
  ///
  /// Retries up to [_maxRetryAttempts] times on failure. If all
  /// attempts fail, clears stored tokens (logout) and throws
  /// [ApiException] so the UI can redirect to the login page.
  Future<void> _regenerateAccessToken() async {
    final refreshToken = await _secureStorage.getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      await _cleanupAndLogout();
      throw ApiException(
        message: 'Session expired. Please log in again.',
        statusCode: 401,
        errorCode: 'MISSING_REFRESH_TOKEN',
      );
    }

    Object? lastError;

    for (int attempt = 1; attempt <= _maxRetryAttempts; attempt++) {
      try {
        debugPrint('Token refresh attempt $attempt/$_maxRetryAttempts');

        final response = await _client
            .post(
              _uri('auth/v2/generateAccessToken'),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $refreshToken',
              },
            )
            .timeout(_timeout);

        _log('POST', 'auth/v2/generateAccessToken', response.statusCode);

        if (response.statusCode != 200) {
          throw ApiException(
            message: 'Token refresh returned ${response.statusCode}',
            statusCode: response.statusCode,
            errorCode: 'TOKEN_REFRESH_FAILED',
          );
        }

        final apiResponse = ApiResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );

        validateTokens(apiResponse);
        await setTokenDetail(apiResponse);
        await updateUserDetail(apiResponse);

        // Success — exit the retry loop
        return;
      } catch (e) {
        lastError = e;
        debugPrint('Token refresh attempt $attempt failed: $e');

        // Wait briefly before retrying (skip delay on last attempt)
        if (attempt < _maxRetryAttempts) {
          await Future.delayed(Duration(seconds: attempt));
        }
      }
    }

    // All attempts exhausted — cleanup and force logout
    await _cleanupAndLogout();
    throw ApiException(
      message: 'Session expired. Please log in again.',
      statusCode: 401,
      errorCode: 'TOKEN_REFRESH_EXHAUSTED',
    );
  }

  /// Clears all auth state from memory and secure storage.
  Future<void> _cleanupAndLogout() async {
    _authToken = null;
    await _secureStorage.clearAll();
  }

  /// Attempts a silent auto-login by regenerating the access token
  /// using the stored refresh token.
  ///
  /// Returns `true` if the refresh succeeded and the user is now
  /// authenticated. Returns `false` if there is no refresh token
  /// or the server rejected it — the caller should redirect to login.
  Future<bool> tryAutoLogin() async {
    try {
      await _regenerateAccessToken();
      return true;
    } catch (e) {
      debugPrint('Auto-login failed: $e');
      return false;
    }
  }

  /// Executes [requestFn], and if it throws a 401 [ApiException],
  /// regenerates the access token and retries the request once.
  Future<ApiResponse> _executeWithRetry(
    Future<http.Response> Function() requestFn,
    String method,
    String path,
  ) async {
    try {
      final response = await requestFn().timeout(_timeout);
      return _processResponse(response, method, path);
    } on ApiException catch (e) {
      // Only attempt refresh on 401 and when not already refreshing
      if (e.statusCode != 401 || _isRefreshing) rethrow;

      _isRefreshing = true;
      try {
        await _regenerateAccessToken();
      } finally {
        _isRefreshing = false;
      }

      // Retry the original request with the new token
      final retryResponse = await requestFn().timeout(_timeout);
      return _processResponse(retryResponse, method, path);
    }
  }

  // ─── Public API ─────────────────────────────────────────────────

  Future<String> getMeetingToken(
    String roomName,
    String participantName,
  ) async {
    var response = await post(
      'conference/token',
      body: {'roomName': roomName, 'participantName': participantName},
    );
    return response.accessToken;
  }

  /// Validates that both [accessToken] and [refreshToken] are present
  /// in the [ApiResponse]. Throws [ApiException] if either is missing
  /// so the calling controller can display the error on the UI.
  void validateTokens(ApiResponse apiResponse) {
    if (apiResponse.accessToken == null || apiResponse.accessToken!.isEmpty) {
      throw ApiException(
        message: 'Authentication failed: access token not received. Please try again.',
        statusCode: 401,
        errorCode: 'MISSING_ACCESS_TOKEN',
        apiResponse: apiResponse,
      );
    }

    if (apiResponse.refreshToken == null || apiResponse.refreshToken!.isEmpty) {
      throw ApiException(
        message: 'Authentication failed: refresh token not received. Please try again.',
        statusCode: 401,
        errorCode: 'MISSING_REFRESH_TOKEN',
        apiResponse: apiResponse,
      );
    }
  }

  /// HTTP POST (LOGIN) — returns `ResponseBody` on success.
  ///
  /// Throws [ApiException] on failure.
  Future<dynamic> login(String path, {Object? body}) async {
    final response = await _client
        .post(
          _uri(path),
          headers: _headers,
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(_timeout);
    var apiResponse = _processResponse(response, 'POST', path);

    // Validate token and refresh token
    validateTokens(apiResponse);

    setTokenDetail(apiResponse);

    return apiResponse.responseBody;
  }

  /// HTTP GET — returns `ResponseBody` on success.
  /// Automatically retries once on 401 after refreshing the access token.
  ///
  /// Throws [ApiException] on failure.
  Future<dynamic> get(String path, {Map<String, String>? queryParams}) async {
    final apiResponse = await _executeWithRetry(
      () => _client.get(_uri(path, queryParams), headers: _headers),
      'GET',
      path,
    );
    return apiResponse;
  }

  /// HTTP POST — returns `ResponseBody` on success.
  /// Automatically retries once on 401 after refreshing the access token.
  ///
  /// Throws [ApiException] on failure.
  Future<dynamic> post(String path, {Object? body}) async {
    final apiResponse = await _executeWithRetry(
      () => _client.post(
        _uri(path),
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      ),
      'POST',
      path,
    );
    return apiResponse;
  }

  /// HTTP PUT — returns `ResponseBody` on success.
  /// Automatically retries once on 401 after refreshing the access token.
  ///
  /// Throws [ApiException] on failure.
  Future<dynamic> put(String path, {Object? body}) async {
    final apiResponse = await _executeWithRetry(
      () => _client.put(
        _uri(path),
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      ),
      'PUT',
      path,
    );
    return apiResponse;
  }

  /// HTTP DELETE — returns `ResponseBody` on success.
  /// Automatically retries once on 401 after refreshing the access token.
  ///
  /// Throws [ApiException] on failure.
  Future<dynamic> delete(String path) async {
    final apiResponse = await _executeWithRetry(
      () => _client.delete(_uri(path), headers: _headers),
      'DELETE',
      path,
    );
    return apiResponse;
  }

  /// Dispose the underlying HTTP client.
  void dispose() => _client.close();
}
