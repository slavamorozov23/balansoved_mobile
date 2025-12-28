import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:balansoved_mobile/core/constants/constants.dart';
import 'package:balansoved_mobile/core/logging/comments_logger.dart';
import 'package:balansoved_mobile/injection_container.dart';
import 'package:talker_flutter/talker_flutter.dart';
import '../models/comment_model.dart';

/// Результат запроса комментариев с метаданными
class CommentsResponse {
  final List<CommentModel> comments;
  final int totalItems;
  final int page;
  final int pageSize;

  CommentsResponse({
    required this.comments,
    required this.totalItems,
    required this.page,
    this.pageSize = 10,
  });

  bool get hasMore => (page + 1) * pageSize < totalItems;
}

/// Источник данных для работы с API комментариев
abstract class CommentsRemoteDataSource {
  /// Получить список комментариев для задачи
  Future<CommentsResponse> getComments({
    required String token,
    required String firmId,
    required String taskId,
    String? parentCommentId,
    int page = 0,
  });

  /// Создать новый комментарий
  Future<CommentModel> createComment({
    required String token,
    required String firmId,
    required String taskId,
    required String text,
    String? parentCommentId,
    String? replyToCommentId,
  });

  /// Обновить комментарий
  Future<CommentModel> updateComment({
    required String token,
    required String firmId,
    required String taskId,
    required String commentId,
    required String createdAt,
    required String text,
  });

  /// Удалить комментарий
  Future<void> deleteComment({
    required String token,
    required String firmId,
    required String taskId,
    required String commentId,
    required String createdAt,
  });
}

class CommentsRemoteDataSourceImpl implements CommentsRemoteDataSource {
  final Dio dio;

  CommentsRemoteDataSourceImpl({required this.dio});

