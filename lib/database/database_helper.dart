import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Classe responsável por gerenciar a conexão com o banco de dados SQLite
/// e realizar as transações de autenticação, inserção, consulta, alteração e deleção.
class DatabaseHelper {
  static final DatabaseHelper _instancia = DatabaseHelper._interno();
  static Database? _bancoDeDados;

  factory DatabaseHelper() => _instancia;

  DatabaseHelper._interno();

  /// Inicia a conexão com o banco de dados.
  Future<Database> get bancoDeDados async {
    if (_bancoDeDados != null) return _bancoDeDados!;
    _bancoDeDados = await _iniciarBanco();
    return _bancoDeDados!;
  }

  /// Configura o caminho do banco no dispositivo e cria as tabelas se for a primeira execução.
  Future<Database> _iniciarBanco() async {
    String caminhoBanco = await getDatabasesPath();
    String caminhoCompleto = join(caminhoBanco, 'coma_bem.db');

    return await openDatabase(
      caminhoCompleto,
      version: 1,
      onCreate: _criarTabelas,
    );
  }

  /// Cria a estrutura inicial do banco de dados (Tabelas).
  Future<void> _criarTabelas(Database db, int versao) async {
    await db.execute('''
      CREATE TABLE usuario (
        usu_id_usuario INTEGER PRIMARY KEY AUTOINCREMENT,
        usu_tx_email TEXT NOT NULL UNIQUE,
        usu_tx_senha TEXT NOT NULL
      )
    ''');
    // As demais tabelas (restaurante, prato, avaliacao) da Atividade 4 devem ser inseridas aqui.
  }

  // ============================================================================
  // TRANSAÇÕES DE MANIPULAÇÃO DE DADOS (CRUD) E AUTENTICAÇÃO
  // ============================================================================

  /// Realiza a AUTENTICAÇÃO do usuário.
  /// Consulta no banco de dados se o e-mail e a senha informados existem e coincidem.
  /// Retorna os dados do usuário em caso de sucesso, ou nulo se as credenciais forem inválidas.
  Future<Map<String, dynamic>?> autenticarUsuario(
      String email, String senha) async {
    Database db = await bancoDeDados;

    List<Map<String, dynamic>> resultado = await db.query(
      'usuario',
      where: 'usu_tx_email = ? AND usu_tx_senha = ?',
      whereArgs: [email, senha],
    );

    if (resultado.isNotEmpty) return resultado.first;
    return null;
  }

  /// Realiza a INSERÇÃO (Create) de um novo registro.
  /// Recebe o nome da tabela e um mapa com os dados, inserindo-os no banco.
  /// Retorna o ID numérico gerado para o novo registro.
  Future<int> inserirDados(String tabela, Map<String, dynamic> dados) async {
    Database db = await bancoDeDados;
    return await db.insert(tabela, dados);
  }

  /// Realiza a CONSULTA (Read) de registros.
  /// Retorna uma lista com todos os dados cadastrados na tabela solicitada.
  Future<List<Map<String, dynamic>>> consultarDados(String tabela) async {
    Database db = await bancoDeDados;
    return await db.query(tabela);
  }

  /// Realiza a ALTERAÇÃO (Update) de um registro existente.
  /// Atualiza os dados com base na coluna de ID (chave primária) informada.
  /// Retorna o número de linhas que foram modificadas no banco.
  Future<int> alterarDados(
      String tabela,
      Map<String, dynamic> novosDados,
      String colunaId,
      int id) async {
    Database db = await bancoDeDados;

    return await db.update(
      tabela,
      novosDados,
      where: '$colunaId = ?',
      whereArgs: [id],
    );
  }

  /// Realiza a DELEÇÃO (Delete) de um registro.
  /// Remove permanentemente os dados da tabela com base no ID informado.
  /// Retorna o número de linhas excluídas.
  Future<int> deletarDados(String tabela, String colunaId, int id) async {
    Database db = await bancoDeDados;
    return await db.delete(
      tabela,
      where: '$colunaId = ?',
      whereArgs: [id],
    );
  }
}