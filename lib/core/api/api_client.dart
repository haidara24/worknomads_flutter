import 'dart:async';
import 'package:dio/dio.dart';
import 'package:worknomads_flutter/core/api/exceptions.dart';
import 'package:worknomads_flutter/core/storage/secure_storage.dart';
import '../api/api_endpoints.dart';

typedef LogoutCallback = void Function();

class ApiClient {
  final Dio dio;
  final Dio _authDio;
  final String baseUrl;
  LogoutCallback? onLogout;

  // Lock for single refresh
  Completer<void>? _refreshCompleter;

  ApiClient({required this.baseUrl})
    : dio = Dio(BaseOptions(baseUrl: baseUrl)),
      _authDio = Dio(BaseOptions(baseUrl: baseUrl)) {
    _setupInterceptors();
  }

  // convenience default for emulator
  static const defaultBaseUrl = String.fromEnvironment(
    'AUTH_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  ApiClient.defaultClient() : this(baseUrl: defaultBaseUrl);

  void _setupInterceptors() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final token = await SecureStorage.getAccessToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } catch (_) {
            // ignore storage errors here
          }
          handler.next(options);
        },
        onError: (err, handler) async {
          final response = err.response;
          // If 401 unauthorized — attempt refresh and retry (unless request was refresh itself)
          final isAuthEndpoint =
              err.requestOptions.path.endsWith(ApiEndpoints.tokenRefresh) ||
              err.requestOptions.path.endsWith(ApiEndpoints.token);
          if (response != null &&
              response.statusCode == 401 &&
              !isAuthEndpoint) {
            try {
              // If a refresh is already in progress, wait for it
              if (_refreshCompleter != null) {
                await _refreshCompleter!.future;
              } else {
                _refreshCompleter = Completer<void>();
                try {
                  final success = await _refreshTokens();
                  if (!success) {
                    // refresh failed
                    _refreshCompleter!.complete();
                    _refreshCompleter = null;
                    if (onLogout != null) onLogout!();
                    return handler.reject(err);
                  }
                  _refreshCompleter!.complete();
                  _refreshCompleter = null;
                } catch (e) {
                  _refreshCompleter!.complete();
                  _refreshCompleter = null;
                  if (onLogout != null) onLogout!();
                  return handler.reject(err);
                }
              }

              // after refresh, retry original request with new token
              final newToken = await SecureStorage.getAccessToken();
              if (newToken == null) {
                if (onLogout != null) onLogout!();
                return handler.reject(err);
              }
              final opts = Options(
                method: err.requestOptions.method,
                headers: Map<String, dynamic>.from(
                  err.requestOptions.headers ?? {},
                ),
                responseType: err.requestOptions.responseType,
                contentType: err.requestOptions.contentType,
                validateStatus: err.requestOptions.validateStatus,
                followRedirects: err.requestOptions.followRedirects,
                extra: err.requestOptions.extra,
              );

              opts.headers!['Authorization'] = 'Bearer $newToken';

              final cloneReq = await dio.request(
                err.requestOptions.path,
                data: err.requestOptions.data,
                queryParameters: err.requestOptions.queryParameters,
                options: opts,
              );
              return handler.resolve(cloneReq);
            } catch (e) {
              // fallback to auth failure
              if (onLogout != null) onLogout!();
              return handler.reject(err);
            }
          }

          // other errors
          return handler.next(err);
        },
      ),
    );
  }

  /// Refresh access token using refresh token stored in SecureStorage.
  /// Returns true if refresh succeeded and tokens saved.
  Future<bool> _refreshTokens() async {
    try {
      final refresh = await SecureStorage.getRefreshToken();
      if (refresh == null || refresh.isEmpty) return false;
      final res = await _authDio.post(
        ApiEndpoints.tokenRefresh,
        data: {"refresh": refresh},
      );
      if (res.statusCode == 200) {
        final data = res.data;
        final newAccess = data['access'] as String?;
        final newRefresh = data['refresh'] as String?; // sometimes not returned
        if (newAccess != null) {
          await SecureStorage.saveAccessToken(newAccess);
        }
        if (newRefresh != null) {
          await SecureStorage.saveRefreshToken(newRefresh);
        }
        return true;
      }
      return false;
    } on DioError catch (e) {
      // treat refresh failure as auth failure
      return false;
    } catch (e) {
      return false;
    }
  }

  // Basic wrappers that map DioError -> AppException
  Future<Response> post(String path, {dynamic data, Options? options}) async {
    try {
      final res = await dio.post(path, data: data, options: options);
      return res;
    } on DioError catch (e) {
      throw _mapDioError(e);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final res = await dio.get(path, queryParameters: queryParameters);
      return res;
    } on DioError catch (e) {
      throw _mapDioError(e);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  AppException _mapDioError(DioError error) {
    if (error.type == DioErrorType.connectionTimeout ||
        error.type == DioErrorType.sendTimeout ||
        error.type == DioErrorType.receiveTimeout ||
        error.type == DioErrorType.connectionError) {
      return NetworkException(error.message ?? "error");
    }

    final status = error.response?.statusCode;
    final message = error.response?.data?.toString() ?? error.message;

    if (status == 401) return AuthException("Unauthorized: $message");
    if (status != null && status >= 500)
      return ServerException("Server error: $message");

    return AppException(message ?? "error");
  }
}
