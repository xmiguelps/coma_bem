import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';

// ============================================================================
// O VISUAL DO COMA BEM
//
// Este arquivo guarda tudo que as telas usam em comum: as cores da marca, as
// fontes, a aparencia dos campos e os pedacos de tela que se repetem
// (estrelas, botoes, cartoes, barra de baixo...). Assim, mudar uma cor aqui
// muda o aplicativo inteiro.
// ============================================================================

/// Cores da marca.
class Cores {
  Cores._();

  static const terracota = Color(0xFFC25B2C);
  static const terracotaEscuro = Color(0xFFA84B22);
  static const terracotaClaro = Color(0xFFD9784C);

  static const creme = Color(0xFFF9F1E9);
  static const cremeEscuro = Color(0xFFEFE2D4);
  static const bege = Color(0xFFEDE0D2);

  static const branco = Color(0xFFFFFFFF);
  static const texto = Color(0xFF1F1A16);
  static const textoSuave = Color(0xFF8A7B6E);
  static const borda = Color(0xFFE8DACA);
  static const ouro = Color(0xFFE0A32E);
  static const grafite = Color(0xFF2B2320);
  static const vermelho = Color(0xFFA5372B);
  static const mapaFundo = Color(0xFFE7EFE4);
  static const mapaGrade = Color(0xFFCFDDCA);
}

/// Estilos de texto.
///
/// Os titulos usam a Playfair (a fonte serifada de `assets/fonts`). Como o
/// arquivo e uma fonte variavel, o peso precisa ir tambem pelo eixo `wght`
/// para renderizar igual no celular, no Windows e no navegador.
class Fonte {
  Fonte._();

  static TextStyle titulo({
    double tamanho = 24,
    Color cor = Cores.texto,
    int peso = 700,
    bool italico = false,
    double? altura,
  }) {
    return TextStyle(
      fontFamily: 'Playfair',
      fontSize: tamanho,
      color: cor,
      height: altura,
      fontStyle: italico ? FontStyle.italic : FontStyle.normal,
      fontWeight: FontWeight.values[(peso ~/ 100).clamp(1, 9) - 1],
      fontVariations: [FontVariation('wght', peso.toDouble())],
    );
  }

  /// Rotulo em caixa alta e espacado (ex.: "NOME DO PRATO").
  static TextStyle rotulo({double tamanho = 11, Color cor = Cores.textoSuave}) {
    return TextStyle(
      fontSize: tamanho,
      color: cor,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.3,
    );
  }

  static TextStyle corpo({
    double tamanho = 14,
    Color cor = Cores.texto,
    FontWeight peso = FontWeight.w400,
    double? altura,
    bool italico = false,
  }) {
    return TextStyle(
      fontSize: tamanho,
      color: cor,
      fontWeight: peso,
      height: altura,
      fontStyle: italico ? FontStyle.italic : FontStyle.normal,
    );
  }

  /// Coordenadas, em fonte de largura fixa.
  static TextStyle mono({double tamanho = 14, Color cor = Cores.texto}) {
    return TextStyle(
      fontFamily: 'monospace',
      fontFamilyFallback: const ['Consolas', 'Courier New'],
      fontSize: tamanho,
      color: cor,
      fontWeight: FontWeight.w500,
    );
  }
}

const double raio = 14;
const double raioCartao = 18;

const List<BoxShadow> sombraSuave = [
  BoxShadow(color: Color(0x0F3B2A1E), blurRadius: 12, offset: Offset(0, 4)),
];

/// Fundo branco arredondado usado nos cartoes.
BoxDecoration cartao({double borda = raioCartao, Color cor = Cores.branco}) {
  return BoxDecoration(
    color: cor,
    borderRadius: BorderRadius.circular(borda),
    border: Border.all(color: Cores.borda),
    boxShadow: sombraSuave,
  );
}

/// Aparencia dos campos de texto brancos de todos os formularios.
InputDecoration campo({
  String? dica,
  Widget? prefixo,
  Widget? sufixo,
  bool mono = false,
}) {
  OutlineInputBorder linha(Color cor, [double largura = 1]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(raio),
      borderSide: BorderSide(color: cor, width: largura),
    );
  }

  return InputDecoration(
    hintText: dica,
    hintStyle: mono
        ? Fonte.mono(cor: Cores.textoSuave)
        : Fonte.corpo(cor: Cores.textoSuave),
    prefixIcon: prefixo,
    suffixIcon: sufixo,
    filled: true,
    fillColor: Cores.branco,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    enabledBorder: linha(Cores.borda),
    border: linha(Cores.borda),
    focusedBorder: linha(Cores.terracota, 1.5),
    errorBorder: linha(Cores.vermelho),
    focusedErrorBorder: linha(Cores.vermelho, 1.5),
  );
}

