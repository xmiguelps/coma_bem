// Testes do Coma Bem.
//
// Rode com `flutter test`. Sao dois grupos:
//  * as regras de validacao dos modelos (encapsulamento);
//  * o banco de dados de verdade, criando as tabelas, gravando uma memoria
//    com o INNER JOIN e conferindo o ON DELETE CASCADE.

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:coma_bem/models/avaliacao.dart';
import 'package:coma_bem/models/cliente.dart';
import 'package:coma_bem/models/memoria.dart';
import 'package:coma_bem/models/prato.dart';
import 'package:coma_bem/models/restaurante.dart';
import 'package:coma_bem/models/usuario.dart';

void main() {
  group('Regras dos modelos', () {
    test('a senha precisa ter no minimo 6 caracteres', () {
      expect(Usuario.senhaValida('12345'), isFalse);
      expect(Usuario.senhaValida('123456'), isTrue);

      final cliente = Cliente(1, 'Miguel', 'miguel@comabem.com', '123456');
      cliente.senha = 'abc'; // curta: deve ser recusada
      expect(cliente.senha, '123456');

      cliente.senha = 'abcdef';
      expect(cliente.senha, 'abcdef');
    });

    test('o e-mail precisa ter formato valido', () {
      expect(Usuario.emailValido('miguel@comabem.com'), isTrue);
      expect(Usuario.emailValido('miguel.comabem.com'), isFalse);
      expect(Usuario.emailValido('miguel@com'), isFalse);
    });

    test('a nota fica sempre entre 1 e 5', () {
      final avaliacao = Avaliacao(null, 9, '', null, null);
      expect(avaliacao.ranking, 5);

      avaliacao.ranking = 0;
      expect(avaliacao.ranking, 1);

      avaliacao.ranking = 3;
      expect(avaliacao.ranking, 3);
      expect(avaliacao.descricaoRanking, 'Bom');
    });

    test('coordenadas fora da faixa sao recusadas', () {
      final restaurante = Restaurante(null, 'Teste', -23.5, -46.6, 'Japonesa');

      restaurante.latitude = 200; // invalida: mantem o valor anterior
      expect(restaurante.latitude, -23.5);

      restaurante.latitude = -10;
      expect(restaurante.latitude, -10);
    });
  });

  group('Banco de dados', () {
    // Fora do celular o SQLite roda via FFI, igual ao que o banco_io.dart
    // faz quando o aplicativo abre no Windows.
    setUpAll(sqfliteFfiInit);

    test('cria as tabelas, grava e apaga uma memoria em cascata', () async {
      // Banco proprio do teste, em memoria, para nao mexer no do aplicativo.
      final db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 1,
          onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
          onCreate: (db, _) async {
            await db.execute('''
              CREATE TABLE restaurante (
                res_id_restaurante    INTEGER PRIMARY KEY AUTOINCREMENT,
                res_nm_restaurante    TEXT NOT NULL,
                res_ds_tipo_culinaria TEXT NOT NULL,
                res_nu_latitude       REAL NOT NULL DEFAULT 0,
                res_nu_longitude      REAL NOT NULL DEFAULT 0,
                res_nm_cidade         TEXT NOT NULL DEFAULT '',
                res_ds_faixa_preco    TEXT NOT NULL DEFAULT '',
                res_dt_visita         TEXT NOT NULL
              )
            ''');
            await db.execute('''
              CREATE TABLE prato (
                pra_id_prato       INTEGER PRIMARY KEY AUTOINCREMENT,
                pra_nm_prato       TEXT NOT NULL,
                pra_tx_foto        TEXT,
                pra_id_restaurante INTEGER NOT NULL,
                FOREIGN KEY (pra_id_restaurante)
                  REFERENCES restaurante (res_id_restaurante) ON DELETE CASCADE
              )
            ''');
            await db.execute('''
              CREATE TABLE avaliacao (
                avl_id_avaliacao    INTEGER PRIMARY KEY AUTOINCREMENT,
                avl_nu_ranking      INTEGER NOT NULL
                                    CHECK (avl_nu_ranking BETWEEN 1 AND 5),
                avl_tx_recomendacao TEXT NOT NULL DEFAULT '',
                avl_dt_avaliacao    TEXT NOT NULL,
                avl_id_prato        INTEGER NOT NULL,
                avl_id_usuario      INTEGER,
                FOREIGN KEY (avl_id_prato)
                  REFERENCES prato (pra_id_prato) ON DELETE CASCADE
              )
            ''');
          },
        ),
      );

      // INSERT nas tres tabelas.
      final restaurante = Restaurante(
        null,
        'Sushi Nakamura',
        -23.5505,
        -46.6333,
        'Japonesa',
        cidade: 'São Paulo, SP',
      );
      final idRestaurante = await db.insert(
        'restaurante',
        restaurante.paraMapa(),
      );

      final prato = Prato(null, 'Tonkotsu Ramen', idRestaurante);
      final idPrato = await db.insert('prato', prato.paraMapa());

      final avaliacao = Avaliacao(null, 4, 'Caldo excelente.', idPrato, null);
      await db.insert('avaliacao', avaliacao.paraMapa());

      // SELECT com INNER JOIN, do jeito que a tela inicial monta a lista.
      final linhas = await db.rawQuery('''
        SELECT r.*, p.*, a.*
          FROM restaurante r
          INNER JOIN prato     p ON p.pra_id_restaurante = r.res_id_restaurante
          INNER JOIN avaliacao a ON a.avl_id_prato       = p.pra_id_prato
      ''');

      expect(linhas, hasLength(1));

      final memoria = Memoria.doMapa(linhas.first);
      expect(memoria.nomeRestaurante, 'Sushi Nakamura');
      expect(memoria.nomePrato, 'Tonkotsu Ramen');
      expect(memoria.ranking, 4);
      expect(memoria.cidade, 'São Paulo, SP');
      expect(memoria.coordenadasCurtas, '-23.5505, -46.6333');

      // A restricao CHECK precisa recusar nota fora da faixa.
      await expectLater(
        db.insert('avaliacao', {
          'avl_nu_ranking': 9,
          'avl_tx_recomendacao': '',
          'avl_dt_avaliacao': DateTime.now().toIso8601String(),
          'avl_id_prato': idPrato,
        }),
        throwsA(isA<DatabaseException>()),
      );

      // DELETE no restaurante leva prato e avaliacao junto (ON DELETE CASCADE).
      await db.delete(
        'restaurante',
        where: 'res_id_restaurante = ?',
        whereArgs: [idRestaurante],
      );

      expect(await db.query('prato'), isEmpty);
      expect(await db.query('avaliacao'), isEmpty);

      await db.close();
    });
  });
}
