/// Representa um produto retornado pela API.
/// Guardamos só os campos que o app usa.
class Produto {
  final int id;
  final String titulo;
  final double preco;
  final String categoria;

  const Produto({
    required this.id,
    required this.titulo,
    required this.preco,
    required this.categoria,
  });

  /// Converte um trecho de JSON (já transformado em Map) em um Produto.
  /// Se o JSON vier num formato inesperado (campo faltando ou com tipo
  /// errado), o "as" lança um TypeError, que o ApiService trata como
  /// "resposta inválida".
  factory Produto.fromJson(Map<String, dynamic> json) => Produto(
    id: json['id'] as int,
    titulo: json['title'] as String,
    preco: (json['price'] as num).toDouble(),
    categoria: json['category'] as String,
  );
}