/// Tipos de culinaria aceitos, com o icone de cada um.
class Culinaria {
  final String nome;
  final IconData icone;
  const Culinaria(this.nome, this.icone);

  static const List<Culinaria> todas = [
    Culinaria('Japonesa', Icons.ramen_dining),
    Culinaria('Italiana', Icons.local_pizza),
    Culinaria('Francesa', Icons.wine_bar),
    Culinaria('Brasileira', Icons.outdoor_grill),
    Culinaria('Mexicana', Icons.local_fire_department),
    Culinaria('Árabe', Icons.kebab_dining),
  ];

  static IconData iconeDe(String tipo) {
    final alvo = tipo.trim().toLowerCase();
    for (final c in todas) {
      if (c.nome.toLowerCase() == alvo) return c.icone;
    }
    return Icons.restaurant_menu;
  }
}

/// Mensagem curta na parte de baixo da tela.
void aviso(BuildContext context, String mensagem, {bool erro = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: erro ? Cores.vermelho : Cores.grafite,
      ),
    );
}

// ============================================================================
// PEDACOS DE TELA REUTILIZADOS
// ============================================================================

/// Rotulo em caixa alta acima de cada campo.
class Rotulo extends StatelessWidget {
  final String texto;
  const Rotulo(this.texto, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(texto.toUpperCase(), style: Fonte.rotulo()),
    );
  }
}

/// Estrelas so para ler.
class Estrelas extends StatelessWidget {
  final int nota;
  final double tamanho;
  const Estrelas(this.nota, {super.key, this.tamanho = 16});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final cheia = i < nota;
        return Icon(
          cheia ? Icons.star_rounded : Icons.star_border_rounded,
          size: tamanho,
          color: cheia ? Cores.ouro : Cores.borda,
        );
      }),
    );
  }
}

/// Estrelas em que o usuario toca para dar a nota.
class EstrelasTocaveis extends StatelessWidget {
  final int nota;
  final ValueChanged<int> aoTocar;
  final double tamanho;

  const EstrelasTocaveis({
    super.key,
    required this.nota,
    required this.aoTocar,
    this.tamanho = 30,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final valor = i + 1;
        final cheia = valor <= nota;
        return Semantics(
          button: true,
          label: 'Dar nota $valor de 5',
          child: InkWell(
            onTap: () => aoTocar(valor),
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Icon(
                cheia ? Icons.star_rounded : Icons.star_border_rounded,
                size: tamanho,
                color: cheia ? Cores.ouro : Cores.textoSuave,
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// Mostra a foto do prato.
///
/// Aceita um endereco `http`, uma imagem em base64 (`data:image/...`) tirada
/// pela camera/galeria, ou nada. Em qualquer falha desenha um fundo com a cor
/// da marca e o icone da culinaria, para nunca aparecer quadrado quebrado.
class FotoPrato extends StatelessWidget {
  final String? foto;
  final String tipoCulinaria;
  final double? altura;

  const FotoPrato({
    super.key,
    required this.foto,
    this.tipoCulinaria = '',
    this.altura,
  });

  @override
  Widget build(BuildContext context) {
    final endereco = foto?.trim() ?? '';
    Widget conteudo;

    if (endereco.startsWith('http')) {
      conteudo = Image.network(
        endereco,
        height: altura,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _reserva(),
        loadingBuilder: (_, filho, progresso) =>
            progresso == null ? filho : _carregando(),
      );
    } else if (endereco.startsWith('data:')) {
      try {
        conteudo = Image.memory(
          base64Decode(endereco.split(',').last),
          height: altura,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _reserva(),
        );
      } catch (_) {
        conteudo = _reserva();
      }
    } else {
      conteudo = _reserva();
    }

    return SizedBox(height: altura, width: double.infinity, child: conteudo);
  }

  Widget _carregando() => Container(
    height: altura,
    color: Cores.cremeEscuro,
    child: const Center(
      child: SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Cores.terracota,
        ),
      ),
    ),
  );

  Widget _reserva() => Container(
    height: altura,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Cores.terracotaClaro, Cores.terracotaEscuro],
      ),
    ),
    child: Center(
      child: Icon(
        Culinaria.iconeDe(tipoCulinaria),
        size: 40,
        color: Colors.white.withValues(alpha: 0.75),
      ),
    ),
  );
}

// Os botoes (BotaoCustomizado, BotaoContornado e BotaoRedondo) e o campo
// de formulario (CampoFormularioCustomizado) ficam em lib/components/.

/// Pilula de filtro da tela inicial ("Todos", "Japonesa"...).
class ChipFiltro extends StatelessWidget {
  final String texto;
  final bool selecionado;
  final VoidCallback aoTocar;

