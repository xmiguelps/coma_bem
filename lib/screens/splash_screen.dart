import 'dart:async';

import 'package:flutter/material.dart';

import '../estilo.dart';
import 'login_screen.dart';

/// Primeira tela do aplicativo: apresenta a marca e, depois de um instante,
/// leva para o login. Tocar na tela pula a espera.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animacao = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  Timer? _temporizador;

  @override
  void initState() {
    super.initState();
    _animacao.forward();
    _temporizador = Timer(const Duration(milliseconds: 2400), _irParaLogin);
  }

  void _irParaLogin() {
    if (!mounted) return;
    _temporizador?.cancel();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, _, _) => const LoginScreen(),
        transitionsBuilder: (_, animacao, _, filho) =>
            FadeTransition(opacity: animacao, child: filho),
      ),
    );
  }

  @override
  void dispose() {
    _temporizador?.cancel();
    _animacao.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores.terracota,
      body: GestureDetector(
        onTap: _irParaLogin,
        child: Stack(
          children: [
            const Positioned.fill(
              child: CustomPaint(painter: BrilhosDeFundo()),
            ),
            const Positioned.fill(child: CustomPaint(painter: Pontilhado())),
            // Ocupa a tela toda para o conteudo ficar centralizado.
            Positioned.fill(
              child: SafeArea(
                child: FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _animacao,
                    curve: Curves.easeOut,
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: ScaleTransition(
                            scale: Tween<double>(begin: 0.92, end: 1).animate(
                              CurvedAnimation(
                                parent: _animacao,
                                curve: Curves.easeOutBack,
                              ),
                            ),
                            child: _marca(),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 28),
                        child: _Pontinhos(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _marca() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
          ),
          child: const Icon(
            Icons.restaurant_menu,
            size: 46,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 34),
        Text(
          'Coma',
          style: Fonte.titulo(
            tamanho: 58,
            cor: Colors.white,
            peso: 800,
            altura: 1.02,
          ),
        ),
        Text(
          'Bem',
          style: Fonte.titulo(
            tamanho: 58,
            cor: Colors.white,
            peso: 800,
            italico: true,
            altura: 1.02,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'MEMÓRIAS QUE FICAM NO PALADAR',
          style: Fonte.rotulo(
            tamanho: 11.5,
            cor: Colors.white.withValues(alpha: 0.85),
          ),
        ),
      ],
    );
  }
}

/// Os tres pontinhos da base da splash.
class _Pontinhos extends StatefulWidget {
  const _Pontinhos();

  @override
  State<_Pontinhos> createState() => _PontinhosState();
}

class _PontinhosState extends State<_Pontinhos>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controlador = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controlador,
      builder: (context, _) {
        final ativo = (_controlador.value * 3).floor() % 3;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final destacado = i == ativo;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: destacado ? 10 : 7,
              height: destacado ? 10 : 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: destacado ? 1 : 0.45),
              ),
            );
          }),
        );
      },
    );
  }
}
