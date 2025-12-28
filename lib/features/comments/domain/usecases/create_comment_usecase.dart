import 'package:dartz/dartz.dart';
import 'package:balansoved_mobile/core/error/failure.dart';
import '../entities/comment_entity.dart';
import '../repositories/comments_repository.dart';

/// UseCase для создания комментария
class CreateCommentUseCase {
  final CommentsRepository repository;

  CreateCommentUseCase(this.repository);

  Future<Either<Failure, CommentEntity>> call({
    required String firmId,
    required String taskId,
    required String text,
    String? parentCommentId,
    String? replyToCommentId,
  }) {
    return repository.createComment(
      firmId: firmId,
      taskId: taskId,
      text: text,
      parentCommentId: parentCommentId,
      replyToCommentId: replyToCommentId,
    );
  }
}
