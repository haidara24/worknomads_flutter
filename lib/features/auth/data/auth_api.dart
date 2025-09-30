import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

class AuthApi {
  final ApiClient client;
  AuthApi({required this.client});

  Future<void> register({
    required String username,
    required String password,
  }) async {
    final res = await client.post(
      ApiEndpoints.register,
      data: {"username": username, "password": password},
    );
    if (res.statusCode != 201) {
      // throw generic error for now
      throw Exception("Registration failed: ${res.statusCode} ${res.data}");
    }
  }

  Future<Map<String, dynamic>> obtainToken({
    required String username,
    required String password,
  }) async {
    final res = await client.post(
      ApiEndpoints.token,
      data: {"username": username, "password": password},
    );
    if (res.statusCode == 200) {
      return Map<String, dynamic>.from(res.data);
    }
    throw Exception("Login failed: ${res.statusCode} ${res.data}");
  }
}
