import 'package:flutter/material.dart';

/// Стили и константы для карточек задач (просмотр и редактирование)
class TaskStyles {
  TaskStyles._();

  // ─────────────────────────────────────────────────────────────────────────────
  // Цветовая схема (адаптивная для светлой/тёмной темы)
  // ─────────────────────────────────────────────────────────────────────────────

  /// Акцентный цвет (глиняный коричневый) — один для обеих тем
  static const Color accentColor = Color.fromARGB(255, 115, 66, 34);
  
  // Кешированные цвета для тёмной темы (Color.lerp тяжёлый)
  static final Color _accentBgDark = Color.lerp(accentColor, Colors.white, 0.6)!.withValues(alpha: 0.18);
  static final Color _accentFgDark = Color.lerp(accentColor, Colors.white, 0.45)!;
  static const Color _accentBgLight = Color(0xFFFCEBE0);

  /// Фон под акцент — адаптивный
  static Color accentBgColor(ColorScheme cs) =>
      cs.brightness == Brightness.light ? _accentBgLight : _accentBgDark;

  /// Контрастный акцентный цвет (для текста/иконок) в зависимости от темы
  static Color accentForegroundColor(ColorScheme cs) =>
      cs.brightness == Brightness.light ? accentColor : _accentFgDark;

  /// Основной цвет текста (заголовки) — из темы
  static Color textPrimary(ColorScheme cs) => cs.onSurface;

  /// Цвет текста (body) — из темы
  static Color textBody(ColorScheme cs) => cs.onSurfaceVariant;

  /// Приглушённый цвет текста — из темы
  static Color textMuted(ColorScheme cs) => cs.outline;

  /// Цвет разделителей — адаптивный
  static Color dividerColor(ColorScheme cs) => cs.outlineVariant;

  /// Цвет поверхности карточки — адаптивный
  static Color surfaceColor(ColorScheme cs) => cs.surfaceContainerLowest;

  /// Цвет для glass-эффекта overlay — адаптивный
  static Color glassColor(ColorScheme cs) => 
      cs.brightness == Brightness.light 
          ? Colors.white 
          : cs.surfaceContainerHighest;

  // ─────────────────────────────────────────────────────────────────────────────
  // Размеры панелей
  // ─────────────────────────────────────────────────────────────────────────────

  static const double sidebarMinWidth = 320;
  static const double sidebarMaxWidth = 360;
  static const double sidebarCreateMinWidth = 300;
  static const double sidebarCreateMaxWidth = 380;

  static const double mainContentMinHeight = 200;
  static const double mainContentNarrowMinHeight = 100;

  static const double wideLayoutBreakpoint = 900;

  // ─────────────────────────────────────────────────────────────────────────────
  // Отступы и скругления
  // ─────────────────────────────────────────────────────────────────────────────

  static const double cardBorderRadius = 24;  // Большой радиус для карточки
  static const double panelBorderRadius = 12;
  static const double panelPadding = 20;
  static const double sectionSpacing = 20;
  static const double itemSpacing = 8;
  static const double chipBorderRadius = 20;
  static const double chipHorizontalPadding = 12;
  static const double chipVerticalPadding = 6;
  static const double avatarSize = 28;

  // ─────────────────────────────────────────────────────────────────────────────
  // Кешированные BorderRadius (избегаем создания объектов в build)
  // ─────────────────────────────────────────────────────────────────────────────
  
  static const BorderRadius kBorderRadius4 = BorderRadius.all(Radius.circular(4));
  static const BorderRadius kBorderRadius8 = BorderRadius.all(Radius.circular(8));
  static const BorderRadius kBorderRadius12 = BorderRadius.all(Radius.circular(12));
  static const BorderRadius kBorderRadius16 = BorderRadius.all(Radius.circular(16));
  static const BorderRadius kBorderRadius20 = BorderRadius.all(Radius.circular(20));
  static const BorderRadius kBorderRadius24 = BorderRadius.all(Radius.circular(24));

  // ─────────────────────────────────────────────────────────────────────────────
  // Размеры иконок
  // ─────────────────────────────────────────────────────────────────────────────

  static const double statusIconSize = 18;
  static const double sectionIconSize = 14;
  static const double reminderIconSize = 16;
  static const double checkboxSize = 22;

  // ─────────────────────────────────────────────────────────────────────────────
  // Типографика
  // ─────────────────────────────────────────────────────────────────────────────

