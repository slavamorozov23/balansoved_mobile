import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:balansoved_mobile/injection_container.dart';
import 'package:balansoved_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:balansoved_mobile/features/employees/presentation/cubit/employees_cubit.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/task_styles.dart';
import '../../domain/entities/comment_entity.dart';
import '../cubit/comments_cubit.dart';
import '../cubit/comments_state.dart';
import 'comment_item.dart';
import 'comment_input.dart';

/// Виджет секции комментариев для задачи
/// 
/// Использование:
/// ```dart
/// CommentsSection(
///   firmId: firmId,
///   taskId: taskId,
/// )
/// ```
class CommentsSection extends StatefulWidget {
  /// ID фирмы
  final String firmId;
  
  /// ID задачи
  final String taskId;
  
  const CommentsSection({
    super.key,
    required this.firmId,
    required this.taskId,
  });

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> with SingleTickerProviderStateMixin {
  late final CommentsCubit _commentsCubit;
  String? _currentUserId;
  
  /// Ключи для скролла к комментариям по ID
  final Map<String, GlobalKey> _commentKeys = {};
  
  /// ID комментария, который сейчас анимируется (подскакивает)
  String? _highlightedCommentId;
  
  /// Контроллер анимации подскакивания
  late final AnimationController _bounceController;
  late final Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _commentsCubit = sl<CommentsCubit>();
    
    // Инициализируем анимацию подскакивания (горизонтальное смещение)
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 12.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 12.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -6.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 4.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 4.0, end: -2.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -2.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeOut,
    ));
    
    // Получаем ID текущего пользователя
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      _currentUserId = authState.user.id;
    }
    
    _ensureEmployeesLoaded();
    // Загружаем комментарии сразу
    _loadComments();
  }

  @override
  void didUpdateWidget(CommentsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.taskId != oldWidget.taskId || widget.firmId != oldWidget.firmId) {
      _ensureEmployeesLoaded();
      _loadComments();
    }
  }

  @override
  void dispose() {
    _commentsCubit.reset();
    _bounceController.dispose();
    super.dispose();
  }

  void _loadComments() {
    _commentsCubit.loadComments(
      firmId: widget.firmId,
      taskId: widget.taskId,
    );
  }

  void _ensureEmployeesLoaded() {
    final employeesState = context.read<EmployeesCubit>().state;
    if (employeesState.isLoading || employeesState.employees.isNotEmpty) {
      return;
    }
    context.read<EmployeesCubit>().fetchEmployees(widget.firmId);
  }

  /// Получить или создать GlobalKey для комментария
  GlobalKey _getKeyForComment(String commentId) {
    return _commentKeys.putIfAbsent(commentId, () => GlobalKey());
  }

  /// Скролл к комментарию и анимация подскакивания
  void _scrollToComment(String commentId) {
    final key = _commentKeys[commentId];
    if (key == null || key.currentContext == null) return;

    // Скроллим к комментарию
    Scrollable.ensureVisible(
      key.currentContext!,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      alignment: 0.3, // Показать комментарий ближе к верху
    ).then((_) {
      // После скролла — запускаем анимацию подскакивания
      setState(() {
        _highlightedCommentId = commentId;
      });
      _bounceController.forward(from: 0).then((_) {
        if (mounted) {
          setState(() {
            _highlightedCommentId = null;
          });
        }
      });
    });
  }

  String _getAuthorName(String authorId, EmployeesState employeesState) {
    final employee = employeesState.employees.cast<dynamic>().firstWhere(
      (e) => e.id == authorId,
      orElse: () => null,
    );
    if (employee == null) {
      return 'Пользователь';
    }
    return employee.userName ?? employee.email ?? 'Пользователь';
  }

  void _handleSubmit(String text, {String? parentCommentId, String? replyToCommentId}) {
    if (parentCommentId != null) {
      _commentsCubit.createComment(
        text: text,
        parentCommentId: parentCommentId,
        replyToCommentId: replyToCommentId,
      );
    } else {
      _commentsCubit.createComment(text: text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentFgColor = TaskStyles.accentForegroundColor(colorScheme);
    final employeesState = context.watch<EmployeesCubit>().state;

    return BlocProvider.value(
      value: _commentsCubit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок секции
          Row(
            children: [
              Icon(
                Icons.comment_outlined,
                color: accentFgColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Комментарии',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: accentFgColor,
                ),
              ),
              const Spacer(),
              BlocBuilder<CommentsCubit, CommentsState>(
                bloc: _commentsCubit,
                builder: (context, state) {
                  if (state is CommentsLoaded) {
                    return Text(
                      '${state.comments.length}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ).padding(horizontal: 16, vertical: 12),
          
          // Разделитель
          Divider(
            height: 1,
            thickness: 1,
            color: colorScheme.outlineVariant,
          ),
          
          // Контент секции
          BlocBuilder<CommentsCubit, CommentsState>(
            bloc: _commentsCubit,
            builder: (context, state) {
              if (state is CommentsLoading) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              
              if (state is CommentsError) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: colorScheme.error,
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          style: TextStyle(color: colorScheme.error),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadComments,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Повторить'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              if (state is CommentsLoaded) {
                return _buildCommentsContent(state, employeesState);
              }
              
              return const SizedBox.shrink();
            },
          ),
        ],
      ).padding(top: 24),
    );
  }

  Widget _buildCommentsContent(
    CommentsLoaded state,
    EmployeesState employeesState,
  ) {
    final isSending = state is CommentsSending;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      children: [
        // Поле ввода СВЕРХУ (только для новых корневых комментариев)
        if (state.replyingToId == null && state.editingCommentId == null)
          CommentInput(
            isSending: isSending,
            onSubmit: (text) => _handleSubmit(text),
          ),
        
        // Список комментариев
        if (state.comments.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 48,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Комментариев пока нет',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Будьте первым!',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                for (final comment in state.comments) ...[
                  _buildCommentWithReplies(comment, state, employeesState),
                ],
                // Кнопка "Загрузить ещё"
                if (state.hasMoreComments)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TextButton.icon(
                      onPressed: () => _commentsCubit.loadMoreComments(),
                      icon: const Icon(Icons.expand_more),
                      label: const Text('Загрузить ещё'),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCommentWithReplies(
    CommentEntity comment,
    CommentsLoaded state,
    EmployeesState employeesState,
  ) {
    final replies = state.replies[comment.id] ?? [];
    final totalReplies = state.repliesTotal[comment.id] ?? 0;
    final repliesExpanded = state.expandedReplies.contains(comment.id);
    final isLoadingReplies = state is CommentsLoadingReplies && 
        state.loadingParentId == comment.id;
    final isReplyingToThis = state.replyingToId == comment.id;
    final isSending = state is CommentsSending;
    final hasMoreReplies = state.repliesHasMore[comment.id] ?? false;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Оборачиваем в AnimatedBuilder для анимации подскакивания
        AnimatedBuilder(
          animation: _bounceAnimation,
          builder: (context, child) {
            final isHighlighted = _highlightedCommentId == comment.id;
            return Transform.translate(
              offset: Offset(isHighlighted ? _bounceAnimation.value : 0, 0),
              child: child,
            );
          },
          child: CommentItem(
            key: _getKeyForComment(comment.id),
            comment: comment,
            authorName: _getAuthorNameSafe(comment.authorId, employeesState),
            isCurrentUser: comment.authorId == _currentUserId,
            isEditing: state.editingCommentId == comment.id,
            repliesCount: totalReplies,
            repliesExpanded: repliesExpanded,
            repliesLoading: isLoadingReplies,
            mentionResolver: (commentId) =>
                _resolveMention(commentId, state, employeesState),
            onMentionTap: _scrollToComment,
            // Если ответов нет — показываем "Ответить", иначе "Показать ответы"
            onReply: totalReplies == 0 
                ? () => _commentsCubit.toggleReplies(comment.id)
                : null,
            // TODO: временно отключены
            // onEdit: comment.authorId == _currentUserId 
            //     ? () => _commentsCubit.startEditing(comment.id)
            //     : null,
            // onDelete: comment.authorId == _currentUserId 
            //     ? () => _showDeleteConfirmation(comment)
            //     : null,
            onToggleReplies: totalReplies > 0 
                ? () => _commentsCubit.toggleReplies(comment.id)
                : null,
          ),
        ),
        
        // Секция ответов (если развёрнута)
        if (repliesExpanded)
          Container(
            margin: const EdgeInsets.only(left: 16, bottom: 8),
            padding: const EdgeInsets.only(left: 12),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Поле ввода для ответа СВЕРХУ ответов
                CommentInput(
                  key: ValueKey('reply_input_${comment.id}_${state.replyToComment?.id ?? ''}'),
                  replyingToName: _getAuthorNameSafe(
                    comment.authorId,
                    employeesState,
                  ),
                  replyToComment: state.replyToComment,
                  replyToAuthorName: state.replyToComment != null 
                      ? _getAuthorNameSafe(
                        state.replyToComment!.authorId,
                        employeesState,
                      )
                      : null,
                  isSending: isSending && isReplyingToThis,
                  onCancel: () => _commentsCubit.toggleReplies(comment.id),
                  onCancelReplyTo: () => _commentsCubit.cancelReplyToComment(),
                  onSubmit: (text) {
                    _handleSubmit(
                      text, 
                      parentCommentId: comment.id,
                      replyToCommentId: state.replyToComment?.id,
                    );
                  },
                ),
                
                const SizedBox(height: 8),
                
                // Список существующих ответов
                for (final reply in replies)
                  AnimatedBuilder(
                    animation: _bounceAnimation,
                    builder: (context, child) {
                      final isHighlighted = _highlightedCommentId == reply.id;
                      return Transform.translate(
                        offset: Offset(isHighlighted ? _bounceAnimation.value : 0, 0),
                        child: child,
                      );
                    },
                    child: CommentItem(
                      key: _getKeyForComment(reply.id),
                      comment: reply,
                      authorName: _getAuthorNameSafe(
                        reply.authorId,
                        employeesState,
                      ),
                      isCurrentUser: reply.authorId == _currentUserId,
                      isEditing: state.editingCommentId == reply.id,
                      isNested: true,
                      // Функция для преобразования @commentId -> имя автора
                      mentionResolver: (commentId) =>
                          _resolveMention(commentId, state, employeesState),
                      onMentionTap: _scrollToComment,
                      // Кнопка "Ответить" у каждого ответа — устанавливает replyToComment
                      onReply: () {
                        _commentsCubit.startReply(
                          comment.id, // Отвечаем в родительский
                          replyToComment: reply,
                        );
                      },
                      // TODO: временно отключены
                      // onEdit: reply.authorId == _currentUserId 
                      //     ? () => _commentsCubit.startEditing(reply.id)
                      //     : null,
                      // onDelete: reply.authorId == _currentUserId 
                      //     ? () => _showDeleteConfirmation(reply)
                      //     : null,
                    ),
                  ),
                
                // Кнопка "Загрузить ещё ответы"
                if (hasMoreReplies)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TextButton.icon(
                      onPressed: () => _commentsCubit.loadMoreReplies(comment.id),
                      icon: const Icon(Icons.expand_more, size: 18),
                      label: const Text('Ещё ответы'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  String _getAuthorNameSafe(
    String authorId,
    EmployeesState employeesState,
  ) {
    try {
      return _getAuthorName(authorId, employeesState);
    } catch (_) {
      return 'Пользователь';
    }
  }

  /// Преобразует @commentId в имя автора комментария для отображения в тексте
  String _resolveMention(
    String commentId,
    CommentsLoaded state,
    EmployeesState employeesState,
  ) {
    final comment = _findComment(commentId, state);
    if (comment == null) {
      return _getAuthorNameSafe(commentId, employeesState);
    }
    return _getAuthorNameSafe(comment.authorId, employeesState);
  }

  CommentEntity? _findComment(String commentId, CommentsLoaded state) {
    // Ищем в корневых комментариях
    for (final comment in state.comments) {
      if (comment.id == commentId) return comment;
    }
    // Ищем в ответах
    for (final replies in state.replies.values) {
      for (final reply in replies) {
        if (reply.id == commentId) return reply;
      }
    }
    return null;
  }

  // TODO: временно отключено
  // void _showDeleteConfirmation(CommentEntity comment) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Удалить комментарий?'),
  //       content: const Text('Это действие нельзя отменить.'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Отмена'),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //             _commentsCubit.deleteComment(
  //               commentId: comment.id,
  //               createdAt: comment.createdAt,
  //             );
  //           },
  //           style: TextButton.styleFrom(
  //             foregroundColor: Theme.of(context).colorScheme.error,
  //           ),
  //           child: const Text('Удалить'),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
