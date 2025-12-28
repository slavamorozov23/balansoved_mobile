import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/usecases/get_comments_usecase.dart';
import '../../domain/usecases/create_comment_usecase.dart';
import '../../domain/usecases/update_comment_usecase.dart';
import '../../domain/usecases/delete_comment_usecase.dart';
import 'comments_state.dart';

/// Cubit для управления комментариями к задаче
class CommentsCubit extends Cubit<CommentsState> {
  final GetCommentsUseCase getCommentsUseCase;
  final CreateCommentUseCase createCommentUseCase;
  final UpdateCommentUseCase updateCommentUseCase;
  final DeleteCommentUseCase deleteCommentUseCase;

  String? _firmId;
  String? _taskId;

  CommentsCubit({
    required this.getCommentsUseCase,
    required this.createCommentUseCase,
    required this.updateCommentUseCase,
    required this.deleteCommentUseCase,
  }) : super(CommentsInitial());

  /// Загрузить комментарии для задачи (корневые)
  Future<void> loadComments({
    required String firmId,
    required String taskId,
  }) async {
    _firmId = firmId;
    _taskId = taskId;
    
    emit(CommentsLoading());

    final result = await getCommentsUseCase(
      firmId: firmId,
      taskId: taskId,
      page: 0,
    );

    result.fold(
      (failure) => emit(CommentsError(failure.message)),
      (commentsResult) {
        // Сортируем по дате (новые сверху)
        final sorted = commentsResult.comments.toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        emit(CommentsLoaded(
          comments: sorted,
          totalItems: commentsResult.totalItems,
          hasMoreComments: commentsResult.hasMore,
          currentPage: commentsResult.page,
        ));
      },
    );

    // После загрузки корневых комментариев — пробуем заранее получить
    // информацию о наличии ответов для каждого комментария
    final currentState = state;
    if (currentState is CommentsLoaded) {
      await _prefetchRepliesMetadata(currentState.comments);
    }
  }

  /// Префетч информации о количестве ответов для списка комментариев
  Future<void> _prefetchRepliesMetadata(List<CommentEntity> comments) async {
    if (_firmId == null || _taskId == null) return;
    var currentState = state;
    if (currentState is! CommentsLoaded || comments.isEmpty) return;

    // Копируем текущие карты, чтобы не терять уже загруженные данные
    final repliesTotal = Map<String, int>.from(currentState.repliesTotal);
    final repliesHasMore = Map<String, bool>.from(currentState.repliesHasMore);
    final repliesPage = Map<String, int>.from(currentState.repliesPage);

    for (final comment in comments) {
      final result = await getCommentsUseCase(
        firmId: _firmId!,
        taskId: _taskId!,
        parentCommentId: comment.id,
        page: 0,
      );

      result.fold(
        (_) {
          // Игнорируем ошибки префетча, они не критичны для работы UI
        },
        (commentsResult) {
          // Сохраняем только метаданные — сами ответы будут загружены
          // при открытии блока ответов через toggleReplies
          if (commentsResult.totalItems > 0) {
            repliesTotal[comment.id] = commentsResult.totalItems;
            repliesHasMore[comment.id] = commentsResult.hasMore;
            repliesPage[comment.id] = commentsResult.page;
          }
        },
      );
    }

    // Обновляем состояние, если к этому моменту мы всё ещё в CommentsLoaded
    currentState = state;
    if (currentState is CommentsLoaded) {
      emit(currentState.copyWith(
        repliesTotal: repliesTotal,
        repliesHasMore: repliesHasMore,
        repliesPage: repliesPage,
      ));
    }
  }

