import 'usuario.dart';

/// Perfil de quem administra um restaurante cadastrado.
class DonoRestaurante extends Usuario {
  String cnpj;

  DonoRestaurante(super.id, super.nome, super.email, super.senha, this.cnpj);

  @override
  List<String> itensDoMenu() => [
    '1. Cadastrar novo prato',
    '2. Ver avaliacoes recebidas',
  ];

  @override
  String descricaoGerenciarConta() =>
      'Gerenciando dados bancarios da empresa CNPJ: $cnpj.';
}
