import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/sales_provider.dart';

class SaleFilterDialog extends ConsumerStatefulWidget {
  final SaleFilterState intialState;
  const SaleFilterDialog({super.key, required this.intialState});

  static Future<SaleFilterState?> show(
    BuildContext context, {
    required SaleFilterState initialState,
  }) {
    return showDialog<SaleFilterState>(
      context: context,
      builder: (context) => SaleFilterDialog(intialState: initialState),
    );
  }

  @override
  ConsumerState<SaleFilterDialog> createState() => _SaleFilterDialogState();
}

class _SaleFilterDialogState extends ConsumerState<SaleFilterDialog> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _ascending = false;

  @override
  void initState() {
    super.initState();
    _startDate = widget.intialState.startDate;
    _endDate = widget.intialState.endDate;
    _ascending = widget.intialState.ascending;
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initialDate = (isStart ? _startDate : _endDate) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = DateTime(picked.year, picked.month, picked.day, 0, 0, 0);
        } else {
          _endDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            23,
            59,
            59,
          );
        }
      });
    }
  }

  void _clearDates() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
  }

  void _apply() {
    final newState = widget.intialState.copyWith(
      startDate: _startDate,
      endDate: _endDate,
      clearStartDate: _startDate == null,
      clearEndDate: _endDate == null,
      ascending: _ascending,
    );
    Navigator.of(context).pop(newState);
  }

  void _reset() {
    Navigator.of(context).pop(const SaleFilterState());
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Non définie';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filtres avancés des ventes'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ordre de tri par date',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Plage de dates',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                if (_startDate != null || _endDate != null)
                  TextButton(
                    onPressed: _clearDates,
                    child: const Text('Effacer les dates'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Du'),
              subtitle: Text(_formatDate(_startDate)),
              onTap: () => _pickDate(isStart: true),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event),
              title: const Text('Au'),
              subtitle: Text(_formatDate(_endDate)),
              onTap: () => _pickDate(isStart: false),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _reset,
          child: const Text('Réinitialiser'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _apply,
          child: const Text('Appliquer'),
        ),
      ],
    );
  }
}
