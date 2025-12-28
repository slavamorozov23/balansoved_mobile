import 'package:flutter/material.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/task_styles.dart';
import '../../domain/entities/comment_entity.dart';

/// Виджет для ввода комментария
class CommentInput extends StatefulWidget {
  final String? initialText;
  final String? replyingToName;
  
  /// Комментарий, на который отвечаем (для отображения "В ответ на...")
  final CommentEntity? replyToComment;
  
  /// Имя автора комментария, на который отвечаем
  final String? replyToAuthorName;
  
  final bool isEditing;
  final bool isSending;
  final VoidCallback? onCancel;
  
  /// Callback для отмены только replyToComment (оставить режим ответа в ветку)
  final VoidCallback? onCancelReplyTo;
  
  final Function(String text) onSubmit;

  const CommentInput({
    super.key,
    this.initialText,
    this.replyingToName,
    this.replyToComment,
    this.replyToAuthorName,
    this.isEditing = false,
    this.isSending = false,
    this.onCancel,
    this.onCancelReplyTo,
    required this.onSubmit,
  });

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  late final TextEditingController _controller;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText ?? '');
    
    // Автофокус при ответе или редактировании
    if (widget.replyingToName != null || widget.isEditing || widget.replyToComment != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void didUpdateWidget(CommentInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Обновляем текст при изменении initialText
    // Важно: проверяем именно значение, а не просто null != null
    if (widget.initialText != oldWidget.initialText) {
      final newText = widget.initialText ?? '';
      // Если новый текст не пустой — устанавливаем его
      // Если пустой — не трогаем (пользователь мог уже что-то написать)
      if (newText.isNotEmpty) {
        _controller.text = newText;
        // Ставим курсор в конец
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: newText.length),
        );
        _focusNode.requestFocus();
      }
    }
    
    // Фокус при начале ответа
    if (widget.replyingToName != null && oldWidget.replyingToName == null) {
      _focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    
    widget.onSubmit(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor = TaskStyles.accentColor;
    final accentFgColor = TaskStyles.accentForegroundColor(colorScheme);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Индикатор ответа/редактирования
          if (widget.replyingToName != null || widget.isEditing)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    widget.isEditing ? Icons.edit : Icons.reply,
                    size: 16,
                    color: accentFgColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.isEditing 
                          ? 'Редактирование комментария'
                          : 'Ответ для ${widget.replyingToName}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: accentFgColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (widget.onCancel != null)
                    IconButton(
                      onPressed: widget.onCancel,
                      icon: const Icon(Icons.close, size: 18),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 28,
                        minHeight: 28,
                      ),
                      color: accentFgColor.withValues(alpha: 0.7),
                    ),
                ],
              ),
            ),
          
          // Плашка "В ответ на..." с кнопкой отмены
          if (widget.replyToComment != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.format_quote,
                    size: 16,
                    color: accentFgColor.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'В ответ на ${widget.replyToAuthorName ?? "пользователя"}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: accentFgColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (widget.replyToComment!.text.isNotEmpty)
                          Text(
                            widget.replyToComment!.text.length > 50
                                ? '${widget.replyToComment!.text.substring(0, 50)}...'
                                : widget.replyToComment!.text,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (widget.onCancelReplyTo != null)
                    IconButton(
                      onPressed: widget.onCancelReplyTo,
                      icon: const Icon(Icons.close, size: 18),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 28,
                        minHeight: 28,
                      ),
                      tooltip: 'Отменить ответ',
                      color: accentFgColor.withValues(alpha: 0.7),
                    ),
                ],
              ),
            ),
          
          // Поле ввода
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  maxLines: null,
                  minLines: 1,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  enabled: !widget.isSending,
                  decoration: InputDecoration(
                    hintText: widget.replyingToName != null 
                        ? 'Написать ответ...'
                        : 'Написать комментарий...',
                    hintStyle: TextStyle(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: colorScheme.outlineVariant,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: colorScheme.outlineVariant,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: accentColor,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    filled: false,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              
              // Кнопка отправки
              IconButton(
                onPressed: widget.isSending ? null : _handleSubmit,
                icon: widget.isSending
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: accentFgColor,
                        ),
                      )
                    : Icon(Icons.send, color: accentFgColor),
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
