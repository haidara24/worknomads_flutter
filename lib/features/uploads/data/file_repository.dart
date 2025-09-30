import 'dart:io';
import 'package:worknomads_flutter/features/uploads/domain/media_file.dart';

import 'file_api.dart';

class FileRepository {
  final FileApi api;

  FileRepository({required this.api});

  Future<UploadedFileModel> uploadImage(
    File file, {
    Function(int sent, int total)? onProgress,
  }) async {
    final response = await api.uploadImage(
      file,
      onSendProgress: (sent, total) {
        if (onProgress != null) onProgress(sent, total);
      },
    );
    return UploadedFileModel.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<UploadedFileModel> uploadAudio(
    File file, {
    Function(int sent, int total)? onProgress,
  }) async {
    final response = await api.uploadAudio(
      file,
      onSendProgress: (sent, total) {
        if (onProgress != null) onProgress(sent, total);
      },
    );
    return UploadedFileModel.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<List<UploadedFileModel>> fetchFiles() async {
    final response = await api.fetchFiles();
    final data = response.data as List;
    return data
        .map((e) => UploadedFileModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
