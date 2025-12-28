import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/task_styles.dart';
import '../../domain/entities/comment_entity.dart';

/// Функция для преобразования @uid в имя пользователя
typedef MentionResolver = String Function(String uid);

/// Callback при нажатии на @mention
typedef MentionTapCallback = void Function(String commentId);

/// Виджет отдельного комментария
class CommentItem extends StatelessWidget {
  final CommentEntity comment;
  final String? authorName;
  final bool isCurrentUser;
  final bool isEditing;
  final int repliesCount;
  final bool repliesExpanded;
  final bool repliesLoading;
  final VoidCallback? onReply;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleReplies;
  final bool isNested;
  
  /// Функция для преобразования @uid -> имя сотрудника
  final MentionResolver? mentionResolver;
  
  /// Callback при нажатии на @mention (для скролла к комментарию)
  final MentionTapCallback? onMentionTap;

  const CommentItem({
    super.key,
    required this.comment,
    this.authorName,
    this.isCurrentUser = false,
    this.isEditing = false,
    this.repliesCount = 0,
    this.repliesExpanded = false,
    this.repliesLoading = false,
    this.onReply,
    this.onEdit,
    this.onDelete,
    this.onToggleReplies,
    this.isNested = false,
    this.mentionResolver,
    this.onMentionTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLight = colorScheme.brightness == Brightness.light;
    final accentColor = TaskStyles.accentColor;
    final accentFgColor = TaskStyles.accentForegroundColor(colorScheme);
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');
    
    return Container(
      margin: EdgeInsets.only(
        left: isNested ? 8 : 0,
        bottom: 12,
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок: автор и дата
          Row(
            children: [
              // Аватар
              CircleAvatar(
                radius: 14,
                backgroundColor: isLight 
                    ? accentColor.withValues(alpha: 0.12) 
                    : accentColor.withValues(alpha: 0.25),
                child: Text(
                  _getInitials(authorName ?? 'U'),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: accentFgColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              
              // Имя автора
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authorName ?? 'Пользователь',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      dateFormat.format(comment.createdAt.toLocal()),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Метка "изменено"
              if (comment.isEdited)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: accentFgColor.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'изменено',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: accentFgColor,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Плашка "В ответ на..." если есть replyToCommentId
          if (comment.replyToCommentId != null && mentionResolver != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: InkWell(
                onTap: onMentionTap != null 
                    ? () => onMentionTap!(comment.replyToCommentId!)
                    : null,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.subdirectory_arrow_right,
                      size: 14,
                      color: accentFgColor.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'В ответ на ${mentionResolver!(comment.replyToCommentId!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: accentFgColor.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Текст комментария с подсветкой @mentions
          _buildCommentText(theme, colorScheme, accentFgColor),
          
          const SizedBox(height: 8),
          
          // Кнопки действий
          Row(
            children: [
              // Кнопка "Ответить" (для корневых без ответов или для вложенных)
              if (onReply != null)
                _ActionButton(
                  icon: Icons.reply,
                  label: 'Ответить',
                  onPressed: onReply!,
                  color: accentFgColor,
                ),
              
              // Кнопка "Посмотреть ответы" (только для корневых с ответами)
              if (repliesCount > 0 && onToggleReplies != null && !isNested)
                _ActionButton(
                  icon: repliesExpanded 
                      ? Icons.expand_less 
                      : Icons.expand_more,
                  label: repliesExpanded 
                      ? 'Скрыть ответы' 
                      : 'Ответов ${repliesCount > 10 ? '10+' : repliesCount}',
                  onPressed: onToggleReplies!,
                  isLoading: repliesLoading,
                  color: accentFgColor,
                ),
              
              const Spacer(),
              
              // Кнопка "Редактировать" (только для своих комментариев)
              if (isCurrentUser && onEdit != null)
                _ActionButton(
                  icon: Icons.edit_outlined,
                  label: 'Изменить',
                  onPressed: onEdit!,
                  color: accentFgColor,
                ),
              
              // Кнопка "Удалить" (только для своих комментариев)
              if (isCurrentUser && onDelete != null)
                _ActionButton(
                  icon: Icons.delete_outline,
                  label: 'Удалить',
                  onPressed: onDelete!,
                  isDestructive: true,
                  color: colorScheme.error,
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'U';
  }

  /// Строит текст комментария с подсветкой @mentions
  Widget _buildCommentText(ThemeData theme, ColorScheme colorScheme, Color accentColor) {
    final text = comment.text;
    
    // Если нет mentionResolver — просто выводим текст
    if (mentionResolver == null) {
      return Text(text, style: theme.textTheme.bodyMedium);
    }

    // Ищем все @uid (uuid формат или простой id)
    final mentionRegex = RegExp(r'@([a-zA-Z0-9\-]+)');
    final matches = mentionRegex.allMatches(text);
    
    if (matches.isEmpty) {
      return Text(text, style: theme.textTheme.bodyMedium);
    }

    // Строим RichText с подсветкой
    final spans = <InlineSpan>[];
    int lastEnd = 0;

    for (final match in matches) {
      // Текст до @mention
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: theme.textTheme.bodyMedium,
        ));
      }

      // @mention — пробуем преобразовать uid в имя
      final commentId = match.group(1)!;
      final resolvedName = mentionResolver!(commentId);
      
      spans.add(TextSpan(
        text: '@$resolvedName',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: accentColor,
          fontWeight: FontWeight.w600,
        ),
        recognizer: onMentionTap != null
            ? (TapGestureRecognizer()..onTap = () => onMentionTap!(commentId))
            : null,
      ));

      lastEnd = match.end;
    }

    // Остаток текста после последнего @mention
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: theme.textTheme.bodyMedium,
      ));
    }

    return RichText(text: TextSpan(children: spans));
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isDestructive;
  final bool isLoading;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isDestructive = false,
    this.isLoading = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveColor = color ?? (isDestructive 
        ? colorScheme.error 
        : colorScheme.primary);

    return TextButton.icon(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: effectiveColor,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: isLoading 
          ? SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: effectiveColor,
              ),
            )
          : Icon(icon, size: 16),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}
