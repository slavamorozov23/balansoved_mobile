import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Cached layout constants.
const _kCellPadding = EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0);
const _kHeaderPadding = EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0);
const _kBorderRadius8 = BorderRadius.all(Radius.circular(8));
const _kScrollbarHeight = 14.0;

/// Таблица с изменяемой шириной колонок и сохранением размеров в prefs.
class ResizableDataTable extends StatefulWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final bool showCheckboxColumn;
  final int? sortColumnIndex;
  final bool sortAscending;
  final String prefsKey;
  final List<double>? initialColumnWidths;
  final double minColumnWidth;
  final double defaultColumnWidth;
  final double borderWidth;
  final bool showFloatingHorizontalScrollbar;

  const ResizableDataTable({
    super.key,
    required this.columns,
    required this.rows,
    required this.prefsKey,
    this.showCheckboxColumn = false,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.initialColumnWidths,
    this.minColumnWidth = 80.0,
    this.defaultColumnWidth = 150.0,
    this.borderWidth = 1.0,
    this.showFloatingHorizontalScrollbar = true,
  });

  @override
  State<ResizableDataTable> createState() => _ResizableDataTableState();
}

class _ResizableDataTableState extends State<ResizableDataTable> {
  late List<double> _columnWidths;
  bool _isInitialized = false;
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  int? _resizingColumnIndex;

  @override
  void initState() {
    super.initState();
    _initializeColumnWidths();
  }

