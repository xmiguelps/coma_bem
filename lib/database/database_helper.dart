import 'package:path/path.dart' as p;
import 'package:sqflite_common/sqlite_api.dart';

import '../models/avaliacao.dart';
import '../models/cliente.dart';
import '../models/memoria.dart';
import '../models/prato.dart';
import '../models/restaurante.dart';
// Importa o SQLite certo para cada plataforma (ver banco_io.dart
// e banco_web.dart).
import 'banco_io.dart' if (dart.library.js_interop) 'banco_web.dart';

/// Erro lancado quando o e-mail informado no cadastro ja existe na base.
class EmailJaCadastradoErro implements Exception {
  final String email;
  const EmailJaCadastradoErro(this.email);

  @override
  String toString() => 'O e-mail $email ja esta cadastrado.';
}

/// Numeros mostrados no topo da tela inicial.
class Estatisticas {
  final int totalRestaurantes;
  final double mediaNotas;
  final int totalCidades;

  const Estatisticas({
    required this.totalRestaurantes,
    required this.mediaNotas,
    required this.totalCidades,
  });

  static const Estatisticas vazia = Estatisticas(
    totalRestaurantes: 0,
    mediaNotas: 0,
    totalCidades: 0,
  );

  String get mediaFormatada => mediaNotas.toStringAsFixed(1);
}

/// Camada de acesso ao banco de dados SQLite (padrao DAO).
///
/// Concentra a criacao das tabelas, os dados de teste e todas as transacoes
/// de INSERT, SELECT, UPDATE e DELETE do aplicativo. Todas as consultas usam
/// parametros (`?`) para evitar SQL Injection.
class DatabaseHelper {
  DatabaseHelper._interno();

  static final DatabaseHelper _instancia = DatabaseHelper._interno();
  static DatabaseHelper get instancia => _instancia;
  factory DatabaseHelper() => _instancia;

  static const String arquivoBanco = 'coma_bem.db';
  static const int versaoBanco = 2;

  Database? _bancoDeDados;
  Future<Database>? _aberturaEmAndamento;

  /// Conexao unica com o banco, aberta sob demanda.
  Future<Database> get bancoDeDados async {
    if (_bancoDeDados != null && _bancoDeDados!.isOpen) return _bancoDeDados!;
    // Evita abrir o banco duas vezes se duas telas pedirem ao mesmo tempo.
    return _aberturaEmAndamento ??= _abrir();
  }

