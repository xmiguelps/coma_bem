import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../components/botao_customizado.dart';
import '../components/campo_formulario_customizado.dart';
import '../database/database_helper.dart';
import '../estilo.dart';
import '../models/avaliacao.dart';
import '../models/cliente.dart';
import '../models/memoria.dart';
import '../models/prato.dart';
import '../models/restaurante.dart';

/// Cadastro e edicao de uma memoria gastronomica.
///
/// Quando [memoria] vem preenchida a tela entra em modo de edicao e o
/// registro e atualizado (UPDATE) em vez de criado (INSERT).
class CadastroScreen extends StatefulWidget {
  final Memoria? memoria;
  final Cliente? usuario;

  const CadastroScreen({super.key, this.memoria, this.usuario});

  bool get ehEdicao => memoria?.id != null;

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _nome = TextEditingController();
  final _prato = TextEditingController();
  final _cidade = TextEditingController();
  final _preco = TextEditingController();
  final _lat = TextEditingController();
  final _lng = TextEditingController();
  final _recomendacao = TextEditingController();

  final _seletorDeImagem = ImagePicker();

  String _tipoCulinaria = '';
  int _nota = 0;
  String? _foto;
  bool _salvando = false;
  bool _buscandoLocal = false;

  /// Fotos prontas para quem esta testando no computador, onde a camera
  /// nao esta disponivel.
  static const List<String> _fotosDeExemplo = [
    'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?auto=format&fit=crop&w=900&q=70',
    'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=900&q=70',
    'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?auto=format&fit=crop&w=900&q=70',
    'https://images.unsplash.com/photo-1476224203421-9ac39bcb3327?auto=format&fit=crop&w=900&q=70',
    'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?auto=format&fit=crop&w=900&q=70',
    'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=900&q=70',
    'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?auto=format&fit=crop&w=900&q=70',
    'https://images.unsplash.com/photo-1565299507177-b0ac66763828?auto=format&fit=crop&w=900&q=70',
  ];

  @override
  void initState() {
    super.initState();

    // Em modo de edicao, comeca com os dados que ja estao no banco.
    final memoria = widget.memoria;
    if (memoria != null) {
      _nome.text = memoria.nomeRestaurante;
      _prato.text = memoria.nomePrato;
      _cidade.text = memoria.cidade;
      _preco.text = memoria.faixaPreco;
      _lat.text = memoria.latitude.toStringAsFixed(4);
      _lng.text = memoria.longitude.toStringAsFixed(4);
      _recomendacao.text = memoria.recomendacao;
      _tipoCulinaria = memoria.tipoCulinaria;
      _nota = memoria.ranking;
      _foto = memoria.foto;
    }

    // Libera o botao de salvar conforme a pessoa preenche.
    _nome.addListener(_redesenhar);
    _prato.addListener(_redesenhar);
  }

  void _redesenhar() => setState(() {});

  @override
  void dispose() {
    _nome.dispose();
    _prato.dispose();
    _cidade.dispose();
    _preco.dispose();
    _lat.dispose();
    _lng.dispose();
    _recomendacao.dispose();
    super.dispose();
  }

  /// Indica se o formulario esta completo. Usado so para mostrar a dica
  /// abaixo do botao; quem realmente barra a gravacao e [_validar].
  bool get _podeSalvar => _validar() == null;

  /// Validacao de front-end (depuracao preventiva).
  ///
  /// Devolve a mensagem do primeiro problema encontrado ou `null` quando
  /// esta tudo certo. Conferir aqui, antes de tocar no banco, evita que o
  /// SQLite recuse a gravacao e derrube o app: a tabela `restaurante` exige
  /// NOT NULL no nome e no tipo de culinaria, e a tabela `avaliacao` tem
  /// CHECK (avl_nu_ranking BETWEEN 1 AND 5) na nota.
  String? _validar() {
    if (_nome.text.trim().isEmpty || _prato.text.trim().isEmpty) {
      return 'Preencha o nome do restaurante e o nome do prato!';
    }

    if (_tipoCulinaria.isEmpty) {
      return 'Escolha o tipo de culinária do restaurante.';
    }

    // Bug do ranking: as estrelas devolvem 0 quando ninguem avaliou, e 0
    // nao passa no CHECK do banco. O mesmo `if` tambem protege contra um
    // valor acima de 5, caso a nota passe a vir digitada um dia.
    if (_nota < 1 || _nota > 5) {
      return 'O Ranking deve ser uma nota de 1 a 5!';
    }

    return null;
  }

