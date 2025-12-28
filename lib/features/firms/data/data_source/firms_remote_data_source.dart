import 'package:balansoved_mobile/core/constants/constants.dart';
import 'package:balansoved_mobile/core/error/exception.dart';
import 'package:balansoved_mobile/features/firms/data/models/firm_model.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

abstract class FirmsRemoteDataSource {
  Future<List<FirmModel>> fetchFirms({required String token});
}

class FirmsRemoteDataSourceImpl implements FirmsRemoteDataSource {
  final Dio dio;

  FirmsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<FirmModel>> fetchFirms({required String token}) async {
    final url = ManagementApiUrls.getUserData();
    try {
      final response = await dio.get(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = _normalizeResponse(response.data);
        final firmsJson = data['firms'] as List? ?? const [];
        return firmsJson
            .map((f) => FirmModel.fromJson(Map<String, dynamic>.from(f)))
            .toList();
      }

      throw ServerException(
        message: 'Ошибка загрузки фирм',
        statusCode: response.statusCode,
        requestUrl: url,
        responseBody: response.data?.toString(),
      );
    } on DioException catch (e) {
      throw NetworkException(
        message: e.message ?? 'Dio error',
        originalError: e.toString(),
        requestUrl: url,
      );
    }
  }

  Map<String, dynamic> _normalizeResponse(dynamic raw) {
    if (raw is String) {
      return jsonDecode(raw) as Map<String, dynamic>;
    }
    if (raw is Map<String, dynamic>) {
      final body = raw['body'];
      if (body is String) {
        return jsonDecode(body) as Map<String, dynamic>;
      }
      if (body is Map<String, dynamic>) {
        return body;
      }
      return raw;
    }
    return <String, dynamic>{};
  }
}
