import 'package:equatable/equatable.dart';

class TaskEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final List<String> clientIds;
  final List<String> assigneeIds;
  final List<String> observerIds;
  final List<String> creatorIds;
  final String status;
  final String priority;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final List<Map<String, dynamic>> attachments;
  final List<Map<String, dynamic>> checklist;
  final List<Map<String, dynamic>> reminders;
  final Map<String, dynamic>? recurrence;
  final Map<String, dynamic> options;
  final String? holidayTransferRule;
  final String? originTaskId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? relativeDates;

  const TaskEntity({
    required this.id,
    required this.title,
    this.description,
    required this.clientIds,
    required this.assigneeIds,
    required this.observerIds,
    required this.creatorIds,
    required this.status,
    required this.priority,
    this.dueDate,
    this.completedAt,
    required this.attachments,
    required this.checklist,
    required this.reminders,
    this.recurrence,
    required this.options,
    this.holidayTransferRule,
    this.originTaskId,
    required this.createdAt,
    required this.updatedAt,
    this.relativeDates,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    clientIds,
    assigneeIds,
    observerIds,
    creatorIds,
    status,
    priority,
    dueDate,
    completedAt,
    attachments,
    checklist,
    reminders,
    recurrence,
    options,
    holidayTransferRule,
    originTaskId,
    createdAt,
    updatedAt,
    relativeDates,
  ];

  TaskEntity copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? clientIds,
    List<String>? assigneeIds,
    List<String>? observerIds,
    List<String>? creatorIds,
    String? status,
    String? priority,
    DateTime? dueDate,
    DateTime? completedAt,
    List<Map<String, dynamic>>? attachments,
    List<Map<String, dynamic>>? checklist,
    List<Map<String, dynamic>>? reminders,
    Map<String, dynamic>? recurrence,
    Map<String, dynamic>? options,
    String? holidayTransferRule,
    String? originTaskId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? relativeDates,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      clientIds: clientIds ?? this.clientIds,
      assigneeIds: assigneeIds ?? this.assigneeIds,
      observerIds: observerIds ?? this.observerIds,
      creatorIds: creatorIds ?? this.creatorIds,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      attachments: attachments ?? this.attachments,
      checklist: checklist ?? this.checklist,
      reminders: reminders ?? this.reminders,
      recurrence: recurrence ?? this.recurrence,
      options: options ?? this.options,
      holidayTransferRule: holidayTransferRule ?? this.holidayTransferRule,
      originTaskId: originTaskId ?? this.originTaskId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      relativeDates: relativeDates ?? this.relativeDates,
    );
  }
}

/// Тип задач для фильтрации
enum TaskViewType {
  timeless, // Бессрочные задачи (due_date IS NULL)
  dated, // Задачи с крайним сроком (due_date IS NOT NULL)
  all, // Все задачи (сортировка по created_at)
  timeline, // Timeline режим (курсорная пагинация по created_at)
}

class TaskParticipantFilter extends Equatable {
  final String employeeId;
  final List<String> roles;

  const TaskParticipantFilter({required this.employeeId, this.roles = const []});

  Map<String, dynamic> toApiJson() {
    return {
      'employee_id': employeeId,
      if (roles.isNotEmpty) 'roles': roles,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'employeeId': employeeId,
      'roles': roles,
    };
  }

  @override
  List<Object?> get props => [employeeId, roles];
}

/// Параметры запроса задач
const _taskParamsUnset = Object();

class TaskRequestParams extends Equatable {
  final TaskViewType viewType;
  final int? page; // Для бессрочных задач (пагинация)
  final int? month; // Для срочных задач (1-12)
  final int? year; // Для срочных задач
  final String? clientId;
  final String? status;
  final List<TaskParticipantFilter> participants;
  final String participantsMode; // 'any' | 'all'
  final bool onlyMy;
  final bool filterByMonth;
  final bool force;
  // Timeline параметры
  final String? direction; // 'initial' | 'older' | 'newer'
  final String? cursorAt; // ISO timestamp
  final String? roleFilter; // 'any' | 'assignee' | 'creator' | 'observer'

