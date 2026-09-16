// ============================================================================
// ROBO ANALISTA DE QUALIDADE - Coma Bem
// ============================================================================
// Teste de INTEGRACAO: em vez de testar uma funcao isolada (como faz o teste
// de unidade em test/coma_bem_test.dart), este teste abre o aplicativo de
// verdade, digita, toca nos botoes e confere o que aparece na tela.
//
// Como rodar:
//   flutter test integration_test/app_test.dart -d windows
// ============================================================================

// 1. Ferramentas visuais do Flutter, para o robo reconhecer botoes e textos.
import 'package:flutter/material.dart';
// 2. Ferramenta de testes padrao do Flutter (expect, find, testWidgets...).
import 'package:flutter_test/flutter_test.dart';
// 3. Motor do robo, instalado no pubspec.yaml.
import 'package:integration_test/integration_test.dart';

// 4. O aplicativo que o robo vai abrir. `as app` da um apelido para
//    chamarmos app.main() la embaixo sem confundir com o main() daqui.
import 'package:coma_bem/main.dart' as app;
import 'package:coma_bem/screens/home_screen.dart';

void main() {
  // Liga a "ignicao" do robo: sem isto ele nao consegue assumir o controle
  // da tela do aparelho.
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Validação Funcional: o robô faz login sozinho', (tester) async {
    // ========================================================================
    // PREPARACAO: ABRINDO O APLICATIVO
    // ========================================================================
    app.main();

    // ATENCAO - diferenca importante em relacao ao guia:
    // o Coma Bem abre na SplashScreen, e ela tem uma animacao de pontinhos
    // com `..repeat()`, ou seja, que roda para sempre. O pumpAndSettle()
    // espera a tela ficar completamente parada, entao ali ele NUNCA
    // terminaria e o teste morreria de timeout.
    // Por isso avancamos o relogio na mao ate a splash dar lugar ao login
    // (o temporizador da splash e de 2,4 segundos).
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // ========================================================================
    // FASE 1: OLHANDO PARA A TELA E PROCURANDO OS ELEMENTOS
    // ========================================================================

    // A tela de login tem exatamente duas caixas de texto.
    // A PRIMEIRA e o e-mail...
    final campoEmail = find.byType(TextField).first;
    // ...e a ULTIMA e a senha.
    final campoSenha = find.byType(TextField).last;

    // O botao principal tem EXATAMENTE o texto 'Entrar'.
    final botaoEntrar = find.text('Entrar');

    // Conferimos que o robo chegou mesmo na tela de login antes de digitar.
    // Se esta linha falhar, o problema esta na abertura do app, nao no login.
    expect(botaoEntrar, findsOneWidget);

    // ========================================================================
    // FASE 2: ACAO (O ROBO DIGITANDO E CLICANDO)
    // ========================================================================

    // Usuario e senha que o proprio app cria em _inserirDadosDeTeste()
    // no database_helper.dart. Qualquer outro e-mail seria recusado.
    await tester.enterText(campoEmail, 'miguel@comabem.com');
    await tester.enterText(campoSenha, '123456');

    // Uma pausa para a tela processar as letrinhas sendo digitadas.
    await tester.pumpAndSettle();

    await tester.tap(botaoEntrar);

    // Espera o app consultar o SQLite e trocar da tela de login para a home.
    await tester.pumpAndSettle();

    // ========================================================================
    // FASE 3: A VALIDACAO FINAL (PASSOU OU REPROVOU?)
    // ========================================================================

    // O guia sugere procurar o texto "Catálogo de Restaurantes", mas o nosso
    // app nao usa esse titulo: a home escreve "Memórias gastronômicas" dentro
    // de um RichText, que o find.text() nao enxerga (ele so acha widgets Text).
    // Entao validamos por duas ancoras confiaveis:

    // 1) a tela do catalogo esta mesmo montada;
    expect(find.byType(HomeScreen), findsOneWidget);

    // 2) e a barra de busca dela apareceu.
    expect(find.text('Buscar restaurante ou prato...'), findsOneWidget);

    // ========================================================================
    // DESAFIO DA DUPLA: navegar ate a tela de Novo Cadastro
    // ========================================================================

    // O botao flutuante (+) do canto inferior direito.
    final botaoNovo = find.byIcon(Icons.add);
    await tester.tap(botaoNovo);

    // Espera a tela de cadastro abrir completamente.
    await tester.pumpAndSettle();

    // Cabecalho da tela nova - fica sempre visivel, e a ancora mais segura.
    expect(find.text('Novo Restaurante'), findsOneWidget);

    // O guia pede para procurar "Foto do Prato". Dois detalhes do nosso app:
    //  - o widget Rotulo escreve tudo em CAIXA ALTA, entao o texto que existe
    //    na tela e 'FOTO DO PRATO';
    //  - ele fica no fim do formulario, e o ListView so constroi o que esta
    //    perto da area visivel. Por isso rolamos a tela ate ele aparecer.
    final rotuloFoto = find.text('FOTO DO PRATO');
    await tester.dragUntilVisible(
      rotuloFoto,
      find.byType(ListView),
      const Offset(0, -250),
    );
    await tester.pumpAndSettle();

    expect(rotuloFoto, findsOneWidget);
  });
}
