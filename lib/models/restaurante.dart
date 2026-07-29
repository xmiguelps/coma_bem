class Restaurante {
  int _idRestaurante;
  String _nomeRestaurante;
  String _latitude;
  String _longitude;
  String _tipoCulinaria;

  Restaurante(
    this._idRestaurante,
    this._nomeRestaurante,
    this._latitude,
    this._longitude,
    this._tipoCulinaria,
  );

  int get idRestaurante => _idRestaurante;
  String get nomeRestaurante => _nomeRestaurante;
  String get latitude => _latitude;
  String get longitude => _longitude;
  String get tipoCulinaria => _tipoCulinaria;

  set nomeRestaurante(String nome) => _nomeRestaurante = nome;
  set latitude(String lat) => _latitude = lat;
  set longitude(String lon) => _longitude = lon;
  set tipoCulinaria(String tipo) => _tipoCulinaria = tipo;

  void exibirCategoriaCulinaria() {
    switch (_tipoCulinaria.toLowerCase()) {
      case 'japonesa':
        print('Categoria: Culinária Asiática - Foco em peixes e arroz.');
        break;

      case 'italiana':
        print('Categoria: Massas e Pizzas artesanais.');
        break;

      case 'brasileira':
        print('Categoria: Churrasco, feijoada e pratos típicos.');
        break;

      default:
        print('Categoria: Culinária Internacional ou Diversa.');
    }
  }
}