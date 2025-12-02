import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/treino.dart';
import '../../services/treino_service.dart';

class ExecutarTreinoPage extends StatefulWidget {
  final Treino treino;
  final String execucaoId;

  const ExecutarTreinoPage({
    super.key,
    required this.treino,
    required this.execucaoId,
  });

  @override
  State<ExecutarTreinoPage> createState() => _ExecutarTreinoPageState();
}

class _ExecutarTreinoPageState extends State<ExecutarTreinoPage> {
  final TreinoService _treinoService = TreinoService();
  int _exercicioAtualIndex = 0;
  int _serieAtual = 1;
  bool _emDescanso = false;
  int _tempoDescanso = 0;
  int _tempoDescansoInicial = 0; // Armazena o tempo inicial do descanso
  Timer? _timerDescanso;
  DateTime? _inicioTreino;
  bool _finalizando = false;

  @override
  void initState() {
    super.initState();
    _inicioTreino = DateTime.now();
  }

  @override
  void dispose() {
    _timerDescanso?.cancel();
    super.dispose();
  }

  ItemTreino get _exercicioAtual => widget.treino.itens[_exercicioAtualIndex];

  int get _totalExercicios => widget.treino.itens.length;
  int get _totalSeries => _exercicioAtual.series;
  double get _progressoGeral => (_exercicioAtualIndex + 1) / _totalExercicios;

