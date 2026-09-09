import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' show databaseFactorySqflitePlugin;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Escolhe o SQLite de Android, iOS, Windows, Linux e macOS.
///
/// O par deste arquivo e o `banco_web.dart`. O `database_helper.dart` importa
/// um ou o outro conforme a plataforma, por isso os dois precisam ter uma
/// funcao com este mesmo nome.
DatabaseFactory abrirFabricaDeBanco() {
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
    case TargetPlatform.iOS:
      // Celular: plugin nativo, grava em data/data/<pacote>/databases.
      return databaseFactorySqflitePlugin;
    default:
      // Computador: o plugin nativo nao existe, usamos o SQLite via FFI.
      sqfliteFfiInit();
      return databaseFactoryFfi;
  }
}
