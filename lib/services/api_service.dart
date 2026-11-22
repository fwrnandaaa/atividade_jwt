import 'dart:convert';
import 'package:http/http.dart' as http;
import '../errors/app_exceptions.dart';
import '../models/produto.dart';
import 'http_helper.dart';
import 'token_storage.dart';

class ApiService {
  static const _base = 'https://dummyjson.com'; // HTTPS
  final TokenStorage _tokens = TokenStorage();

  /// GET /auth/products com Authorization: Bearer <token>.
  /// Em caso de 401/403: apaga o token e lança TokenExpiradoException.
  Future<List<Produto>> listarProdutos() async {
    // 1) Recupera o token do armazenamento seguro.
    final token = await _tokens.ler();
    if (token == null || token.isEmpty) {
      throw const TokenExpiradoException();
    }

    // 2) Faz o GET enviando o token no cabeçalho.
    final resp = await executar(() => http.get(
      Uri.parse('$_base/auth/products?limit=30'),
      headers: {'Authorization': 'Bearer $token'},
    ));

    // 3) Interpreta o código de status.
    if (resp.statusCode == 401 || resp.statusCode == 403) {
      await _tokens.apagar();
      throw const TokenExpiradoException();
    }
    if (resp.statusCode != 200) {
      throw ErroServidorException(resp.statusCode);
    }

    // 4) Converte o JSON em uma lista de Produto.
    try {
      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      final lista = json['products'] as List<dynamic>;
      return lista
          .map((e) => Produto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on FormatException {
      throw const RespostaInvalidaException();
    } on TypeError {
      throw const RespostaInvalidaException();
    }
  }
}