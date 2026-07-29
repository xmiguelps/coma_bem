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
      print('Nota $nota salva com sucesso!');
    } else if (nota > 5) {
      _ranking = 5;
      print('Aviso: A nota máxima permitida é 5.');
    } else {
      _ranking = 1;
      print('Aviso: A nota mínima permitida é 1.');
    }
  }

  set recomendacao(String texto) => _recomendacao = texto;
}