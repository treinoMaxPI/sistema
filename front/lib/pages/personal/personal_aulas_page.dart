import 'package:flutter/material.dart';
import 'package:characters/characters.dart';
import '../../widgets/modal_components.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';
import 'dart:math' as math;
import '../../theme/typography.dart';
import '../../services/aula_service.dart';
import '../../services/categoria_service.dart';
import '../../models/categoria.dart';

class PersonalAulasPage extends StatefulWidget {
  const PersonalAulasPage({super.key});

  @override
  State<PersonalAulasPage> createState() => _PersonalAulasPageState();
}

class _PersonalAulasPageState extends State<PersonalAulasPage> {
  final AulaService _aulaService = AulaService();
  List<AulaResponse> _aulas = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _carregarAulas();
  }

  Future<void> _carregarAulas() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final resp = await _aulaService.listar();
    if (resp.success && resp.data != null) {
      setState(() {
        _aulas = resp.data!;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = resp.message ?? 'Erro ao carregar aulas';
        _isLoading = false;
      });
    }
  }

  void _abrirNovaAula() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _NovaAulaSheet(
        onSalvar: (req) async {
          final resp = await _aulaService.criar(req);
          if (!resp.success) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erro: ${resp.message ?? 'Erro ao criar aula'}'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Aula criada com sucesso!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          }
          await _carregarAulas();
        },
      ),
    );
  }

  void _editarAula(int index) {
    final original = _aulas[index];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _NovaAulaSheet(
        initialTitulo: original.titulo,
        initialMensagem: original.descricao,
        initialImagemUrl: original.imagemUrl,

        initialCategoriaId: original.categoria?['id'],
        initialDuracao: original.duracao,
        initialAgendamento: original.agendamento,
        onSalvar: (req) async {
          final resp = await _aulaService.atualizar(original.id, req);
          if (!resp.success) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erro: ${resp.message ?? 'Erro ao atualizar aula'}'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Aula atualizada com sucesso!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          }
          await _carregarAulas();
        },
      ),
    );
  }

  Future<void> _removerAula(int index) async {
    final id = _aulas[index].id;
    final resp = await _aulaService.excluir(id);
    if (!resp.success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${resp.message ?? 'Erro ao excluir aula'}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aula deletada com sucesso!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
    await _carregarAulas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Aulas'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFFF312E),
        foregroundColor: Colors.white,
        onPressed: _abrirNovaAula,
        icon: const Icon(Icons.add),
        label: const Text('Nova Aula'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : (_errorMessage != null
                ? Center(
                    child: Text(
                      _errorMessage!,
                      style: AppTypography.bodyMedium.copyWith(color: Colors.redAccent),
                    ),
                  )
                : _aulas.isEmpty
                    ? _EmptyStateAulas(onCreate: _abrirNovaAula)
                    : ListView.separated(
                        itemCount: _aulas.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final a = _aulas[index];
                          return _AulaCard(
                            aula: a,
                            onEdit: () => _editarAula(index),
                            onDelete: () => _removerAula(index),
                            formatDate: _formatDate,
                          );
                        },
                      )),
      ),
    );
  }

  String _formatDate(String iso) {
    DateTime dt;
    try {
      dt = DateTime.parse(iso).toLocal();
    } catch (_) {
      return iso;
    }
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dt.day)}/${two(dt.month)}/${dt.year} ${two(dt.hour)}:${two(dt.minute)}';
  }
}

class _EmptyStateAulas extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyStateAulas({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.school, color: Colors.grey, size: 48),
          const SizedBox(height: 8),
          Text('Sem aulas por enquanto', style: AppTypography.bodyLarge),
          const SizedBox(height: 8),
          Text('Clique em “Nova Aula” para criar a primeira aula.', style: AppTypography.caption),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onCreate,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF312E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Nova Aula'),
          ),
        ],
      ),
    );
  }
}

class _NovaAulaSheet extends StatefulWidget {
  final void Function(CriarAulaRequest req) onSalvar;
  final String? initialTitulo;
  final String? initialMensagem;
  final String? initialImagemUrl;
  final String? initialCategoriaId;
  final int? initialDuracao;
  final AgendamentoResponse? initialAgendamento;

  const _NovaAulaSheet({
    required this.onSalvar,
    this.initialTitulo,
    this.initialMensagem,
    this.initialImagemUrl,
    this.initialCategoriaId,
    this.initialDuracao,
    this.initialAgendamento,
  });

  @override
  State<_NovaAulaSheet> createState() => _NovaAulaSheetState();
}

