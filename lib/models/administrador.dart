import 'usuario.dart';

/// Perfil com acesso total ao sistema.
class Administrador extends Usuario {
  Administrador(super.id, super.nome, super.email, super.senha);

  @override
  List<String> itensDoMenu() => [
    '1. Aprovar novos restaurantes',
    '2. Banir usuarios',
    '3. Auditar avaliacoes',
  ];

  @override
  String descricaoGerenciarConta() =>
      'Acesso total as configuracoes do sistema Coma Bem.';
}
