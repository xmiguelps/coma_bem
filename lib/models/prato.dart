/// Prato pedido em um restaurante. Um prato pertence a um unico restaurante.
class Prato {
  int? _idPrato;
  String _nomePrato;
  String? _foto;
  int? _idRestaurante;

  Prato(this._idPrato, this._nomePrato, this._idRestaurante, [this._foto]);

  int? get idPrato => _idPrato;
  String get nomePrato => _nomePrato;
  String? get foto => _foto;
  int? get idRestaurante => _idRestaurante;

  set nomePrato(String nome) {
    if (nome.trim().isEmpty) return;
    _nomePrato = nome.trim();
  }

  set foto(String? foto) => _foto = foto;
  set idRestaurante(int? id) => _idRestaurante = id;

  Map<String, dynamic> paraMapa() {
    return {
      if (_idPrato != null) 'pra_id_prato': _idPrato,
      'pra_nm_prato': _nomePrato,
      'pra_tx_foto': _foto,
      'pra_id_restaurante': _idRestaurante,
    };
  }

  factory Prato.doMapa(Map<String, dynamic> mapa) {
    return Prato(
      mapa['pra_id_prato'] as int?,
      (mapa['pra_nm_prato'] ?? '') as String,
      mapa['pra_id_restaurante'] as int?,
      mapa['pra_tx_foto'] as String?,
    );
  }
}
