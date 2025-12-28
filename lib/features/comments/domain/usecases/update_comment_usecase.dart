import 'package:dartz/dartz.dart';
import 'package:balansoved_mobile/core/error/failure.dart';
import '../entities/comment_entity.dart';
import '../repositories/comments_repository.dart';

/// UseCase для обновления комментария
class UpdateCommentUseCase {
  final CommentsRepository repository;

  UpdateCommentUseCase(this.repository);

  Future<Either<Failure, CommentEntity>> call({
    required String firmId,
    required String taskId,
    required String commentId,
    required DateTime createdAt,
    required String text,
  }) {
    return repository.updateComment(
      firmId: firmId,
      taskId: taskId,
      commentId: commentId,
      createdAt: createdAt,
      text: text,
    );
  }
}
