import 'package:flutter/material.dart';

import '../../../providers/categories_provider.dart';

/// Dialogue modale pour configurer les filtres avancés (tri et plage de dates).
class CategoryFilterDialog extends StatefulWidget {
  final CategoryFilterState initialState;

  const CategoryFilterDialog({
    super.key,
    required this.initialState,
  });

  static Future<CategoryFilterState?> show(
    BuildContext context, {
    required CategoryFilterState initialState,
  }) {
    return showDialog<CategoryFilterState>(
      context: context,
      builder: (context) => CategoryFilterDialog(initialState: initialState),
    );
  }

  @override
  State<CategoryFilterDialog> createState() => _CategoryFilterDialogState();
}

class _CategoryFilterDialogState extends State<CategoryFilterDialog> {
  late DateTime? _startDate;
  late DateTime? _endDate;
  late bool _ascending;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialState.startDate;
    _endDate = widget.initialState.endDate;
    _ascending = widget.initialState.ascending;
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
          _endDate = DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
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
    final newState = widget.initialState.copyWith(
      startDate: _startDate,
      endDate: _endDate,
      clearStartDate: _startDate == null,
      clearEndDate: _endDate == null,
      ascending: _ascending,
    );
    Navigator.of(context).pop(newState);
  }

  void _reset() {
    Navigator.of(context).pop(const CategoryFilterState());
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Non définie';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filtres avancés'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ordre de tri',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: true,
                  label: Text('A -> Z'),
                  icon: Icon(Icons.sort_by_alpha),
                ),
                ButtonSegment(
                  value: false,
                  label: Text('Z -> A'),
                  icon: Icon(Icons.sort_by_alpha_outlined),
                ),
              ],
              selected: {_ascending},
              onSelectionChanged: (newSelection) {
                setState(() {
                  _ascending = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Date de création',
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
