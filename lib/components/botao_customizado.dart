import 'package:flutter/material.dart';

import '../estilo.dart';

/// Botao principal do aplicativo.
///
/// Antes, cada tela montava o seu proprio `ElevatedButton` repetindo cor,
/// altura e cantos arredondados. Agora todas usam este componente, entao a
/// aparencia dos botoes de Entrar, Salvar e Editar e sempre a mesma.
///
/// Fica terracota quando pode ser usado e bege quando esta bloqueado, que e
/// o comportamento desenhado no prototipo: enquanto o formulario nao esta
/// completo, [aoTocar] vem nulo e o botao aparece apagado.
class BotaoCustomizado extends StatelessWidget {
  /// Texto do botao.
  final String texto;

  /// O que fazer no toque. Passe `null` para deixar o botao bloqueado.
  final VoidCallback? aoTocar;

  /// Icone opcional antes do texto.
  final IconData? icone;

  /// Troca o texto por um indicador de carregamento durante a gravacao.
  final bool carregando;

  const BotaoCustomizado({
    super.key,
    required this.texto,
    this.aoTocar,
    this.icone,
    this.carregando = false,
  });

  @override
  Widget build(BuildContext context) {
    final ativo = aoTocar != null && !carregando;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: Material(
        color: ativo ? Cores.terracota : Cores.bege,
        borderRadius: BorderRadius.circular(raio),
        elevation: ativo ? 1 : 0,
        child: InkWell(
          onTap: ativo ? aoTocar : null,
          borderRadius: BorderRadius.circular(raio),
          child: Center(
            child: carregando
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Cores.textoSuave,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icone != null) ...[
                        Icon(
                          icone,
                          size: 19,
                          color: ativo ? Colors.white : Cores.textoSuave,
                        ),
                        const SizedBox(width: 10),
                      ],
                      Text(
                        texto,
                        style: Fonte.titulo(
                          tamanho: 17,
                          cor: ativo ? Colors.white : Cores.textoSuave,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Botao secundario: branco com contorno.
///
/// Usado quando a acao existe mas nao e a principal da tela, como
/// "Acessar como visitante" no login e "Sair" no perfil.
class BotaoContornado extends StatelessWidget {
  final String texto;
  final IconData? icone;
  final VoidCallback? aoTocar;

  const BotaoContornado({
    super.key,
    required this.texto,
    this.icone,
    this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: Material(
        color: Cores.branco,
        borderRadius: BorderRadius.circular(raio),
        child: InkWell(
          onTap: aoTocar,
          borderRadius: BorderRadius.circular(raio),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(raio),
              border: Border.all(color: Cores.borda),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icone != null) ...[
                  Icon(icone, size: 19, color: Cores.texto),
                  const SizedBox(width: 10),
                ],
                Text(texto, style: Fonte.corpo(peso: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Botao redondo de um icone so: voltar, compartilhar, excluir, perfil.
///
/// Sobre as fotos ele recebe um fundo escuro translucido; sobre o fundo
/// creme, fundo branco com contorno.
class BotaoRedondo extends StatelessWidget {
  final IconData icone;
  final VoidCallback? aoTocar;
  final Color fundo;
  final Color corIcone;
  final double tamanho;

  /// Texto que aparece ao parar o mouse em cima (util no computador) e que
  /// tambem serve de descricao para leitores de tela.
  final String? dica;

  const BotaoRedondo({
    super.key,
    required this.icone,
    this.aoTocar,
    this.fundo = Cores.branco,
    this.corIcone = Cores.texto,
    this.tamanho = 42,
    this.dica,
  });

  @override
  Widget build(BuildContext context) {
    final botao = SizedBox(
      width: tamanho,
      height: tamanho,
      child: Material(
        color: fundo,
        shape: CircleBorder(
          side: fundo == Cores.branco
              ? const BorderSide(color: Cores.borda)
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: aoTocar,
          child: Icon(icone, size: tamanho * 0.46, color: corIcone),
        ),
      ),
    );

    return dica == null ? botao : Tooltip(message: dica!, child: botao);
  }
}
