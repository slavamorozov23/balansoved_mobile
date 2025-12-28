import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:balansoved_mobile/features/firms/domain/entities/firm_entity.dart';
import 'package:balansoved_mobile/features/firms/presentation/cubit/firms_cubit.dart';

class FirmSelector extends StatelessWidget {
  const FirmSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FirmsCubit, FirmsState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if (state.firms.isEmpty) {
          return const Text('Нет фирм');
        }

        final current = state.selectedFirm ?? state.firms.first;
        final label =
            current.name.isNotEmpty ? current.name : 'Фирма: ${current.id}';

        return IconButton(
          onPressed: () async {
            final selected = await _selectFirmBottomSheet(
              context,
              firms: state.firms,
              selectedFirmId: current.id,
            );
            if (!context.mounted) return;
            if (selected == null || selected.id == current.id) return;
            context.read<FirmsCubit>().selectFirm(selected);
          },
          icon: const Icon(Icons.apartment_outlined),
          tooltip: label,
        );
      },
    );
  }

  Future<FirmEntity?> _selectFirmBottomSheet(
    BuildContext context, {
    required List<FirmEntity> firms,
    required String selectedFirmId,
  }) async {
    return showModalBottomSheet<FirmEntity?>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return _FirmPickerSheet(
                firms: firms,
                selectedFirmId: selectedFirmId,
                scrollController: scrollController,
              );
            },
          ),
        );
      },
    );
  }
}

class _FirmPickerSheet extends StatefulWidget {
  final List<FirmEntity> firms;
  final String selectedFirmId;
  final ScrollController scrollController;

  const _FirmPickerSheet({
    required this.firms,
    required this.selectedFirmId,
    required this.scrollController,
  });

  @override
  State<_FirmPickerSheet> createState() => _FirmPickerSheetState();
}

class _FirmPickerSheetState extends State<_FirmPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _labelForFirm(FirmEntity firm) {
    return firm.name.isNotEmpty ? firm.name : firm.id;
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final filtered =
        query.isEmpty
            ? widget.firms
            : widget.firms.where((f) {
                final label = _labelForFirm(f).toLowerCase();
                return label.contains(query);
              }).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Поиск фирмы',
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              children: [
                for (final firm in filtered)
                  ListTile(
                    title: Text(_labelForFirm(firm)),
                    leading: Radio<String>(
                      value: firm.id,
                      groupValue: widget.selectedFirmId,
                      onChanged: (_) => Navigator.of(context).pop(firm),
                    ),
                    onTap: () => Navigator.of(context).pop(firm),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
