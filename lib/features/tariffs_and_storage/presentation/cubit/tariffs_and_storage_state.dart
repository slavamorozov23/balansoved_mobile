import 'package:equatable/equatable.dart';

abstract class TariffsAndStorageState extends Equatable {
  const TariffsAndStorageState();

  @override
  List<Object?> get props => [];
}

class TariffsAndStorageInitial extends TariffsAndStorageState {}

class FileDownloadInProgress extends TariffsAndStorageState {
  final String fileKey;

  const FileDownloadInProgress({required this.fileKey});

  @override
  List<Object?> get props => [fileKey];
}

class FileDownloadUrlReady extends TariffsAndStorageState {
  final String downloadUrl;
  final String fileKey;

  const FileDownloadUrlReady({
    required this.downloadUrl,
    required this.fileKey,
  });

  @override
  List<Object?> get props => [downloadUrl, fileKey];
}

class TariffsAndStorageError extends TariffsAndStorageState {
  final String message;
  final String? fileKey;

  const TariffsAndStorageError({required this.message, this.fileKey});

  @override
  List<Object?> get props => [message, fileKey];
}
