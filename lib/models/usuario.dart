/// Classe base abstrata de todos os perfis do sistema.
///
/// Concentra o encapsulamento dos dados sensiveis (senha) e declara os
/// metodos que cada perfil sobrescreve - a base do polimorfismo do projeto.
abstract class Usuario {
  int? _idUsuario;
  String _nomeUsuario;
  String _email;
  String _senha;

  Usuario(this._idUsuario, this._nomeUsuario, this._email, this._senha);

  int? get idUsuario => _idUsuario;
  String get nomeUsuario => _nomeUsuario;
  String get email => _email;
  String get senha => _senha;

  /// Primeiro nome, usado na saudacao da tela inicial.
  String get primeiroNome => _nomeUsuario.trim().isEmpty
      ? 'Gastronomo'
      : _nomeUsuario.trim().split(' ').first;

  set idUsuario(int? id) => _idUsuario = id;

  set nomeUsuario(String nome) {
    if (nome.trim().isEmpty) return;
    _nomeUsuario = nome.trim();
  }

  set email(String email) {
    if (!emailValido(email)) return;
    _email = email.trim().toLowerCase();
  }

  set senha(String senha) {
    if (!senhaValida(senha)) return;
    _senha = senha;
  }

  /// Regra de negocio: a senha precisa ter no minimo 6 caracteres.
  static bool senhaValida(String senha) => senha.length >= 6;

  /// Validacao simples de formato de e-mail.
  static bool emailValido(String email) {
    final texto = email.trim();
    return RegExp(r'^[\w.\-+]+@[\w\-]+\.[\w.\-]+$').hasMatch(texto);
  }

  Map<String, dynamic> paraMapa() {
    return {
      if (_idUsuario != null) 'usu_id_usuario': _idUsuario,
      'usu_nm_usuario': _nomeUsuario,
      'usu_tx_email': _email,
      'usu_tx_senha': _senha,
    };
  }

  /// Menu exibido para o perfil - cada subclasse tem o seu.
  List<String> itensDoMenu();

  /// Acao de gerenciamento de conta especifica do perfil.
  String descricaoGerenciarConta();

  void exibirMenu() {
    // ignore: avoid_print
    print('--- Menu de $_nomeUsuario ---');
    for (final item in itensDoMenu()) {
      // ignore: avoid_print
      print(item);
    }
  }

  void gerenciarConta() {
    // ignore: avoid_print
    print(descricaoGerenciarConta());
  }
}
