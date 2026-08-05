import 'usuario.dart';

class Administrador extends Usuario {
  Administrador(int id, String nome, String email, String senha)
      : super(id, nome, email, senha);

  @override
  void exibirMenu() {
    print('--- Painel do Administrador ---');
    print('1. Aprovar novos restaurantes');
    print('2. Banir usuários');
  }

  @override
  void gerenciarConta() {
    print('Acesso total às configurações do sistema Coma Bem.');
  }
}