  void _iniciarDescanso() {
    if (_exercicioAtual.tempoDescanso == null || 
        _exercicioAtual.tempoDescanso!.isEmpty) {
      _proximaSerie();
      return;
    }

    // Parse tempo de descanso (formato: "60s", "1min", "90")
    String tempoStr = _exercicioAtual.tempoDescanso!.toLowerCase();
    int segundos = 60; // padrão
    
    if (tempoStr.contains('min')) {
      int minutos = int.tryParse(tempoStr.replaceAll('min', '').trim()) ?? 1;
      segundos = minutos * 60;
    } else if (tempoStr.contains('s')) {
      segundos = int.tryParse(tempoStr.replaceAll('s', '').trim()) ?? 60;
    } else {
      segundos = int.tryParse(tempoStr) ?? 60;
    }

    setState(() {
      _emDescanso = true;
      _tempoDescanso = segundos;
      _tempoDescansoInicial = segundos; // Armazena o tempo inicial
    });

    _timerDescanso?.cancel();
    _timerDescanso = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_tempoDescanso > 0) {
        setState(() {
          _tempoDescanso--;
        });
      } else {
        timer.cancel();
        _proximaSerie();
      }
    });
  }

  void _proximaSerie() {
    setState(() {
      _emDescanso = false;
      _timerDescanso?.cancel();
      
      if (_serieAtual < _totalSeries) {
        _serieAtual++;
      } else {
        // Próximo exercício
        if (_exercicioAtualIndex < _totalExercicios - 1) {
          _exercicioAtualIndex++;
          _serieAtual = 1;
        } else {
          // Treino completo
          _finalizarTreino();
        }
      }
    });
  }

  void _pularDescanso() {
    _timerDescanso?.cancel();
    _proximaSerie();
  }

  Future<void> _finalizarTreino() async {
    if (_finalizando) return;
    
    setState(() {
      _finalizando = true;
    });

    final response = await _treinoService.finalizarTreino(widget.execucaoId);
    
    if (mounted) {
      if (response.success) {
        Navigator.of(context).pop(true); // Retorna true indicando que foi finalizado
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Treino finalizado com sucesso! 🎉'),
            backgroundColor: Color(0xFF4CAF50),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        setState(() {
          _finalizando = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Erro ao finalizar treino'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _sairSemFinalizar() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Sair do treino?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'O treino não será marcado como finalizado. Você pode continuar depois.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Fechar dialog
              Navigator.pop(context); // Sair da tela
            },
            child: const Text(
              'Sair',
              style: TextStyle(color: Color(0xFFFF312E)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatarTempo(int segundos) {
    int minutos = segundos ~/ 60;
    int segs = segundos % 60;
    return '${minutos.toString().padLeft(2, '0')}:${segs.toString().padLeft(2, '0')}';
  }

  String _calcularTempoTotal() {
    if (_inicioTreino == null) return '00:00';
    final duracao = DateTime.now().difference(_inicioTreino!);
    final minutos = duracao.inMinutes;
    final segundos = duracao.inSeconds % 60;
    return '${minutos.toString().padLeft(2, '0')}:${segundos.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _sairSemFinalizar();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: _sairSemFinalizar,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.treino.nome,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Exercício ${_exercicioAtualIndex + 1} de $_totalExercicios',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.timer, color: Color(0xFFFF312E), size: 20),
                  const SizedBox(width: 4),
                  Text(
                    _calcularTempoTotal(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Barra de progresso geral
            Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 0),
              child: LinearProgressIndicator(
                value: _progressoGeral,
                backgroundColor: Colors.grey[800],
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF312E)),
              ),
            ),
            
            Expanded(
              child: _emDescanso ? _buildTelaDescanso() : _buildTelaExercicio(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTelaDescanso() {
    // Calcular progresso baseado no tempo inicial armazenado
    final progresso = _tempoDescansoInicial > 0 
        ? 1.0 - (_tempoDescanso / _tempoDescansoInicial)
        : 0.0;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black,
            const Color(0xFF1A1A1A),
            Colors.black,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Título
              const Text(
                'TEMPO DE DESCANSO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 48),
              
              // Timer circular responsivo
              LayoutBuilder(
                builder: (context, constraints) {
                  final size = constraints.maxWidth > 400 
                      ? 280.0 
                      : constraints.maxWidth * 0.7;
                  final fontSize = size * 0.25;
                  final strokeWidth = size * 0.08;
                  
                  return SizedBox(
                    width: size,
                    height: size,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Círculo de fundo
                        Container(
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[900]?.withOpacity(0.3),
                            border: Border.all(
                              color: const Color(0xFFFF312E).withOpacity(0.2),
                              width: 2,
                            ),
                          ),
                        ),
                        // Progresso circular
                        SizedBox(
                          width: size,
                          height: size,
                          child: CircularProgressIndicator(
                            value: progresso,
                            strokeWidth: strokeWidth,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _tempoDescanso <= 5 
                                  ? Colors.orange 
                                  : const Color(0xFFFF312E),
                            ),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        // Tempo no centro
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _formatarTempo(_tempoDescanso),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: fontSize,
                                fontWeight: FontWeight.bold,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'segundos',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: fontSize * 0.3,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 48),
              
              // Indicador visual de progresso
              Container(
                width: double.infinity,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progresso,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF312E),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Botão pular descanso
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _pularDescanso,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: Colors.grey[700]!,
                        width: 1,
                      ),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.skip_next, size: 24),
                      const SizedBox(width: 12),
                      const Text(
                        'PULAR DESCANSO',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Dica
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[900]?.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey[800]!,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.grey[400],
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Aproveite para se hidratar e se preparar para a próxima série',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTelaExercicio() {
    final isUltimoExercicio = _exercicioAtualIndex == _totalExercicios - 1;
    final isUltimaSerie = _serieAtual == _totalSeries;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card do exercício atual
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFF312E).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF312E),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Center(
                        child: Text(
                          '${_exercicioAtualIndex + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _exercicioAtual.exercicioNome ?? 'Exercício',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Série $_serieAtual de $_totalSeries',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoCard(
                      'Séries',
                      '$_serieAtual/$_totalSeries',
                      Icons.repeat,
                    ),
                    _buildInfoCard(
                      'Repetições',
                      _exercicioAtual.repeticoes,
                      Icons.fitness_center,
                    ),
                    if (_exercicioAtual.tempoDescanso != null)
                      _buildInfoCard(
                        'Descanso',
                        _exercicioAtual.tempoDescanso!,
                        Icons.timer,
                      ),
                  ],
                ),
                if (_exercicioAtual.observacao != null &&
                    _exercicioAtual.observacao!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Color(0xFFFF312E),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _exercicioAtual.observacao!,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (_exercicioAtual.exercicioVideoUrl != null &&
                    _exercicioAtual.exercicioVideoUrl!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Mostrar vídeo (implementar se necessário)
                    },
                    icon: const Icon(Icons.play_circle_outline),
                    label: const Text('Ver demonstração'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Botão de ação
          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: _finalizando ? null : () {
                if (isUltimaSerie && isUltimoExercicio) {
                  _finalizarTreino();
                } else {
                  _iniciarDescanso();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isUltimaSerie && isUltimoExercicio
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFFF312E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _finalizando
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      isUltimaSerie && isUltimoExercicio
                          ? 'FINALIZAR TREINO'
                          : 'CONCLUIR SÉRIE',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFFF312E), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

