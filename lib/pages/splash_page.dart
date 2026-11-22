import 'package:flutter/material.dart';
import '../errors/app_exceptions.dart';
import '../services/token_storage.dart';
import 'lista_page.dart';
import 'login_page.dart';

/// Tela inicial: se já existe token no secure storage vai direto para a lista
/// (sessão persistida); caso contrário, para o login.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _decidir();
  }

  Future<void> _decidir() async {
    Widget destino;
    try {
      final token = await TokenStorage().ler();
      destino = (token != null && token.isNotEmpty)
          ? const ListaPage()
          : const LoginPage();
    } on ArmazenamentoException catch (e) {
      destino = LoginPage(mensagem: e.message);
    }
    if (!mounted) return;
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => destino));
  }

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}