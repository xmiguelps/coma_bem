class Avaliacao {
  int _idAvaliacao;
  int _ranking;
  String _recomendacao;
  int _idPrato;
  int _idUsuario;

  Avaliacao(
    this._idAvaliacao,
    this._ranking,
    this._recomendacao,
    this._idPrato,
    this._idUsuario,
  );

  int get idAvaliacao => _idAvaliacao;
  int get ranking => _ranking;
  String get recomendacao => _recomendacao;
  int get idPrato => _idPrato;
  int get idUsuario => _idUsuario;

  set ranking(int nota) {
    if (nota >= 1 && nota <= 5) {
      _ranking = nota;
    } else {
      print("Erro: A nota deve estar entre 1 e 5.");
    }
  }

  set recomendacao(String texto) => _recomendacao = texto;
}