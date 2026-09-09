import 'dart:async';

import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../estilo.dart';
import '../models/cliente.dart';
import '../models/memoria.dart';
import 'cadastro_screen.dart';
import 'detalhe_screen.dart';
import 'login_screen.dart';

/// Tela inicial: lista as memorias gastronomicas gravadas no banco, com
/// busca por texto e filtro por tipo de culinaria.
class HomeScreen extends StatefulWidget {
  /// Quem entrou. Fica `null` quando a pessoa escolheu "Acessar como
  /// visitante" - nesse caso a avaliacao e gravada sem dono.
  final Cliente? usuario;

  const HomeScreen({super.key, this.usuario});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _busca = TextEditingController();

  List<Memoria> _memorias = [];
  List<String> _tipos = [];
  Estatisticas _numeros = Estatisticas.vazia;

  String _tipoEscolhido = '';
  bool _carregando = true;
  String? _erro;
  Timer? _esperaDaBusca;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _esperaDaBusca?.cancel();
    _busca.dispose();
    super.dispose();
  }

  /// Le do banco aplicando os filtros ativos. Quem filtra e o SQL, nao a
  /// lista em memoria.
  Future<void> _carregar() async {
    if (!mounted) return;

    try {
      final memorias = await DatabaseHelper.instancia.listarMemorias(
        tipoCulinaria: _tipoEscolhido.isEmpty ? null : _tipoEscolhido,
        termo: _busca.text,
      );
      final tipos = await DatabaseHelper.instancia
          .tiposDeCulinariaCadastrados();
      final numeros = await DatabaseHelper.instancia.estatisticas();

      if (!mounted) return;
      setState(() {
        _memorias = memorias;
        _tipos = tipos;
        _numeros = numeros;
        _carregando = false;
        _erro = null;
      });
    } catch (erro) {
      if (!mounted) return;
      setState(() {
        _carregando = false;
        _erro = '$erro';
      });
    }
  }

  void _aoDigitarBusca(String _) {
    // Espera a pessoa parar de digitar antes de consultar o banco.
    _esperaDaBusca?.cancel();
    _esperaDaBusca = Timer(const Duration(milliseconds: 300), _carregar);
  }

  Future<void> _abrirDetalhe(Memoria memoria) async {
    final mudou = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            DetalheScreen(memoria: memoria, usuario: widget.usuario),
      ),
    );
    if (mudou == true) await _carregar();
  }

  Future<void> _novaMemoria() async {
    final salvou = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CadastroScreen(usuario: widget.usuario),
      ),
    );
    if (salvou == true) await _carregar();
  }

  /// Toque longo no cartao: atalho para editar ou excluir.
  Future<void> _atalhos(Memoria memoria) async {
    final acao = await showModalBottomSheet<String>(
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
            Text(
              memoria.nomeRestaurante,
              style: Fonte.titulo(tamanho: 19),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(
                'Editar memória',
                style: Fonte.corpo(peso: FontWeight.w600),
              ),
              onTap: () => Navigator.pop(folha, 'editar'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Cores.vermelho),
              title: Text(
                'Excluir memória',
                style: Fonte.corpo(peso: FontWeight.w600, cor: Cores.vermelho),
              ),
              onTap: () => Navigator.pop(folha, 'excluir'),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );

    if (!mounted || acao == null) return;

    if (acao == 'editar') {
      final salvou = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) =>
              CadastroScreen(memoria: memoria, usuario: widget.usuario),
        ),
      );
      if (salvou == true) await _carregar();
      return;
    }

    final confirmou = await confirmarExclusao(context, memoria.nomeRestaurante);
    if (confirmou != true || !mounted) return;

    final id = memoria.id;
    if (id != null) await DatabaseHelper.instancia.excluirMemoria(id);
    await _carregar();
    if (!mounted) return;
    aviso(context, 'Memória excluída.');
  }

  /// Botao de perfil do topo: mostra quem entrou e permite sair.
  void _abrirPerfil() {
    final usuario = widget.usuario;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Cores.creme,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (folha) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: const BoxDecoration(
                  color: Cores.terracota,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    usuario == null
                        ? '?'
                        : usuario.primeiroNome.characters.first.toUpperCase(),
                    style: Fonte.titulo(
                      tamanho: 26,
                      cor: Colors.white,
                      peso: 800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                usuario?.nomeUsuario ?? 'Visitante',
                style: Fonte.titulo(tamanho: 21),
              ),
              const SizedBox(height: 4),
              Text(
                usuario?.email ?? 'Você está navegando sem conta',
                style: Fonte.corpo(tamanho: 13, cor: Cores.textoSuave),
              ),
              const SizedBox(height: 22),
              BotaoBranco(
                texto: usuario == null ? 'Entrar em uma conta' : 'Sair',
                icone: usuario == null ? Icons.login : Icons.logout,
                aoTocar: () {
                  Navigator.pop(folha);
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // Interface
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores.creme,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: Cores.terracota,
          onRefresh: _carregar,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _cabecalho()),
              SliverToBoxAdapter(child: _filtros()),
              _lista(),
              const SliverToBoxAdapter(child: SizedBox(height: 90)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _novaMemoria,
        backgroundColor: Cores.terracota,
        foregroundColor: Colors.white,
        tooltip: 'Cadastrar restaurante',
        child: const Icon(Icons.add, size: 28),
      ),
      bottomNavigationBar: const BarraDeBaixo(),
    );
  }

  Widget _cabecalho() {
    final saudacao = widget.usuario?.primeiroNome ?? 'Gastrônomo';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'OLÁ, ${saudacao.toUpperCase()}',
                      style: Fonte.rotulo(tamanho: 10.5),
                    ),
                    const SizedBox(height: 5),
                    // "gastronômicas" em itálico e terracota, como no desenho.
                    RichText(
                      text: TextSpan(
                        style: Fonte.titulo(tamanho: 27),
                        children: [
                          const TextSpan(text: 'Memórias '),
                          TextSpan(
                            text: 'gastronômicas',
                            style: Fonte.titulo(
                              tamanho: 27,
                              cor: Cores.terracota,
                              italico: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              BotaoRedondo(
                icone: Icons.person_outline,
                aoTocar: _abrirPerfil,
                dica: 'Perfil',
              ),
            ],
          ),
          const SizedBox(height: 18),
          _painelDeNumeros(),
          const SizedBox(height: 16),
          TextField(
            controller: _busca,
            onChanged: _aoDigitarBusca,
            textInputAction: TextInputAction.search,
            decoration: campo(
              dica: 'Buscar restaurante ou prato...',
              prefixo: const Icon(
                Icons.search,
                size: 21,
                color: Cores.textoSuave,
              ),
              sufixo: _busca.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close, size: 19),
                      color: Cores.textoSuave,
                      tooltip: 'Limpar busca',
                      onPressed: () {
                        _busca.clear();
                        _carregar();
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// Faixa com os numeros do topo, calculados pelo SQLite.
  Widget _painelDeNumeros() {
    Widget item(IconData icone, String valor, String rotulo) {
      return Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, size: 15, color: Cores.terracota),
            const SizedBox(width: 7),
            Flexible(
              child: RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: valor,
                      style: Fonte.corpo(tamanho: 14.5, peso: FontWeight.w800),
                    ),
                    TextSpan(
                      text: ' $rotulo',
                      style: Fonte.corpo(tamanho: 12.5, cor: Cores.textoSuave),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    const divisor = SizedBox(
      height: 22,
      child: VerticalDivider(width: 1, color: Cores.borda),
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
      decoration: BoxDecoration(
        color: Cores.branco.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(raio),
        border: Border.all(color: Cores.borda),
      ),
      child: Row(
        children: [
          item(
            Icons.storefront_outlined,
            '${_numeros.totalRestaurantes}',
            _numeros.totalRestaurantes == 1 ? 'restaurante' : 'restaurantes',
          ),
          divisor,
          item(Icons.star_border_rounded, _numeros.mediaFormatada, 'média'),
          divisor,
          item(
            Icons.location_on_outlined,
            '${_numeros.totalCidades}',
            _numeros.totalCidades == 1 ? 'cidade' : 'cidades',
          ),
        ],
      ),
    );
  }

  Widget _filtros() {
    // O primeiro chip ("Todos") e representado pelo texto vazio.
    final opcoes = ['', ..._tipos];

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: SizedBox(
        height: 42,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: opcoes.length,
          separatorBuilder: (_, _) => const SizedBox(width: 9),
          itemBuilder: (_, i) {
            final tipo = opcoes[i];
            return ChipFiltro(
              texto: tipo.isEmpty ? 'Todos' : tipo,
              selecionado: _tipoEscolhido == tipo,
              aoTocar: () {
                setState(() => _tipoEscolhido = tipo);
                _carregar();
              },
            );
          },
        ),
      ),
    );
  }

  Widget _lista() {
    if (_carregando) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator(color: Cores.terracota)),
      );
    }

    if (_erro != null) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: ListaVazia(
          icone: Icons.error_outline,
          titulo: 'Erro ao ler o banco',
          descricao: _erro!,
        ),
      );
    }

    if (_memorias.isEmpty) {
      final filtrando = _busca.text.isNotEmpty || _tipoEscolhido.isNotEmpty;

      return SliverFillRemaining(
        hasScrollBody: false,
        child: ListaVazia(
          icone: filtrando ? Icons.search_off : Icons.restaurant_menu,
          titulo: filtrando ? 'Nenhum resultado' : 'Nenhuma memória ainda',
          descricao: filtrando
              ? 'Tente outra busca ou toque em "Todos" para ver tudo.'
              : 'Toque no botão + para registrar o primeiro restaurante que '
                    'marcou o seu paladar.',
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      sliver: SliverList.separated(
        itemCount: _memorias.length,
        separatorBuilder: (_, _) => const SizedBox(height: 16),
        itemBuilder: (_, i) => _Cartao(
          memoria: _memorias[i],
          aoTocar: () => _abrirDetalhe(_memorias[i]),
          aoPressionar: () => _atalhos(_memorias[i]),
        ),
      ),
    );
  }
}

/// Pergunta antes de apagar. Usada aqui e na tela de detalhe.
Future<bool?> confirmarExclusao(BuildContext context, String nome) {
  return showDialog<bool>(
    context: context,
    builder: (dialogo) => AlertDialog(
      title: Text('Excluir memória', style: Fonte.titulo(tamanho: 20)),
      content: Text(
        'Excluir "$nome"? O prato e a avaliação também serão apagados.',
        style: Fonte.corpo(altura: 1.45),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogo, false),
          child: Text('Cancelar', style: Fonte.corpo(cor: Cores.textoSuave)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogo, true),
          child: Text(
            'Excluir',
            style: Fonte.corpo(cor: Cores.vermelho, peso: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

/// Cartao de uma memoria na lista.
class _Cartao extends StatelessWidget {
  final Memoria memoria;
  final VoidCallback aoTocar;
  final VoidCallback aoPressionar;

  const _Cartao({
    required this.memoria,
    required this.aoTocar,
    required this.aoPressionar,
  });

  @override
  Widget build(BuildContext context) {
    final nota = memoria.ranking;

    return Material(
      color: Cores.branco,
      borderRadius: BorderRadius.circular(raioCartao),
      child: InkWell(
        onTap: aoTocar,
        onLongPress: aoPressionar,
        borderRadius: BorderRadius.circular(raioCartao),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(raioCartao),
            border: Border.all(color: Cores.borda),
            boxShadow: sombraSuave,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  FotoPrato(
                    foto: memoria.foto,
                    tipoCulinaria: memoria.tipoCulinaria,
                    altura: 168,
                  ),
                  Positioned(
                    left: 12,
                    top: 12,
                    child: Selo(
                      texto: memoria.tipoCulinaria,
                      icone: Culinaria.iconeDe(memoria.tipoCulinaria),
                      fundo: Cores.creme,
                    ),
                  ),
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Selo(
                      texto: nota.toStringAsFixed(1),
                      icone: Icons.star_rounded,
                      // Nota maxima ganha o selo na cor da marca.
                      fundo: nota == 5
                          ? Cores.terracota
                          : Cores.grafite.withValues(alpha: 0.85),
                      cor: Colors.white,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            memoria.nomeRestaurante,
                            style: Fonte.titulo(tamanho: 20),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Estrelas(nota, tamanho: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Cores.textoSuave,
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            memoria.cidade.isEmpty
                                ? 'Sem cidade'
                                : memoria.cidade,
                            style: Fonte.corpo(
                              tamanho: 13,
                              cor: Cores.textoSuave,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '  ·  ',
                          style: Fonte.corpo(
                            tamanho: 13,
                            cor: Cores.textoSuave,
                          ),
                        ),
                        Flexible(
                          flex: 2,
                          child: Text(
                            memoria.nomePrato,
                            style: Fonte.corpo(
                              tamanho: 13,
                              cor: Cores.terracota,
                              peso: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
}
