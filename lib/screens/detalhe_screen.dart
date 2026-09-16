import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../database/database_helper.dart';
import '../components/botao_customizado.dart';
import '../estilo.dart';
import '../models/cliente.dart';
import '../models/memoria.dart';
import 'cadastro_screen.dart';
import 'home_screen.dart' show confirmarExclusao;

/// Detalhe de uma memoria gastronomica.
///
/// Mostra tudo que foi gravado nas tres tabelas (restaurante, prato e
/// avaliacao) e permite reavaliar, editar, compartilhar e excluir.
class DetalheScreen extends StatefulWidget {
  final Memoria memoria;
  final Cliente? usuario;

  const DetalheScreen({super.key, required this.memoria, this.usuario});

  @override
  State<DetalheScreen> createState() => _DetalheScreenState();
}

class _DetalheScreenState extends State<DetalheScreen> {
  late Memoria _memoria = widget.memoria;

  /// Avisa a tela inicial que ela precisa recarregar a lista.
  bool _mudouAlgo = false;

  Future<void> _recarregar() async {
    final id = _memoria.id;
    if (id == null) return;

    final atualizada = await DatabaseHelper.instancia.buscarMemoria(id);
    if (!mounted || atualizada == null) return;
    setState(() => _memoria = atualizada);
  }

  /// Tocar em uma estrela grava a nota nova na hora (UPDATE direto).
  Future<void> _reavaliar(int nota) async {
    final idAvaliacao = _memoria.avaliacao.idAvaliacao;
    if (idAvaliacao == null || nota == _memoria.ranking) return;

    // Mesma protecao da tela de cadastro: a nota tem que respeitar o
    // CHECK (avl_nu_ranking BETWEEN 1 AND 5) da tabela `avaliacao`.
    if (nota < 1 || nota > 5) {
      aviso(context, 'O Ranking deve ser uma nota de 1 a 5!', erro: true);
      return;
    }

    try {
      await DatabaseHelper.instancia.atualizarNota(idAvaliacao, nota);
      _mudouAlgo = true;
      await _recarregar();

      if (!mounted) return;
      aviso(context, 'Nota atualizada para $nota de 5.');
    } catch (erro, pilha) {
      debugPrint('DEBUG - Erro ao atualizar a nota: $erro');
      debugPrintStack(stackTrace: pilha);

      if (!mounted) return;
      aviso(context, 'Não foi possível atualizar a nota.', erro: true);
    }
  }

