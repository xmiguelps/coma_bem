class Prato {
  int _idPrato;
  String _nomePrato;
  String? _foto;
  int _idRestaurante;

  Prato(this._idPrato, this._nomePrato, this._idRestaurante, [this._foto]);

  int get idPrato => _idPrato;
  String get nomePrato => _nomePrato;
  String? get foto => _foto;
  int get idRestaurante => _idRestaurante;

  set nomePrato(String nome) => _nomePrato = nome;
  set foto(String? foto) => _foto = foto;
}