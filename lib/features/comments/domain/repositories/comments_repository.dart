import 'package:dartz/dartz.dart';
import 'package:balansoved_mobile/core/error/failure.dart';
import '../entities/comment_entity.dart';

/// Результат запроса комментариев
class CommentsResult {
  final List<CommentEntity> comments;
  final int totalItems;
  final int page;
  final bool hasMore;

  CommentsResult({
    required this.comments,
    required this.totalItems,
    required this.page,
    required this.hasMore,
  });
}

/// Репозиторий для работы с комментариями
abstract class CommentsRepository {
  /// Получить список комментариев для задачи
  /// [firmId] - ID фирмы
  /// [taskId] - ID задачи
  /// [parentCommentId] - ID родительского комментария (для загрузки ответов)
  /// [page] - номер страницы (0-based)
  Future<Either<Failure, CommentsResult>> getComments({
    required String firmId,
    required String taskId,
    String? parentCommentId,
    int page = 0,
  });

  /// Создать новый комментарий
  /// [firmId] - ID фирмы
  /// [taskId] - ID задачи
  /// [text] - Текст комментария
  /// [parentCommentId] - ID родительского комментария (для ответа в ветку)
  /// [replyToCommentId] - ID конкретного комментария, на который отвечаем (цитирование)
  Future<Either<Failure, CommentEntity>> createComment({
    required String firmId,
    required String taskId,
    required String text,
    String? parentCommentId,
    String? replyToCommentId,
  });

  /// Обновить существующий комментарий
  /// [firmId] - ID фирмы
  /// [taskId] - ID задачи
  /// [commentId] - ID комментария
  /// [createdAt] - Дата создания (часть составного ключа)
  /// [text] - Новый текст комментария
  Future<Either<Failure, CommentEntity>> updateComment({
    required String firmId,
    required String taskId,
    required String commentId,
    required DateTime createdAt,
    required String text,
  });

  /// Удалить комментарий
  /// [firmId] - ID фирмы
  /// [taskId] - ID задачи
  /// [commentId] - ID комментария
  /// [createdAt] - Дата создания (часть составного ключа)
  Future<Either<Failure, void>> deleteComment({
    required String firmId,
    required String taskId,
    required String commentId,
    required DateTime createdAt,
  });
}
