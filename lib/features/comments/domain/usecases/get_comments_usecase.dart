import 'package:dartz/dartz.dart';
import 'package:balansoved_mobile/core/error/failure.dart';
import '../repositories/comments_repository.dart';

/// UseCase для получения списка комментариев
class GetCommentsUseCase {
  final CommentsRepository repository;

  GetCommentsUseCase(this.repository);

  Future<Either<Failure, CommentsResult>> call({
    required String firmId,
    required String taskId,
    String? parentCommentId,
    int page = 0,
  }) {
    return repository.getComments(
      firmId: firmId,
      taskId: taskId,
      parentCommentId: parentCommentId,
      page: page,
    );
  }
}
