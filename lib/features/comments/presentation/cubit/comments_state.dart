import 'package:equatable/equatable.dart';
import '../../domain/entities/comment_entity.dart';

abstract class CommentsState extends Equatable {
  const CommentsState();

  @override
  List<Object?> get props => [];
}

/// Начальное состояние
class CommentsInitial extends CommentsState {}

/// Загрузка комментариев
class CommentsLoading extends CommentsState {}

/// Комментарии успешно загружены
class CommentsLoaded extends CommentsState {
  /// Список комментариев верхнего уровня
  final List<CommentEntity> comments;
  
  /// Общее количество корневых комментариев
  final int totalItems;
  
  /// Есть ли ещё комментарии для подгрузки
  final bool hasMoreComments;
  
  /// Текущая страница корневых комментариев
  final int currentPage;
  
  /// Карта ответов: commentId -> список ответов
  final Map<String, List<CommentEntity>> replies;
  
  /// Карта общего количества ответов: commentId -> total
  final Map<String, int> repliesTotal;
  
  /// Карта hasMore для ответов: commentId -> hasMore
  final Map<String, bool> repliesHasMore;
  
  /// Карта текущих страниц ответов: commentId -> page
  final Map<String, int> repliesPage;
  
  /// ID комментариев, для которых показываются ответы
  final Set<String> expandedReplies;
  
  /// ID комментария, на который пишется ответ (null если не пишется)
  final String? replyingToId;
  
  /// Комментарий, на который отвечаем (для отображения "В ответ на...")
  final CommentEntity? replyToComment;
  
  /// ID редактируемого комментария (null если не редактируется)
  final String? editingCommentId;

  const CommentsLoaded({
    required this.comments,
    this.totalItems = 0,
    this.hasMoreComments = false,
    this.currentPage = 0,
    this.replies = const {},
    this.repliesTotal = const {},
    this.repliesHasMore = const {},
    this.repliesPage = const {},
    this.expandedReplies = const {},
    this.replyingToId,
    this.replyToComment,
    this.editingCommentId,
  });

  CommentsLoaded copyWith({
    List<CommentEntity>? comments,
    int? totalItems,
    bool? hasMoreComments,
    int? currentPage,
    Map<String, List<CommentEntity>>? replies,
    Map<String, int>? repliesTotal,
    Map<String, bool>? repliesHasMore,
    Map<String, int>? repliesPage,
    Set<String>? expandedReplies,
    String? replyingToId,
    CommentEntity? replyToComment,
    String? editingCommentId,
    bool clearReplyingTo = false,
    bool clearEditingComment = false,
    bool clearReplyToComment = false,
  }) {
    return CommentsLoaded(
      comments: comments ?? this.comments,
      totalItems: totalItems ?? this.totalItems,
      hasMoreComments: hasMoreComments ?? this.hasMoreComments,
      currentPage: currentPage ?? this.currentPage,
      replies: replies ?? this.replies,
      repliesTotal: repliesTotal ?? this.repliesTotal,
      repliesHasMore: repliesHasMore ?? this.repliesHasMore,
      repliesPage: repliesPage ?? this.repliesPage,
      expandedReplies: expandedReplies ?? this.expandedReplies,
      replyingToId: clearReplyingTo ? null : (replyingToId ?? this.replyingToId),
      replyToComment: clearReplyToComment ? null : (replyToComment ?? this.replyToComment),
      editingCommentId: clearEditingComment ? null : (editingCommentId ?? this.editingCommentId),
    );
  }

  @override
  List<Object?> get props => [
        comments,
        totalItems,
        hasMoreComments,
        currentPage,
        replies,
        repliesTotal,
        repliesHasMore,
        repliesPage,
        expandedReplies,
        replyingToId,
        replyToComment,
        editingCommentId,
      ];
}

/// Загрузка ответов на комментарий
class CommentsLoadingReplies extends CommentsLoaded {
  final String loadingParentId;

  const CommentsLoadingReplies({
    required super.comments,
    super.totalItems,
    super.hasMoreComments,
    super.currentPage,
    super.replies,
    super.repliesTotal,
    super.repliesHasMore,
    super.repliesPage,
    super.expandedReplies,
    super.replyingToId,
    super.replyToComment,
    super.editingCommentId,
    required this.loadingParentId,
  });

  @override
  List<Object?> get props => [...super.props, loadingParentId];
}

/// Отправка нового комментария
class CommentsSending extends CommentsLoaded {
  const CommentsSending({
    required super.comments,
    super.totalItems,
    super.hasMoreComments,
    super.currentPage,
    super.replies,
    super.repliesTotal,
    super.repliesHasMore,
    super.repliesPage,
    super.expandedReplies,
    super.replyingToId,
    super.replyToComment,
    super.editingCommentId,
  });
}

/// Ошибка
class CommentsError extends CommentsState {
  final String message;

  const CommentsError(this.message);

  @override
  List<Object?> get props => [message];
}
