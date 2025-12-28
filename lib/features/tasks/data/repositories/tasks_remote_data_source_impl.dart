import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:balansoved_mobile/core/constants/constants.dart';
import 'package:balansoved_mobile/core/error/exception.dart';
import 'package:balansoved_mobile/features/tasks/data/data_source/tasks_remote_data_source.dart';
import 'package:balansoved_mobile/features/tasks/data/models/task_model.dart';
import 'package:balansoved_mobile/features/tasks/domain/entities/task_entity.dart';
import 'package:balansoved_mobile/injection_container.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:balansoved_mobile/core/logging/tasks_logger.dart';

class TasksRemoteDataSourceImpl implements TasksRemoteDataSource {
  final http.Client client;
  final String? Function() getToken;

  TasksRemoteDataSourceImpl({required this.client, required this.getToken});

  Map<String, String> get _headers {
    final token = getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<TasksApiResult> getTasks(
    String firmId,
    TaskRequestParams params,
  ) async {
    final uri = Uri.parse(TasksApiUrls.manage());

    final requestBodyMap = <String, dynamic>{
      'firm_id': firmId,
      'action': 'GET',
      'only_my': params.onlyMy,
    };

    final filters = <String, dynamic>{};
    if (params.clientId != null) {
      filters['client_id'] = params.clientId;
    }
    if (params.status != null && params.status!.isNotEmpty) {
      filters['status'] = params.status;
    }
    if (params.participants.isNotEmpty) {
      filters['participants'] =
          params.participants.map((p) => p.toApiJson()).toList();
      filters['participants_mode'] = params.participantsMode;
    }

    // Добавляем параметры в зависимости от типа запроса
    switch (params.viewType) {
      case TaskViewType.timeless:
        // Бессрочные задачи с пагинацией
        if (params.page != null) {
          requestBodyMap['page'] = params.page;
        }
        break;

      case TaskViewType.dated:
        // Задачи с крайним сроком за месяц
        requestBodyMap['get_dated_tasks'] = true;
        if (params.month != null) {
          requestBodyMap['month'] = params.month;
        }
        if (params.year != null) {
          requestBodyMap['year'] = params.year;
        }
        break;

      case TaskViewType.all:
        // Все задачи с пагинацией, сортировка по created_at
        requestBodyMap['get_all_tasks'] = true;
        if (params.page != null) {
          requestBodyMap['page'] = params.page;
        }
        break;

      case TaskViewType.timeline:
        // Timeline режим с курсорной пагинацией
        requestBodyMap['mode'] = 'timeline';
        requestBodyMap['direction'] = params.direction ?? 'initial';
        if (params.cursorAt != null) {
          requestBodyMap['cursor_at'] = params.cursorAt;
        }
        filters['role'] = params.roleFilter ?? 'any';
        break;
    }

    if (filters.isNotEmpty) {
      requestBodyMap['filters'] = filters;
    }

    // Добавляем фильтр по клиенту, если он есть (для не-timeline режимов)
    if (params.clientId != null) {
      requestBodyMap['client_id'] = params.clientId;
    }
    if (params.status != null && params.status!.isNotEmpty) {
      requestBodyMap['status'] = params.status;
    }

    final requestBody = jsonEncode(requestBodyMap);

    sl<Talker>().info('TASKS DS: HTTP Request',
      {
        'method': 'POST',
        'url': uri.toString(),
        'headers': _headers,
        'body': requestBody,
      },
    );

    final response = await client.post(
      uri,
      headers: _headers,
      body: requestBody,
    );

    sl<Talker>().info('TASKS DS: HTTP Response',
      {
        'statusCode': response.statusCode,
        'headers': response.headers,
        'body': response.body,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List<TaskModel> tasks;
      TaskPaginationMeta? paginationMeta;

      if (data['metadata'] != null) {
        // Пагинированный список с метаданными
        tasks =
            (data['data'] as List)
                .map((task) => TaskModel.fromJson(task))
                .toList();
        paginationMeta = TaskPaginationMeta.fromJson(data['metadata']);
      } else {
        // Срочные задачи или простой список
        if (data['data'] is List) {
          tasks =
              (data['data'] as List)
                  .map((task) => TaskModel.fromJson(task))
                  .toList();
        } else {
          // Single task returned
          tasks = [TaskModel.fromJson(data['data'])];
        }
      }

      // Диагностическое логирование идентификаторов исполнителей из полученных задач
      try {
        final assigneeIds = <String>{};
        for (final t in tasks) {
          assigneeIds.addAll(t.assigneeIds);
        }
        sl<Talker>().logCustom(
          TasksLog(
            '📦 TASKS DS: Получено задач=${tasks.length}, уникальных assigneeIds=${assigneeIds.length}, sample=[${assigneeIds.take(12).join(', ')}]',
          ),
        );
      } catch (_) {}

      return TasksApiResult(tasks: tasks, paginationMeta: paginationMeta);
    } else {
      throw ServerException(
        message: 'Failed to fetch tasks',
        statusCode: response.statusCode,
        requestUrl: uri.toString(),
        requestBody: requestBody,
        responseBody: response.body,
      );
    }
  }

  @override
  Future<TaskModel> getTask(String firmId, String taskId,
      {bool onlyMy = true}) async {
    final uri = Uri.parse(TasksApiUrls.manage());
    final requestBody = jsonEncode({
      'firm_id': firmId,
      'action': 'GET',
      'task_id': taskId,
      'only_my': onlyMy,
    });

    sl<Talker>().info('TASKS DS: HTTP Request',
      {
        'method': 'POST',
        'url': uri.toString(),
        'headers': _headers,
        'body': requestBody,
      },
    );

    final response = await client.post(
      uri,
      headers: _headers,
      body: requestBody,
    );

    sl<Talker>().info('TASKS DS: HTTP Response',
      {
        'statusCode': response.statusCode,
        'headers': response.headers,
        'body': response.body,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return TaskModel.fromJson(data['data']);
    } else {
      throw ServerException(
        message: 'Failed to fetch task',
        statusCode: response.statusCode,
        requestUrl: uri.toString(),
        requestBody: requestBody,
        responseBody: response.body,
      );
    }
  }

  @override
  Future<String> saveTask(String firmId, TaskModel task) async {
    final Map<String, dynamic> body = {
      'firm_id': firmId,
      'action': 'UPSERT',
      'payload': task.toJson(),
    };

    // Если у задачи есть ID, то это обновление
    if (task.id.isNotEmpty && task.id != 'new') {
      body['task_id'] = task.id;
    }

    final uri = Uri.parse(TasksApiUrls.manage());
    final requestBody = jsonEncode(body);

    sl<Talker>().info('TASKS DS: HTTP Request',
      {
        'method': 'POST',
        'url': uri.toString(),
        'headers': _headers,
        'body': requestBody,
      },
    );

    Future<http.Response> post(String body) async {
      final res = await client.post(uri, headers: _headers, body: body);
      sl<Talker>().info('TASKS DS: HTTP Response',
        {
          'statusCode': res.statusCode,
          'headers': res.headers,
          'body': res.body,
        },
      );
      return res;
    }

    http.Response response = await post(requestBody);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['task_id'] ?? task.id;
    }

    // Если получили 403 и сообщение о частичном доступе, повторяем с урезанным payload
    if (response.statusCode == 403 &&
        response.body.contains("only modify 'status' and 'checklist_json'")) {
      final minimalPayload = {
        'status': task.status,
        'checklist_json': jsonEncode(task.checklist),
        'updated_at':
            '${DateTime.now().toUtc().toIso8601String().split('.').first}Z',
      };
      final retryBody = jsonEncode({
        'firm_id': firmId,
        'action': 'UPSERT',
        'task_id': task.id,
        'payload': minimalPayload,
      });

      response = await post(retryBody);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['task_id'] ?? task.id;
      }
    }

    throw ServerException(
      message: 'Failed to save task',
      statusCode: response.statusCode,
      requestUrl: uri.toString(),
      requestBody: requestBody,
      responseBody: response.body,
    );
  }

  @override
  Future<void> deleteTask(String firmId, String taskId) async {
    final uri = Uri.parse(TasksApiUrls.manage());
    final requestBody = jsonEncode({
      'firm_id': firmId,
      'action': 'DELETE',
      'task_id': taskId,
    });

    sl<Talker>().info('TASKS DS: HTTP Request',
      {
        'method': 'POST',
        'url': uri.toString(),
        'headers': _headers,
        'body': requestBody,
      },
    );

    final response = await client.post(
      uri,
      headers: _headers,
      body: requestBody,
    );

    sl<Talker>().info('TASKS DS: HTTP Response',
      {
        'statusCode': response.statusCode,
        'headers': response.headers,
        'body': response.body,
      },
    );

    if (response.statusCode != 200) {
      throw ServerException(
        message: 'Failed to delete task',
        statusCode: response.statusCode,
        requestUrl: uri.toString(),
        requestBody: requestBody,
        responseBody: response.body,
      );
    }
  }
}
