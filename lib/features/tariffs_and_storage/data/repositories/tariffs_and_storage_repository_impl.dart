import 'package:dartz/dartz.dart';
import 'package:balansoved_mobile/core/error/exception.dart';
import 'package:balansoved_mobile/core/error/failure.dart';
import 'package:balansoved_mobile/features/auth/data/data_source/auth_local_data_source.dart';
import 'package:balansoved_mobile/features/tariffs_and_storage/data/data_source/file_download_remote_data_source.dart';
import 'package:balansoved_mobile/features/tariffs_and_storage/data/data_source/file_save_local_data_source.dart';
import 'package:balansoved_mobile/features/tariffs_and_storage/data/data_source/tariffs_and_storage_remote_data_source.dart';
import 'package:balansoved_mobile/features/tariffs_and_storage/domain/entities/file_download_entity.dart';
import 'package:balansoved_mobile/features/tariffs_and_storage/domain/entities/file_download_result_entity.dart';
import 'package:balansoved_mobile/features/tariffs_and_storage/domain/repositories/tariffs_and_storage_repository.dart';

class TariffsAndStorageRepositoryImpl
    implements ITariffsAndStorageRepository {
  final ITariffsAndStorageRemoteDataSource remoteDataSource;
  final IFileDownloadRemoteDataSource fileDownloadRemoteDataSource;
  final IFileSaveLocalDataSource fileSaveLocalDataSource;
  final IAuthLocalDataSource localAuth;

  TariffsAndStorageRepositoryImpl({
    required this.remoteDataSource,
    required this.fileDownloadRemoteDataSource,
    required this.fileSaveLocalDataSource,
    required this.localAuth,
  });

  @override
  Future<Either<Failure, FileDownloadEntity>> getDownloadUrl({
    required String firmId,
    required String fileKey,
  }) async {
    try {
      final token = await localAuth.getAccessToken();
      if (token == null) {
        return const Left(
          ConnectionFailure(message: 'Токен авторизации не найден'),
        );
      }

      final result = await remoteDataSource.getDownloadUrl(
        token: token,
        firmId: firmId,
        fileKey: fileKey,
      );
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, details: e.toString()));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, details: e.toString()));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Неизвестная ошибка: $e'));
    }
  }

  @override
  Future<Either<Failure, FileDownloadResultEntity>> downloadAndSaveFile({
    required String firmId,
    required String fileKey,
    required String fileName,
  }) async {
    try {
      final token = await localAuth.getAccessToken();
      if (token == null) {
        return const Left(
          ConnectionFailure(message: 'Токен авторизации не найден'),
        );
      }

      final permissions = await fileSaveLocalDataSource.requestPermissions(
        fileName: fileName,
      );
      if (permissions.requiresGallery && !permissions.galleryGranted) {
        return const Left(
          AccessDeniedFailure(message: 'Нужно разрешение на доступ к галерее'),
        );
      }

      final downloadUrl = await remoteDataSource.getDownloadUrl(
        token: token,
        firmId: firmId,
        fileKey: fileKey,
      );
      final downloadData = await fileDownloadRemoteDataSource.downloadFile(
        downloadUrl: downloadUrl.downloadUrl,
      );
      final saved = await fileSaveLocalDataSource.saveFile(
        bytes: downloadData.bytes,
        fileName: fileName,
        mimeType: downloadData.mimeType,
        storageGranted: permissions.storageGranted,
        galleryGranted: permissions.galleryGranted,
      );

      return Right(saved.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, details: e.toString()));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, details: e.toString()));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, details: e.toString()));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Неизвестная ошибка: $e'));
    }
  }
}
