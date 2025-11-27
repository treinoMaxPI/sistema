import 'package:flutter/material.dart';
import '../services/treino_service.dart';
import '../services/exercicio_service.dart';
import '../models/treino.dart';
import '../models/exercicio.dart';
import '../models/grupo_muscular.dart';
import '../widgets/modal_components.dart';

class CriarTreinoDialog extends StatefulWidget {
  final String usuarioId;
  final VoidCallback onTreinoCriado;

  const CriarTreinoDialog({
    super.key,
    required this.usuarioId,
    required this.onTreinoCriado,
  });

  @override
  State<CriarTreinoDialog> createState() => _CriarTreinoDialogState();
}

class _CriarTreinoDialogState extends State<CriarTreinoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _nivelController = TextEditingController();
  bool _isLoading = false;
  List<ItemTreino> _itens = [];
  final ExercicioService _exercicioService = ExercicioService();
  List<Exercicio> _exerciciosDisponiveis = [];
  bool _isLoadingExercicios = true;
  List<String> _tiposTreinoSelecionados = [];

  final List<String> _niveis = [
    'Iniciante',
    'Intermediário',
    'Avançado',
  ];

  // Usa o enum GrupoMuscular do backend para garantir consistência
  List<String> get _tiposTreino => GrupoMuscular.allAsString;

  @override
  void initState() {
    super.initState();
    _carregarExercicios();
  }

  Future<void> _carregarExercicios() async {
    final response = await _exercicioService.listarTodos();
    if (response.success && response.data != null) {
      setState(() {
        _exerciciosDisponiveis = response.data!;
        _isLoadingExercicios = false;
      });
    } else {
      setState(() {
        _isLoadingExercicios = false;
      });
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _nivelController.dispose();
    super.dispose();
  }

  void _adicionarItemTreino() {
    setState(() {
      _itens.add(ItemTreino(
        exercicioId: '',
        ordem: _itens.length + 1,
        series: 3,
        repeticoes: '10',
      ));
    });
  }

  void _removerItemTreino(int index) {
    setState(() {
      _itens.removeAt(index);
      // Reordenar
      for (int i = 0; i < _itens.length; i++) {
        _itens[i] = ItemTreino(
          id: _itens[i].id,
          exercicioId: _itens[i].exercicioId,
          exercicioNome: _itens[i].exercicioNome,
          ordem: i + 1,
          series: _itens[i].series,
          repeticoes: _itens[i].repeticoes,
          tempoDescanso: _itens[i].tempoDescanso,
          observacao: _itens[i].observacao,
        );
      }
    });
  }

  Future<void> _criarTreino() async {
    if (!_formKey.currentState!.validate()) return;
    if (_itens.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione pelo menos um exercício'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validar que todos os itens têm exercício selecionado
    for (var item in _itens) {
      if (item.exercicioId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Todos os exercícios devem ser selecionados'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    final request = CriarTreinoRequest(
      nome: _nomeController.text,
      tipoTreino: _tiposTreinoSelecionados.isEmpty 
          ? null 
          : _tiposTreinoSelecionados.join(', '),
      descricao: _descricaoController.text.isEmpty ? null : _descricaoController.text,
      nivel: _nivelController.text.isEmpty ? null : _nivelController.text,
      itens: _itens,
      usuarioId: widget.usuarioId,
    );

    final treinoService = TreinoService();
    final response = await treinoService.criarTreino(request);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (response.success) {
        Navigator.pop(context);
        widget.onTreinoCriado();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Treino criado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Erro ao criar treino'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalSheet(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Criar Treino',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Treino *',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFFF312E)),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nome é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Tipo de Treino',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tiposTreino.map((tipo) {
                  final isSelected = _tiposTreinoSelecionados.contains(tipo);
                  return FilterChip(
                    label: Text(tipo),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _tiposTreinoSelecionados.add(tipo);
                        } else {
                          _tiposTreinoSelecionados.remove(tipo);
                        }
                      });
                    },
                    backgroundColor: Colors.black,
                    selectedColor: const Color(0xFFFF312E).withOpacity(0.3),
                    checkmarkColor: const Color(0xFFFF312E),
                    labelStyle: TextStyle(
                      color: isSelected ? const Color(0xFFFF312E) : Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFFFF312E) : Colors.grey[800]!,
                      width: 1.5,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFFF312E)),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _nivelController.text.isEmpty ? null : _nivelController.text,
                decoration: const InputDecoration(
                  labelText: 'Nível',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFFF312E)),
                  ),
                ),
                dropdownColor: const Color(0xFF1A1A1A),
                style: const TextStyle(color: Colors.white),
                items: _niveis.map((nivel) {
                  return DropdownMenuItem<String>(
                    value: nivel,
                    child: Text(nivel),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _nivelController.text = value ?? '';
                  });
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Exercícios',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: _adicionarItemTreino,
                    icon: const Icon(Icons.add, color: Color(0xFFFF312E)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ..._itens.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return _buildItemTreinoCard(item, index);
              }),
              if (_itens.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Nenhum exercício adicionado',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _criarTreino,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF312E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Criar Treino'),
              ),
            ],
          ),
        ),
    );
  }

  Future<void> _selecionarExercicio(int index, ItemTreino item) async {
    final exercicioSelecionado = await showModalBottomSheet<Exercicio>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ExercicioSelectionModal(
        exercicios: _exerciciosDisponiveis,
        exercicioAtual: item.exercicioId.isNotEmpty
            ? _exerciciosDisponiveis.firstWhere(
                (e) => e.id == item.exercicioId,
                orElse: () => _exerciciosDisponiveis.first,
              )
            : null,
      ),
    );

    if (exercicioSelecionado != null) {
      setState(() {
        _itens[index] = ItemTreino(
          id: item.id,
          exercicioId: exercicioSelecionado.id,
          exercicioNome: exercicioSelecionado.nome,
          ordem: item.ordem,
          series: item.series,
          repeticoes: item.repeticoes,
          tempoDescanso: item.tempoDescanso,
          observacao: item.observacao,
        );
      });
    }
  }

  Widget _buildItemTreinoCard(ItemTreino item, int index) {
    Exercicio? exercicioSelecionado;
    if (item.exercicioId.isNotEmpty) {
      exercicioSelecionado = _exerciciosDisponiveis.firstWhere(
        (e) => e.id == item.exercicioId,
        orElse: () => _exerciciosDisponiveis.first,
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF1A1A1A),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF312E),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _isLoadingExercicios
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: CircularProgressIndicator(
                              color: Color(0xFFFF312E),
                            ),
                          ),
                        )
                      : InkWell(
                          onTap: () => _selecionarExercicio(index, item),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: item.exercicioId.isEmpty
                                    ? Colors.red.withOpacity(0.5)
                                    : Colors.grey.withOpacity(0.3),
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.exercicioId.isEmpty
                                            ? 'Selecione um exercício *'
                                            : item.exercicioNome ?? 'Exercício',
                                        style: TextStyle(
                                          color: item.exercicioId.isEmpty
                                              ? Colors.grey
                                              : Colors.white,
                                          fontSize: 15,
                                          fontWeight: item.exercicioId.isEmpty
                                              ? FontWeight.normal
                                              : FontWeight.w500,
                                        ),
                                      ),
                                      if (item.exercicioId.isNotEmpty &&
                                          exercicioSelecionado?.descricao != null)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text(
                                            exercicioSelecionado!.descricao!,
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _removerItemTreino(index),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'Remover exercício',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: item.series.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Séries',
                      labelStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFFF312E)),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final series = int.tryParse(value) ?? 3;
                      setState(() {
                        _itens[index] = ItemTreino(
                          id: item.id,
                          exercicioId: item.exercicioId,
                          exercicioNome: item.exercicioNome,
                          ordem: item.ordem,
                          series: series,
                          repeticoes: item.repeticoes,
                          tempoDescanso: item.tempoDescanso,
                          observacao: item.observacao,
                        );
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: item.repeticoes,
                    decoration: const InputDecoration(
                      labelText: 'Repetições',
                      labelStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFFF312E)),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    onChanged: (value) {
                      setState(() {
                        _itens[index] = ItemTreino(
                          id: item.id,
                          exercicioId: item.exercicioId,
                          exercicioNome: item.exercicioNome,
                          ordem: item.ordem,
                          series: item.series,
                          repeticoes: value,
                          tempoDescanso: item.tempoDescanso,
                          observacao: item.observacao,
                        );
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: item.tempoDescanso,
              decoration: const InputDecoration(
                labelText: 'Tempo de Descanso',
                labelStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFFF312E)),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                setState(() {
                  _itens[index] = ItemTreino(
                    id: item.id,
                    exercicioId: item.exercicioId,
                    exercicioNome: item.exercicioNome,
                    ordem: item.ordem,
                    series: item.series,
                    repeticoes: item.repeticoes,
                    tempoDescanso: value.isEmpty ? null : value,
                    observacao: item.observacao,
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class EditarTreinoDialog extends StatefulWidget {
  final Treino treino;
  final VoidCallback onTreinoAtualizado;

  const EditarTreinoDialog({
    super.key,
    required this.treino,
    required this.onTreinoAtualizado,
  });

  @override
  State<EditarTreinoDialog> createState() => _EditarTreinoDialogState();
}

class _EditarTreinoDialogState extends State<EditarTreinoDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _descricaoController;
  late final TextEditingController _nivelController;
  bool _isLoading = false;
  List<ItemTreino> _itens = [];
  final ExercicioService _exercicioService = ExercicioService();
  List<Exercicio> _exerciciosDisponiveis = [];
  bool _isLoadingExercicios = true;
  List<String> _tiposTreinoSelecionados = [];

  final List<String> _niveis = [
    'Iniciante',
    'Intermediário',
    'Avançado',
  ];

  // Usa o enum GrupoMuscular do backend para garantir consistência
  List<String> get _tiposTreino => GrupoMuscular.allAsString;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.treino.nome);
    // Parse tipoTreino string para lista (ex: "A, B, C" -> ["A", "B", "C"])
    if (widget.treino.tipoTreino != null && widget.treino.tipoTreino!.isNotEmpty) {
      _tiposTreinoSelecionados = widget.treino.tipoTreino!
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    _descricaoController = TextEditingController(text: widget.treino.descricao ?? '');
    _nivelController = TextEditingController(text: widget.treino.nivel ?? '');
    _itens = List.from(widget.treino.itens);
    _carregarExercicios();
  }

  Future<void> _carregarExercicios() async {
    final response = await _exercicioService.listarTodos();
    if (response.success && response.data != null) {
      setState(() {
        _exerciciosDisponiveis = response.data!;
        _isLoadingExercicios = false;
      });
    } else {
      setState(() {
        _isLoadingExercicios = false;
      });
    }
  }

  Future<void> _selecionarExercicio(int index, ItemTreino item) async {
    final exercicioSelecionado = await showModalBottomSheet<Exercicio>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ExercicioSelectionModal(
        exercicios: _exerciciosDisponiveis,
        exercicioAtual: item.exercicioId.isNotEmpty
            ? _exerciciosDisponiveis.firstWhere(
                (e) => e.id == item.exercicioId,
                orElse: () => _exerciciosDisponiveis.first,
              )
            : null,
      ),
    );

    if (exercicioSelecionado != null) {
      setState(() {
        _itens[index] = ItemTreino(
          id: item.id,
          exercicioId: exercicioSelecionado.id,
          exercicioNome: exercicioSelecionado.nome,
          ordem: item.ordem,
          series: item.series,
          repeticoes: item.repeticoes,
          tempoDescanso: item.tempoDescanso,
          observacao: item.observacao,
        );
      });
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _nivelController.dispose();
    super.dispose();
  }

  void _adicionarItemTreino() {
    setState(() {
      _itens.add(ItemTreino(
        exercicioId: '',
        ordem: _itens.length + 1,
        series: 3,
        repeticoes: '10',
      ));
    });
  }

  void _removerItemTreino(int index) {
    setState(() {
      _itens.removeAt(index);
      // Reordenar
      for (int i = 0; i < _itens.length; i++) {
        _itens[i] = ItemTreino(
          id: _itens[i].id,
          exercicioId: _itens[i].exercicioId,
          exercicioNome: _itens[i].exercicioNome,
          ordem: i + 1,
          series: _itens[i].series,
          repeticoes: _itens[i].repeticoes,
          tempoDescanso: _itens[i].tempoDescanso,
          observacao: _itens[i].observacao,
        );
      }
    });
  }

  Future<void> _atualizarTreino() async {
    if (!_formKey.currentState!.validate()) return;
    if (_itens.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione pelo menos um exercício'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validar que todos os itens têm exercício selecionado
    for (var item in _itens) {
      if (item.exercicioId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Todos os exercícios devem ser selecionados'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    final request = AtualizarTreinoRequest(
      nome: _nomeController.text,
      tipoTreino: _tiposTreinoSelecionados.isEmpty 
          ? null 
          : _tiposTreinoSelecionados.join(', '),
      descricao: _descricaoController.text.isEmpty ? null : _descricaoController.text,
      nivel: _nivelController.text.isEmpty ? null : _nivelController.text,
      itens: _itens,
    );

    final treinoService = TreinoService();
    final response = await treinoService.atualizarTreino(widget.treino.id, request);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (response.success) {
        Navigator.pop(context);
        widget.onTreinoAtualizado();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Treino atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Erro ao atualizar treino'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalSheet(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Editar Treino',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Treino *',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFFF312E)),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nome é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Tipo de Treino',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tiposTreino.map((tipo) {
                  final isSelected = _tiposTreinoSelecionados.contains(tipo);
                  return FilterChip(
                    label: Text(tipo),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _tiposTreinoSelecionados.add(tipo);
                        } else {
                          _tiposTreinoSelecionados.remove(tipo);
                        }
                      });
                    },
                    backgroundColor: Colors.black,
                    selectedColor: const Color(0xFFFF312E).withOpacity(0.3),
                    checkmarkColor: const Color(0xFFFF312E),
                    labelStyle: TextStyle(
                      color: isSelected ? const Color(0xFFFF312E) : Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFFFF312E) : Colors.grey[800]!,
                      width: 1.5,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFFF312E)),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _nivelController.text.isEmpty ? null : _nivelController.text,
                decoration: const InputDecoration(
                  labelText: 'Nível',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFFF312E)),
                  ),
                ),
                dropdownColor: const Color(0xFF1A1A1A),
                style: const TextStyle(color: Colors.white),
                items: _niveis.map((nivel) {
                  return DropdownMenuItem<String>(
                    value: nivel,
                    child: Text(nivel),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _nivelController.text = value ?? '';
                  });
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Exercícios',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: _adicionarItemTreino,
                    icon: const Icon(Icons.add, color: Color(0xFFFF312E)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ..._itens.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return _buildItemTreinoCard(item, index);
              }),
              if (_itens.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Nenhum exercício adicionado',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _atualizarTreino,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF312E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Atualizar Treino'),
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildItemTreinoCard(ItemTreino item, int index) {
    Exercicio? exercicioSelecionado;
    if (item.exercicioId.isNotEmpty) {
      exercicioSelecionado = _exerciciosDisponiveis.firstWhere(
        (e) => e.id == item.exercicioId,
        orElse: () => _exerciciosDisponiveis.isNotEmpty ? _exerciciosDisponiveis.first : Exercicio(
          id: '',
          nome: '',
          grupoMuscular: [],
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF1A1A1A),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF312E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _isLoadingExercicios
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: CircularProgressIndicator(
                              color: Color(0xFFFF312E),
                            ),
                          ),
                        )
                      : InkWell(
                          onTap: () => _selecionarExercicio(index, item),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: item.exercicioId.isEmpty
                                    ? Colors.red.withOpacity(0.5)
                                    : Colors.grey.withOpacity(0.3),
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.exercicioId.isEmpty
                                            ? 'Selecione um exercício *'
                                            : item.exercicioNome ?? 'Exercício',
                                        style: TextStyle(
                                          color: item.exercicioId.isEmpty
                                              ? Colors.grey
                                              : Colors.white,
                                          fontSize: 15,
                                          fontWeight: item.exercicioId.isEmpty
                                              ? FontWeight.normal
                                              : FontWeight.w500,
                                        ),
                                      ),
                                      if (item.exercicioId.isNotEmpty &&
                                          exercicioSelecionado?.descricao != null)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text(
                                            exercicioSelecionado!.descricao!,
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _removerItemTreino(index),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'Remover exercício',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: item.series.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Séries',
                      labelStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFFF312E)),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final series = int.tryParse(value) ?? 3;
                      setState(() {
                        _itens[index] = ItemTreino(
                          id: item.id,
                          exercicioId: item.exercicioId,
                          exercicioNome: item.exercicioNome,
                          ordem: item.ordem,
                          series: series,
                          repeticoes: item.repeticoes,
                          tempoDescanso: item.tempoDescanso,
                          observacao: item.observacao,
                        );
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: item.repeticoes,
                    decoration: const InputDecoration(
                      labelText: 'Repetições',
                      labelStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFFF312E)),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    onChanged: (value) {
                      setState(() {
                        _itens[index] = ItemTreino(
                          id: item.id,
                          exercicioId: item.exercicioId,
                          exercicioNome: item.exercicioNome,
                          ordem: item.ordem,
                          series: item.series,
                          repeticoes: value,
                          tempoDescanso: item.tempoDescanso,
                          observacao: item.observacao,
                        );
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: item.tempoDescanso,
              decoration: const InputDecoration(
                labelText: 'Tempo de Descanso',
                labelStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFFF312E)),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                setState(() {
                  _itens[index] = ItemTreino(
                    id: item.id,
                    exercicioId: item.exercicioId,
                    exercicioNome: item.exercicioNome,
                    ordem: item.ordem,
                    series: item.series,
                    repeticoes: item.repeticoes,
                    tempoDescanso: value.isEmpty ? null : value,
                    observacao: item.observacao,
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}


// Widget para seleção de exercícios com busca
class _ExercicioSelectionModal extends StatefulWidget {
  final List<Exercicio> exercicios;
  final Exercicio? exercicioAtual;

  const _ExercicioSelectionModal({
    required this.exercicios,
    this.exercicioAtual,
  });

  @override
  State<_ExercicioSelectionModal> createState() =>
      _ExercicioSelectionModalState();
}

class _ExercicioSelectionModalState extends State<_ExercicioSelectionModal> {
  final TextEditingController _searchController = TextEditingController();
  List<Exercicio> _exerciciosFiltrados = [];

  @override
  void initState() {
    super.initState();
    _exerciciosFiltrados = widget.exercicios;
    _searchController.addListener(_filtrarExercicios);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filtrarExercicios() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _exerciciosFiltrados = widget.exercicios;
      } else {
        _exerciciosFiltrados = widget.exercicios
            .where((exercicio) =>
                exercicio.nome.toLowerCase().contains(query) ||
                (exercicio.descricao?.toLowerCase().contains(query) ?? false))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                const Text(
                  'Selecionar Exercício',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar exercício...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.black.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[800]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFFF312E),
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _exerciciosFiltrados.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchController.text.isEmpty
                              ? Icons.fitness_center
                              : Icons.search_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isEmpty
                              ? 'Nenhum exercício disponível'
                              : 'Nenhum exercício encontrado',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _exerciciosFiltrados.length,
                    itemBuilder: (context, index) {
                      final exercicio = _exerciciosFiltrados[index];
                      final isSelected =
                          widget.exercicioAtual?.id == exercicio.id;
                      return InkWell(
                        onTap: () => Navigator.pop(context, exercicio),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFFF312E).withOpacity(0.2)
                                : Colors.black.withOpacity(0.3),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFFF312E)
                                  : Colors.grey.withOpacity(0.2),
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      exercicio.nome,
                                      style: TextStyle(
                                        color: isSelected
                                            ? const Color(0xFFFF312E)
                                            : Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (exercicio.descricao != null &&
                                        exercicio.descricao!.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        exercicio.descricao!,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFFFF312E),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}
