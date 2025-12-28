import 'package:equatable/equatable.dart';

/// Сущность комментария к задаче
class CommentEntity extends Equatable {
  /// Уникальный идентификатор комментария
  final String id;
  
  /// ID задачи, к которой относится комментарий
  final String taskId;
  
  /// ID автора комментария
  final String authorId;
  
  /// Текст комментария
  final String text;
  
  /// Дата создания комментария
  final DateTime createdAt;
  
  /// Дата обновления комментария (null если не редактировался)
  final DateTime? updatedAt;
  
  /// ID родительского комментария (для ответов)
  /// null — если это комментарий верхнего уровня
  final String? parentCommentId;
  
  /// ID конкретного комментария, на который дается ответ (цитирование)
  /// Используется для визуализации "В ответ на..." и уведомлений
  final String? replyToCommentId;
  
  /// Флаг удалённого комментария (soft delete)
  final bool isDeleted;

  const CommentEntity({
    required this.id,
    required this.taskId,
    required this.authorId,
    required this.text,
    required this.createdAt,
    this.updatedAt,
    this.parentCommentId,
    this.replyToCommentId,
    this.isDeleted = false,
  });

  /// Проверяет, является ли комментарий ответом на другой комментарий
  bool get isReply => parentCommentId != null;
  
  /// Проверяет, был ли комментарий отредактирован
  bool get isEdited => updatedAt != null && updatedAt != createdAt;

  CommentEntity copyWith({
    String? id,
    String? taskId,
    String? authorId,
    String? text,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? parentCommentId,
    String? replyToCommentId,
    bool? isDeleted,
  }) {
    return CommentEntity(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      authorId: authorId ?? this.authorId,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      replyToCommentId: replyToCommentId ?? this.replyToCommentId,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  List<Object?> get props => [
        id,
        taskId,
        authorId,
        text,
        createdAt,
        updatedAt,
        parentCommentId,
        replyToCommentId,
        isDeleted,
      ];
}
