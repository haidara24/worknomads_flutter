class UploadedFileModel {
  final int id;
  final String ownerUsername;
  final String filename;
  final String fileType; // "image" or "audio"
  final String contentType;
  final int? fileSize;
  final DateTime uploadedAt;
  final String fileUrl;

  UploadedFileModel({
    required this.id,
    required this.ownerUsername,
    required this.filename,
    required this.fileType,
    required this.contentType,
    required this.uploadedAt,
    required this.fileUrl,
    this.fileSize,
  });

  factory UploadedFileModel.fromJson(Map<String, dynamic> json) {
    return UploadedFileModel(
      id: json['id'],
      ownerUsername: json['owner_username'],
      filename: json['filename'],
      fileType: json['file_type'],
      contentType: json['content_type'] ?? '',
      fileSize: json['file_size'],
      uploadedAt: DateTime.parse(json['uploaded_at']),
      fileUrl: json['file_url'],
    );
  }
}
