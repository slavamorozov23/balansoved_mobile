import '../models/file_download_model.dart';

abstract class ITariffsAndStorageRemoteDataSource {
  Future<FileDownloadModel> getDownloadUrl({
    required String token,
    required String firmId,
    required String fileKey,
  });
}