  Future<void> _initializeColumnWidths() async {
    await _loadColumnWidths();
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  Future<void> _loadColumnWidths() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(widget.prefsKey);

      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> widths = jsonDecode(jsonString);
        _columnWidths = widths.cast<double>();

        if (_columnWidths.length != widget.columns.length) {
          _resetToDefaults();
        }
      } else {
        _resetToDefaults();
      }
    } catch (_) {
      _resetToDefaults();
    }
  }

  void _resetToDefaults() {
    if (widget.initialColumnWidths != null &&
        widget.initialColumnWidths!.length == widget.columns.length) {
      _columnWidths = List.from(widget.initialColumnWidths!);
    } else {
      _columnWidths = List.filled(
        widget.columns.length,
        widget.defaultColumnWidth,
      );
    }
  }

  Future<void> _saveColumnWidths() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(widget.prefsKey, jsonEncode(_columnWidths));
    } catch (_) {
      // Ignore persistence errors.
    }
  }

  void _updateColumnWidth(int index, double delta) {
    setState(() {
      _columnWidths[index] = (_columnWidths[index] + delta).clamp(
        widget.minColumnWidth,
        double.infinity,
      );
    });
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  Widget _buildHeader(List<double> effectiveColumnWidths) {
    final theme = Theme.of(context);
    final headerBgColor =
        theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);
    final dividerColor = theme.dividerColor;

    return Container(
      decoration: BoxDecoration(
        color: headerBgColor,
        border: Border(
          bottom: BorderSide(
            color: dividerColor,
            width: widget.borderWidth,
          ),
        ),
      ),
      child: Row(
        children: List.generate(widget.columns.length * 2 - 1, (index) {
          if (index.isOdd) {
            final columnIndex = index ~/ 2;
            return GestureDetector(
              onPanStart: (_) {
                _resizingColumnIndex = columnIndex;
              },
              onPanUpdate: (details) {
                _updateColumnWidth(columnIndex, details.delta.dx);
              },
              onPanEnd: (_) {
                _resizingColumnIndex = null;
                _saveColumnWidths();
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeColumn,
                child: Container(
                  width: 4,
                  height: 48,
                  color: Colors.transparent,
                  child: Center(
                    child: Container(
                      width: widget.borderWidth,
                      color: _resizingColumnIndex == columnIndex
                          ? theme.colorScheme.primary
                          : theme.dividerColor,
                    ),
                  ),
                ),
              ),
            );
          }

          final columnIndex = index ~/ 2;
          final column = widget.columns[columnIndex];
          return Container(
            width: effectiveColumnWidths[columnIndex],
            height: 48,
            padding: _kHeaderPadding,
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: column.onSort != null
                  ? () {
                      final newAscending =
                          widget.sortColumnIndex == columnIndex
                              ? !widget.sortAscending
                              : true;
                      column.onSort!(columnIndex, newAscending);
                    }
                  : null,
              child: Row(
                children: [
                  Expanded(child: column.label),
                  if (widget.sortColumnIndex == columnIndex)
                    Icon(
                      widget.sortAscending
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      size: 16,
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRow(
    DataRow row,
    int rowIndex,
    List<double> effectiveColumnWidths,
  ) {
    final theme = Theme.of(context);
    final isEven = rowIndex.isEven;
    final rowBgColor = isEven
        ? theme.colorScheme.surface
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.05);
    final borderColor = theme.dividerColor.withValues(alpha: 0.2);

    return Container(
      decoration: BoxDecoration(
        color: rowBgColor,
        border: Border(
          bottom: BorderSide(
            color: borderColor,
            width: widget.borderWidth,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: row.onSelectChanged != null
              ? () => row.onSelectChanged!(true)
              : null,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(widget.columns.length * 2 - 1, (index) {
              if (index.isOdd) {
                return const SizedBox(width: 4);
              }
              final columnIndex = index ~/ 2;
              return Container(
                width: effectiveColumnWidths[columnIndex],
                constraints: const BoxConstraints(minHeight: 44),
                padding: _kCellPadding,
                alignment: Alignment.centerLeft,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: row.cells[columnIndex].child,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedHeight = constraints.maxHeight.isFinite;

        const separatorWidth = 4.0;
        final separatorCount = widget.columns.length - 1;

        final baseContentWidth = _columnWidths.isNotEmpty
            ? _columnWidths.reduce((a, b) => a + b)
            : 0.0;
        final baseTotalWidth = baseContentWidth + separatorCount * separatorWidth;

        double availableWidth = constraints.maxWidth;
        if (!availableWidth.isFinite) {
          availableWidth = baseTotalWidth;
        }

        final borderOffset = widget.borderWidth * 2;
        final availableForContent = availableWidth - borderOffset;
        final needsHorizontalScroll = baseTotalWidth > availableForContent;

        final shouldExpandHorizontally =
            availableForContent.isFinite &&
            availableForContent > 0 &&
            availableForContent > baseTotalWidth;

        final double targetContentWidth = shouldExpandHorizontally
            ? (availableForContent - separatorCount * separatorWidth)
                .clamp(0.0, double.infinity)
            : baseContentWidth;

        final double scale = (baseContentWidth > 0 && targetContentWidth > 0)
            ? (targetContentWidth / baseContentWidth)
            : 1.0;

        final effectiveColumnWidths = _columnWidths
            .map(
              (w) => (w * scale).clamp(widget.minColumnWidth, double.infinity),
            )
            .toList();

        final effectiveTotalWidth =
            (effectiveColumnWidths.isNotEmpty
                    ? effectiveColumnWidths.reduce((a, b) => a + b)
                    : 0.0) +
                separatorCount * separatorWidth;

        Widget buildTableBody() {
          final bottomPadding =
              needsHorizontalScroll && widget.showFloatingHorizontalScrollbar
                  ? _kScrollbarHeight + 4.0
                  : 0.0;

          if (hasBoundedHeight) {
            return Column(
              children: [
                _buildHeader(effectiveColumnWidths),
                Expanded(
                  child: ScrollbarTheme(
                    data: ScrollbarThemeData(
                      thumbColor: WidgetStateProperty.all(
                        Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.4),
                      ),
                      trackColor: WidgetStateProperty.all(
                        Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.1),
                      ),
                      radius: const Radius.circular(4),
                      thickness: WidgetStateProperty.all(8.0),
                    ),
                    child: Scrollbar(
                      controller: _verticalScrollController,
                      thumbVisibility: true,
                      trackVisibility: true,
                      child: ListView.builder(
                        controller: _verticalScrollController,
                        padding: EdgeInsets.only(
                          bottom: bottomPadding,
                        ),
                        itemCount: widget.rows.length,
                        itemBuilder: (context, index) {
                          return _buildRow(
                            widget.rows[index],
                            index,
                            effectiveColumnWidths,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(effectiveColumnWidths),
              ...widget.rows.asMap().entries.map((entry) {
                return _buildRow(entry.value, entry.key, effectiveColumnWidths);
              }),
              if (bottomPadding > 0) SizedBox(height: bottomPadding),
            ],
          );
        }

        final tableContent = hasBoundedHeight
            ? SizedBox(
                width: effectiveTotalWidth,
                height: constraints.maxHeight,
                child: buildTableBody(),
              )
            : SizedBox(
                width: effectiveTotalWidth,
                child: buildTableBody(),
              );

        final theme = Theme.of(context);

        if (!needsHorizontalScroll) {
          return RepaintBoundary(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: theme.dividerColor),
                borderRadius: _kBorderRadius8,
              ),
              clipBehavior: Clip.antiAlias,
              child: tableContent,
            ),
          );
        }

        final horizontalScrollView = SingleChildScrollView(
          controller: _horizontalScrollController,
          scrollDirection: Axis.horizontal,
          child: tableContent,
        );

        final horizontalContent =
            widget.showFloatingHorizontalScrollbar
                ? ScrollbarTheme(
                    data: ScrollbarThemeData(
                      thumbColor: WidgetStateProperty.all(
                        theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                      trackColor: WidgetStateProperty.all(
                        theme.colorScheme.onSurface.withValues(alpha: 0.1),
                      ),
                      radius: const Radius.circular(4),
                      thickness: WidgetStateProperty.all(8.0),
                    ),
                    child: Scrollbar(
                      controller: _horizontalScrollController,
                      thumbVisibility: true,
                      trackVisibility: true,
                      scrollbarOrientation: ScrollbarOrientation.bottom,
                      child: horizontalScrollView,
                    ),
                  )
                : horizontalScrollView;

        return RepaintBoundary(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: theme.dividerColor),
              borderRadius: _kBorderRadius8,
            ),
            clipBehavior: Clip.antiAlias,
            child: horizontalContent,
          ),
        );
      },
    );
  }
}
