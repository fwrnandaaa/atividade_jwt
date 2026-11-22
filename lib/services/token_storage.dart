import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../errors/app_exceptions.dart';

/// Único lugar do app que toca no token JWT.
/// Usa Keychain (iOS) e Keystore (Android) via flutter_secure_storage.
class TokenStorage {
  static const _chave = 'access_token';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Grava o token no armazenamento seguro.
  Future<void> salvar(String token) async {
    try {
      await _storage.write(key: _chave, value: token);
    } catch (_) {
      throw const ArmazenamentoException(
          'Falha ao gravar a sessão no armazenamento seguro.');
    }
  }

  /// Lê o token. Retorna null se ainda não houver nenhum salvo.
  Future<String?> ler() async {
    try {
      return await _storage.read(key: _chave);
    } catch (_) {
      throw const ArmazenamentoException(
          'Falha ao ler a sessão do armazenamento seguro.');
    }
  }

  /// Remove o token (usado no logout e quando a API responde 401).
  Future<void> apagar() async {
    try {
      await _storage.delete(key: _chave);
    } catch (_) {
      throw const ArmazenamentoException(
          'Falha ao remover a sessão do armazenamento seguro.');
    }
  }
}