  const TaskRequestParams({
    required this.viewType,
    this.page,
    this.month,
    this.year,
    this.clientId,
    this.status,
    this.participants = const [],
    this.participantsMode = 'any',
    this.onlyMy = true,
    this.filterByMonth = false,
    this.force = false,
    this.direction,
    this.cursorAt,
    this.roleFilter,
  });

  /// Создать параметры для бессрочных задач
  factory TaskRequestParams.timeless({
    int page = 0,
    String? clientId,
    String? status,
    List<TaskParticipantFilter> participants = const [],
    String participantsMode = 'any',
    bool onlyMy = true,
    bool filterByMonth = false,
    bool force = false,
  }) {
    return TaskRequestParams(
      viewType: TaskViewType.timeless,
      page: page,
      clientId: clientId,
      status: status,
      participants: participants,
      participantsMode: participantsMode,
      onlyMy: onlyMy,
      filterByMonth: filterByMonth,
      force: force,
    );
  }

  /// Создать параметры для задач с крайним сроком
  factory TaskRequestParams.dated({
    required int month,
    required int year,
    String? clientId,
    String? status,
    List<TaskParticipantFilter> participants = const [],
    String participantsMode = 'any',
    bool onlyMy = true,
    bool filterByMonth = false,
    bool force = false,
  }) {
    return TaskRequestParams(
      viewType: TaskViewType.dated,
      month: month,
      year: year,
      clientId: clientId,
      status: status,
      participants: participants,
      participantsMode: participantsMode,
      onlyMy: onlyMy,
      filterByMonth: filterByMonth,
      force: force,
    );
  }

  /// Создать параметры для текущего месяца
  factory TaskRequestParams.currentMonth({
    String? clientId,
    String? status,
    List<TaskParticipantFilter> participants = const [],
    String participantsMode = 'any',
    bool onlyMy = true,
    bool filterByMonth = false,
    bool force = false,
  }) {
    final now = DateTime.now();
    return TaskRequestParams(
      viewType: TaskViewType.dated,
      month: now.month,
      year: now.year,
      clientId: clientId,
      status: status,
      participants: participants,
      participantsMode: participantsMode,
      onlyMy: onlyMy,
      filterByMonth: filterByMonth,
      force: force,
    );
  }

  /// Создать параметры для общей таблицы (все задачи, сортировка по created_at)
  factory TaskRequestParams.all({
    int page = 0,
    String? clientId,
    String? status,
    List<TaskParticipantFilter> participants = const [],
    String participantsMode = 'any',
    bool onlyMy = true,
    bool force = false,
  }) {
    return TaskRequestParams(
      viewType: TaskViewType.all,
      page: page,
      clientId: clientId,
      status: status,
      participants: participants,
      participantsMode: participantsMode,
      onlyMy: onlyMy,
      filterByMonth: false,
      force: force,
    );
  }

  /// Создать параметры для timeline режима (курсорная пагинация)
  factory TaskRequestParams.timeline({
    String direction = 'initial',
    String? cursorAt,
    String? clientId,
    String? status,
    List<TaskParticipantFilter> participants = const [],
    String participantsMode = 'any',
    String roleFilter = 'any',
    bool force = false,
  }) {
    return TaskRequestParams(
      viewType: TaskViewType.timeline,
      direction: direction,
      cursorAt: cursorAt,
      clientId: clientId,
      status: status,
      participants: participants,
      participantsMode: participantsMode,
      roleFilter: roleFilter,
      force: force,
    );
  }

