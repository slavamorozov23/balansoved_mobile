import 'package:equatable/equatable.dart';

class FileDownloadResultEntity extends Equatable {
  final String fileName;
  final String filePath;
  final bool savedToGallery;

  const FileDownloadResultEntity({
    required this.fileName,
    required this.filePath,
    required this.savedToGallery,
  });

  @override
  List<Object?> get props => [fileName, filePath, savedToGallery];
}
