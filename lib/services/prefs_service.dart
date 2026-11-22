import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences: SOMENTE dados não sensíveis
/// (tema, último usuário digitado, última pesquisa).
/// NUNCA guardar senha ou token aqui (texto plano no dispositivo).
class PrefsService {
  static const _kTema = 'tema_escuro';
  static const _kUsuario = 'ultimo_usuario';
  static const _kBusca = 'ultima_pesquisa';

  /// Guarda o tema atual. A tela "escuta" esse valor e se redesenha
  /// sozinha quando ele muda.
  static final ValueNotifier<ThemeMode> tema = ValueNotifier(ThemeMode.light);

  /// Lê o tema salvo (chamado uma vez ao abrir o app).
  static Future<void> carregarTema() async {
    try {
      final p = await SharedPreferences.getInstance();
      tema.value =
      (p.getBool(_kTema) ?? false) ? ThemeMode.dark : ThemeMode.light;
    } catch (_) {}
  }

  /// Troca claro <-> escuro e salva a escolha.
  static Future<void> alternarTema() async {
    final escuro = tema.value == ThemeMode.light;
    tema.value = escuro ? ThemeMode.dark : ThemeMode.light;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(_kTema, escuro);
    } catch (_) {}
  }

  static Future<String?> lerUltimoUsuario() => _ler(_kUsuario);
  static Future<void> salvarUltimoUsuario(String v) => _salvar(_kUsuario, v);

  static Future<String?> lerUltimaPesquisa() => _ler(_kBusca);
  static Future<void> salvarUltimaPesquisa(String v) => _salvar(_kBusca, v);

  static Future<String?> _ler(String chave) async {
    try {
      return (await SharedPreferences.getInstance()).getString(chave);
    } catch (_) {
      return null;
    }
  }

  static Future<void> _salvar(String chave, String valor) async {
    try {
      await (await SharedPreferences.getInstance()).setString(chave, valor);
    } catch (_) {}
  }
}