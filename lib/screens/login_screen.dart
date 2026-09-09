import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../components/botao_customizado.dart';
import '../components/campo_formulario_customizado.dart';
import '../database/database_helper.dart';
import '../estilo.dart';
import '../models/cliente.dart';
import '../models/usuario.dart';
import 'home_screen.dart';

/// Tela de entrada: confere e-mail e senha na tabela `usuario` do SQLite,
/// ou deixa entrar como visitante.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _senha = TextEditingController();

  bool _senhaVisivel = false;
  bool _entrando = false;

  @override
  void initState() {
    super.initState();
    // Reavalia se o botao "Entrar" pode ser liberado a cada letra digitada.
    _email.addListener(_redesenhar);
    _senha.addListener(_redesenhar);
  }

  void _redesenhar() => setState(() {});

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  bool get _podeEntrar =>
      Usuario.emailValido(_email.text) && _senha.text.isNotEmpty;

  Future<void> _entrar() async {
    setState(() => _entrando = true);

    try {
      final usuario = await DatabaseHelper.instancia.autenticar(
        _email.text,
        _senha.text,
      );

      if (!mounted) return;

      if (usuario == null) {
        setState(() => _entrando = false);
        aviso(context, 'E-mail ou senha inválidos.', erro: true);
        return;
      }

      _abrirInicio(usuario);
    } catch (erro) {
      if (!mounted) return;
      setState(() => _entrando = false);
      aviso(context, 'Não foi possível abrir o banco: $erro', erro: true);
    }
  }

  /// O usuario logado (ou `null`, no modo visitante) segue para a tela
  /// inicial e de la para o cadastro, para gravar quem fez a avaliacao.
  void _abrirInicio(Cliente? usuario) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomeScreen(usuario: usuario)),
    );
  }

  void _esqueciSenha() {
    showDialog<void>(
      context: context,
      builder: (dialogo) => AlertDialog(
        title: Text('Recuperar senha', style: Fonte.titulo(tamanho: 20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'O Coma Bem guarda tudo no seu aparelho, então não há envio de '
              'e-mail de recuperação.\n\nVocê pode criar uma conta nova ou '
              'usar a conta de demonstração:',
              style: Fonte.corpo(altura: 1.5),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: cartao(borda: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('miguel@comabem.com', style: Fonte.mono(tamanho: 13)),
                  const SizedBox(height: 4),
                  Text('123456', style: Fonte.mono(tamanho: 13)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogo),
            child: Text('Fechar', style: Fonte.corpo(cor: Cores.textoSuave)),
          ),
          TextButton(
            onPressed: () {
              _email.text = 'miguel@comabem.com';
              _senha.text = '123456';
              Navigator.pop(dialogo);
            },
            child: Text(
              'Preencher',
              style: Fonte.corpo(cor: Cores.terracota, peso: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _criarConta() async {
    final novo = await showDialog<Cliente>(
      context: context,
      builder: (_) => const _DialogoCriarConta(),
    );

    if (novo != null && mounted) _abrirInicio(novo);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Cores.creme,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _cabecalho(context),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 26, 22, 30),
                child: _formulario(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cabecalho(BuildContext context) {
    final alturaBarra = MediaQuery.of(context).padding.top;

    return ClipPath(
      clipper: const CurvaCabecalho(),
      child: Container(
        height: 258 + alturaBarra,
        color: Cores.terracota,
        child: Stack(
          children: [
            const Positioned.fill(
              child: CustomPaint(painter: Pontilhado(espacamento: 26)),
            ),
            // Positioned.fill faz a coluna ocupar a largura toda; sem isso ela
            // encolhe no texto e o conteudo gruda na esquerda.
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.only(top: alturaBarra),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.24),
                        ),
                      ),
                      child: const Icon(
                        Icons.restaurant_menu,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Coma Bem',
                      style: Fonte.titulo(
                        tamanho: 36,
                        cor: Colors.white,
                        peso: 800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Seu diário gastronômico pessoal',
                      style: Fonte.corpo(
                        tamanho: 13.5,
                        cor: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 26),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _formulario() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Bem-vindo de volta', style: Fonte.titulo(tamanho: 27)),
        const SizedBox(height: 6),
        Text(
          'Entre para ver seus restaurantes favoritos',
          style: Fonte.corpo(cor: Cores.textoSuave),
        ),
        const SizedBox(height: 24),

        CampoFormularioCustomizado(
          titulo: 'E-mail',
          controlador: _email,
          dica: 'seu@email.com',
          tipoTeclado: TextInputType.emailAddress,
          acaoDoTeclado: TextInputAction.next,
          corrigirTexto: false,
        ),

        CampoFormularioCustomizado(
          titulo: 'Senha',
          controlador: _senha,
          dica: '••••••••',
          ocultarTexto: !_senhaVisivel,
          acaoDoTeclado: TextInputAction.done,
          aoEnviar: (_) {
            if (_podeEntrar && !_entrando) _entrar();
          },
          espacoAbaixo: 0,
          sufixo: IconButton(
            onPressed: () => setState(() => _senhaVisivel = !_senhaVisivel),
            tooltip: _senhaVisivel ? 'Ocultar senha' : 'Mostrar senha',
            icon: Icon(
              _senhaVisivel
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 20,
              color: Cores.textoSuave,
            ),
          ),
        ),

        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _esqueciSenha,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Esqueci a senha',
              style: Fonte.corpo(
                tamanho: 13,
                cor: Cores.terracota,
                peso: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),

        BotaoCustomizado(
          texto: 'Entrar',
          carregando: _entrando,
          aoTocar: _podeEntrar ? _entrar : null,
        ),
        const SizedBox(height: 22),

        Row(
          children: [
            const Expanded(child: Divider(color: Cores.borda, height: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                'ou',
                style: Fonte.corpo(tamanho: 12.5, cor: Cores.textoSuave),
              ),
            ),
            const Expanded(child: Divider(color: Cores.borda, height: 1)),
          ],
        ),
        const SizedBox(height: 22),

        BotaoContornado(
          texto: 'Acessar como visitante',
          icone: Icons.visibility_outlined,
          aoTocar: _entrando ? null : () => _abrirInicio(null),
        ),
        const SizedBox(height: 14),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Não tem conta?',
              style: Fonte.corpo(tamanho: 13.5, cor: Cores.textoSuave),
            ),
            TextButton(
              onPressed: _entrando ? null : _criarConta,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Criar conta',
                style: Fonte.corpo(
                  tamanho: 13.5,
                  cor: Cores.terracota,
                  peso: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Cadastro de usuario novo, em uma janela sobre o login.
class _DialogoCriarConta extends StatefulWidget {
  const _DialogoCriarConta();

  @override
  State<_DialogoCriarConta> createState() => _DialogoCriarContaState();
}

class _DialogoCriarContaState extends State<_DialogoCriarConta> {
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _senha = TextEditingController();

  bool _salvando = false;
  String? _erroEmail;

  @override
  void initState() {
    super.initState();
    for (final c in [_nome, _email, _senha]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  bool get _podeSalvar =>
      _nome.text.trim().isNotEmpty &&
      Usuario.emailValido(_email.text) &&
      Usuario.senhaValida(_senha.text);

  Future<void> _salvar() async {
    setState(() {
      _salvando = true;
      _erroEmail = null;
    });

    try {
      final novo = await DatabaseHelper.instancia.cadastrarUsuario(
        nome: _nome.text,
        email: _email.text,
        senha: _senha.text,
      );
      if (!mounted) return;
      Navigator.pop(context, novo);
    } on EmailJaCadastradoErro {
      if (!mounted) return;
      setState(() {
        _salvando = false;
        _erroEmail = 'Este e-mail já está cadastrado.';
      });
    } catch (erro) {
      if (!mounted) return;
      setState(() => _salvando = false);
      aviso(context, 'Não foi possível criar a conta: $erro', erro: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Criar conta', style: Fonte.titulo(tamanho: 21)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CampoFormularioCustomizado(
              titulo: 'Nome',
              controlador: _nome,
              dica: 'Como quer ser chamado',
              capitalizacao: TextCapitalization.words,
              acaoDoTeclado: TextInputAction.next,
              espacoAbaixo: 16,
            ),

            CampoFormularioCustomizado(
              titulo: 'E-mail',
              controlador: _email,
              dica: 'seu@email.com',
              tipoTeclado: TextInputType.emailAddress,
              acaoDoTeclado: TextInputAction.next,
              corrigirTexto: false,
              erro: _erroEmail,
              espacoAbaixo: 16,
            ),

            CampoFormularioCustomizado(
              titulo: 'Senha',
              controlador: _senha,
              dica: 'Mínimo de 6 caracteres',
              ocultarTexto: true,
              acaoDoTeclado: TextInputAction.done,
              aoEnviar: (_) {
                if (_podeSalvar && !_salvando) _salvar();
              },
              erro: _senha.text.isNotEmpty && !Usuario.senhaValida(_senha.text)
                  ? 'A senha precisa ter pelo menos 6 caracteres.'
                  : null,
              espacoAbaixo: 0,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _salvando ? null : () => Navigator.pop(context),
          child: Text('Cancelar', style: Fonte.corpo(cor: Cores.textoSuave)),
        ),
        TextButton(
          onPressed: _podeSalvar && !_salvando ? _salvar : null,
          child: Text(
            _salvando ? 'Salvando...' : 'Criar',
            style: Fonte.corpo(
              cor: _podeSalvar ? Cores.terracota : Cores.textoSuave,
              peso: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
