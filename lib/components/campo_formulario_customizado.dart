import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../estilo.dart';

/// Campo de formulario reutilizavel do Coma Bem.
///
/// Antes da refatoracao, cada campo das telas de login e de cadastro repetia
/// o mesmo bloco: um rotulo em caixa alta, um `TextField` e a mesma
/// `InputDecoration` com as cores do projeto. Agora tudo isso mora aqui e as
/// telas passam a usar uma linha por campo (principio DRY).
///
/// E um `StatelessWidget` porque o visual do campo nao muda por si so: quem
/// guarda o que foi digitado e o [TextEditingController] da tela.
class CampoFormularioCustomizado extends StatelessWidget {
  /// Rotulo mostrado acima do campo (ex.: "NOME DO PRATO").
  final String titulo;

  /// Guarda e devolve o texto digitado.
  final TextEditingController controlador;

  /// Texto cinza de exemplo dentro do campo.
  final String? dica;

  /// Tipo de teclado: texto, e-mail, numero...
  final TextInputType tipoTeclado;

  /// `true` esconde o que foi digitado (campos de senha).
  final bool ocultarTexto;

  /// Quantas linhas o campo ocupa. Acima de 1 vira uma area de texto.
  final int linhas;

  /// Usa fonte de largura fixa, para as coordenadas do GPS.
  final bool mono;

  /// Rotulo menor, usado nos sub-campos de latitude e longitude.
  final bool rotuloPequeno;

  /// Icone ou botao no canto direito (ex.: o olho que mostra a senha).
  final Widget? sufixo;

  /// Mensagem de erro em vermelho abaixo do campo.
  final String? erro;

  /// Deixa a primeira letra maiuscula automaticamente.
  final TextCapitalization capitalizacao;

  /// Botao de confirmacao do teclado (proximo, buscar, concluir...).
  final TextInputAction? acaoDoTeclado;

  /// Chamado quando a pessoa confirma no teclado.
  final ValueChanged<String>? aoEnviar;

  /// Filtra o que pode ser digitado (ex.: so numeros e sinal de menos).
  final List<TextInputFormatter>? formatadores;

  /// A correcao automatica atrapalha em e-mail; por isso pode ser desligada.
  final bool corrigirTexto;

  /// Espaco livre depois do campo, para as telas nao precisarem de SizedBox.
  final double espacoAbaixo;

  const CampoFormularioCustomizado({
    super.key,
    required this.titulo,
    required this.controlador,
    this.dica,
    this.tipoTeclado = TextInputType.text,
    this.ocultarTexto = false,
    this.linhas = 1,
    this.mono = false,
    this.rotuloPequeno = false,
    this.sufixo,
    this.erro,
    this.capitalizacao = TextCapitalization.none,
    this.acaoDoTeclado,
    this.aoEnviar,
    this.formatadores,
    this.corrigirTexto = true,
    this.espacoAbaixo = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: espacoAbaixo),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo.toUpperCase(),
            style: rotuloPequeno ? Fonte.rotulo(tamanho: 9.5) : Fonte.rotulo(),
          ),
          SizedBox(height: rotuloPequeno ? 6 : 8),
          TextField(
            controller: controlador,
            keyboardType: tipoTeclado,
            obscureText: ocultarTexto,
            maxLines: ocultarTexto ? 1 : linhas,
            style: mono ? Fonte.mono() : null,
            autocorrect: corrigirTexto,
            textCapitalization: capitalizacao,
            textInputAction: acaoDoTeclado,
            onSubmitted: aoEnviar,
            inputFormatters: formatadores,
            // A aparencia (fundo branco, cantos e cor da borda em foco) vem
            // do `campo()` em estilo.dart, usado por todo o aplicativo.
            decoration: campo(
              dica: dica,
              sufixo: sufixo,
              mono: mono,
            ).copyWith(errorText: erro),
          ),
        ],
      ),
    );
  }
}