  TaskRequestParams copyWith({
    TaskViewType? viewType,
    int? page,
    int? month,
    int? year,
    Object? clientId = _taskParamsUnset,
    Object? status = _taskParamsUnset,
    Object? participants = _taskParamsUnset,
    Object? participantsMode = _taskParamsUnset,
    bool? onlyMy,
    bool? filterByMonth,
    bool? force,
    String? direction,
    Object? cursorAt = _taskParamsUnset,
    Object? roleFilter = _taskParamsUnset,
  }) {
    final newClientId =
        identical(clientId, _taskParamsUnset)
            ? this.clientId
            : clientId as String?;
    final newStatus =
        identical(status, _taskParamsUnset) ? this.status : status as String?;
    final newParticipants =
        identical(participants, _taskParamsUnset)
            ? this.participants
            : participants as List<TaskParticipantFilter>;
    final newParticipantsMode =
        identical(participantsMode, _taskParamsUnset)
            ? this.participantsMode
            : participantsMode as String;
    final newCursorAt =
        identical(cursorAt, _taskParamsUnset)
            ? this.cursorAt
            : cursorAt as String?;
    final newRoleFilter =
        identical(roleFilter, _taskParamsUnset)
            ? this.roleFilter
            : roleFilter as String?;
    return TaskRequestParams(
      viewType: viewType ?? this.viewType,
      page: page ?? this.page,
      month: month ?? this.month,
      year: year ?? this.year,
      clientId: newClientId,
      status: newStatus,
      participants: newParticipants,
      participantsMode: newParticipantsMode,
      onlyMy: onlyMy ?? this.onlyMy,
      filterByMonth: filterByMonth ?? this.filterByMonth,
      force: force ?? this.force,
      direction: direction ?? this.direction,
      cursorAt: newCursorAt,
      roleFilter: newRoleFilter,
    );
  }

  String get displayText {
    switch (viewType) {
      case TaskViewType.timeless:
        return 'Бессрочные задачи${page != null ? ' (стр. ${page! + 1})' : ''}';
      case TaskViewType.dated:
        if (month != null && year != null) {
          return '${_getMonthName(month!)} $year';
        }
        return 'Задачи с крайним сроком';
      case TaskViewType.all:
        return 'Общая таблица${page != null ? ' (стр. ${page! + 1})' : ''}';
      case TaskViewType.timeline:
        return 'Лента задач';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Январь',
      'Февраль',
      'Март',
      'Апрель',
      'Май',
      'Июнь',
      'Июль',
      'Август',
      'Сентябрь',
      'Октябрь',
      'Ноябрь',
      'Декабрь',
    ];
    return months[month - 1];
  }

  @override
  List<Object?> get props => [
    viewType,
    page,
    month,
    year,
    clientId,
    status,
    participants,
    participantsMode,
    onlyMy,
    filterByMonth,
    direction,
    cursorAt,
    roleFilter,
    // force исключен из сравнения, чтобы избежать бесконечных запросов
  ];

  /// Сериализация в JSON
  Map<String, dynamic> toJson() {
    return {
      'viewType': viewType.name,
      if (page != null) 'page': page,
      if (month != null) 'month': month,
      if (year != null) 'year': year,
      if (clientId != null) 'clientId': clientId,
      if (status != null) 'status': status,
      if (participants.isNotEmpty)
        'participants': participants.map((p) => p.toJson()).toList(),
      'participantsMode': participantsMode,
      'onlyMy': onlyMy,
      'filterByMonth': filterByMonth,
      if (direction != null) 'direction': direction,
      if (cursorAt != null) 'cursorAt': cursorAt,
      if (roleFilter != null) 'roleFilter': roleFilter,
    };
  }
}

/// Метаданные пагинации для бессрочных задач
class TaskPaginationMeta extends Equatable {
  final int totalTasks;
  final int currentPage;
  final int pageSize;
  final int totalPages;

  const TaskPaginationMeta({
    required this.totalTasks,
    required this.currentPage,
    required this.pageSize,
    required this.totalPages,
  });

  bool get hasNextPage => currentPage < totalPages - 1;
  bool get hasPreviousPage => currentPage > 0;

  factory TaskPaginationMeta.fromJson(Map<String, dynamic> json) {
    return TaskPaginationMeta(
      totalTasks: json['total_tasks'] ?? 0,
      currentPage: json['current_page'] ?? 0,
      pageSize: json['page_size'] ?? 100,
      totalPages: json['total_pages'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [totalTasks, currentPage, pageSize, totalPages];
}
