import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../services/treino_service.dart';
import '../../models/treino.dart';

// Para web - imports condicionais
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html if (dart.library.html) 'dart:html';
// ignore: avoid_web_libraries_in_flutter  
import 'dart:ui_web' as ui_web if (dart.library.html) 'dart:ui_web';

class MeusTreinosPage extends StatefulWidget {
  const MeusTreinosPage({super.key});

  @override
  State<MeusTreinosPage> createState() => _MeusTreinosPageState();
}

class _MeusTreinosPageState extends State<MeusTreinosPage> {
  final TreinoService _treinoService = TreinoService();
  List<Treino> _treinos = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _carregarTreinos();
  }

  Future<void> _carregarTreinos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Para CUSTOMER, o backend já filtra automaticamente pelos treinos do usuário logado
    final response = await _treinoService.listarTodos();

    if (response.success && response.data != null) {
      setState(() {
        _treinos = response.data!;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = response.message ?? 'Erro ao carregar treinos';
        _isLoading = false;
      });
    }
  }

  List<Treino> get _treinosFiltrados {
    if (_searchQuery.isEmpty) {
      return _treinos;
    }
    return _treinos.where((treino) {
      final nome = treino.nome.toLowerCase();
      final descricao = treino.descricao?.toLowerCase() ?? '';
      final nivel = treino.nivel?.toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return nome.contains(query) ||
          descricao.contains(query) ||
          nivel.contains(query);
    }).toList();
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
          'Meus Treinos',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar treinos...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
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
          // Content
          Expanded(
            child: _isLoading
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
                              onPressed: _carregarTreinos,
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
                    : _treinosFiltrados.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _searchQuery.isNotEmpty
                                      ? Icons.search_off
                                      : Icons.fitness_center,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isNotEmpty
                                      ? 'Nenhum treino encontrado'
                                      : 'Nenhum treino cadastrado',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (_searchQuery.isEmpty) ...[
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Seu personal trainer ainda não criou treinos para você.',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _carregarTreinos,
                            color: const Color(0xFFFF312E),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _treinosFiltrados.length,
                              itemBuilder: (context, index) {
                                final treino = _treinosFiltrados[index];
                                return _buildTreinoCard(treino);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  void _mostrarVideo(String videoUrl) {
    showDialog(
      context: context,
      builder: (context) => _VideoDialog(videoUrl: videoUrl),
    );
  }

  Widget _buildTreinoCard(Treino treino) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        iconColor: const Color(0xFFFF312E),
        collapsedIconColor: Colors.grey,
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    treino.nome,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (treino.tipoTreino != null && treino.tipoTreino!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        treino.tipoTreino!,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (treino.descricao != null && treino.descricao!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                treino.descricao!,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (treino.nivel != null && treino.nivel!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF312E).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  treino.nivel!,
                  style: const TextStyle(
                    color: Color(0xFFFF312E),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            if (treino.itens.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.fitness_center,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${treino.itens.length} ${treino.itens.length == 1 ? 'exercício' : 'exercícios'}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        children: [
          if (treino.descricao != null && treino.descricao!.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                treino.descricao!,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
          ],
          if (treino.itens.isNotEmpty) ...[
            const Divider(color: Colors.grey),
            const SizedBox(height: 12),
            const Text(
              'Exercícios:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...treino.itens.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF312E),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            '${item.ordem}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.exercicioNome ?? 'Exercício',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (item.exercicioVideoUrl != null &&
                                    item.exercicioVideoUrl!.isNotEmpty)
                                  IconButton(
                                    onPressed: () => _mostrarVideo(item.exercicioVideoUrl!),
                                    icon: const Icon(
                                      Icons.play_circle_outline,
                                      color: Color(0xFFFF312E),
                                      size: 28,
                                    ),
                                    tooltip: 'Ver vídeo do exercício',
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.series} séries x ${item.repeticoes}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                            if (item.tempoDescanso != null &&
                                item.tempoDescanso!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  'Descanso: ${item.tempoDescanso}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            if (item.observacao != null &&
                                item.observacao!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  item.observacao!,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}

// Dialog para exibir vídeo do exercício
class _VideoDialog extends StatelessWidget {
  final String videoUrl;

  const _VideoDialog({required this.videoUrl});

  bool _isImageOrGif(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.endsWith('.gif') ||
        lowerUrl.endsWith('.jpg') ||
        lowerUrl.endsWith('.jpeg') ||
        lowerUrl.endsWith('.png') ||
        lowerUrl.endsWith('.webp') ||
        lowerUrl.contains('.gif') ||
        lowerUrl.contains('image/');
  }

  String _getEmbedUrl(String url) {
    // Se for imagem ou GIF, retornar a URL original
    if (_isImageOrGif(url)) {
      return url;
    }
    
    // Se for YouTube
    if (url.contains('youtube.com/watch?v=')) {
      final videoId = url.split('v=')[1].split('&')[0];
      return 'https://www.youtube.com/embed/$videoId';
    }
    // Se for YouTube short link
    if (url.contains('youtu.be/')) {
      final videoId = url.split('youtu.be/')[1].split('?')[0];
      return 'https://www.youtube.com/embed/$videoId';
    }
    // Se for Vimeo
    if (url.contains('vimeo.com/')) {
      final videoId = url.split('vimeo.com/')[1].split('?')[0];
      return 'https://player.vimeo.com/video/$videoId';
    }
    // Se já for uma URL de embed, retornar como está
    if (url.contains('embed') || url.contains('player')) {
      return url;
    }
    // Caso contrário, tentar usar como iframe direto
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final embedUrl = _getEmbedUrl(videoUrl);
    final isImage = _isImageOrGif(videoUrl);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    isImage ? 'Demonstração do Exercício' : 'Vídeo do Exercício',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
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
            // Video/Image player
            isImage
                ? Container(
                    constraints: const BoxConstraints(
                      maxHeight: 500,
                      maxWidth: double.infinity,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        embedUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 300,
                            color: Colors.black,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFFF312E),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 300,
                            color: Colors.black,
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 48,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Erro ao carregar imagem',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                : AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      color: Colors.black,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _buildVideoPlayer(embedUrl),
                      ),
                    ),
                  ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer(String embedUrl) {
    if (kIsWeb) {
      // Para web, criar iframe HTML
      final String viewType = 'iframe-${embedUrl.hashCode}';
      
      // Registrar o viewType (registrar sempre, pois pode ser reutilizado)
      ui_web.platformViewRegistry.registerViewFactory(
        viewType,
        (int viewId) {
          final iframe = html.IFrameElement()
            ..src = embedUrl
            ..style.border = 'none'
            ..style.width = '100%'
            ..style.height = '100%'
            ..allowFullscreen = true
            ..allow = 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture';
          return iframe;
        },
      );
      
      // Usar HtmlElementView do Flutter (disponível apenas em web)
      return SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: HtmlElementView(viewType: viewType),
      );
    } else {
      // Para mobile, mostrar botão para abrir em navegador
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.play_circle_filled,
                size: 64,
                color: Color(0xFFFF312E),
              ),
              const SizedBox(height: 16),
              const Text(
                'Vídeo disponível',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  // Abrir vídeo em navegador externo
                  // Usar url_launcher package se necessário
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF312E),
                ),
                child: const Text(
                  'Abrir vídeo',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}

