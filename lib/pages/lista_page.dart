import 'package:flutter/material.dart';
import '../errors/app_exceptions.dart';
import '../models/produto.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/prefs_service.dart';
import '../services/token_storage.dart';
import 'login_page.dart';

class ListaPage extends StatefulWidget {
  const ListaPage({super.key});

  @override
  State<ListaPage> createState() => _ListaPageState();
}

class _ListaPageState extends State<ListaPage> {
  final _api = ApiService();
  final _busca = TextEditingController();

  List<Produto> _produtos = [];
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _iniciar();
  }

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  Future<void> _iniciar() async {
    // SharedPreferences: restaura a última pesquisa (dado não sensível).
    _busca.text = await PrefsService.lerUltimaPesquisa() ?? '';
    await _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final lista = await _api.listarProdutos();
      if (!mounted) return;
      setState(() {
        _produtos = lista;
        _carregando = false;
      });
    } on TokenExpiradoException catch (e) {
      // 401: token já foi removido do secure storage pelo ApiService.
      _irParaLogin(e.message);
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = e.message;
        _carregando = false;
      });
    }
  }

  void _irParaLogin(String mensagem) {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginPage(mensagem: mensagem)),
          (_) => false,
    );
  }

  Future<void> _sair() async {
    try {
      await AuthService().logout();
    } on AppException catch (_) {
      // Mesmo se falhar ao apagar, volta ao login.
    }
    _irParaLogin('Você saiu da sessão.');
  }

  /// Apenas para demonstração (captura de tela "token inválido").
  Future<void> _simularTokenInvalido() async {
    try {
      await TokenStorage().salvar('token.invalido.para.teste');
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
      return;
    }
    await _carregar();
  }

  @override
  Widget build(BuildContext context) {
    final termo = _busca.text.toLowerCase();
    final filtrados = _produtos
        .where((p) => p.titulo.toLowerCase().contains(termo))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
        actions: [
          IconButton(
            tooltip: 'Alternar tema',
            icon: const Icon(Icons.brightness_6),
            onPressed: PrefsService.alternarTema,
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'sair') _sair();
              if (v == 'invalido') _simularTokenInvalido();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                  value: 'invalido', child: Text('Simular token inválido')),
              PopupMenuItem(value: 'sair', child: Text('Sair')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _busca,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                labelText: 'Buscar produto',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) {
                setState(() {});
                PrefsService.salvarUltimaPesquisa(v);
              },
            ),
          ),
          Expanded(child: _conteudo(filtrados)),
        ],
      ),
    );
  }

  Widget _conteudo(List<Produto> filtrados) {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 64),
              const SizedBox(height: 12),
              Text(_erro!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                  onPressed: _carregar, child: const Text('Tentar novamente')),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _carregar,
      child: ListView.builder(
        itemCount: filtrados.length,
        itemBuilder: (_, i) {
          final p = filtrados[i];
          return ListTile(
            leading: CircleAvatar(child: Text('${p.id}')),
            title: Text(p.titulo),
            subtitle: Text(p.categoria),
            trailing: Text(
              'US\$ ${p.preco.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }
}