  // ==========================================================================
  // Geolocalizacao
  // ==========================================================================

  /// Le a posicao do aparelho e preenche latitude e longitude.
  Future<void> _usarLocalizacaoAtual() async {
    setState(() => _buscandoLocal = true);

    String? problema;
    Position? posicao;

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        problema = 'Ative a localização do aparelho para usar esta opção.';
      } else {
        var permissao = await Geolocator.checkPermission();
        if (permissao == LocationPermission.denied) {
          permissao = await Geolocator.requestPermission();
        }

        if (permissao == LocationPermission.denied ||
            permissao == LocationPermission.deniedForever) {
          problema = 'Permissão de localização negada.';
        } else {
          posicao = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 20),
            ),
          );
        }
      }
    } catch (_) {
      problema =
          'Não foi possível obter a localização agora. Digite as '
          'coordenadas manualmente.';
    }

    if (!mounted) return;
    setState(() => _buscandoLocal = false);

    if (posicao == null) {
      aviso(context, problema ?? 'Localização indisponível.', erro: true);
      return;
    }

    setState(() {
      _lat.text = posicao!.latitude.toStringAsFixed(4);
      _lng.text = posicao.longitude.toStringAsFixed(4);
    });
    aviso(context, 'Localização atual preenchida.');
  }

  // ==========================================================================
  // Foto do prato
  // ==========================================================================

  Future<void> _escolherFoto() async {
    final opcao = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Cores.creme,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (folha) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Text('Foto do prato', style: Fonte.titulo(tamanho: 19)),
            const SizedBox(height: 6),
            _opcao(folha, Icons.photo_camera_outlined, 'Tirar foto', 'camera'),
            _opcao(
              folha,
              Icons.photo_library_outlined,
              'Escolher da galeria',
              'galeria',
            ),
            _opcao(
              folha,
              Icons.collections_bookmark_outlined,
              'Usar foto de exemplo',
              'exemplo',
            ),
            if (_foto != null)
              _opcao(
                folha,
                Icons.delete_outline,
                'Remover foto',
                'remover',
                cor: Cores.vermelho,
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );

    if (!mounted || opcao == null) return;

    switch (opcao) {
      case 'camera':
        await _capturar(ImageSource.camera);
      case 'galeria':
        await _capturar(ImageSource.gallery);
      case 'exemplo':
        await _escolherExemplo();
      case 'remover':
        setState(() => _foto = null);
    }
  }

  Widget _opcao(
    BuildContext folha,
    IconData icone,
    String texto,
    String valor, {
    Color cor = Cores.texto,
  }) {
    return ListTile(
      leading: Icon(icone, color: cor),
      title: Text(
        texto,
        style: Fonte.corpo(peso: FontWeight.w600, cor: cor),
      ),
      onTap: () => Navigator.pop(folha, valor),
    );
  }

  Future<void> _capturar(ImageSource origem) async {
    try {
      final arquivo = await _seletorDeImagem.pickImage(
        source: origem,
        maxWidth: 1400,
        imageQuality: 78,
      );
      if (arquivo == null) return;

      // A imagem vai para o banco em base64, entao funciona igual no
      // celular, no Windows e no navegador.
      final bytes = await arquivo.readAsBytes();
      if (!mounted) return;
      setState(() => _foto = 'data:image/jpeg;base64,${base64Encode(bytes)}');
    } catch (_) {
      if (!mounted) return;
      aviso(
        context,
        origem == ImageSource.camera
            ? 'A câmera não está disponível aqui. Use a galeria ou uma foto '
                  'de exemplo.'
            : 'Não foi possível abrir a galeria.',
        erro: true,
      );
    }
  }

  Future<void> _escolherExemplo() async {
    final escolhida = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Cores.creme,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (folha) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Fotos de exemplo', style: Fonte.titulo(tamanho: 19)),
              const SizedBox(height: 14),
              SizedBox(
                height: 96,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _fotosDeExemplo.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (_, i) {
                    final url = _fotosDeExemplo[i];
                    return GestureDetector(
                      onTap: () => Navigator.pop(folha, url),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 128,
                          child: FotoPrato(
                            foto: url,
                            tipoCulinaria: _tipoCulinaria,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (escolhida != null && mounted) setState(() => _foto = escolhida);
  }

  // ==========================================================================
  // Gravacao
  // ==========================================================================

  Future<void> _salvar() async {
    // 1. VALIDACAO DE FRONT-END (prevencao de bug)
    // Antes de tentar salvar, conferimos se o basico foi preenchido.
    final problema = _validar();
    if (problema != null) {
      aviso(context, problema, erro: true);
      return; // O `return` encerra a funcao aqui: nada abaixo e executado.
    }

    setState(() => _salvando = true);

    final anterior = widget.memoria;

    // Aceita virgula ou ponto na digitacao das coordenadas.
    double numero(TextEditingController c) =>
        double.tryParse(c.text.trim().replaceAll(',', '.')) ?? 0;

    final restaurante = Restaurante(
      anterior?.restaurante.idRestaurante,
      _nome.text.trim(),
      numero(_lat),
      numero(_lng),
      _tipoCulinaria,
      cidade: _cidade.text.trim(),
      faixaPreco: _preco.text.trim(),
      dataVisita: anterior?.dataVisita ?? DateTime.now(),
    );

    final prato = Prato(
      anterior?.prato.idPrato,
      _prato.text.trim(),
      restaurante.idRestaurante,
      _foto,
    );

    final avaliacao = Avaliacao(
      anterior?.avaliacao.idAvaliacao,
      _nota,
      _recomendacao.text.trim(),
      prato.idPrato,
      anterior?.avaliacao.idUsuario ?? widget.usuario?.idUsuario,
    );

    // 2. BLOCO TRY/CATCH (tratamento de excecoes)
    // `try` significa "tente executar este codigo". Se o SQLite falhar
    // (violacao de CHECK, banco ocupado, disco cheio...), o app nao fecha
    // na cara do usuario: a execucao pula direto para o `catch`.
    try {
      await DatabaseHelper.instancia.salvarMemoria(
        Memoria(restaurante: restaurante, prato: prato, avaliacao: avaliacao),
        idUsuario: widget.usuario?.idUsuario,
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
      aviso(
        context,
        widget.ehEdicao
            ? 'Memória atualizada com sucesso!'
            : 'Memória gastronômica salva!',
      );
    } catch (erro, pilha) {
      // 3. DEPURACAO DE ERROS (catch)
      // debugPrint mostra o erro exato no Debug Console do VS Code, e some
      // sozinho na versao de release (ao contrario do print comum).
      debugPrint('DEBUG - Erro ao salvar no SQLite: $erro');
      debugPrintStack(stackTrace: pilha);

      // Ja o usuario recebe uma mensagem amigavel.
      if (!mounted) return;
      setState(() => _salvando = false);
      aviso(context, 'Ocorreu um erro inesperado ao salvar.', erro: true);
    }
  }

  // ==========================================================================
  // Interface
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores.creme,
      body: SafeArea(
        child: Column(
          children: [
            _cabecalho(),
            const Divider(height: 1, color: Cores.borda),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
                children: [
                  CampoFormularioCustomizado(
                    titulo: 'Nome do restaurante',
                    controlador: _nome,
                    dica: 'Ex: Sushi Nakamura',
                    capitalizacao: TextCapitalization.words,
                    espacoAbaixo: 22,
                  ),

                  const Rotulo('Tipo de culinária'),
                  Wrap(
                    spacing: 9,
                    runSpacing: 9,
                    children: Culinaria.todas.map((c) {
                      return ChipCulinaria(
                        culinaria: c,
                        selecionado: _tipoCulinaria == c.nome,
                        aoTocar: () => setState(
                          () => _tipoCulinaria = _tipoCulinaria == c.nome
                              ? ''
                              : c.nome,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 22),

                  CampoFormularioCustomizado(
                    titulo: 'Nome do prato',
                    controlador: _prato,
                    dica: 'Ex: Tonkotsu Ramen',
                    capitalizacao: TextCapitalization.words,
                    espacoAbaixo: 22,
                  ),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: CampoFormularioCustomizado(
                          titulo: 'Cidade',
                          controlador: _cidade,
                          dica: 'Ex: São Paulo, SP',
                          capitalizacao: TextCapitalization.words,
                          espacoAbaixo: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CampoFormularioCustomizado(
                          titulo: 'Faixa de preço',
                          controlador: _preco,
                          dica: r'Ex: R$ 68-95',
                          espacoAbaixo: 22,
                        ),
                      ),
                    ],
                  ),

                  const Rotulo('Geolocalização'),
                  _coordenadas(),
                  const SizedBox(height: 12),
                  _botaoLocalizacao(),
                  const SizedBox(height: 22),

                  const Rotulo('Ranking (1 a 5 estrelas)'),
                  _cartaoDaNota(),
                  const SizedBox(height: 22),

                  CampoFormularioCustomizado(
                    titulo: 'Recomendação pessoal',
                    controlador: _recomendacao,
                    dica: 'Descreva sua experiência, o que pediu, o que amou…',
                    linhas: 5,
                    capitalizacao: TextCapitalization.sentences,
                    espacoAbaixo: 22,
                  ),

                  const Rotulo('Foto do prato'),
                  _areaDaFoto(),
                  const SizedBox(height: 30),

                  BotaoCustomizado(
                    texto: widget.ehEdicao
                        ? 'Salvar alterações'
                        : 'Salvar restaurante',
                    carregando: _salvando,
                    // O botao fica sempre ativo de proposito: quem avisa o
                    // que falta e o SnackBar de _validar(), que explica o
                    // erro, em vez de um botao apagado sem explicacao.
                    aoTocar: _salvando ? null : _salvar,
                  ),
                  if (!_podeSalvar) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Preencha o nome, o tipo de culinária, o prato e a nota '
                      'para salvar.',
                      textAlign: TextAlign.center,
                      style: Fonte.corpo(tamanho: 12.5, cor: Cores.textoSuave),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cabecalho() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 20, 16),
      child: Row(
        children: [
          BotaoRedondo(
            icone: Icons.arrow_back,
            aoTocar: () => Navigator.pop(context),
            dica: 'Voltar',
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.ehEdicao ? 'Editar memória' : 'Novo Restaurante',
                  style: Fonte.titulo(tamanho: 24),
                ),
                const SizedBox(height: 2),
                Text(
                  'Registre sua experiência gastronômica',
                  style: Fonte.corpo(tamanho: 12.5, cor: Cores.textoSuave),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _coordenadas() {
    Widget umCampo(String rotulo, TextEditingController controlador) {
      return Expanded(
        child: CampoFormularioCustomizado(
          titulo: rotulo,
          controlador: controlador,
          dica: '0.0000',
          mono: true,
          rotuloPequeno: true,
          espacoAbaixo: 0,
          tipoTeclado: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          // So numeros, ponto, virgula e sinal de menos.
          formatadores: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,\-]')),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        umCampo('Latitude', _lat),
        const SizedBox(width: 12),
        umCampo('Longitude', _lng),
      ],
    );
  }

  Widget _botaoLocalizacao() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: Material(
        color: Cores.bege,
        borderRadius: BorderRadius.circular(raio),
        child: InkWell(
          onTap: _buscandoLocal ? null : _usarLocalizacaoAtual,
          borderRadius: BorderRadius.circular(raio),
          child: Center(
            child: _buscandoLocal
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Cores.terracota,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.near_me_outlined,
                        size: 18,
                        color: Cores.texto,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Usar localização atual',
                        style: Fonte.corpo(peso: FontWeight.w600),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _cartaoDaNota() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: cartao(borda: raio),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _nota == 0
                  ? 'Toque para avaliar'
                  : Avaliacao(null, _nota, '', null, null).descricaoRanking,
              style: Fonte.corpo(
                cor: _nota == 0 ? Cores.textoSuave : Cores.texto,
                peso: _nota == 0 ? FontWeight.w400 : FontWeight.w600,
              ),
            ),
          ),
          EstrelasTocaveis(
            nota: _nota,
            tamanho: 28,
            // Tocar na mesma estrela de novo limpa a nota.
            aoTocar: (valor) =>
                setState(() => _nota = _nota == valor ? 0 : valor),
          ),
        ],
      ),
    );
  }

  Widget _areaDaFoto() {
    if (_foto == null) {
      return AreaTracejada(
        aoTocar: _escolherFoto,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.photo_camera_outlined,
              size: 30,
              color: Cores.textoSuave,
            ),
            const SizedBox(height: 10),
            Text(
              'Adicionar foto',
              style: Fonte.corpo(tamanho: 13.5, cor: Cores.textoSuave),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: FotoPrato(
            foto: _foto,
            tipoCulinaria: _tipoCulinaria,
            altura: 170,
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: Row(
            children: [
              BotaoRedondo(
                icone: Icons.edit_outlined,
                tamanho: 36,
                fundo: Colors.black.withValues(alpha: 0.45),
                corIcone: Colors.white,
                aoTocar: _escolherFoto,
                dica: 'Trocar foto',
              ),
              const SizedBox(width: 8),
              BotaoRedondo(
                icone: Icons.close,
                tamanho: 36,
                fundo: Colors.black.withValues(alpha: 0.45),
                corIcone: Colors.white,
                aoTocar: () => setState(() => _foto = null),
                dica: 'Remover foto',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
