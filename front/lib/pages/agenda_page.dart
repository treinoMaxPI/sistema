import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gym_management/widgets/page_header.dart';
import 'package:gym_management/theme/typography.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  Map<String, List<Map<String, dynamic>>> _notes = {};
  final TextEditingController _noteController = TextEditingController();
  bool _loading = true;
  bool _annual = false;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('agenda_notes');
    if (raw != null && raw.isNotEmpty) {
      final decoded = json.decode(raw);
      if (decoded is Map<String, dynamic>) {
        final Map<String, List<Map<String, dynamic>>> map = {};
        decoded.forEach((k, v) {
          final list = <Map<String, dynamic>>[];
          if (v is List) {
            for (final item in v) {
              if (item is String) {
                list.add({'t': item, 'a': false});
              } else if (item is Map<String, dynamic>) {
                final t = item['t'] ?? item['text'] ?? '';
                final a = item['a'] ?? item['annual'] ?? false;
                list.add({'t': t, 'a': a == true});
              }
            }
          }
          map[k] = list;
        });
        _notes = map;
      }
    }
    setState(() {
      _loading = false;
    });
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('agenda_notes', json.encode(_notes));
  }

  String _keyFor(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  String _annualKeyFor(DateTime d) => '${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _addNote() async {
    final text = _noteController.text.trim();
    if (text.isEmpty) return;
    final key = _annual ? _annualKeyFor(_selectedDate) : _keyFor(_selectedDate);
    final list = _notes[key] ?? <Map<String, dynamic>>[];
    list.add({'t': text, 'a': _annual});
    _notes[key] = list;
    _noteController.clear();
    await _saveNotes();
    setState(() {});
  }

  void _removeNote(int index) async {
    final key = _keyFor(_selectedDate);
    final list = _notes[key] ?? <Map<String, dynamic>>[];
    if (index >= 0 && index < list.length) {
      list.removeAt(index);
      _notes[key] = list;
      await _saveNotes();
      setState(() {});
    }
  }

  void _editNote(String key, int index) async {
    final list = _notes[key] ?? <Map<String, dynamic>>[];
    if (index < 0 || index >= list.length) return;
    final controller = TextEditingController(text: (list[index]['t'] ?? '') as String);
    bool annual = (list[index]['a'] ?? false) as bool;
    final red = const Color(0xFFFF312E);
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Theme.of(context).colorScheme.outline)),
          title: Text('Editar observação', style: AppTypography.titleMedium.copyWith(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            maxLines: 4,
            decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Switch(
                        value: annual,
                        onChanged: (v) {
                          annual = v;
                        },
                      ),
                      const SizedBox(width: 8),
                      const Text('Repetir todos os anos'),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final text = controller.text.trim();
                    if (text.isNotEmpty) {
                      final oldAnnual = (list[index]['a'] ?? false) as bool;
                      if (oldAnnual == annual) {
                        list[index] = {'t': text, 'a': annual};
                        _notes[key] = list;
                      } else {
                        final currentDate = _parseKeyFlexible(key);
                        list.removeAt(index);
                        _notes[key] = list;
                        final targetKey = annual ? _annualKeyFor(currentDate) : _keyFor(currentDate);
                        final targetList = _notes[targetKey] ?? <Map<String, dynamic>>[];
                        targetList.add({'t': text, 'a': annual});
                        _notes[targetKey] = targetList;
                      }
                    }
                    Navigator.of(ctx).pop();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: red, foregroundColor: Colors.white),
                  child: const Text('Salvar'),
                )
              ],
            )
          ],
        );
      },
    );
    await _saveNotes();
    setState(() {});
  }

  List<DateTime> _daysInMonth(DateTime month) {
    final last = DateTime(month.year, month.month + 1, 0);
    final days = <DateTime>[];
    for (int i = 0; i < last.day; i++) {
      days.add(DateTime(month.year, month.month, i + 1));
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final outline = Theme.of(context).colorScheme.outline;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final red = const Color(0xFFFF312E);
    final days = _daysInMonth(_currentMonth);
    final selectedKey = _keyFor(_selectedDate);
    final selectedNotes = _notes[selectedKey]?.map((e) => e['t'] as String).toList() ?? <String>[];
    final allNotes = _buildAllNotes();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const PageHeader(title: 'Agenda'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: outline)),
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
                              });
                            },
                            icon: Icon(Icons.chevron_left, color: onSurface),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                '${_currentMonth.month.toString().padLeft(2, '0')}/${_currentMonth.year}',
                                style: AppTypography.titleMedium.copyWith(color: onSurface, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
                              });
                            },
                            icon: Icon(Icons.chevron_right, color: onSurface),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: _showMonthPicker,
                            icon: const Icon(Icons.calendar_month),
                            label: const Text('Meses'),
                            style: ElevatedButton.styleFrom(backgroundColor: red, foregroundColor: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('S'),
                          Text('T'),
                          Text('Q'),
                          Text('Q'),
                          Text('S'),
                          Text('S'),
                          Text('D'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final width = constraints.maxWidth;
                          final itemW = (width - 6 * 6) / 7;
                          return Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: days.map((d) {
                              final isSelected = d.year == _selectedDate.year && d.month == _selectedDate.month && d.day == _selectedDate.day;
                              final hasNotes = ((_notes[_keyFor(d)] ?? []).isNotEmpty) || ((_notes[_annualKeyFor(d)] ?? []).isNotEmpty);
                              return SizedBox(
                                width: itemW,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedDate = d;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: isSelected ? red.withOpacity(0.15) : surface,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: isSelected ? red : outline),
                                    ),
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('${d.day}', style: AppTypography.bodyMedium.copyWith(color: onSurface)),
                                        if (hasNotes) ...[
                                          const SizedBox(width: 6),
                                          Icon(Icons.event_note, size: 16, color: red),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: outline)),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text('Observações', style: AppTypography.titleMedium.copyWith(color: onSurface, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _noteController,
                                decoration: InputDecoration(
                                  hintText: 'Adicionar observação...',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              children: [
                                Switch(
                                  value: _annual,
                                  onChanged: (v) {
                                    setState(() {
                                      _annual = v;
                                    });
                                  },
                                ),
                                const SizedBox(width: 4),
                                const Text('Todos os anos'),
                              ],
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _addNote,
                              style: ElevatedButton.styleFrom(backgroundColor: red, foregroundColor: Colors.white),
                              child: const Text('Adicionar'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: allNotes.isEmpty
                              ? Center(child: Text('Sem observações.', style: AppTypography.caption.copyWith(color: onSurface.withOpacity(0.7))))
                              : ListView.separated(
                                  itemCount: allNotes.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                                  itemBuilder: (context, index) {
                                    final item = allNotes[index];
                                    final dateLabel = item['keyLabel'] as String;
                                    final text = item['text'] as String;
                                    final key = item['key'] as String;
                                    final idx = item['index'] as int;
                                    return Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: outline)),
                                      child: Row(
                                        children: [
                                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                            Text(dateLabel, style: AppTypography.caption.copyWith(color: onSurface.withOpacity(0.7))),
                                            const SizedBox(height: 6),
                                            Text(text, style: AppTypography.bodyMedium.copyWith(color: onSurface)),
                                          ])),
                                          IconButton(
                                            onPressed: () => _editNote(key, idx),
                                            icon: Icon(Icons.edit, color: onSurface.withOpacity(0.9)),
                                            tooltip: 'Editar',
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              if (_selectedDate != _parseKey(key)) {
                                                setState(() { _selectedDate = _parseKey(key); });
                                              }
                                              _removeNote(idx);
                                            },
                                            icon: Icon(Icons.delete, color: onSurface.withOpacity(0.8)),
                                            tooltip: 'Remover',
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
    );
  }

  DateTime _parseKey(String k) {
    final parts = k.split('-');
    final y = int.tryParse(parts[0]) ?? DateTime.now().year;
    final m = int.tryParse(parts[1]) ?? DateTime.now().month;
    final d = int.tryParse(parts[2]) ?? DateTime.now().day;
    return DateTime(y, m, d);
  }

  List<Map<String, dynamic>> _buildAllNotes() {
    final items = <Map<String, dynamic>>[];
    for (final entry in _notes.entries) {
      final date = _parseKeyFlexible(entry.key);
      final list = entry.value;
      for (int i = 0; i < list.length; i++) {
        final text = list[i]['t'] as String;
        final isAnnual = (list[i]['a'] ?? false) as bool;
        final label = isAnnual ? '${date.day}/${date.month} (todos os anos)' : '${date.day}/${date.month}/${date.year}';
        items.add({'key': entry.key, 'index': i, 'text': text, 'keyLabel': label, 'date': date});
      }
    }
    items.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    return items;
  }

  DateTime _parseKeyFlexible(String k) {
    final parts = k.split('-');
    if (parts.length == 3) {
      final y = int.tryParse(parts[0]) ?? DateTime.now().year;
      final m = int.tryParse(parts[1]) ?? DateTime.now().month;
      final d = int.tryParse(parts[2]) ?? DateTime.now().day;
      return DateTime(y, m, d);
    } else if (parts.length == 2) {
      final m = int.tryParse(parts[0]) ?? DateTime.now().month;
      final d = int.tryParse(parts[1]) ?? DateTime.now().day;
      return DateTime(DateTime.now().year, m, d);
    }
    return DateTime.now();
  }

  Future<void> _showMonthPicker() async {
    final months = const ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    int viewYear = _currentMonth.year;
    final surface = Theme.of(context).colorScheme.surface;
    final outline = Theme.of(context).colorScheme.outline;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final red = const Color(0xFFFF312E);
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSB) => AlertDialog(
            backgroundColor: surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: outline)),
            title: Row(
              children: [
                IconButton(
                  onPressed: () => setSB(() => viewYear = viewYear - 1),
                  icon: Icon(Icons.chevron_left, color: onSurface),
                ),
                Expanded(
                  child: Center(
                    child: Text('$viewYear', style: AppTypography.titleMedium.copyWith(color: onSurface, fontWeight: FontWeight.bold)),
                  ),
                ),
                IconButton(
                  onPressed: () => setSB(() => viewYear = viewYear + 1),
                  icon: Icon(Icons.chevron_right, color: onSurface),
                ),
              ],
            ),
            content: SizedBox(
              width: 360,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(12, (i) {
                  final isCurrent = (viewYear == _currentMonth.year && (i + 1) == _currentMonth.month);
                  return SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentMonth = DateTime(viewYear, i + 1);
                        });
                        Navigator.of(ctx).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCurrent ? red : surface,
                        foregroundColor: isCurrent ? Colors.white : onSurface,
                        side: BorderSide(color: outline),
                      ),
                      child: Text(months[i]),
                    ),
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }
}
