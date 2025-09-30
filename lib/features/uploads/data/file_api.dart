import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

class FileApi {
  final ApiClient client;
  FileApi({required this.client});

  /// Upload image file. field name expected by backend: 'image'
  Future<Response> uploadImage(
    File file, {
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final filename = file.path.split('/').last;
      final formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(file.path, filename: filename),
      });

      final res = await client.dio.post(
        ApiEndpoints.uploadImage,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
        onSendProgress: onSendProgress,
      );

      print("Upload successful: ${res.statusCode}");
      print("Response data: ${res.data}");

      return res;
    } on DioError catch (e) {
      // Dio-specific errors (network, timeout, response errors, etc.)
      print("DioError: ${e.message}");
      if (e.response != null) {
        print("Error status: ${e.response?.statusCode}");
        print("Error data: ${e.response?.data}");
      }
      rethrow; // rethrow so repo layer can handle it
    } catch (e) {
      // Any other error
      print("Unexpected error: $e");
      rethrow;
    }
  }

  /// Upload audio file. field name expected by backend: 'audio'
  Future<Response> uploadAudio(
    File file, {
    ProgressCallback? onSendProgress,
  }) async {
    final filename = file.path.split('/').last;
    final formData = FormData.fromMap({
      "audio": await MultipartFile.fromFile(file.path, filename: filename),
    });
    final res = await client.dio.post(
      ApiEndpoints.uploadAudio,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
      onSendProgress: onSendProgress,
    );
    return res;
  }

  /// Fetch list of uploaded files for the token owner
  Future<Response> fetchFiles() async {
    final res = await client.dio.get(ApiEndpoints.listFiles);
    return res;
  }
}
