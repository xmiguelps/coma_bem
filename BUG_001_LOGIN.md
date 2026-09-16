# Relatório de Bug: Falha no Fluxo de Login

| Campo | Valor |
|---|---|
| **ID do Bug** | #001 |
| **Severidade** | ALTA — impede o acesso ao aplicativo |
| **Funcionalidade** | Tela de Login (`lib/screens/login_screen.dart`) |
| **Detectado por** | Teste de regressão automatizado (`integration_test/app_test.dart`) |
| **Ambiente** | Windows 11 · Flutter 3.47.4 (stable) · `flutter test integration_test/app_test.dart -d windows` |
| **Data** | 16/09/2026 |
| **Status** | CORRIGIDO |

---

## 1. Descrição do Problema

O robô de testes de integração falhou ao tentar realizar o login no aplicativo
durante os testes de regressão. O fluxo é interrompido logo no início da Fase 1,
quando o robô procura o botão principal da tela de login — antes mesmo de
conseguir preencher e-mail e senha.

A falha foi introduzida por uma alteração de interface que não foi comunicada à
equipe de testes.

## 2. Passos para Reproduzir

1. Abrir o aplicativo no dispositivo (emulador Android ou Windows desktop).
2. Aguardar a splash screen dar lugar à tela de login.
3. Procurar o botão principal de acesso pelo texto `"Entrar"`.
4. Tentar preencher e-mail e senha e clicar no botão.

Ou, de forma automatizada:

```
flutter test integration_test/app_test.dart -d windows
```

## 3. Resultado Esperado

O robô deveria encontrar exatamente um widget com o texto `"Entrar"`, preencher
as credenciais de teste (`miguel@comabem.com` / `123456`), clicar no botão e ser
redirecionado para a tela principal (`HomeScreen`), onde validaria a presença da
barra de busca `"Buscar restaurante ou prato..."`.

Terminal em verde: `All tests passed!`

## 4. Resultado Atual (O Erro)

O teste falha na linha 61 de `integration_test/app_test.dart`. Log real do terminal:

```
══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞═══════════════════════════════
The following TestFailure was thrown running a test:
Expected: exactly one matching candidate
  Actual: _TextWidgetFinder:<Found 0 widgets with text "Entrar": []>
   Which: means none were found but one was expected

When the exception was thrown, this was the stack:
#4      main.<anonymous closure> (integration_test/app_test.dart:61:5)

This was caught by the test expectation on the following line:
  integration_test/app_test.dart line 61
The test description was:
  Validação Funcional: o robô faz login sozinho
═══════════════════════════════════════════════════════════════════════════════
00:04 +0 -1: Validação Funcional: o robô faz login sozinho [E]
00:04 +0 -1: Some tests failed.
```

**Tradução:** o robô esperava encontrar exatamente um widget com o texto
`"Entrar"` na árvore de widgets, mas encontrou **zero**.

> **Observação técnica:** o guia da atividade previa que a falha aconteceria por
> *Timeout*. Neste projeto ela acontece de forma **imediata**, porque o teste faz
> `expect(botaoEntrar, findsOneWidget)` antes de tentar o toque. Falhar rápido e
> com mensagem clara é melhor que esperar o timeout — o log já entrega a causa.

## 5. Causa Raiz Encontrada (Análise)

O texto do botão principal em `lib/screens/login_screen.dart` (linha 294) foi
alterado de `'Entrar'` para `'Acessar'`:

```dart
BotaoCustomizado(
  texto: 'Acessar',          // era: 'Entrar'
  carregando: _entrando,
  aoTocar: _podeEntrar ? _entrar : null,
),
```

A alteração é puramente visual e **não quebrou o aplicativo para o usuário
humano** — o login continua funcionando se a pessoa clicar no botão. O que
quebrou foi o script de automação, que localiza o botão pelo texto exato
(`find.text('Entrar')`) e passou a não encontrá-lo.

Esse é justamente o valor do teste de regressão: uma mudança que parecia
inofensiva foi barrada automaticamente antes de chegar à produção.

## 6. Correção Aplicada

Havia duas opções:

| Opção | Ação | Avaliação |
|---|---|---|
| **A** | Reverter o botão para `Text('Entrar')` | ✅ **Escolhida** |
| **B** | Atualizar o robô para `find.text('Acessar')` | ❌ Descartada |

**Justificativa:** a regra geral é que o teste deve se adaptar às melhorias da
interface — mas isso vale quando a mudança de interface foi *intencional e
aprovada*. Aqui não foi: a alteração entrou sem passar pela equipe de testes e
sem justificativa de produto. Adaptar o teste (Opção B) seria legitimar uma
mudança não combinada e, pior, destruir a única evidência de que ela aconteceu.

A Opção A restaura o comportamento acordado. Se no futuro o time decidir que
"Acessar" é de fato o melhor rótulo, aí sim o caminho correto é alterar a
interface **e** o teste na mesma entrega, de forma consciente.

## 7. Validação da Correção

Após reverter o rótulo para `'Entrar'`:

```
00:00 +0: Validação Funcional: o robô faz login sozinho
00:06 +1: (tearDownAll)
00:06 +1: All tests passed!
```

Ciclo completo de Qualidade de Software concluído:
**Criação do Teste → Detecção de Regressão → Análise → Documentação → Correção.**
