import 'package:http/http.dart' as http;
import 'package:balansoved_mobile/core/error/exception.dart';
import '../data_source/file_download_remote_data_source.dart';
import '../models/file_download_data_model.dart';

class FileDownloadRemoteDataSourceImpl implements IFileDownloadRemoteDataSource {
  final http.Client client;

  FileDownloadRemoteDataSourceImpl({required this.client});

  @override
  Future<FileDownloadDataModel> downloadFile({
    required String downloadUrl,
  }) async {
    final uri = Uri.parse(downloadUrl);
    final response = await client.get(uri);
    if (response.statusCode == 200) {
      return FileDownloadDataModel(
        bytes: response.bodyBytes,
        mimeType: response.headers['content-type'],
      );
    }

    throw ServerException(
      message: 'Ошибка загрузки файла',
      statusCode: response.statusCode,
      requestUrl: uri.toString(),
      responseBody: response.body,
    );
  }
}
