import 'usuario.dart';

/// Perfil padrao do aplicativo: registra e avalia suas memorias.
class Cliente extends Usuario {
  Cliente(super.id, super.nome, super.email, super.senha);

  String avaliarPrato(String prato, int nota) {
    return '$nomeUsuario avaliou o prato $prato com nota ${nota.clamp(1, 5)}.';
  }

  @override
  List<String> itensDoMenu() => [
    '1. Buscar restaurantes',
    '2. Minhas memorias gastronomicas',
    '3. Ranking pessoal',
  ];

  @override
  String descricaoGerenciarConta() =>
      'Gerenciando forma de pagamento e endereco de entrega.';

  /// Reconstroi o cliente a partir de uma linha da tabela `usuario`.
  factory Cliente.doMapa(Map<String, dynamic> mapa) {
    return Cliente(
      mapa['usu_id_usuario'] as int?,
      (mapa['usu_nm_usuario'] ?? '') as String,
      (mapa['usu_tx_email'] ?? '') as String,
      (mapa['usu_tx_senha'] ?? '') as String,
    );
  }
}