class _NovaAulaSheetState extends State<_NovaAulaSheet> {
  late final TextEditingController _tituloController;
  late final TextEditingController _descricaoController;
  late final TextEditingController _duracaoController;
  Uint8List? _pickedBytes;
  String? _pickedFilename;
  final AulaService _service = AulaService();
  final CategoriaService _categoriaService = CategoriaService(baseUrl: 'http://localhost:8080');
  List<Categoria> _categorias = [];
  String? _selectedCategoriaId;
  bool _saving = false;

  // Agendamento fields
  bool _isRecorrente = false;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  TimeOfDay? _recorrenteTime;
  // 0=Seg, 1=Ter, ..., 6=Dom
  final List<bool> _selectedDays = List.filled(7, false);

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.initialTitulo);
    _descricaoController = TextEditingController(text: widget.initialMensagem);
    _duracaoController = TextEditingController(text: widget.initialDuracao?.toString() ?? '');
    _selectedCategoriaId = widget.initialCategoriaId;
    
    if (widget.initialAgendamento != null) {
      final ag = widget.initialAgendamento!;
      _isRecorrente = ag.recorrente;
      if (_isRecorrente) {
        _selectedDays[0] = ag.segunda ?? false;
        _selectedDays[1] = ag.terca ?? false;
        _selectedDays[2] = ag.quarta ?? false;
        _selectedDays[3] = ag.quinta ?? false;
        _selectedDays[4] = ag.sexta ?? false;
        _selectedDays[5] = ag.sabado ?? false;
        _selectedDays[6] = ag.domingo ?? false;
        
        if (ag.horarioRecorrente != null) {
          final hr = ag.horarioRecorrente!;
          _recorrenteTime = TimeOfDay(hour: hr ~/ 60, minute: hr % 60);
        }
      } else if (ag.dataExata != null) {
        try {
          final dt = DateTime.parse(ag.dataExata!);
          _selectedDate = dt;
          _selectedTime = TimeOfDay.fromDateTime(dt);
        } catch (_) {}
      }
    }

    _carregarCategorias();
  }

  Future<void> _carregarCategorias() async {
    try {
      final token = await _getToken();
      final list = await _categoriaService.listarTodas(token);
      setState(() {
        _categorias = list;
      });
    } catch (e) {
      // Ignorar erro
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _duracaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModalSheet(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Nova Aula', style: AppTypography.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: _tituloController,
              style: AppTypography.bodyMedium.copyWith(color: Colors.white),
              cursorColor: Colors.white,
              decoration: _inputDecoration('Título'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedCategoriaId,
              dropdownColor: const Color(0xFF1E1E1E),
              style: AppTypography.bodyMedium.copyWith(color: Colors.white),
              decoration: _inputDecoration('Categoria'),
              items: _categorias.map((c) => DropdownMenuItem(
                value: c.id,
                child: Text(c.nome),
              )).toList(),
              onChanged: (val) => setState(() => _selectedCategoriaId = val),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descricaoController,
              maxLines: 3,
              style: AppTypography.bodyMedium.copyWith(color: Colors.white),
              cursorColor: Colors.white,
              decoration: _inputDecoration('Descrição'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _duracaoController,
              keyboardType: TextInputType.number,
              style: AppTypography.bodyMedium.copyWith(color: Colors.white),
              cursorColor: Colors.white,
              decoration: _inputDecoration('Duração (minutos)'),
            ),
            const SizedBox(height: 16),
            const Text('Agendamento', style: AppTypography.bodyLarge),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Aula Recorrente?', style: AppTypography.bodyMedium),
              value: _isRecorrente,
              onChanged: (val) => setState(() => _isRecorrente = val),
              activeColor: const Color(0xFFFF312E),
              contentPadding: EdgeInsets.zero,
            ),
            if (_isRecorrente) ...[
              const Text('Dias da Semana', style: AppTypography.bodyMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildDayToggle('Seg', 0),
                  _buildDayToggle('Ter', 1),
                  _buildDayToggle('Qua', 2),
                  _buildDayToggle('Qui', 3),
                  _buildDayToggle('Sex', 4),
                  _buildDayToggle('Sáb', 5),
                  _buildDayToggle('Dom', 6),
                ],
              ),
              const SizedBox(height: 12),
              _buildTimePicker(
                label: 'Horário',
                time: _recorrenteTime,
                onPick: (t) => setState(() => _recorrenteTime = t),
              ),
            ] else ...[
              _buildDatePicker(
                label: 'Data',
                date: _selectedDate,
                onPick: (d) => setState(() => _selectedDate = d),
              ),
              const SizedBox(height: 12),
              _buildTimePicker(
                label: 'Horário',
                time: _selectedTime,
                onPick: (t) => setState(() => _selectedTime = t),
              ),
            ],
            const SizedBox(height: 12),
            _ImagePickerRow(
              pickedBytes: _pickedBytes,
              pickedFilename: _pickedFilename,
              onPick: () async {
                final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
                if (result != null && result.files.isNotEmpty) {
                  final f = result.files.first;
                  if (f.bytes != null) {
                    const int maxBytes = 5 * 1024 * 1024;
                    if (f.size > maxBytes) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Arquivo muito grande. Tamanho máximo: 5MB.')));
                      }
                      return;
                    }
                    setState(() {
                      _pickedBytes = f.bytes!;
                      _pickedFilename = f.name;
                    });
                  }
                }
              },
              onRemove: () => setState(() {
                _pickedBytes = null;
                _pickedFilename = null;
              }),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[700]!),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF312E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _saving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Salvar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTypography.bodySmall.copyWith(color: Colors.white70),
      filled: true,
      fillColor: Colors.black.withOpacity(0.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[800]!),
      ),
    );
  }

  Widget _buildDatePicker({required String label, required DateTime? date, required ValueChanged<DateTime> onPick}) {
    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final d = await showDatePicker(
          context: context,
          initialDate: date ?? now,
          firstDate: now,
          lastDate: now.add(const Duration(days: 365)),
        );
        if (d != null) onPick(d);
      },
      child: InputDecorator(
        decoration: _inputDecoration(label),
        child: Text(
          date != null ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}' : 'Selecione a data',
          style: AppTypography.bodyMedium.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTimePicker({required String label, required TimeOfDay? time, required ValueChanged<TimeOfDay> onPick}) {
    return InkWell(
      onTap: () async {
        final t = await showTimePicker(
          context: context,
          initialTime: time ?? TimeOfDay.now(),
        );
        if (t != null) onPick(t);
      },
      child: InputDecorator(
        decoration: _inputDecoration(label),
        child: Text(
          time != null ? '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}' : 'Selecione o horário',
          style: AppTypography.bodyMedium.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildDayToggle(String label, int index) {
    final isSelected = _selectedDays[index];
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) => setState(() => _selectedDays[index] = val),
      selectedColor: const Color(0xFFFF312E),
      checkmarkColor: Colors.white,
      labelStyle: AppTypography.bodySmall.copyWith(
        color: isSelected ? Colors.white : Colors.white70,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: isSelected ? const Color(0xFFFF312E) : Colors.grey[800]!),
      ),
    );
  }

  Future<void> _submit() async {
    final titulo = _tituloController.text.trim();
    final descricao = _descricaoController.text.trim();
    final duracaoStr = _duracaoController.text.trim();
    
    if (titulo.isEmpty || descricao.isEmpty || duracaoStr.isEmpty || _selectedCategoriaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todos os campos obrigatórios'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final duracao = int.tryParse(duracaoStr);
    if (duracao == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Duração inválida'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    AgendamentoRequest agendamento;
    if (_isRecorrente) {
      if (!_selectedDays.contains(true) || _recorrenteTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecione pelo menos um dia e o horário'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }
      final minutes = _recorrenteTime!.hour * 60 + _recorrenteTime!.minute;
      agendamento = AgendamentoRequest(
        recorrente: true,
        horarioRecorrente: minutes,
        segunda: _selectedDays[0],
        terca: _selectedDays[1],
        quarta: _selectedDays[2],
        quinta: _selectedDays[3],
        sexta: _selectedDays[4],
        sabado: _selectedDays[5],
        domingo: _selectedDays[6],
      );
    } else {
      if (_selectedDate == null || _selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecione a data e horário'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }
      final dt = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
      agendamento = AgendamentoRequest(
        recorrente: false,
        dataExata: dt.toIso8601String(),
      );
    }

    setState(() => _saving = true);
    String? finalUrl;
    if (_pickedBytes != null && _pickedFilename != null) {
      final up = await _service.uploadImagem(_pickedBytes!, _pickedFilename!);
      if (up.success && up.data != null) finalUrl = up.data;
      else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro: ${up.message ?? 'Erro ao enviar imagem'}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }

    final req = CriarAulaRequest(
      titulo: titulo,
      descricao: descricao,
      bannerUrl: finalUrl ?? widget.initialImagemUrl,
      duracao: duracao,
      categoriaId: _selectedCategoriaId!,
      agendamento: agendamento,
    );

    widget.onSalvar(req);
    if (mounted) Navigator.pop(context);
    setState(() => _saving = false);
  }
}

class _ImagePickerRow extends StatelessWidget {
  final Uint8List? pickedBytes;
  final String? pickedFilename;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _ImagePickerRow({required this.pickedBytes, required this.pickedFilename, required this.onPick, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: onPick,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F1F1F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              icon: const Icon(Icons.image, color: Colors.white),
              label: const Text('Adicionar imagem'),
            ),
            const SizedBox(width: 12),
            if (pickedBytes != null)
              OutlinedButton.icon(
                onPressed: onRemove,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey[700]!),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                icon: const Icon(Icons.close, color: Colors.white),
                label: const Text('Remover'),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Tamanho máximo: 5MB',
          style: AppTypography.caption.copyWith(color: Colors.white54),
        ),
        const SizedBox(height: 8),
        if (pickedBytes != null) _ResponsiveImagePreview(bytes: pickedBytes!),
      ],
    );
  }
}

class _ResponsiveImagePreview extends StatelessWidget {
  final Uint8List bytes;
  const _ResponsiveImagePreview({required this.bytes});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        double ar = _aspectForWidth(w);
        final double desiredHeight = w / ar;
        final double maxPreviewHeight = 160;
        final double height = math.min(desiredHeight, maxPreviewHeight);
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: Image.memory(
              bytes,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.black,
                  alignment: Alignment.center,
                  child: Text('Falha ao pré-visualizar imagem', style: AppTypography.caption),
                );
              },
            ),
          ),
        );
      },
    );
  }

  double _aspectForWidth(double w) {
    if (w < 480) return 4 / 5;
    if (w < 800) return 3 / 4;
    return 16 / 9;
  }
}

