import 'package:worknomads_flutter/core/api/api_client.dart';
import 'package:worknomads_flutter/core/api/api_endpoints.dart';
import 'package:worknomads_flutter/core/api/exceptions.dart';
import 'package:worknomads_flutter/core/storage/secure_storage.dart';
import 'package:worknomads_flutter/features/auth/data/auth_api.dart';
import 'package:worknomads_flutter/features/auth/domain/auth_models.dart';

class AuthRepository {
  final ApiClient apiClient;
  final AuthApi api;

  AuthRepository({required this.apiClient}) : api = AuthApi(client: apiClient);

  Future<void> register(String username, String password) async {
    try {
      final res = await apiClient.post(
        ApiEndpoints.register,
        data: {"username": username, "password": password},
      );
      if (res.statusCode != 201) {
        return;
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  Future<TokenPair> login(String username, String password) async {
    try {
      final res = await apiClient.post(
        ApiEndpoints.token,
        data: {"username": username, "password": password},
      );
      if (res.statusCode == 200) {
        final data = res.data;
        final access = data['access'] as String;
        final refresh = data['refresh'] as String;
        print(access);
        print(refresh);
        await SecureStorage.saveAccessToken(access);
        await SecureStorage.saveRefreshToken(refresh);
        return TokenPair(access: access, refresh: refresh);
      }
      throw AuthException('Login failed: ${res.statusCode}');
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  Future<void> logout() async {
    await SecureStorage.clearAll();
  }

  /// Explicit refresh call (returns true if succeeded)
  Future<bool> refresh() async {
    try {
      final res = await apiClient.post(
        ApiEndpoints.tokenRefresh,
        data: {"refresh": await SecureStorage.getRefreshToken()},
      );
      if (res.statusCode == 200) {
        final data = res.data;
        final access = data['access'] as String?;
        final refresh = data['refresh'] as String?;
        if (access != null) {
          await SecureStorage.saveAccessToken(access);
        }
        if (refresh != null) {
          await SecureStorage.saveRefreshToken(refresh);
        }
        return true;
      }
      return false;
    } on AppException {
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<String?> getAccessToken() => SecureStorage.getAccessToken();
}
