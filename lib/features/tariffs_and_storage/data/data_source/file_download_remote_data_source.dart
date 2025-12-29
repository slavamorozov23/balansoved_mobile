import '../models/file_download_data_model.dart';

abstract class IFileDownloadRemoteDataSource {
  Future<FileDownloadDataModel> downloadFile({required String downloadUrl});
}
