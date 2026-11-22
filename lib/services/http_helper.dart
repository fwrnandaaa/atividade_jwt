import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../errors/app_exceptions.dart';

/// Tempo máximo de espera por uma resposta do servidor.
const _limite = Duration(seconds: 10);

/// Executa uma requisição aplicando timeout e convertendo falhas de
/// rede em exceções do app (servidor indisponível / timeout).
Future<http.Response> executar(
    Future<http.Response> Function() requisicao) async {
  try {
    return await requisicao().timeout(_limite);
  } on TimeoutException {
    throw const TimeoutConexaoException();
  } on SocketException {
    throw const ServidorIndisponivelException();
  } on HandshakeException {
    throw const ServidorIndisponivelException();
  } on http.ClientException {
    throw const ServidorIndisponivelException();
  }
}