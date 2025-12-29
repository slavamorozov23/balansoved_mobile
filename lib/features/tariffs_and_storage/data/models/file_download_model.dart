import '../../domain/entities/file_download_entity.dart';

class FileDownloadModel extends FileDownloadEntity {
  const FileDownloadModel({
    required super.downloadUrl,
    required super.fileKey,
  });

  factory FileDownloadModel.fromJson(
    Map<String, dynamic> json, {
    String? fallbackFileKey,
  }) {
    final downloadUrl = json['download_url']?.toString() ?? '';
    final fileKey = json['file_key']?.toString() ?? fallbackFileKey ?? '';
    return FileDownloadModel(downloadUrl: downloadUrl, fileKey: fileKey);
  }

  FileDownloadEntity toEntity() {
    return FileDownloadEntity(downloadUrl: downloadUrl, fileKey: fileKey);
  }

  factory FileDownloadModel.fromEntity(FileDownloadEntity entity) {
    return FileDownloadModel(
      downloadUrl: entity.downloadUrl,
      fileKey: entity.fileKey,
    );
  }
}
