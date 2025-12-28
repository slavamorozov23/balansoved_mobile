import 'package:dartz/dartz.dart';
import 'package:balansoved_mobile/core/error/failure.dart';
import '../repositories/comments_repository.dart';

/// UseCase для удаления комментария
class DeleteCommentUseCase {
  final CommentsRepository repository;

  DeleteCommentUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String firmId,
    required String taskId,
    required String commentId,
    required DateTime createdAt,
  }) {
    return repository.deleteComment(
      firmId: firmId,
      taskId: taskId,
      commentId: commentId,
      createdAt: createdAt,
    );
  }
}