  Future<void> _editar() async {
    final salvou = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            CadastroScreen(memoria: _memoria, usuario: widget.usuario),
      ),
    );

    if (salvou == true) {
      _mudouAlgo = true;
      await _recarregar();
    }
  }

  Future<void> _compartilhar() async {
    await Clipboard.setData(ClipboardData(text: _memoria.textoCompartilhavel));
    if (!mounted) return;
    aviso(context, 'Memória copiada para a área de transferência.');
  }

  Future<void> _excluir() async {
    final confirmou = await confirmarExclusao(
      context,
      _memoria.nomeRestaurante,
    );
    if (confirmou != true || !mounted) return;

    final id = _memoria.id;
    if (id != null) await DatabaseHelper.instancia.excluirMemoria(id);

    if (!mounted) return;
    Navigator.of(context).pop(true);
    aviso(context, 'Memória excluída.');
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (jaSaiu, _) {
        // Devolve para a tela inicial se houve alteracao.
        if (!jaSaiu) Navigator.of(context).pop(_mudouAlgo);
      },
      child: Scaffold(
        backgroundColor: Cores.creme,
        body: CustomScrollView(
          slivers: [
            _foto(context),
            SliverToBoxAdapter(child: _conteudo()),
          ],
        ),
        bottomNavigationBar: const BarraDeBaixo(),
      ),
    );
  }

  // ==========================================================================
  // Foto do topo
  // ==========================================================================

  Widget _foto(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: false,
      backgroundColor: Cores.terracota,
      automaticallyImplyLeading: false,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            FotoPrato(
              foto: _memoria.foto,
              tipoCulinaria: _memoria.tipoCulinaria,
            ),
            // Escurece o topo para os botoes ficarem legiveis em qualquer foto.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [Color(0x66000000), Colors.transparent],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              top: MediaQuery.of(context).padding.top + 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BotaoRedondo(
                    icone: Icons.arrow_back,
                    fundo: Colors.black.withValues(alpha: 0.42),
                    corIcone: Colors.white,
                    aoTocar: () => Navigator.of(context).pop(_mudouAlgo),
                    dica: 'Voltar',
                  ),
                  Row(
                    children: [
                      BotaoRedondo(
                        icone: Icons.ios_share,
                        fundo: Colors.black.withValues(alpha: 0.42),
                        corIcone: Colors.white,
                        aoTocar: _compartilhar,
                        dica: 'Compartilhar',
                      ),
                      const SizedBox(width: 10),
                      BotaoRedondo(
                        icone: Icons.delete_outline,
                        fundo: Colors.black.withValues(alpha: 0.42),
                        corIcone: Colors.white,
                        aoTocar: _excluir,
                        dica: 'Excluir',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              left: 16,
              bottom: 18,
              child: Selo(
                texto: 'Culinária ${_memoria.tipoCulinaria}',
                icone: Culinaria.iconeDe(_memoria.tipoCulinaria),
                fundo: Cores.terracota,
                cor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // Conteudo
  // ==========================================================================

  Widget _conteudo() {
    return Container(
      // Sobe um pouco para a folha creme cobrir a base da foto.
      transform: Matrix4.translationValues(0, -22, 0),
      decoration: const BoxDecoration(
        color: Cores.creme,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 34),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  _memoria.nomeRestaurante,
                  style: Fonte.titulo(tamanho: 29, altura: 1.15),
                ),
              ),
              const SizedBox(width: 12),
              Selo(
                texto: _memoria.ranking.toStringAsFixed(1),
                icone: Icons.star_rounded,
                fundo: Cores.terracota,
                cor: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _memoria.nomePrato,
            style: Fonte.corpo(
              tamanho: 15.5,
              cor: Cores.terracota,
              peso: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              EstrelasTocaveis(nota: _memoria.ranking, aoTocar: _reavaliar),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _memoria.avaliacao.descricaoRanking,
                  style: Fonte.corpo(tamanho: 12.5, cor: Cores.textoSuave),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          _quatroCartoes(),
          const SizedBox(height: 16),
          _cartaoGeolocalizacao(),
          const SizedBox(height: 16),
          _cartaoRecomendacao(),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: BotaoCustomizado(
                  texto: 'Editar',
                  icone: Icons.edit_outlined,
                  aoTocar: _editar,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 60,
                height: 54,
                child: Material(
                  color: Cores.branco,
                  borderRadius: BorderRadius.circular(raio),
                  child: InkWell(
                    onTap: _compartilhar,
                    borderRadius: BorderRadius.circular(raio),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(raio),
                        border: Border.all(color: Cores.borda),
                      ),
                      child: const Icon(Icons.link, color: Cores.texto),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quatroCartoes() {
    // O IntrinsicHeight da aos dois cartoes da linha a mesma altura. Sem ele,
    // o `stretch` recebe altura infinita dentro da Column e o layout quebra.
    Widget linha(CartaoInfo esquerda, CartaoInfo direita) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: esquerda),
            const SizedBox(width: 12),
            Expanded(child: direita),
          ],
        ),
      );
    }

    return Column(
      children: [
        linha(
          CartaoInfo(
            icone: Icons.calendar_today_outlined,
            rotulo: 'Visitado em',
            valor: _memoria.dataVisitaFormatada,
          ),
          CartaoInfo(
            icone: Icons.local_offer_outlined,
            rotulo: 'Faixa de preço',
            valor: _memoria.faixaPreco.isEmpty
                ? 'Não informada'
                : _memoria.faixaPreco,
          ),
        ),
        const SizedBox(height: 12),
        linha(
          CartaoInfo(
            icone: Icons.location_on_outlined,
            rotulo: 'Cidade',
            valor: _memoria.cidade.isEmpty ? 'Não informada' : _memoria.cidade,
          ),
          CartaoInfo(
            icone: Icons.star_border_rounded,
            rotulo: 'Ranking',
            valor: '${_memoria.ranking} de 5 estrelas',
          ),
        ),
      ],
    );
  }

  Widget _cartaoGeolocalizacao() {
    Widget coordenada(String rotulo, double valor) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Cores.cremeEscuro,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(rotulo, style: Fonte.rotulo(tamanho: 9.5)),
              const SizedBox(height: 6),
              Text('${valor.toStringAsFixed(6)}°', style: Fonte.mono()),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: cartao(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.map_outlined, size: 19, color: Cores.terracota),
              const SizedBox(width: 9),
              Text('Geolocalização', style: Fonte.titulo(tamanho: 18)),
            ],
          ),
          const SizedBox(height: 3),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Text(
              'Coordenadas GPS registradas',
              style: Fonte.corpo(tamanho: 12.5, cor: Cores.textoSuave),
            ),
          ),
          const SizedBox(height: 14),
          MiniMapa(
            latitude: _memoria.latitude,
            longitude: _memoria.longitude,
            etiqueta:
                '${_memoria.latitude.toStringAsFixed(4)}°, '
                '${_memoria.longitude.toStringAsFixed(4)}°',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              coordenada('Latitude', _memoria.latitude),
              const SizedBox(width: 12),
              coordenada('Longitude', _memoria.longitude),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cartaoRecomendacao() {
    final texto = _memoria.recomendacao.trim();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: cartao(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.chat_bubble_outline,
                size: 18,
                color: Cores.terracota,
              ),
              const SizedBox(width: 9),
              Text('Recomendação pessoal', style: Fonte.titulo(tamanho: 18)),
            ],
          ),
          const SizedBox(height: 14),
          if (texto.isEmpty)
            Text(
              'Você ainda não escreveu uma recomendação para este prato. '
              'Toque em Editar para registrar o que achou.',
              style: Fonte.corpo(cor: Cores.textoSuave, altura: 1.5),
            )
          else
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(width: 3, color: Cores.terracota),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.format_quote,
                          size: 18,
                          color: Cores.terracotaClaro,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          texto,
                          style: Fonte.corpo(
                            tamanho: 14.5,
                            altura: 1.55,
                            italico: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 18),
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Cores.cremeEscuro,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline,
                  size: 17,
                  color: Cores.textoSuave,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.usuario?.primeiroNome ?? 'Você',
                    style: Fonte.corpo(tamanho: 13.5, peso: FontWeight.w700),
                  ),
                  Text(
                    _memoria.dataAvaliacaoFormatada,
                    style: Fonte.corpo(tamanho: 11.5, cor: Cores.textoSuave),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