  /// Загрузить следующую страницу корневых комментариев
  Future<void> loadMoreComments() async {
    final currentState = state;
    if (currentState is! CommentsLoaded || 
        _firmId == null || 
        _taskId == null ||
        !currentState.hasMoreComments) {
      return;
    }

    final nextPage = currentState.currentPage + 1;

    final result = await getCommentsUseCase(
      firmId: _firmId!,
      taskId: _taskId!,
      page: nextPage,
    );

    result.fold(
      (failure) => emit(CommentsError(failure.message)),
      (commentsResult) {
        final allComments = [...currentState.comments, ...commentsResult.comments];
        allComments.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        emit(currentState.copyWith(
          comments: allComments,
          totalItems: commentsResult.totalItems,
          hasMoreComments: commentsResult.hasMore,
          currentPage: nextPage,
        ));

        // Пробуем заранее получить информацию о наличии ответов
        // только для вновь загруженных комментариев
        _prefetchRepliesMetadata(commentsResult.comments);
      },
    );
  }

  /// Открыть/закрыть ответы на комментарий
  Future<void> toggleReplies(String parentCommentId) async {
    final currentState = state;
    if (currentState is! CommentsLoaded || _firmId == null || _taskId == null) {
      return;
    }

    // Если ответы уже развёрнуты — сворачиваем
    if (currentState.expandedReplies.contains(parentCommentId)) {
      emit(currentState.copyWith(
        expandedReplies: Set.from(currentState.expandedReplies)..remove(parentCommentId),
        clearReplyingTo: true,
      ));
      return;
    }

    // Показываем индикатор загрузки
    emit(CommentsLoadingReplies(
      comments: currentState.comments,
      replies: currentState.replies,
      repliesTotal: currentState.repliesTotal,
      repliesHasMore: currentState.repliesHasMore,
      repliesPage: currentState.repliesPage,
      expandedReplies: currentState.expandedReplies,
      replyingToId: currentState.replyingToId,
      editingCommentId: currentState.editingCommentId,
      totalItems: currentState.totalItems,
      hasMoreComments: currentState.hasMoreComments,
      currentPage: currentState.currentPage,
      loadingParentId: parentCommentId,
    ));

    final result = await getCommentsUseCase(
      firmId: _firmId!,
      taskId: _taskId!,
      parentCommentId: parentCommentId,
      page: 0,
    );

    result.fold(
      (failure) => emit(CommentsError(failure.message)),
      (commentsResult) {
        final updatedReplies = Map<String, List<CommentEntity>>.from(currentState.replies);
        final sorted = commentsResult.comments.toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt)); // Старые сверху для ответов
        updatedReplies[parentCommentId] = sorted;

        final updatedTotal = Map<String, int>.from(currentState.repliesTotal);
        updatedTotal[parentCommentId] = commentsResult.totalItems;

        final updatedHasMore = Map<String, bool>.from(currentState.repliesHasMore);
        updatedHasMore[parentCommentId] = commentsResult.hasMore;

        final updatedPage = Map<String, int>.from(currentState.repliesPage);
        updatedPage[parentCommentId] = commentsResult.page;

        emit(CommentsLoaded(
          comments: currentState.comments,
          replies: updatedReplies,
          repliesTotal: updatedTotal,
          repliesHasMore: updatedHasMore,
          repliesPage: updatedPage,
          expandedReplies: Set.from(currentState.expandedReplies)..add(parentCommentId),
          replyingToId: parentCommentId, // Автоматически начинаем режим ответа
          editingCommentId: currentState.editingCommentId,
          totalItems: currentState.totalItems,
          hasMoreComments: currentState.hasMoreComments,
          currentPage: currentState.currentPage,
        ));
      },
    );
  }

  /// Загрузить следующую страницу ответов
  Future<void> loadMoreReplies(String parentCommentId) async {
    final currentState = state;
    if (currentState is! CommentsLoaded || _firmId == null || _taskId == null) {
      return;
    }

    if (!(currentState.repliesHasMore[parentCommentId] ?? false)) {
      return;
    }

    final nextPage = (currentState.repliesPage[parentCommentId] ?? 0) + 1;

    final result = await getCommentsUseCase(
      firmId: _firmId!,
      taskId: _taskId!,
      parentCommentId: parentCommentId,
      page: nextPage,
    );

    result.fold(
      (failure) => emit(CommentsError(failure.message)),
      (commentsResult) {
        final updatedReplies = Map<String, List<CommentEntity>>.from(currentState.replies);
        final existing = updatedReplies[parentCommentId] ?? [];
        final newReplies = [...existing, ...commentsResult.comments];
        newReplies.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        updatedReplies[parentCommentId] = newReplies;

        final updatedHasMore = Map<String, bool>.from(currentState.repliesHasMore);
        updatedHasMore[parentCommentId] = commentsResult.hasMore;

        final updatedPage = Map<String, int>.from(currentState.repliesPage);
        updatedPage[parentCommentId] = nextPage;

        emit(currentState.copyWith(
          replies: updatedReplies,
          repliesHasMore: updatedHasMore,
          repliesPage: updatedPage,
        ));
      },
    );
  }

  /// Начать ответ на комментарий
  /// [replyToComment] — комментарий, на который отвечаем (для отображения "В ответ на...")
  void startReply(String parentCommentId, {CommentEntity? replyToComment}) {
    final currentState = state;
    if (currentState is CommentsLoaded) {
      emit(CommentsLoaded(
        comments: currentState.comments,
        totalItems: currentState.totalItems,
        hasMoreComments: currentState.hasMoreComments,
        currentPage: currentState.currentPage,
        replies: currentState.replies,
        repliesTotal: currentState.repliesTotal,
        repliesHasMore: currentState.repliesHasMore,
        repliesPage: currentState.repliesPage,
        expandedReplies: currentState.expandedReplies,
        replyingToId: parentCommentId,
        replyToComment: replyToComment,
        editingCommentId: null,
      ));
    }
  }

  /// Отменить ответ
  void cancelReply() {
    final currentState = state;
    if (currentState is CommentsLoaded) {
      emit(currentState.copyWith(
        clearReplyingTo: true,
        clearReplyToComment: true,
      ));
    }
  }

  /// Отменить только replyToComment (оставить режим ответа в ветку)
  void cancelReplyToComment() {
    final currentState = state;
    if (currentState is CommentsLoaded) {
      emit(currentState.copyWith(
        clearReplyToComment: true,
      ));
    }
  }

  /// Начать редактирование комментария
  void startEditing(String commentId) {
    final currentState = state;
    if (currentState is CommentsLoaded) {
      emit(currentState.copyWith(
        editingCommentId: commentId,
        clearReplyingTo: true,
      ));
    }
  }

  /// Отменить редактирование
  void cancelEditing() {
    final currentState = state;
    if (currentState is CommentsLoaded) {
      emit(currentState.copyWith(clearEditingComment: true));
    }
  }

  /// Создать новый комментарий
  Future<void> createComment({
    required String text,
    String? parentCommentId,
    String? replyToCommentId,
  }) async {
    if (_firmId == null || _taskId == null) return;

    final currentState = state;
    if (currentState is! CommentsLoaded) return;

    emit(CommentsSending(
      comments: currentState.comments,
      totalItems: currentState.totalItems,
      hasMoreComments: currentState.hasMoreComments,
      currentPage: currentState.currentPage,
      replies: currentState.replies,
      repliesTotal: currentState.repliesTotal,
      repliesHasMore: currentState.repliesHasMore,
      repliesPage: currentState.repliesPage,
      expandedReplies: currentState.expandedReplies,
      replyingToId: currentState.replyingToId,
      replyToComment: currentState.replyToComment,
      editingCommentId: currentState.editingCommentId,
    ));

    final result = await createCommentUseCase(
      firmId: _firmId!,
      taskId: _taskId!,
      text: text,
      parentCommentId: parentCommentId,
      replyToCommentId: replyToCommentId,
    );

    result.fold(
      (failure) => emit(CommentsError(failure.message)),
      (newComment) {
        // Добавляем комментарий локально вместо полной перезагрузки
        if (parentCommentId != null) {
          // Это ответ — добавляем в список ответов
          final updatedReplies = Map<String, List<CommentEntity>>.from(currentState.replies);
          final existingReplies = updatedReplies[parentCommentId] ?? [];
          updatedReplies[parentCommentId] = [...existingReplies, newComment];
          
          // Обновляем счётчик ответов
          final updatedTotal = Map<String, int>.from(currentState.repliesTotal);
          updatedTotal[parentCommentId] = (updatedTotal[parentCommentId] ?? 0) + 1;
          
          emit(CommentsLoaded(
            comments: currentState.comments,
            totalItems: currentState.totalItems,
            hasMoreComments: currentState.hasMoreComments,
            currentPage: currentState.currentPage,
            replies: updatedReplies,
            repliesTotal: updatedTotal,
            repliesHasMore: currentState.repliesHasMore,
            repliesPage: currentState.repliesPage,
            expandedReplies: currentState.expandedReplies,
            replyingToId: null, // Сбрасываем режим ответа
            replyToComment: null,
            editingCommentId: null,
          ));
        } else {
          // Это корневой комментарий — добавляем в начало списка
          final updatedComments = [newComment, ...currentState.comments];
          
          emit(CommentsLoaded(
            comments: updatedComments,
            totalItems: currentState.totalItems + 1,
            hasMoreComments: currentState.hasMoreComments,
            currentPage: currentState.currentPage,
            replies: currentState.replies,
            repliesTotal: currentState.repliesTotal,
            repliesHasMore: currentState.repliesHasMore,
            repliesPage: currentState.repliesPage,
            expandedReplies: currentState.expandedReplies,
            replyingToId: null,
            replyToComment: null,
            editingCommentId: null,
          ));
        }
      },
    );
  }

  /// Обновить комментарий
  Future<void> updateComment({
    required String commentId,
    required DateTime createdAt,
    required String text,
  }) async {
    if (_firmId == null || _taskId == null) return;

    final currentState = state;
    if (currentState is! CommentsLoaded) return;

    emit(CommentsSending(
      comments: currentState.comments,
      totalItems: currentState.totalItems,
      hasMoreComments: currentState.hasMoreComments,
      currentPage: currentState.currentPage,
      replies: currentState.replies,
      repliesTotal: currentState.repliesTotal,
      repliesHasMore: currentState.repliesHasMore,
      repliesPage: currentState.repliesPage,
      expandedReplies: currentState.expandedReplies,
      replyingToId: currentState.replyingToId,
      replyToComment: currentState.replyToComment,
      editingCommentId: currentState.editingCommentId,
    ));

    final result = await updateCommentUseCase(
      firmId: _firmId!,
      taskId: _taskId!,
      commentId: commentId,
      createdAt: createdAt,
      text: text,
    );

    result.fold(
      (failure) => emit(CommentsError(failure.message)),
      (comment) {
        // Перезагружаем комментарии для актуальности
        loadComments(firmId: _firmId!, taskId: _taskId!);
      },
    );
  }

  /// Удалить комментарий
  Future<void> deleteComment({
    required String commentId,
    required DateTime createdAt,
  }) async {
    if (_firmId == null || _taskId == null) return;

    final currentState = state;
    if (currentState is! CommentsLoaded) return;

    final result = await deleteCommentUseCase(
      firmId: _firmId!,
      taskId: _taskId!,
      commentId: commentId,
      createdAt: createdAt,
    );

    result.fold(
      (failure) => emit(CommentsError(failure.message)),
      (_) {
        // Перезагружаем комментарии для актуальности
        loadComments(firmId: _firmId!, taskId: _taskId!);
      },
    );
  }

  /// Сброс состояния
  void reset() {
    _firmId = null;
    _taskId = null;
    emit(CommentsInitial());
  }
}
