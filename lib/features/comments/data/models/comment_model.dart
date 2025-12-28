import '../../domain/entities/comment_entity.dart';

/// Модель комментария для работы с API
class CommentModel extends CommentEntity {
  const CommentModel({
    required super.id,
    required super.taskId,
    required super.authorId,
    required super.text,
    required super.createdAt,
    super.updatedAt,
    super.parentCommentId,
    super.replyToCommentId,
    super.isDeleted,
  });

  /// Создание модели из JSON
  factory CommentModel.fromJson(Map<String, dynamic> json) {
    try {
      return CommentModel(
        id: json['comment_id']?.toString() ?? '',
        taskId: json['task_id']?.toString() ?? '',
        authorId: json['author_user_id']?.toString() ?? '',
        text: json['text']?.toString() ?? '',
        createdAt: _parseDateTime(json['created_at']),
        updatedAt: json['updated_at'] != null 
            ? _parseDateTime(json['updated_at']) 
            : null,
        parentCommentId: json['parent_comment_id']?.toString(),
        replyToCommentId: json['reply_to_comment_id']?.toString(),
        isDeleted: json['is_deleted'] == true || json['is_deleted'] == 'true',
      );
    } catch (e) {
      // Логируем проблемный JSON для отладки
      throw FormatException('"data": ${e.toString()}\nJSON: $json');
    }
  }

  /// Преобразование в JSON для отправки на сервер
  Map<String, dynamic> toJson() {
    return {
      'comment_id': id,
      'task_id': taskId,
      'author_user_id': authorId,
      'text': text,
      'created_at': _formatDateTime(createdAt),
      if (updatedAt != null) 'updated_at': _formatDateTime(updatedAt!),
      if (parentCommentId != null) 'parent_comment_id': parentCommentId,
      if (replyToCommentId != null) 'reply_to_comment_id': replyToCommentId,
      'is_deleted': isDeleted,
    };
  }

  /// Парсинг даты из различных форматов (микросекунды или ISO)
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    
    if (value is int) {
      // Микросекунды (как в YDB)
      return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true);
    }
    
    if (value is String) {
      // Попробуем сначала как число микросекунд в строке
      final parsed = int.tryParse(value);
      if (parsed != null) {
        return DateTime.fromMicrosecondsSinceEpoch(parsed, isUtc: true);
      }
      // ISO формат
      return DateTime.parse(value);
    }
    
    return DateTime.now();
  }

  /// Форматирование даты для API
  static String _formatDateTime(DateTime dateTime) {
    return dateTime.toUtc().toIso8601String();
  }

  /// Создание модели из entity
  factory CommentModel.fromEntity(CommentEntity entity) {
    return CommentModel(
      id: entity.id,
      taskId: entity.taskId,
      authorId: entity.authorId,
      text: entity.text,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      parentCommentId: entity.parentCommentId,
      replyToCommentId: entity.replyToCommentId,
      isDeleted: entity.isDeleted,
    );
  }

  /// Преобразование в entity
  CommentEntity toEntity() {
    return CommentEntity(
      id: id,
      taskId: taskId,
      authorId: authorId,
      text: text,
      createdAt: createdAt,
      updatedAt: updatedAt,
      parentCommentId: parentCommentId,
      replyToCommentId: replyToCommentId,
      isDeleted: isDeleted,
    );
  }
}
