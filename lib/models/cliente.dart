import 'usuario.dart';

class Cliente extends Usuario {
  Cliente(int id, String nome, String email, String senha)
      : super(id, nome, email, senha);

  void avaliarPrato(String prato, int nota) {
    print('O cliente $nomeUsuario avaliou o prato $prato com nota $nota.');
  }

  @override
  void exibirMenu() {
    print('--- Menu do Cliente ---');
    print('1. Buscar Restaurantes');
    print('2. Meus Favoritos');
  }

  @override
  void gerenciarConta() {
    print('Gerenciando forma de pagamento e endereço de entrega.');
  }
}