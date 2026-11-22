import 'dart:convert';
import 'package:http/http.dart' as http;
import '../errors/app_exceptions.dart';
import 'http_helper.dart';
import 'token_storage.dart';

class AuthService {
  static const _base = 'https://dummyjson.com'; // HTTPS
  final TokenStorage _tokens = TokenStorage();

  /// POST /auth/login -> extrai o accessToken do JSON e grava no secure storage.
  Future<void> login(String usuario, String senha) async {
    // 1) Envia usuário e senha para a API.
    final resp = await executar(() => http.post(
      Uri.parse('$_base/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': usuario,
        'password': senha,
        'expiresInMins': 30,
      }),
    ));

    // 2) Interpreta o código de status da resposta.
    if (resp.statusCode == 400 || resp.statusCode == 401) {
      throw const CredenciaisInvalidasException();
    }
    if (resp.statusCode != 200) {
      throw ErroServidorException(resp.statusCode);
    }

    // 3) Lê o JSON e extrai o accessToken.
    String? token;
    try {
      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      token = json['accessToken'] as String?;
    } on FormatException {
      throw const RespostaInvalidaException();
    } on TypeError {
      throw const RespostaInvalidaException();
    }
    if (token == null || token.isEmpty) {
      throw const RespostaInvalidaException();
    }

    // 4) Guarda o token no armazenamento seguro.
    await _tokens.salvar(token); // pode lançar ArmazenamentoException
  }

  /// Logout: apenas remove o token guardado.
  Future<void> logout() => _tokens.apagar();
}