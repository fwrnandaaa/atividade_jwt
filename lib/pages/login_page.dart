import 'package:flutter/material.dart';
import '../errors/app_exceptions.dart';
import '../services/auth_service.dart';
import '../services/prefs_service.dart';
import 'lista_page.dart';

class LoginPage extends StatefulWidget {
  /// Mensagem exibida ao chegar aqui (ex.: "Sessão expirada").
  final String? mensagem;
  const LoginPage({super.key, this.mensagem});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usuario = TextEditingController();
  final _senha = TextEditingController();
  final _auth = AuthService();
  bool _carregando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _erro = widget.mensagem;
    // SharedPreferences: apenas o nome de usuário (nunca a senha).
    PrefsService.lerUltimoUsuario().then((u) {
      if (u != null && mounted) _usuario.text = u;
    });
  }

  @override
  void dispose() {
    _usuario.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      await _auth.login(_usuario.text.trim(), _senha.text);
      await PrefsService.salvarUltimoUsuario(_usuario.text.trim());
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ListaPage()));
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = e.message;
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.lock_outline, size: 64, color: cores.primary),
                  const SizedBox(height: 16),
                  Text('Entrar',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _usuario,
                    decoration: const InputDecoration(
                      labelText: 'Usuário',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _senha,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Senha',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _carregando ? null : _entrar(),
                  ),
                  if (_erro != null) ...[
                    const SizedBox(height: 12),
                    Text(_erro!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: cores.error)),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _carregando ? null : _entrar,
                    child: _carregando
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Text('Entrar'),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Teste: emilys / emilyspass',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: cores.outline),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}