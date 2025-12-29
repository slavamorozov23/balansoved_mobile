import '../../domain/entities/file_download_result_entity.dart';

class FileSaveResultModel extends FileDownloadResultEntity {
  const FileSaveResultModel({
    required super.fileName,
    required super.filePath,
    required super.savedToGallery,
  });

  FileDownloadResultEntity toEntity() {
    return FileDownloadResultEntity(
      fileName: fileName,
      filePath: filePath,
      savedToGallery: savedToGallery,
    );
  }
}
