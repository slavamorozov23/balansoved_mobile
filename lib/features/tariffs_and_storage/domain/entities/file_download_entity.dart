import 'package:equatable/equatable.dart';

class FileDownloadEntity extends Equatable {
  final String downloadUrl;
  final String fileKey;

  const FileDownloadEntity({required this.downloadUrl, required this.fileKey});

  @override
  List<Object?> get props => [downloadUrl, fileKey];
}