class _AulaCard extends StatelessWidget {
  final AulaResponse aula;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String Function(String) formatDate;

  const _AulaCard({required this.aula, required this.onEdit, required this.onDelete, required this.formatDate});

  Color get _cardColor => const Color(0xFF121212);
  Color get _borderColor => const Color(0xFF1E1E1E);
  Color get _accent => const Color(0xFFFF312E);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_hasImage) _buildImage(context),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 8),
                Text(aula.descricao, style: AppTypography.bodyMedium.copyWith(color: Colors.white70), maxLines: 3, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 16),
                _buildInfoRow(),
                const SizedBox(height: 16),
                _buildActions(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool get _hasImage => (aula.imagemUrl != null && aula.imagemUrl!.trim().isNotEmpty);

  Widget _buildImage(BuildContext context) {
    String url = aula.imagemUrl!;
    if (url.startsWith('/')) {
      final uri = Uri.parse(AulaService.baseUrl);
      url = '${uri.scheme}://${uri.host}:${uri.port}$url';
    }
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(color: Colors.black, child: const Center(child: CircularProgressIndicator()));
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.black,
            child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.broken_image, color: Colors.white54, size: 36), const SizedBox(height: 8), Text('Erro ao carregar imagem', style: AppTypography.caption)]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            aula.titulo,
            style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        if (aula.categoria != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _accent.withOpacity(0.5)),
            ),
            child: Text(
              aula.categoria!['nome'],
              style: AppTypography.caption.copyWith(color: _accent, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildIconText(Icons.timer, '${aula.duracao} min'),
        const SizedBox(height: 4),
        if (aula.agendamento != null) ...[
          if (aula.agendamento!.recorrente)
            _buildIconText(Icons.repeat, _formatRecurrence(aula.agendamento!))
          else if (aula.agendamento!.dataExata != null)
            _buildIconText(Icons.calendar_today, _formatExactDate(aula.agendamento!.dataExata!)),
          
          if (aula.agendamento!.horarioRecorrente != null)
             _buildIconText(Icons.access_time, _formatTime(aula.agendamento!.horarioRecorrente!))
          else if (aula.agendamento!.dataExata != null)
             _buildIconText(Icons.access_time, _formatTimeFromDate(aula.agendamento!.dataExata!)),
        ],
      ],
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.white54),
        const SizedBox(width: 8),
        Text(text, style: AppTypography.bodySmall.copyWith(color: Colors.white70)),
      ],
    );
  }

  String _formatRecurrence(AgendamentoResponse ag) {
    List<String> days = [];
    if (ag.segunda == true) days.add('Seg');
    if (ag.terca == true) days.add('Ter');
    if (ag.quarta == true) days.add('Qua');
    if (ag.quinta == true) days.add('Qui');
    if (ag.sexta == true) days.add('Sex');
    if (ag.sabado == true) days.add('Sáb');
    if (ag.domingo == true) days.add('Dom');
    
    if (days.isEmpty) return 'Recorrente';
    return days.join(', ');
  }

  String _formatExactDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  String _formatTime(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  String _formatTimeFromDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit, size: 18),
          label: const Text('Editar'),
          style: TextButton.styleFrom(foregroundColor: Colors.white70),
        ),
        const SizedBox(width: 8),
        TextButton.icon(
          onPressed: onDelete,
          icon: const Icon(Icons.delete, size: 18),
          label: const Text('Excluir'),
          style: TextButton.styleFrom(foregroundColor: _accent),
        ),
      ],
    );
  }


}