  static TextStyle sectionLabelStyle(ColorScheme cs) => TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: textMuted(cs),
    letterSpacing: 1,
  );

  static TextStyle breadcrumbsStyle(ColorScheme cs) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: textMuted(cs),
    letterSpacing: 0.5,
  );

  static TextStyle titleStyle(ColorScheme cs) => TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: textPrimary(cs),
    height: 1.2,
  );

  static TextStyle sidebarLabelStyle(ColorScheme cs) => TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: textMuted(cs),
  );

  static TextStyle sidebarValueStyle(ColorScheme cs) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textPrimary(cs),
  );

  // ─────────────────────────────────────────────────────────────────────────────
  // Иконки статусов
  // ─────────────────────────────────────────────────────────────────────────────

  static IconData getStatusIcon(String status) {
    switch (status) {
      case 'completed':
      case 'done':
        return Icons.check_circle_outline;
      case 'cancelled':
        return Icons.cancel_outlined;
      case 'in_progress':
      case 'ongoing':
        return Icons.play_circle_outline;
      case 'pending':
        return Icons.hourglass_empty;
      default:
        return Icons.help_outline;
    }
  }

  static Color getStatusColor(String status, ColorScheme colorScheme) {
    switch (status) {
      case 'completed':
      case 'done':
        return Colors.green.shade700;
      case 'cancelled':
        return colorScheme.error;
      case 'in_progress':
      case 'ongoing':
        return Colors.blue.shade700;
      case 'pending':
        return Colors.orange.shade700;
      default:
        return colorScheme.onSurface;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Иконки приоритетов
  // ─────────────────────────────────────────────────────────────────────────────

  static IconData getPriorityIcon(String priority) {
    switch (priority) {
      case 'critical':
        return Icons.priority_high;
      case 'high':
        return Icons.arrow_upward;
      case 'medium':
        return Icons.remove;
      case 'low':
        return Icons.arrow_downward;
      default:
        return Icons.remove;
    }
  }

  static Color getPriorityColor(String priority, ColorScheme colorScheme) {
    switch (priority) {
      case 'critical':
        return Colors.red.shade700;
      case 'high':
        return Colors.orange.shade700;
      case 'medium':
        return Colors.blue.shade600;
      case 'low':
        return Colors.grey.shade600;
      default:
        return colorScheme.onSurface;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Иконки секций
  // ─────────────────────────────────────────────────────────────────────────────

  static const IconData clientsIcon = Icons.business_outlined;
  static const IconData assigneeIcon = Icons.person_outline;
  static const IconData coAssigneesIcon = Icons.people_outline;
  static const IconData observersIcon = Icons.visibility_outlined;
  static const IconData creatorIcon = Icons.assignment_ind_outlined;
  static const IconData remindersIcon = Icons.notifications_outlined;
  static const IconData calendarIcon = Icons.calendar_today_outlined;
  static const IconData alarmIcon = Icons.alarm;
  static const IconData settingsIcon = Icons.tune;

  // ─────────────────────────────────────────────────────────────────────────────
  // Декорации панелей
  // ─────────────────────────────────────────────────────────────────────────────

  static BoxDecoration panelDecoration(ColorScheme cs) {
    final glass = glassColor(cs);
    return BoxDecoration(
      color: glass.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(panelBorderRadius),
      border: Border(
        left: BorderSide(color: glass.withValues(alpha: 0.8), width: 1),
      ),
    );
  }

  static BoxDecoration panelHeaderDecoration(ColorScheme colorScheme) {
    return const BoxDecoration();
  }

  static BoxDecoration chipDecoration(ColorScheme colorScheme) {
    return BoxDecoration(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(chipBorderRadius),
    );
  }

  /// Декорация главной карточки — glass panel эффект
  static BoxDecoration cardDecoration(ColorScheme cs) {
    final glass = glassColor(cs);
    final bool isLight = cs.brightness == Brightness.light;
    // В тёмной теме делаем контур немного светлее, чтобы по углам была
    // более чёткая "белая" грань.
    final borderColor = isLight
        ? glass.withValues(alpha: 0.8)
        : Colors.white.withValues(alpha: 0.14);
    return BoxDecoration(
      color: surfaceColor(cs).withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(cardBorderRadius),
      border: Border.all(
        color: borderColor,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: cs.shadow.withValues(alpha: 0.08),
          blurRadius: 32,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  /// Декорация статус-бейджа
  static BoxDecoration statusBadgeDecoration(Color statusColor) {
    return BoxDecoration(
      color: statusColor.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
    );
  }

  /// Декорация чекбокса
  static BoxDecoration checkboxDecoration(bool isChecked, ColorScheme cs) {
    if (isChecked) {
      return BoxDecoration(
        gradient: const LinearGradient(
          colors: [accentColor, Color(0xFFE06B22)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: const Color(0xFFB64900), width: 1),
      );
    }
    final glass = glassColor(cs);
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          glass.withValues(alpha: 0.96),
          cs.surfaceContainerHighest.withValues(alpha: 0.8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(5),
      border: Border.all(
        color: cs.outline.withValues(alpha: 0.5),
        width: 1,
      ),
    );
  }

  /// Декорация элемента чек-листа
  static BoxDecoration checkRowDecoration(bool isHovered, ColorScheme cs) {
    final baseColor = dividerColor(cs);
    final borderColor = cs.brightness == Brightness.light
        ? baseColor
        : baseColor.withValues(alpha: 0.2);

    return BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: borderColor,
          width: 1,
        ),
      ),
    );
  }

  /// Декорация карточки вложений
  static BoxDecoration attachmentsCardDecoration(ColorScheme cs) {
    final glass = glassColor(cs);
    return BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: glass.withValues(alpha: 0.9),
        width: 1,
      ),
      color: glass.withValues(alpha: 0.04),
    );
  }

  /// Декорация чипа вложения
  static BoxDecoration attachmentChipDecoration(ColorScheme cs) {
    final glass = glassColor(cs);
    return BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: cs.outline.withValues(alpha: 0.5),
        width: 1,
      ),
      color: glass.withValues(alpha: 0.95),
    );
  }

  /// Аватар с инициалами — требует ColorScheme
  static Widget buildAvatar(String name, ColorScheme cs, {double size = avatarSize}) {
    final initials = _getInitials(name);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: textPrimary(cs),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: cs.onInverseSurface,
          fontSize: size * 0.38,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  /// Цвет типа файла вложения
  static Color getFileTypeColor(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return const Color(0xFFD32F2F);
      case 'doc':
      case 'docx':
        return const Color(0xFF1976D2);
      case 'xls':
      case 'xlsx':
        return const Color(0xFF388E3C);
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'gif':
        return const Color(0xFF7B1FA2);
      case 'zip':
      case 'rar':
        return const Color(0xFFF57C00);
      case 'txt':
        return const Color(0xFF616161);
      default:
        return const Color(0xFF757575);
    }
  }
}
