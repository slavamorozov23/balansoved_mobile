import 'package:dartz/dartz.dart';
import 'package:balansoved_mobile/core/error/failure.dart';
import '../entities/file_download_entity.dart';
import '../entities/file_download_result_entity.dart';

abstract class ITariffsAndStorageRepository {
  Future<Either<Failure, FileDownloadEntity>> getDownloadUrl({
    required String firmId,
    required String fileKey,
  });

  Future<Either<Failure, FileDownloadResultEntity>> downloadAndSaveFile({
    required String firmId,
    required String fileKey,
    required String fileName,
  });
}
