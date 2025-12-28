import 'dart:convert';

import 'package:balansoved_mobile/core/constants/constants.dart';
import 'package:balansoved_mobile/core/error/exception.dart';
import 'package:balansoved_mobile/core/logging/employees_logger.dart';
import 'package:balansoved_mobile/features/employees/data/data_source/employees_remote_data_source.dart';
import 'package:balansoved_mobile/features/employees/data/models/employee_model.dart';
import 'package:balansoved_mobile/features/employees/domain/entities/employee_entity.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:balansoved_mobile/injection_container.dart';
import 'package:talker_flutter/talker_flutter.dart';

class EmployeesRemoteDataSourceImpl implements EmployeesRemoteDataSource {
  final Dio? dio;
  final http.Client? httpClient;

  EmployeesRemoteDataSourceImpl({this.dio, this.httpClient})
      : assert(
          dio != null || httpClient != null,
          'Either dio or httpClient must be provided',
        );

  @override
  Future<List<EmployeeEntity>> fetchEmployees(String token, String firmId) {
    if (dio != null) {
      return _fetchEmployeesDio(token, firmId);
    }
    return _fetchEmployeesHttp(token, firmId);
  }

  Future<List<EmployeeEntity>> _fetchEmployeesDio(
    String token,
    String firmId,
  ) async {
    final url = ManagementApiUrls.editEmployees();
    try {
      sl<Talker>().logCustom(
        EmployeesLog('EMPLOYEES DS: Fetch employees via DIO'),
      );
      final response = await dio!.post(
        url,
        data: {'firm_id': firmId, 'action': 'GET_INFO'},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final items = _extractEmployeeList(response.data);
        final employees =
            items
                .map(
                  (e) => EmployeeModel.fromJson(
                    Map<String, dynamic>.from(e as Map),
                  ).toEntity(),
                )
                .toList();
        return employees;
      }
      throw ServerException(
        message: 'Ошибка получения списка сотрудников',
        statusCode: response.statusCode,
        requestUrl: url,
        responseBody: response.data.toString(),
      );
    } on DioException catch (e) {
      throw NetworkException(
        message: e.message ?? 'Dio error',
        originalError: e.toString(),
        requestUrl: url,
      );
    }
  }

  Future<List<EmployeeEntity>> _fetchEmployeesHttp(
    String token,
    String firmId,
  ) async {
    final url = Uri.parse(ManagementApiUrls.editEmployees());
    try {
      final response = await httpClient!.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'firm_id': firmId, 'action': 'GET_INFO'}),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final items = _extractEmployeeList(decoded);
        final employees =
            items
                .map(
                  (e) => EmployeeModel.fromJson(
                    Map<String, dynamic>.from(e as Map),
                  ).toEntity(),
                )
                .toList();
        return employees;
      }
      throw ServerException(
        message: 'Ошибка получения списка сотрудников',
        statusCode: response.statusCode,
        requestUrl: url.toString(),
        responseBody: response.body,
      );
    } catch (e) {
      throw NetworkException(message: e.toString(), requestUrl: url.toString());
    }
  }

  List<dynamic> _extractEmployeeList(dynamic raw) {
    if (raw is List) {
      return raw;
    }
    final normalized = _normalizeResponse(raw);
    final data = normalized['data'];
    if (data is List) {
      return data;
    }
    final employees = normalized['employees'];
    if (employees is List) {
      return employees;
    }
    return const [];
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
