/// Exceções próprias do app: cada cenário de falha exigido
/// na atividade tem a sua classe, com uma mensagem pronta para a tela.
class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

/// Sem internet, servidor fora do ar, DNS falhou, etc.
class ServidorIndisponivelException extends AppException {
  const ServidorIndisponivelException()
      : super('Servidor indisponível. Verifique sua conexão e tente novamente.');
}

/// A requisição demorou mais que o limite (10 segundos).
class TimeoutConexaoException extends AppException {
  const TimeoutConexaoException()
      : super('Tempo de conexão esgotado. Tente novamente.');
}

/// Usuário ou senha errados no login.
class CredenciaisInvalidasException extends AppException {
  const CredenciaisInvalidasException()
      : super('Usuário ou senha inválidos.');
}

/// A API respondeu 401: o token é inválido ou expirou.
class TokenExpiradoException extends AppException {
  const TokenExpiradoException()
      : super('Sessão expirada. Faça login novamente.');
}

/// O servidor respondeu, mas o JSON veio quebrado ou em formato inesperado.
class RespostaInvalidaException extends AppException {
  const RespostaInvalidaException()
      : super('O servidor enviou uma resposta inválida.');
}

/// Falha ao ler, gravar ou apagar no flutter_secure_storage.
class ArmazenamentoException extends AppException {
  const ArmazenamentoException(super.message);
}

/// Qualquer outro status HTTP inesperado (500, 404, etc.).
class ErroServidorException extends AppException {
  const ErroServidorException(int status)
      : super('Erro inesperado do servidor (HTTP $status).');
}