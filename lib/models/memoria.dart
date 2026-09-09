import 'avaliacao.dart';
import 'prato.dart';
import 'restaurante.dart';

/// Uma "memoria gastronomica": o registro completo que o usuario ve na tela.
///
/// Ela agrega as tres tabelas relacionadas do banco (`restaurante`, `prato` e
/// `avaliacao`) em um unico objeto, montado a partir do SELECT com INNER JOIN
/// executado pelo [DatabaseHelper].
class Memoria {
  final Restaurante restaurante;
  final Prato prato;
  final Avaliacao avaliacao;

  const Memoria({
    required this.restaurante,
    required this.prato,
    required this.avaliacao,
  });

  int? get id => restaurante.idRestaurante;
  String get nomeRestaurante => restaurante.nomeRestaurante;
  String get tipoCulinaria => restaurante.tipoCulinaria;
  String get cidade => restaurante.cidade;
  String get faixaPreco => restaurante.faixaPreco;
  double get latitude => restaurante.latitude;
  double get longitude => restaurante.longitude;
  DateTime get dataVisita => restaurante.dataVisita;

  String get nomePrato => prato.nomePrato;
  String? get foto => prato.foto;

  int get ranking => avaliacao.ranking;
  String get recomendacao => avaliacao.recomendacao;

  /// Monta a memoria a partir de uma linha do JOIN entre as tres tabelas.
  factory Memoria.doMapa(Map<String, dynamic> mapa) {
    return Memoria(
      restaurante: Restaurante.doMapa(mapa),
      prato: Prato.doMapa(mapa),
      avaliacao: Avaliacao.doMapa(mapa),
    );
  }

  /// Data no formato "12 Ago 2026", usado nos cartoes de detalhe.
  static String formatarData(DateTime data) {
    const meses = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez',
    ];
    final dia = data.day.toString().padLeft(2, '0');
    return '$dia ${meses[data.month - 1]} ${data.year}';
  }

  String get dataVisitaFormatada => formatarData(dataVisita);
  String get dataAvaliacaoFormatada => formatarData(avaliacao.dataAvaliacao);

  /// Coordenadas exibidas no cartao de geolocalizacao.
  String get coordenadasCurtas =>
      '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';

  /// Texto compartilhavel da memoria (usado pelo botao de compartilhar).
  String get textoCompartilhavel {
    final estrelas = '${'*' * ranking}${'-' * (5 - ranking)}';
    return 'Coma Bem - $nomeRestaurante ($tipoCulinaria)\n'
        'Prato: $nomePrato\n'
        'Nota: $estrelas ($ranking de 5)\n'
        'Cidade: ${cidade.isEmpty ? 'nao informada' : cidade}\n'
        'Coordenadas: $coordenadasCurtas\n'
        '${recomendacao.isEmpty ? '' : '\n"$recomendacao"'}';
  }

  /// Filtro usado pela busca da tela inicial.
  bool corresponde(String termo) {
    final t = termo.trim().toLowerCase();
    if (t.isEmpty) return true;
    return nomeRestaurante.toLowerCase().contains(t) ||
        nomePrato.toLowerCase().contains(t) ||
        tipoCulinaria.toLowerCase().contains(t) ||
        cidade.toLowerCase().contains(t);
  }
}
