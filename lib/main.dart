import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'estilo.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ComaBemApp());
}

class ComaBemApp extends StatelessWidget {
  const ComaBemApp({super.key});

  @override
  Widget build(BuildContext context) {
    // A splash tem fundo terracota, entao os icones da barra de status
    // precisam ser claros.
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return MaterialApp(
      title: 'Coma Bem',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Cores.creme,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Cores.terracota,
          primary: Cores.terracota,
          surface: Cores.creme,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Cores.grafite,
          contentTextStyle: Fonte.corpo(cor: Colors.white),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(raio),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: Cores.creme,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
