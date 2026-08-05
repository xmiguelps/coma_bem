import 'models/cliente.dart';
import 'models/administrador.dart';
import 'models/dono_restaurante.dart';
import 'models/usuario.dart';

void main() {
  Cliente cliente = Cliente(1, 'João', 'joao@email.com', '123456');
  Administrador admin = Administrador(2, 'Chefia', 'admin@comabem.com', 'admin123');
  DonoRestaurante dono = DonoRestaurante(
    3,
    'Sra. Bella',
    'bella@cantina.com',
    'senha789',
    '12.345.678/0001-99',
  );

  List<Usuario> listaDeUsuarios = [cliente, admin, dono];

  for (Usuario user in listaDeUsuarios) {
    print('\nLogado como: ${user.nomeUsuario}');

    user.exibirMenu();
    user.gerenciarConta();
  }

  print('\n--- Ação Específica ---');
  cliente.avaliarPrato('Lasanha', 5);
}