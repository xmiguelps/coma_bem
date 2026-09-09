// Os campos desta classe sao privados de proposito (encapsulamento), e em
// Dart um atributo privado nao pode ser usado como parametro nomeado.
// Por isso 'cidade' e 'faixaPreco' chegam como parametros comuns e sao
// repassados na lista de inicializacao.
// ignore_for_file: prefer_initializing_formals

/// Restaurante visitado pelo usuario.
///
/// Mantem o encapsulamento exigido pela atividade: todos os atributos sao
/// privados e o acesso acontece por getters/setters com validacao.
class Restaurante {
  int? _idRestaurante;
  String _nomeRestaurante;
  double _latitude;
  double _longitude;
  String _tipoCulinaria;
  String _cidade;
  String _faixaPreco;
  DateTime _dataVisita;

  Restaurante(
    this._idRestaurante,
    this._nomeRestaurante,
    this._latitude,
    this._longitude,
    this._tipoCulinaria, {
    String cidade = '',
    String faixaPreco = '',
    DateTime? dataVisita,
  }) : _cidade = cidade,
       _faixaPreco = faixaPreco,
       // Sem data informada, a visita e considerada de hoje.
       _dataVisita = dataVisita ?? DateTime.now();

  int? get idRestaurante => _idRestaurante;
  String get nomeRestaurante => _nomeRestaurante;
  double get latitude => _latitude;
  double get longitude => _longitude;
  String get tipoCulinaria => _tipoCulinaria;
  String get cidade => _cidade;
  String get faixaPreco => _faixaPreco;
  DateTime get dataVisita => _dataVisita;

  set nomeRestaurante(String nome) {
    if (nome.trim().isEmpty) return;
    _nomeRestaurante = nome.trim();
  }

  /// Latitude valida vai de -90 a 90 graus.
  set latitude(double lat) {
    if (lat < -90 || lat > 90) return;
    _latitude = lat;
  }

  /// Longitude valida vai de -180 a 180 graus.
  set longitude(double lon) {
    if (lon < -180 || lon > 180) return;
    _longitude = lon;
  }

  set tipoCulinaria(String tipo) => _tipoCulinaria = tipo;
  set cidade(String cidade) => _cidade = cidade;
  set faixaPreco(String faixa) => _faixaPreco = faixa;
  set dataVisita(DateTime data) => _dataVisita = data;

  /// Descreve a categoria da culinaria (demonstracao de polimorfismo de
  /// comportamento por meio de `switch`).
  String descreverCategoriaCulinaria() {
    switch (_tipoCulinaria.toLowerCase()) {
      case 'japonesa':
        return 'Culinaria Asiatica - foco em peixes e arroz.';
      case 'italiana':
        return 'Massas e pizzas artesanais.';
      case 'brasileira':
        return 'Churrasco, feijoada e pratos tipicos.';
      case 'francesa':
        return 'Alta gastronomia, molhos e panificacao.';
      case 'mexicana':
        return 'Tacos, pimentas e milho.';
      default:
        return 'Culinaria internacional ou diversa.';
    }
  }

  void exibirCategoriaCulinaria() {
    // ignore: avoid_print
    print('Categoria: ${descreverCategoriaCulinaria()}');
  }

  /// Converte o objeto para as colunas da tabela `restaurante`.
  Map<String, dynamic> paraMapa() {
    return {
      if (_idRestaurante != null) 'res_id_restaurante': _idRestaurante,
      'res_nm_restaurante': _nomeRestaurante,
      'res_ds_tipo_culinaria': _tipoCulinaria,
      'res_nu_latitude': _latitude,
      'res_nu_longitude': _longitude,
      'res_nm_cidade': _cidade,
      'res_ds_faixa_preco': _faixaPreco,
      'res_dt_visita': _dataVisita.toIso8601String(),
    };
  }

  /// Reconstroi o objeto a partir de uma linha do banco de dados.
  factory Restaurante.doMapa(Map<String, dynamic> mapa) {
    return Restaurante(
      mapa['res_id_restaurante'] as int?,
      (mapa['res_nm_restaurante'] ?? '') as String,
      (mapa['res_nu_latitude'] as num?)?.toDouble() ?? 0,
      (mapa['res_nu_longitude'] as num?)?.toDouble() ?? 0,
      (mapa['res_ds_tipo_culinaria'] ?? '') as String,
      cidade: (mapa['res_nm_cidade'] ?? '') as String,
      faixaPreco: (mapa['res_ds_faixa_preco'] ?? '') as String,
      dataVisita:
          DateTime.tryParse((mapa['res_dt_visita'] ?? '') as String) ??
          DateTime.now(),
    );
  }
}