  const ChipFiltro({
    super.key,
    required this.texto,
    required this.selecionado,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selecionado ? Cores.terracota : Cores.branco,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: aoTocar,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selecionado ? Cores.terracota : Cores.borda,
            ),
          ),
          child: Text(
            texto,
            style: Fonte.corpo(
              tamanho: 13.5,
              peso: FontWeight.w600,
              cor: selecionado ? Colors.white : Cores.texto,
            ),
          ),
        ),
      ),
    );
  }
}

/// Chip com icone da escolha do tipo de culinaria no cadastro.
class ChipCulinaria extends StatelessWidget {
  final Culinaria culinaria;
  final bool selecionado;
  final VoidCallback aoTocar;

  const ChipCulinaria({
    super.key,
    required this.culinaria,
    required this.selecionado,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    final cor = selecionado ? Colors.white : Cores.texto;

    return Material(
      color: selecionado ? Cores.terracota : Cores.branco,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: aoTocar,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selecionado ? Cores.terracota : Cores.borda,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(culinaria.icone, size: 17, color: cor),
              const SizedBox(width: 8),
              Text(
                culinaria.nome,
                style: Fonte.corpo(
                  tamanho: 13.5,
                  peso: FontWeight.w600,
                  cor: cor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Selo que fica por cima da foto do prato.
class Selo extends StatelessWidget {
  final String texto;
  final IconData? icone;
  final Color fundo;
  final Color cor;

  const Selo({
    super.key,
    required this.texto,
    this.icone,
    this.fundo = Cores.branco,
    this.cor = Cores.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(20),
        boxShadow: sombraSuave,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icone != null) ...[
            Icon(icone, size: 14, color: cor),
            const SizedBox(width: 6),
          ],
          Text(
            texto,
            style: Fonte.corpo(tamanho: 12.5, peso: FontWeight.w700, cor: cor),
          ),
        ],
      ),
    );
  }
}

/// Cartao pequeno da tela de detalhe (VISITADO EM, CIDADE...).
class CartaoInfo extends StatelessWidget {
  final IconData icone;
  final String rotulo;
  final String valor;

  const CartaoInfo({
    super.key,
    required this.icone,
    required this.rotulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: cartao(borda: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icone, size: 14, color: Cores.terracota),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  rotulo.toUpperCase(),
                  style: Fonte.rotulo(tamanho: 9.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            valor,
            style: Fonte.corpo(tamanho: 14.5, peso: FontWeight.w700),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

/// Mapa desenhado a mao com o pino da coordenada gravada.
///
/// Nao usa servico externo nem chave de API: e so um desenho que ilustra o
/// ponto guardado nas colunas de latitude e longitude.
class MiniMapa extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String etiqueta;

  const MiniMapa({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.etiqueta,
  });

  @override
  Widget build(BuildContext context) {
    // A parte quebrada da coordenada desloca o pino, entao lugares
    // diferentes aparecem em posicoes diferentes do desenho.
    double posicao(double valor) => (0.25 + (valor.abs() % 1) * 0.5) * 2 - 1;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 152,
        width: double.infinity,
        color: Cores.mapaFundo,
        child: Stack(
          children: [
            const Positioned.fill(child: CustomPaint(painter: GradeDeMapa())),
            Align(
              alignment: Alignment(posicao(longitude), posicao(latitude)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: const BoxDecoration(
                      color: Cores.terracota,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Cores.grafite,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      etiqueta,
                      style: Fonte.mono(tamanho: 11, cor: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Area tracejada de "Adicionar foto".
class AreaTracejada extends StatelessWidget {
  final Widget child;
  final VoidCallback? aoTocar;

  const AreaTracejada({super.key, required this.child, this.aoTocar});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: aoTocar,
      borderRadius: BorderRadius.circular(16),
      child: CustomPaint(
        // foregroundPainter desenha DEPOIS do filho. Com `painter` o fundo
        // branco do container cobriria o tracejado.
        foregroundPainter: const BordaTracejada(),
        child: Container(
          height: 130,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Cores.branco,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

/// Barra de baixo do design: icones vazados e um pontinho no item ativo.
///
/// Só a aba Início tem tela nesta versão; as outras avisam que ainda não
/// fazem parte do protótipo.
class BarraDeBaixo extends StatelessWidget {
  final int indiceAtivo;
  final ValueChanged<int>? aoTocar;

  static const List<(IconData, String)> itens = [
    (Icons.home_outlined, 'Início'),
    (Icons.map_outlined, 'Mapa'),
    (Icons.bar_chart_rounded, 'Ranking'),
    (Icons.person_outline, 'Perfil'),
  ];

  const BarraDeBaixo({super.key, this.indiceAtivo = 0, this.aoTocar});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Cores.creme,
        border: Border(top: BorderSide(color: Cores.borda)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(itens.length, (i) {
              final (icone, texto) = itens[i];
              final ativo = i == indiceAtivo;
              final cor = ativo ? Cores.terracota : Cores.textoSuave;

              return Expanded(
                child: InkWell(
                  onTap: () {
                    if (aoTocar != null) {
                      aoTocar!(i);
                    } else if (!ativo) {
                      aviso(
                        context,
                        '$texto ainda não faz parte desta versão.',
                      );
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icone, size: 23, color: cor),
                      const SizedBox(height: 4),
                      Text(
                        texto.toUpperCase(),
                        style: Fonte.rotulo(tamanho: 9, cor: cor),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ativo ? Cores.terracota : Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

/// Aviso de lista vazia.
class ListaVazia extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String descricao;

  const ListaVazia({
    super.key,
    this.icone = Icons.restaurant_menu,
    required this.titulo,
    required this.descricao,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Cores.cremeEscuro,
                shape: BoxShape.circle,
              ),
              child: Icon(icone, size: 34, color: Cores.terracota),
            ),
            const SizedBox(height: 18),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: Fonte.titulo(tamanho: 20),
            ),
            const SizedBox(height: 8),
            Text(
              descricao,
              textAlign: TextAlign.center,
              style: Fonte.corpo(cor: Cores.textoSuave, altura: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// DESENHOS (CustomPainter / CustomClipper)
// ============================================================================

/// Textura de pontinhos do fundo da splash e do cabecalho do login.
class Pontilhado extends CustomPainter {
  final double espacamento;
  const Pontilhado({this.espacamento = 22});

  @override
  void paint(Canvas canvas, Size size) {
    final tinta = Paint()..color = const Color(0x1FFFFFFF);
    for (double y = espacamento / 2; y < size.height; y += espacamento) {
      for (double x = espacamento / 2; x < size.width; x += espacamento) {
        canvas.drawCircle(Offset(x, y), 1.4, tinta);
      }
    }
  }

  @override
  bool shouldRepaint(Pontilhado antigo) => antigo.espacamento != espacamento;
}

/// Manchas claras e escuras que dao profundidade ao fundo da splash.
class BrilhosDeFundo extends CustomPainter {
  const BrilhosDeFundo();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, -size.height * 0.18),
        width: size.width * 1.9,
        height: size.height * 0.62,
      ),
      Paint()..color = const Color(0x14FFFFFF),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.75, size.height * 1.08),
        width: size.width * 1.7,
        height: size.height * 0.5,
      ),
      Paint()..color = const Color(0x0F000000),
    );
  }

  @override
  bool shouldRepaint(BrilhosDeFundo antigo) => false;
}

/// Curva do cabecalho do login: a borda de baixo desce mais no meio.
class CurvaCabecalho extends CustomClipper<Path> {
  const CurvaCabecalho();

  @override
  Path getClip(Size size) {
    const profundidade = 46.0;
    return Path()
      ..lineTo(0, size.height - profundidade)
      ..quadraticBezierTo(
        size.width / 2,
        size.height + profundidade * 0.75,
        size.width,
        size.height - profundidade,
      )
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(CurvaCabecalho antigo) => false;
}

/// Grade do mini mapa.
class GradeDeMapa extends CustomPainter {
  const GradeDeMapa();

  @override
  void paint(Canvas canvas, Size size) {
    final grade = Paint()
      ..color = Cores.mapaGrade
      ..strokeWidth = 1;

    const passo = 34.0;
    for (double x = passo; x < size.width; x += passo) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grade);
    }
    for (double y = passo; y < size.height; y += passo) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grade);
    }

    // Duas avenidas mais largas, para o mapa nao ficar uniforme.
    final avenida = Paint()
      ..color = Cores.mapaGrade
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(0, size.height * 0.68),
      Offset(size.width, size.height * 0.52),
      avenida,
    );
    canvas.drawLine(
      Offset(size.width * 0.28, 0),
      Offset(size.width * 0.4, size.height),
      avenida,
    );
  }

  @override
  bool shouldRepaint(GradeDeMapa antigo) => false;
}

/// Borda tracejada da area "Adicionar foto".
class BordaTracejada extends CustomPainter {
  const BordaTracejada();

  @override
  void paint(Canvas canvas, Size size) {
    final tinta = Paint()
      ..color = const Color(0xFFD6C3AE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.butt;

    final contorno = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0.8, 0.8, size.width - 1.6, size.height - 1.6),
          const Radius.circular(16),
        ),
      );

    for (final metrica in contorno.computeMetrics()) {
      double andado = 0;
      while (andado < metrica.length) {
        final fim = math.min(andado + 8, metrica.length);
        canvas.drawPath(metrica.extractPath(andado, fim), tinta);
        andado = fim + 7;
      }
    }
  }

  @override
  bool shouldRepaint(BordaTracejada antigo) => false;
}
