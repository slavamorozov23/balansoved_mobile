import 'package:dartz/dartz.dart';
import 'package:balansoved_mobile/core/error/failure.dart';
import '../entities/file_download_entity.dart';
import '../repositories/tariffs_and_storage_repository.dart';

class DownloadFileUseCase {
  final ITariffsAndStorageRepository repository;

  const DownloadFileUseCase(this.repository);

  Future<Either<Failure, FileDownloadEntity>> call({
    required String firmId,
    required String fileKey,
  }) async {
    return repository.getDownloadUrl(firmId: firmId, fileKey: fileKey);
  }
}
