import 'package:equatable/equatable.dart';
import '../../domain/entities/file_download_result_entity.dart';

abstract class FileDownloadState extends Equatable {
  const FileDownloadState();

  @override
  List<Object?> get props => [];
}

class FileDownloadInitial extends FileDownloadState {}

class FileDownloadInProgress extends FileDownloadState {
  final String fileKey;

  const FileDownloadInProgress({required this.fileKey});

  @override
  List<Object?> get props => [fileKey];
}

class FileDownloadSuccess extends FileDownloadState {
  final String fileKey;
  final FileDownloadResultEntity result;

  const FileDownloadSuccess({
    required this.fileKey,
    required this.result,
  });

  @override
  List<Object?> get props => [fileKey, result];
}

class FileDownloadFailure extends FileDownloadState {
  final String fileKey;
  final String message;

  const FileDownloadFailure({
    required this.fileKey,
    required this.message,
  });

  @override
  List<Object?> get props => [fileKey, message];
}
