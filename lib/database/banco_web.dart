import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// Escolhe o SQLite do navegador (Chrome / Edge).
///
/// Depende de `web/sqflite_sw.js` e `web/sqlite3.wasm`, criados pelo comando
/// `dart run sqflite_common_ffi_web:setup`. Os dados ficam no IndexedDB do
/// navegador, entao continuam la depois de fechar a aba.
DatabaseFactory abrirFabricaDeBanco() => databaseFactoryFfiWeb;