  @override
  Future<CommentsResponse> getComments({
    required String token,
    required String firmId,
    required String taskId,
    String? parentCommentId,
    int page = 0,
  }) async {
    try {
      sl<Talker>().logCustom(
        CommentsLog('COMMENTS DS: Getting comments for task $taskId'),
      );

      final response = await dio.post(
        CommentsApiUrls.manage(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
        data: jsonEncode({
          'firm_id': firmId,
          'task_id': taskId,
          'action': 'GET',
          'page': page,
          if (parentCommentId != null) 'parent_comment_id': parentCommentId,
        }),
      );

      if (response.statusCode == 200) {
        var data = response.data;
        
        // Подробное логирование сырого ответа
        sl<Talker>().logCustom(
          CommentsLog('COMMENTS DS: Raw response type: ${data.runtimeType}'),
        );
        sl<Talker>().logCustom(
          CommentsLog('COMMENTS DS: Raw response: $data'),
        );
        
        // Если data пришла как String — парсим JSON
        if (data is String) {
          sl<Talker>().logCustom(
            CommentsLog('COMMENTS DS: Response is String, parsing JSON...'),
          );
          data = jsonDecode(data);
        }
        
        final List<dynamic> commentsJson = data['data'] ?? [];
        final metadata = data['metadata'] as Map<String, dynamic>? ?? {};
        final totalItems = metadata['total_items'] as int? ?? commentsJson.length;
        
        sl<Talker>().logCustom(
          CommentsLog('COMMENTS DS: Received ${commentsJson.length} comments, total: $totalItems, page: $page'),
        );

        final comments = commentsJson
            .map((json) => CommentModel.fromJson(json as Map<String, dynamic>))
            .toList();
            
        return CommentsResponse(
          comments: comments,
          totalItems: totalItems,
          page: page,
        );
      } else {
        throw Exception('Failed to load comments: ${response.statusCode}');
      }
    } on DioException catch (e) {
      sl<Talker>().logCustom(
        CommentsErrorLog('COMMENTS DS: DioException in getComments', e),
      );
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      sl<Talker>().logCustom(
        CommentsErrorLog('COMMENTS DS: Error in getComments', e),
      );
      rethrow;
    }
  }

  @override
  Future<CommentModel> createComment({
    required String token,
    required String firmId,
    required String taskId,
    required String text,
    String? parentCommentId,
    String? replyToCommentId,
  }) async {
    try {
      sl<Talker>().logCustom(
        CommentsLog('COMMENTS DS: Creating comment for task $taskId'),
      );

      final response = await dio.post(
        CommentsApiUrls.manage(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
        data: jsonEncode({
          'firm_id': firmId,
          'task_id': taskId,
          'action': 'UPSERT',
          'payload': {
            'text': text,
            if (parentCommentId != null) 'parent_comment_id': parentCommentId,
            if (replyToCommentId != null) 'reply_to_comment_id': replyToCommentId,
          },
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        var data = response.data;

        // Логируем сырой ответ UPSERT
        sl<Talker>().logCustom(
          CommentsLog('COMMENTS DS: createComment raw response type: ${data.runtimeType}'),
        );
        sl<Talker>().logCustom(
          CommentsLog('COMMENTS DS: createComment raw response: $data'),
        );

        // Если пришла строка — парсим JSON
        if (data is String) {
          data = jsonDecode(data);
        }

        final commentId = data['comment_id']?.toString() ?? '';

        sl<Talker>().logCustom(
          CommentsLog('COMMENTS DS: Created comment $commentId'),
        );

        // API возвращает только comment_id при создании
        // Загружаем полный список чтобы получить созданный комментарий
        final commentsResp = await getComments(
          token: token,
          firmId: firmId,
          taskId: taskId,
          parentCommentId: parentCommentId,
        );
        
        final createdComment = commentsResp.comments.firstWhere(
          (c) => c.id == commentId,
          orElse: () => CommentModel(
            id: commentId,
            taskId: taskId,
            authorId: '',
            text: text,
            createdAt: DateTime.now(),
            parentCommentId: parentCommentId,
          ),
        );
        
        return createdComment;
      } else {
        throw Exception('Failed to create comment: ${response.statusCode}');
      }
    } on DioException catch (e) {
      sl<Talker>().logCustom(
        CommentsErrorLog('COMMENTS DS: DioException in createComment', e),
      );
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      sl<Talker>().logCustom(
        CommentsErrorLog('COMMENTS DS: Error in createComment', e),
      );
      rethrow;
    }
  }

  @override
  Future<CommentModel> updateComment({
    required String token,
    required String firmId,
    required String taskId,
    required String commentId,
    required String createdAt,
    required String text,
  }) async {
    try {
      sl<Talker>().logCustom(
        CommentsLog('COMMENTS DS: Updating comment $commentId'),
      );

      final response = await dio.post(
        CommentsApiUrls.manage(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
        data: jsonEncode({
          'firm_id': firmId,
          'task_id': taskId,
          'action': 'UPSERT',
          'comment_id': commentId,
          'created_at': createdAt,
          'payload': {
            'text': text,
          },
        }),
      );

      if (response.statusCode == 200) {
        sl<Talker>().logCustom(
          CommentsLog('COMMENTS DS: Updated comment $commentId'),
        );

        // Загружаем обновлённый комментарий
        final resp = await getComments(
          token: token,
          firmId: firmId,
          taskId: taskId,
        );
        
        return resp.comments.firstWhere(
          (c) => c.id == commentId,
          orElse: () => CommentModel(
            id: commentId,
            taskId: taskId,
            authorId: '',
            text: text,
            createdAt: DateTime.parse(createdAt),
            updatedAt: DateTime.now(),
          ),
        );
      } else {
        throw Exception('Failed to update comment: ${response.statusCode}');
      }
    } on DioException catch (e) {
      sl<Talker>().logCustom(
        CommentsErrorLog('COMMENTS DS: DioException in updateComment', e),
      );
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      sl<Talker>().logCustom(
        CommentsErrorLog('COMMENTS DS: Error in updateComment', e),
      );
      rethrow;
    }
  }

  @override
  Future<void> deleteComment({
    required String token,
    required String firmId,
    required String taskId,
    required String commentId,
    required String createdAt,
  }) async {
    try {
      sl<Talker>().logCustom(
        CommentsLog('COMMENTS DS: Deleting comment $commentId'),
      );

      final response = await dio.post(
        CommentsApiUrls.manage(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
        data: jsonEncode({
          'firm_id': firmId,
          'task_id': taskId,
          'action': 'DELETE',
          'comment_id': commentId,
          'created_at': createdAt,
        }),
      );

      if (response.statusCode == 200) {
        sl<Talker>().logCustom(
          CommentsLog('COMMENTS DS: Deleted comment $commentId'),
        );
      } else {
        throw Exception('Failed to delete comment: ${response.statusCode}');
      }
    } on DioException catch (e) {
      sl<Talker>().logCustom(
        CommentsErrorLog('COMMENTS DS: DioException in deleteComment', e),
      );
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      sl<Talker>().logCustom(
        CommentsErrorLog('COMMENTS DS: Error in deleteComment', e),
      );
      rethrow;
    }
  }
}
