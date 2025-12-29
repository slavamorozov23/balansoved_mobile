import 'package:dartz/dartz.dart';
import 'package:balansoved_mobile/core/error/failure.dart';
import '../entities/file_download_result_entity.dart';
import '../repositories/tariffs_and_storage_repository.dart';

class DownloadAndSaveFileUseCase {
  final ITariffsAndStorageRepository repository;

  const DownloadAndSaveFileUseCase(this.repository);

  Future<Either<Failure, FileDownloadResultEntity>> call({
    required String firmId,
    required String fileKey,
    required String fileName,
  }) async {
    return repository.downloadAndSaveFile(
      firmId: firmId,
      fileKey: fileKey,
      fileName: fileName,
    );
  }
}
