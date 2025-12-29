import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:balansoved_mobile/core/constants/constants.dart';
import 'package:balansoved_mobile/core/error/exception.dart';
import '../data_source/tariffs_and_storage_remote_data_source.dart';
import '../models/file_download_model.dart';

class TariffsAndStorageRemoteDataSourceImpl
    implements ITariffsAndStorageRemoteDataSource {
  final Dio dio;

  TariffsAndStorageRemoteDataSourceImpl({required this.dio});

  Map<String, String> _getHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<FileDownloadModel> getDownloadUrl({
    required String token,
    required String firmId,
    required String fileKey,
  }) async {
    final url = TariffsAndStorageApiUrls.manage();
    final requestBody = jsonEncode({
      'firm_id': firmId,
      'action': 'GET_DOWNLOAD_URL',
      'file_key': fileKey,
    });

    try {
      final response = await dio.post(
        url,
        options: Options(headers: _getHeaders(token)),
        data: requestBody,
      );

      if (response.statusCode == 200) {
        dynamic data = response.data;
        if (data is String) {
          data = jsonDecode(data);
        }
        if (data is Map<String, dynamic>) {
          final nested = data['data'];
          final downloadUrl =
              data['download_url'] ??
              (nested is Map<String, dynamic> ? nested['download_url'] : null);
          if (downloadUrl is String && downloadUrl.isNotEmpty) {
            return FileDownloadModel(
              downloadUrl: downloadUrl,
              fileKey: fileKey,
            );
          }
        }
        throw const ServerException(
          message: 'Сервер вернул пустой download_url',
        );
      }

      throw ServerException(
        message: 'DIO ${response.statusCode}: ${response.data}',
        statusCode: response.statusCode,
        requestUrl: url,
        requestBody: requestBody,
      );
    } on DioException catch (e) {
      throw NetworkException(
        message: 'Ошибка сети при запросе URL для скачивания',
        originalError: e.toString(),
        requestUrl: url,
        stackTrace: e.stackTrace.toString(),
      );
    }
  }
}
