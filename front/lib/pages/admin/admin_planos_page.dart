import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/plano_service.dart';
import '../../widgets/modal_components.dart';

class AdminPlanosPage extends StatefulWidget {
  const AdminPlanosPage({super.key});

  @override
  State<AdminPlanosPage> createState() => _AdminPlanosPageState();
}

class _AdminPlanosPageState extends State<AdminPlanosPage> {
  final PlanoService _planoService = PlanoService();
  List<PlanoResponse> _planos = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _carregarPlanos();
  }

  Future<void> _carregarPlanos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await _planoService.listarPlanos(ativos: false);

    if (response.success && response.data != null) {
      setState(() {
        _planos = response.data!;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = response.message ?? 'Erro ao carregar planos';
        _isLoading = false;
      });
    }
  }

  void _toggleShowOnlyActive() {
    _carregarPlanos();
  }

  void _showCriarPlanoDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CriarPlanoDialog(
        onPlanoCriado: _carregarPlanos,
      ),
    );
  }

  void _showEditarPlanoDialog(PlanoResponse plano) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditarPlanoDialog(
        plano: plano,
        onPlanoAtualizado: _carregarPlanos,
      ),
    );
  }

  void _showAtualizarPrecoDialog(PlanoResponse plano) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AtualizarPrecoDialog(
        plano: plano,
        onPrecoAtualizado: _carregarPlanos,
      ),
    );
  }

  Future<void> _alterarStatusPlano(PlanoResponse plano, bool novoStatus) async {
    final response =
        await _planoService.alterarStatusPlano(plano.id, novoStatus);

    if (response.success) {
      _carregarPlanos();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Plano ${novoStatus ? 'ativado' : 'desativado'} com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message ?? 'Erro ao alterar status do plano'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Gerenciar Planos',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCriarPlanoDialog,
        backgroundColor: const Color(0xFFFF312E),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFF312E),
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _carregarPlanos,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF312E),
                        ),
                        child: const Text(
                          'Tentar Novamente',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )
              : _planos.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Nenhum plano encontrado',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Não há planos cadastrados',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _planos.length,
                      itemBuilder: (context, index) {
                        final plano = _planos[index];
                        return _PlanoCard(
                            plano: plano,
                            onEditar: () => _showEditarPlanoDialog(plano),
                            onAlterarStatus: (novoStatus) =>
                                _alterarStatusPlano(plano, novoStatus),
                            onAtualizarPreco: () =>
                                _showAtualizarPrecoDialog(plano));
                      },
                    ),
    );
  }
}

class _PlanoCard extends StatelessWidget {
  final PlanoResponse plano;
  final VoidCallback onEditar;
  final Function(bool) onAlterarStatus;
  final VoidCallback onAtualizarPreco;

  const _PlanoCard({
    required this.plano,
    required this.onEditar,
    required this.onAlterarStatus,
    required this.onAtualizarPreco,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: plano.ativo ? const Color(0xFFFF312E) : Colors.grey[700]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  plano.nome,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: plano.ativo
                      ? const Color(0xFF00C853).withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  plano.ativo ? 'ATIVO' : 'INATIVO',
                  style: TextStyle(
                    color: plano.ativo ? const Color(0xFF00C853) : Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            plano.descricao,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                plano.precoFormatado,
                style: const TextStyle(
                  color: Color(0xFFFF312E),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              _buildActionButton(
                icon: Icons.edit,
                color: Colors.blue,
                onPressed: onEditar,
                tooltip: 'Editar',
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: plano.ativo ? Icons.toggle_on : Icons.toggle_off,
                color: plano.ativo ? Colors.green : Colors.orange,
                onPressed: () => onAlterarStatus(!plano.ativo),
                tooltip: plano.ativo ? 'Desativar' : 'Ativar',
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.attach_money,
                color: Colors.yellow,
                onPressed: onAtualizarPreco,
                tooltip: 'Alterar Preço',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: color, size: 20),
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
    );
  }
}

class CriarPlanoDialog extends StatefulWidget {
  final VoidCallback onPlanoCriado;

  const CriarPlanoDialog({super.key, required this.onPlanoCriado});

  @override
  State<CriarPlanoDialog> createState() => _CriarPlanoDialogState();
}

class _CriarPlanoDialogState extends State<CriarPlanoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _precoController = TextEditingController();
  bool _ativo = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _precoController.dispose();
    super.dispose();
  }

  Future<void> _criarPlano() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final precoText =
        _precoController.text.replaceAll('.', '').replaceAll(',', '.');
    final preco = double.tryParse(precoText);

    if (preco == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Formato de preço inválido'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final request = CriarPlanoRequest(
      nome: _nomeController.text.trim(),
      descricao: _descricaoController.text.trim(),
      precoCentavos: (preco * 100).round(),
      ativo: _ativo,
    );

    final response = await PlanoService().criarPlano(request);