  Future<Database> _abrir() async {
    final fabrica = abrirFabricaDeBanco();
    final caminho = p.join(await fabrica.getDatabasesPath(), arquivoBanco);

    final banco = await fabrica.openDatabase(
      caminho,
      options: OpenDatabaseOptions(
        version: versaoBanco,
        onConfigure: (db) async {
          // Sem isso o SQLite ignora as chaves estrangeiras.
          await db.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: (db, versao) async {
          await _criarTabelas(db);
          await _inserirDadosDeTeste(db);
        },
        onUpgrade: (db, versaoAntiga, versaoNova) async {
          // A versao 1 tinha apenas a tabela `usuario`. Recriamos a estrutura
          // completa para quem ja possuia o banco antigo no aparelho.
          await _removerTabelas(db);
          await _criarTabelas(db);
          await _inserirDadosDeTeste(db);
        },
      ),
    );

    _bancoDeDados = banco;
    _aberturaEmAndamento = null;
    return banco;
  }

  /// Fecha a conexao (usado nos testes).
  Future<void> fechar() async {
    await _bancoDeDados?.close();
    _bancoDeDados = null;
    _aberturaEmAndamento = null;
  }

  // ==========================================================================
  // ESTRUTURA DO BANCO
  // ==========================================================================

  Future<void> _removerTabelas(Database db) async {
    for (final tabela in ['avaliacao', 'prato', 'restaurante', 'usuario']) {
      await db.execute('DROP TABLE IF EXISTS $tabela');
    }
  }

  /// Cria as quatro tabelas do modelo relacional, com chave primaria,
  /// chaves estrangeiras, UNIQUE no e-mail e CHECK na nota (1 a 5).
  Future<void> _criarTabelas(Database db) async {
    await db.execute('''
      CREATE TABLE usuario (
        usu_id_usuario INTEGER PRIMARY KEY AUTOINCREMENT,
        usu_nm_usuario TEXT    NOT NULL,
        usu_tx_email   TEXT    NOT NULL UNIQUE,
        usu_tx_senha   TEXT    NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE restaurante (
        res_id_restaurante    INTEGER PRIMARY KEY AUTOINCREMENT,
        res_nm_restaurante    TEXT    NOT NULL,
        res_ds_tipo_culinaria TEXT    NOT NULL,
        res_nu_latitude       REAL    NOT NULL DEFAULT 0,
        res_nu_longitude      REAL    NOT NULL DEFAULT 0,
        res_nm_cidade         TEXT    NOT NULL DEFAULT '',
        res_ds_faixa_preco    TEXT    NOT NULL DEFAULT '',
        res_dt_visita         TEXT    NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE prato (
        pra_id_prato       INTEGER PRIMARY KEY AUTOINCREMENT,
        pra_nm_prato       TEXT    NOT NULL,
        pra_tx_foto        TEXT,
        pra_id_restaurante INTEGER NOT NULL,
        FOREIGN KEY (pra_id_restaurante)
          REFERENCES restaurante (res_id_restaurante) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE avaliacao (
        avl_id_avaliacao    INTEGER PRIMARY KEY AUTOINCREMENT,
        avl_nu_ranking      INTEGER NOT NULL CHECK (avl_nu_ranking BETWEEN 1 AND 5),
        avl_tx_recomendacao TEXT    NOT NULL DEFAULT '',
        avl_dt_avaliacao    TEXT    NOT NULL,
        avl_id_prato        INTEGER NOT NULL,
        avl_id_usuario      INTEGER,
        FOREIGN KEY (avl_id_prato)
          REFERENCES prato (pra_id_prato) ON DELETE CASCADE,
        FOREIGN KEY (avl_id_usuario)
          REFERENCES usuario (usu_id_usuario) ON DELETE SET NULL
      )
    ''');
  }

  // ==========================================================================
  // DADOS DE TESTE (5 usuarios, 5 restaurantes, 5 pratos, 5 avaliacoes)
  // ==========================================================================

  Future<void> _inserirDadosDeTeste(Database db) async {
    const usuarios = [
      ['Miguel Passos', 'miguel@comabem.com', '123456'],
      ['Ana Ribeiro', 'ana@comabem.com', '123456'],
      ['Carlos Tavares', 'carlos@comabem.com', '123456'],
      ['Beatriz Nunes', 'beatriz@comabem.com', '123456'],
      ['Rafael Lima', 'rafael@comabem.com', '123456'],
    ];

    for (final u in usuarios) {
      await db.insert('usuario', {
        'usu_nm_usuario': u[0],
        'usu_tx_email': u[1],
        'usu_tx_senha': u[2],
      });
    }

    final memorias = <Map<String, Object?>>[
      {
        'nome': 'Sushi Nakamura',
        'tipo': 'Japonesa',
        'lat': -23.5505,
        'lng': -46.6333,
        'cidade': 'São Paulo, SP',
        'preco': r'R$ 68-95',
        'dias': 21,
        'prato': 'Tonkotsu Ramen',
        'foto':
            'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?auto=format&fit=crop&w=900&q=70',
        'nota': 4,
        'texto':
            'Caldo extraordinariamente encorpado, preparado por 18 horas. '
            'O ovo marinado derrete na boca. Ambiente minimalista e autêntico '
            '— chegue antes das 19h para evitar fila.',
      },
      {
        'nome': 'Trattoria della Nonna',
        'tipo': 'Italiana',
        'lat': -23.5629,
        'lng': -46.6544,
        'cidade': 'São Paulo, SP',
        'preco': r'R$ 90-140',
        'dias': 40,
        'prato': 'Tagliatelle al Ragù',
        'foto':
            'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=900&q=70',
        'nota': 5,
        'texto':
            'Massa fresca feita na hora e um ragù de cozimento lento que '
            'rende oito horas de paciência. Peça a burrata de entrada e deixe '
            'espaço para o tiramisù.',
      },
      {
        'nome': 'Le Petit Bistrô',
        'tipo': 'Francesa',
        'lat': -22.9711,
        'lng': -43.1822,
        'cidade': 'Rio de Janeiro, RJ',
        'preco': r'R$ 120-180',
        'dias': 65,
        'prato': 'Coq au Vin',
        'foto':
            'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?auto=format&fit=crop&w=900&q=70',
        'nota': 4,
        'texto':
            'Clássico bem executado, com vinho tinto reduzido na medida '
            'certa. Salão pequeno e iluminação baixa — perfeito para um jantar '
            'sem pressa.',
      },
      {
        'nome': 'Casa do Churrasco',
        'tipo': 'Brasileira',
        'lat': -23.5975,
        'lng': -46.6866,
        'cidade': 'São Paulo, SP',
        'preco': r'R$ 55-80',
        'dias': 12,
        'prato': 'Costela no Bafo',
        'foto':
            'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?auto=format&fit=crop&w=900&q=70',
        'nota': 4,
        'texto':
            'Doze horas de brasa e a carne desmancha no garfo. A farofa de '
            'banana acompanha muito bem. Vá em grupo, as porções são generosas.',
      },
      {
        'nome': 'Taquería El Sol',
        'tipo': 'Mexicana',
        'lat': -22.9847,
        'lng': -43.1979,
        'cidade': 'Rio de Janeiro, RJ',
        'preco': r'R$ 40-65',
        'dias': 5,
        'prato': 'Tacos al Pastor',
        'foto':
            'https://images.unsplash.com/photo-1476224203421-9ac39bcb3327?auto=format&fit=crop&w=900&q=70',
        'nota': 4,
        'texto':
            'Tortilla de milho feita na chapa e abacaxi grelhado '
            'equilibrando a pimenta. O molho verde da casa é o melhor que já '
            'provei por aqui.',
      },
    ];

    final agora = DateTime.now();
    for (final m in memorias) {
      final data = agora.subtract(Duration(days: m['dias'] as int));

      final idRestaurante = await db.insert('restaurante', {
        'res_nm_restaurante': m['nome'],
        'res_ds_tipo_culinaria': m['tipo'],
        'res_nu_latitude': m['lat'],
        'res_nu_longitude': m['lng'],
        'res_nm_cidade': m['cidade'],
        'res_ds_faixa_preco': m['preco'],
        'res_dt_visita': data.toIso8601String(),
      });

      final idPrato = await db.insert('prato', {
        'pra_nm_prato': m['prato'],
        'pra_tx_foto': m['foto'],
        'pra_id_restaurante': idRestaurante,
      });

      await db.insert('avaliacao', {
        'avl_nu_ranking': m['nota'],
        'avl_tx_recomendacao': m['texto'],
        'avl_dt_avaliacao': data.toIso8601String(),
        'avl_id_prato': idPrato,
        'avl_id_usuario': 1,
      });
    }
  }

  // ==========================================================================
  // USUARIO - autenticacao e cadastro
  // ==========================================================================

  /// Autentica o usuario. Devolve `null` quando e-mail ou senha nao conferem.
  Future<Cliente?> autenticar(String email, String senha) async {
    final db = await bancoDeDados;
    final resultado = await db.query(
      'usuario',
      where: 'usu_tx_email = ? AND usu_tx_senha = ?',
      whereArgs: [email.trim().toLowerCase(), senha],
      limit: 1,
    );

    if (resultado.isEmpty) return null;
    return Cliente.doMapa(resultado.first);
  }

  /// Cadastra um novo usuario. Lanca [EmailJaCadastradoErro] se o e-mail
  /// ja existir (a coluna possui restricao UNIQUE).
  Future<Cliente> cadastrarUsuario({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final db = await bancoDeDados;
    final normalizado = email.trim().toLowerCase();

    final existente = await db.query(
      'usuario',
      where: 'usu_tx_email = ?',
      whereArgs: [normalizado],
      limit: 1,
    );
    if (existente.isNotEmpty) throw EmailJaCadastradoErro(normalizado);

    final id = await db.insert('usuario', {
      'usu_nm_usuario': nome.trim(),
      'usu_tx_email': normalizado,
      'usu_tx_senha': senha,
    });

    return Cliente(id, nome.trim(), normalizado, senha);
  }

  // ==========================================================================
  // MEMORIAS - SELECT com INNER JOIN entre restaurante, prato e avaliacao
  // ==========================================================================

  static const String _selectMemorias = '''
    SELECT r.*, p.*, a.*
      FROM restaurante r
      INNER JOIN prato     p ON p.pra_id_restaurante = r.res_id_restaurante
      INNER JOIN avaliacao a ON a.avl_id_prato       = p.pra_id_prato
  ''';

  /// Lista as memorias, opcionalmente filtrando por tipo de culinaria e por
  /// um termo de busca (nome do restaurante, do prato ou cidade).
  Future<List<Memoria>> listarMemorias({
    String? tipoCulinaria,
    String? termo,
    bool ordenarPorNota = false,
  }) async {
    final db = await bancoDeDados;

    final condicoes = <String>[];
    final parametros = <Object?>[];

    if (tipoCulinaria != null && tipoCulinaria.isNotEmpty) {
      condicoes.add('r.res_ds_tipo_culinaria = ?');
      parametros.add(tipoCulinaria);
    }

    final busca = termo?.trim() ?? '';
    if (busca.isNotEmpty) {
      condicoes.add(
        '(r.res_nm_restaurante LIKE ? OR p.pra_nm_prato LIKE ? '
        'OR r.res_nm_cidade LIKE ? OR r.res_ds_tipo_culinaria LIKE ?)',
      );
      parametros.addAll(List.filled(4, '%$busca%'));
    }

    final where = condicoes.isEmpty ? '' : 'WHERE ${condicoes.join(' AND ')}';
    final ordem = ordenarPorNota
        ? 'ORDER BY a.avl_nu_ranking DESC, r.res_dt_visita DESC'
        : 'ORDER BY r.res_dt_visita DESC, r.res_id_restaurante DESC';

    final linhas = await db.rawQuery(
      '$_selectMemorias $where $ordem',
      parametros,
    );
    return linhas.map(Memoria.doMapa).toList();
  }

  /// Busca uma memoria especifica pelo id do restaurante.
  Future<Memoria?> buscarMemoria(int idRestaurante) async {
    final db = await bancoDeDados;
    final linhas = await db.rawQuery(
      '$_selectMemorias WHERE r.res_id_restaurante = ? LIMIT 1',
      [idRestaurante],
    );
    if (linhas.isEmpty) return null;
    return Memoria.doMapa(linhas.first);
  }

  /// Grava a memoria inteira em uma unica transacao: se qualquer comando
  /// falhar, nada e gravado. Faz INSERT quando a memoria e nova e UPDATE
  /// quando ela ja possui id.
  ///
  /// Devolve o id do restaurante gravado.
  Future<int> salvarMemoria(Memoria memoria, {int? idUsuario}) async {
    final db = await bancoDeDados;

    return db.transaction<int>((txn) async {
      final dadosRestaurante = memoria.restaurante.paraMapa()
        ..remove('res_id_restaurante');
      final dadosPrato = memoria.prato.paraMapa()..remove('pra_id_prato');
      final dadosAvaliacao = memoria.avaliacao.paraMapa()
        ..remove('avl_id_avaliacao');

      final idExistente = memoria.restaurante.idRestaurante;

      if (idExistente == null) {
        final idRestaurante = await txn.insert('restaurante', dadosRestaurante);

        dadosPrato['pra_id_restaurante'] = idRestaurante;
        final idPrato = await txn.insert('prato', dadosPrato);

        dadosAvaliacao['avl_id_prato'] = idPrato;
        dadosAvaliacao['avl_id_usuario'] = idUsuario;
        await txn.insert('avaliacao', dadosAvaliacao);

        return idRestaurante;
      }

      await txn.update(
        'restaurante',
        dadosRestaurante,
        where: 'res_id_restaurante = ?',
        whereArgs: [idExistente],
      );

      dadosPrato['pra_id_restaurante'] = idExistente;
      await txn.update(
        'prato',
        dadosPrato,
        where: 'pra_id_prato = ?',
        whereArgs: [memoria.prato.idPrato],
      );

      // Mantem o autor original da avaliacao ao editar.
      dadosAvaliacao.remove('avl_id_usuario');
      dadosAvaliacao['avl_id_prato'] = memoria.prato.idPrato;
      await txn.update(
        'avaliacao',
        dadosAvaliacao,
        where: 'avl_id_avaliacao = ?',
        whereArgs: [memoria.avaliacao.idAvaliacao],
      );

      return idExistente;
    });
  }

  /// Atualiza somente a nota de uma avaliacao (UPDATE rapido pelas estrelas).
  Future<int> atualizarNota(int idAvaliacao, int novaNota) async {
    final db = await bancoDeDados;
    return db.update(
      'avaliacao',
      {
        'avl_nu_ranking': novaNota.clamp(1, 5),
        'avl_dt_avaliacao': DateTime.now().toIso8601String(),
      },
      where: 'avl_id_avaliacao = ?',
      whereArgs: [idAvaliacao],
    );
  }

  /// Exclui o restaurante. Prato e avaliacao saem junto por causa do
  /// ON DELETE CASCADE declarado nas chaves estrangeiras.
  Future<int> excluirMemoria(int idRestaurante) async {
    final db = await bancoDeDados;
    return db.delete(
      'restaurante',
      where: 'res_id_restaurante = ?',
      whereArgs: [idRestaurante],
    );
  }

  /// Numeros do cabecalho da tela inicial, calculados pelo proprio SQLite.
  Future<Estatisticas> estatisticas() async {
    final db = await bancoDeDados;
    final linhas = await db.rawQuery('''
      SELECT COUNT(DISTINCT r.res_id_restaurante) AS total,
             AVG(a.avl_nu_ranking)                AS media,
             COUNT(DISTINCT NULLIF(TRIM(r.res_nm_cidade), '')) AS cidades
        FROM restaurante r
        INNER JOIN prato     p ON p.pra_id_restaurante = r.res_id_restaurante
        INNER JOIN avaliacao a ON a.avl_id_prato       = p.pra_id_prato
    ''');

    if (linhas.isEmpty) return Estatisticas.vazia;
    final linha = linhas.first;

    return Estatisticas(
      totalRestaurantes: (linha['total'] as num?)?.toInt() ?? 0,
      mediaNotas: (linha['media'] as num?)?.toDouble() ?? 0,
      totalCidades: (linha['cidades'] as num?)?.toInt() ?? 0,
    );
  }

  /// Tipos de culinaria que possuem ao menos um restaurante cadastrado.
  /// Alimenta os filtros da tela inicial.
  Future<List<String>> tiposDeCulinariaCadastrados() async {
    final db = await bancoDeDados;
    final linhas = await db.rawQuery('''
      SELECT DISTINCT res_ds_tipo_culinaria AS tipo
        FROM restaurante
       WHERE TRIM(res_ds_tipo_culinaria) <> ''
       ORDER BY res_ds_tipo_culinaria COLLATE NOCASE
    ''');
    return linhas.map((l) => l['tipo'] as String).toList();
  }

  /// Apaga tudo e volta aos dados de teste iniciais.
  Future<void> restaurarDadosDeTeste() async {
    final db = await bancoDeDados;
    await db.transaction((txn) async {
      await txn.delete('avaliacao');
      await txn.delete('prato');
      await txn.delete('restaurante');
      await txn.delete('usuario');
    });
    await _inserirDadosDeTeste(db);
  }

  // ==========================================================================
  // Helpers genericos de CRUD mantidos das atividades anteriores
  // ==========================================================================

  Future<int> inserirDados(String tabela, Map<String, Object?> dados) async =>
      (await bancoDeDados).insert(tabela, dados);

  Future<List<Map<String, Object?>>> consultarDados(String tabela) async =>
      (await bancoDeDados).query(tabela);

  Future<int> alterarDados(
    String tabela,
    Map<String, Object?> novosDados,
    String colunaId,
    int id,
  ) async => (await bancoDeDados).update(
    tabela,
    novosDados,
    where: '$colunaId = ?',
    whereArgs: [id],
  );

  Future<int> deletarDados(String tabela, String colunaId, int id) async =>
      (await bancoDeDados).delete(
        tabela,
        where: '$colunaId = ?',
        whereArgs: [id],
      );

  /// Memoria nova (ainda nao gravada), usada pela tela de cadastro.
  static Memoria memoriaEmBranco() {
    return Memoria(
      restaurante: Restaurante(null, '', 0, 0, ''),
      prato: Prato(null, '', null),
      avaliacao: Avaliacao(null, 1, '', null, null),
    );
  }
}
