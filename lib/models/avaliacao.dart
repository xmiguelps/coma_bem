/// Avaliacao que um usuario faz de um prato (nota de 1 a 5 e recomendacao).
class Avaliacao {
  int? _idAvaliacao;
  int _ranking;
  String _recomendacao;
  DateTime _dataAvaliacao;
  int? _idPrato;
  int? _idUsuario;

  Avaliacao(
    this._idAvaliacao,
    int ranking,
    this._recomendacao,
    this._idPrato,
    this._idUsuario, {
    DateTime? dataAvaliacao,
  }) : _ranking = ranking.clamp(1, 5),
       _dataAvaliacao = dataAvaliacao ?? DateTime.now();

  int? get idAvaliacao => _idAvaliacao;
  int get ranking => _ranking;
  String get recomendacao => _recomendacao;
  DateTime get dataAvaliacao => _dataAvaliacao;
  int? get idPrato => _idPrato;
  int? get idUsuario => _idUsuario;

  /// A nota e sempre normalizada para a faixa permitida de 1 a 5 estrelas,
  /// espelhando a restricao CHECK criada na tabela `avaliacao`.
  set ranking(int nota) => _ranking = nota.clamp(1, 5);

  set recomendacao(String texto) => _recomendacao = texto;
  set dataAvaliacao(DateTime data) => _dataAvaliacao = data;
  set idPrato(int? id) => _idPrato = id;
  set idUsuario(int? id) => _idUsuario = id;

  /// Texto exibido junto das estrelas na interface.
  String get descricaoRanking {
    switch (_ranking) {
      case 5:
        return 'Inesquecivel';
      case 4:
        return 'Muito bom';
      case 3:
        return 'Bom';
      case 2:
        return 'Regular';
      default:
        return 'Nao gostei';
    }
  }

  Map<String, dynamic> paraMapa() {
    return {
      if (_idAvaliacao != null) 'avl_id_avaliacao': _idAvaliacao,
      'avl_nu_ranking': _ranking,
      'avl_tx_recomendacao': _recomendacao,
      'avl_dt_avaliacao': _dataAvaliacao.toIso8601String(),
      'avl_id_prato': _idPrato,
      'avl_id_usuario': _idUsuario,
    };
  }

  factory Avaliacao.doMapa(Map<String, dynamic> mapa) {
    return Avaliacao(
      mapa['avl_id_avaliacao'] as int?,
      (mapa['avl_nu_ranking'] as num?)?.toInt() ?? 1,
      (mapa['avl_tx_recomendacao'] ?? '') as String,
      mapa['avl_id_prato'] as int?,
      mapa['avl_id_usuario'] as int?,
      dataAvaliacao:
          DateTime.tryParse((mapa['avl_dt_avaliacao'] ?? '') as String) ??
          DateTime.now(),
    );
  }
}
