import 'package:dartz/dartz.dart';
import 'package:balansoved_mobile/core/error/failure.dart';
import 'package:balansoved_mobile/core/logging/comments_logger.dart';
import 'package:balansoved_mobile/features/auth/data/data_source/auth_local_data_source.dart';
import 'package:balansoved_mobile/injection_container.dart';
import 'package:talker_flutter/talker_flutter.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/repositories/comments_repository.dart';
import '../data_source/comments_remote_data_source.dart';

class CommentsRepositoryImpl implements CommentsRepository {
  final CommentsRemoteDataSource remoteDataSource;
  final IAuthLocalDataSource localAuth;

  CommentsRepositoryImpl({
    required this.remoteDataSource,
    required this.localAuth,
  });

  Future<String?> _getToken() async {
    return await localAuth.getAccessToken();
  }

  @override
  Future<Either<Failure, CommentsResult>> getComments({
    required String firmId,
    required String taskId,
    String? parentCommentId,
    int page = 0,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return Left(ServerFailure(message: 'Токен доступа отсутствует'));
      }

      final response = await remoteDataSource.getComments(
        token: token,
        firmId: firmId,
        taskId: taskId,
        parentCommentId: parentCommentId,
        page: page,
      );

      return Right(CommentsResult(
        comments: response.comments.map((m) => m.toEntity()).toList(),
        totalItems: response.totalItems,
        page: response.page,
        hasMore: response.hasMore,
      ));
    } catch (e) {
      sl<Talker>().logCustom(
        CommentsErrorLog('CommentsRepository: Error in getComments', e),
      );
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CommentEntity>> createComment({
    required String firmId,
    required String taskId,
    required String text,
    String? parentCommentId,
    String? replyToCommentId,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return Left(ServerFailure(message: 'Токен доступа отсутствует'));
      }

      final comment = await remoteDataSource.createComment(
        token: token,
        firmId: firmId,
        taskId: taskId,
        text: text,
        parentCommentId: parentCommentId,
        replyToCommentId: replyToCommentId,
      );

      return Right(comment.toEntity());
    } catch (e) {
      sl<Talker>().logCustom(
        CommentsErrorLog('CommentsRepository: Error in createComment', e),
      );
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CommentEntity>> updateComment({
    required String firmId,
    required String taskId,
    required String commentId,
    required DateTime createdAt,
    required String text,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return Left(ServerFailure(message: 'Токен доступа отсутствует'));
      }

      final comment = await remoteDataSource.updateComment(
        token: token,
        firmId: firmId,
        taskId: taskId,
        commentId: commentId,
        createdAt: createdAt.toUtc().toIso8601String(),
        text: text,
      );

      return Right(comment.toEntity());
    } catch (e) {
      sl<Talker>().logCustom(
        CommentsErrorLog('CommentsRepository: Error in updateComment', e),
      );
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteComment({
    required String firmId,
    required String taskId,
    required String commentId,
    required DateTime createdAt,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return Left(ServerFailure(message: 'Токен доступа отсутствует'));
      }

      await remoteDataSource.deleteComment(
        token: token,
        firmId: firmId,
        taskId: taskId,
        commentId: commentId,
        createdAt: createdAt.toUtc().toIso8601String(),
      );

      return const Right(null);
    } catch (e) {
      sl<Talker>().logCustom(
        CommentsErrorLog('CommentsRepository: Error in deleteComment', e),
      );
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