    if (response.success) {
      if (mounted) {
        Navigator.pop(context);
        widget.onPlanoCriado();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Plano criado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Erro ao criar plano'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalSheet(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Criar Novo Plano',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nomeController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Nome do Plano',
                labelStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFFF312E)),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nome é obrigatório';
                }
                if (value.trim().length < 3) {
                  return 'Nome deve ter pelo menos 3 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descricaoController,
              style: const TextStyle(color: Colors.white),
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
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Descrição é obrigatória';
                }
                if (value.trim().length < 10) {
                  return 'Descrição deve ter pelo menos 10 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _precoController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
              ],
              onChanged: (value) {
                if (value.contains('.')) {
                  final newValue = value.replaceAll('.', ',');
                  _precoController.value = _precoController.value.copyWith(
                    text: newValue,
                    selection: TextSelection.collapsed(offset: newValue.length),
                  );
                }
              },
              decoration: const InputDecoration(
                labelText: 'Preço (R\$)',
                labelStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFFF312E)),
                ),
                prefixText: 'R\$ ',
                prefixStyle: TextStyle(color: Colors.white),
                hintText: '0,00',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Preço é obrigatório';
                }

                if (value.contains('.')) {
                  return 'Use vírgula (,) como separador decimal';
                }
                final precoText =
                    value.replaceAll('.', '').replaceAll(',', '.');
                final preco = double.tryParse(precoText);
                if (preco == null || preco <= 0) {
                  return 'Preço deve ser maior que zero';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _ativo,
                  onChanged: (value) {
                    setState(() {
                      _ativo = value ?? true;
                    });
                  },
                  checkColor: Colors.white,
                  fillColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.selected)) {
                        return const Color(0xFFFF312E);
                      }
                      return Colors.grey;
                    },
                  ),
                ),
                const Text(
                  'Plano Ativo',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _criarPlano,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF312E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Criar Plano'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EditarPlanoDialog extends StatefulWidget {
  final PlanoResponse plano;
  final VoidCallback onPlanoAtualizado;

  const EditarPlanoDialog({
    super.key,
    required this.plano,
    required this.onPlanoAtualizado,
  });

  @override
  State<EditarPlanoDialog> createState() => _EditarPlanoDialogState();
}

class _EditarPlanoDialogState extends State<EditarPlanoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nomeController.text = widget.plano.nome;
    _descricaoController.text = widget.plano.descricao;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _atualizarPlano() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final request = AtualizarPlanoRequest(
      nome: _nomeController.text.trim(),
      descricao: _descricaoController.text.trim(),
    );

    final response =
        await PlanoService().atualizarPlano(widget.plano.id, request);

    if (response.success) {
      if (mounted) {
        Navigator.pop(context);
        widget.onPlanoAtualizado();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Plano atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Erro ao atualizar plano'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalSheet(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Editar Plano',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nomeController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Nome do Plano',
                labelStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFFF312E)),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nome é obrigatório';
                }
                if (value.trim().length < 3) {
                  return 'Nome deve ter pelo menos 3 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descricaoController,
              style: const TextStyle(color: Colors.white),
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
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Descrição é obrigatória';
                }
                if (value.trim().length < 10) {
                  return 'Descrição deve ter pelo menos 10 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _atualizarPlano,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF312E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Salvar Alterações'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AtualizarPrecoDialog extends StatefulWidget {
  final PlanoResponse plano;
  final VoidCallback onPrecoAtualizado;

  const AtualizarPrecoDialog({
    super.key,
    required this.plano,
    required this.onPrecoAtualizado,
  });

  @override
  State<AtualizarPrecoDialog> createState() => _AtualizarPrecoDialogState();
}

class _AtualizarPrecoDialogState extends State<AtualizarPrecoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _precoController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _precoController.text = (widget.plano.precoCentavos / 100)
        .toStringAsFixed(2)
        .replaceAll('.', ',');
  }

  @override
  void dispose() {
    _precoController.dispose();
    super.dispose();
  }

  Future<void> _atualizarPreco() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final precoText =
        _precoController.text.replaceAll('.', '').replaceAll(',', '.');
    final preco = double.tryParse(precoText);

    if (preco == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Formato de preço inválido'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final precoCentavos = (preco * 100).round();
    final response = await PlanoService()
        .atualizarPrecoPlano(widget.plano.id, precoCentavos);

    if (response.success) {
      if (mounted) {
        Navigator.pop(context);
        widget.onPrecoAtualizado();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preço atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Erro ao atualizar preço'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalSheet(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Atualizar Preço',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Plano: ${widget.plano.nome}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _precoController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              onChanged: (value) {
                if (value.contains('.')) {
                  final newValue = value.replaceAll('.', ',');
                  _precoController.value = _precoController.value.copyWith(
                    text: newValue,
                    selection: TextSelection.collapsed(offset: newValue.length),
                  );
                }
              },
              decoration: const InputDecoration(
                labelText: 'Novo Preço (R\$)',
                labelStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFFF312E)),
                ),
                prefixText: 'R\$ ',
                prefixStyle: TextStyle(color: Colors.white),
                hintText: '0,00',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Preço é obrigatório';
                }

                if (value.contains('.')) {
                  return 'Use vírgula (,) como separador decimal';
                }

                final precoText =
                    value.replaceAll('.', '').replaceAll(',', '.');
                final preco = double.tryParse(precoText);
                if (preco == null || preco <= 0) {
                  return 'Preço deve ser maior que zero';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _atualizarPreco,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF312E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Atualizar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
