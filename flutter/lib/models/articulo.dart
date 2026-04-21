/// articulo.dart
///
/// Modelo de dominio para un Artículo.
/// Incluye la lógica de cálculo de precio con descuento y valoración en estrellas.

class Articulo {
  final int?    id;
  final String  articulo;
  final double  precio;
  final double  descuento;
  final String  urlimagen;
  final double  valoracion;     // Escala 0–50; dividir entre 10 = estrellas (0–5)
  final int     calificaciones;
  final String  descripcion;

  const Articulo({
    this.id,
    required this.articulo,
    required this.precio,
    required this.descuento,
    required this.urlimagen,
    required this.valoracion,
    required this.calificaciones,
    required this.descripcion,
  });

  // ── Lógica de negocio ──────────────────────────────────────────────────────

  /// Indica si el artículo tiene descuento activo.
  bool get tieneDescuento => descuento > 0;

  /// Precio final: precio * (1 - descuento/100).
  /// Si no hay descuento, retorna el precio original.
  double get precioFinal {
    if (!tieneDescuento) return precio;
    return precio * (1 - descuento / 100);
  }

  /// Precio original formateado (antes del descuento).
  double get precioOriginal => precio;

  /// Valoración en escala 0–5 para mostrar estrellas.
  double get estrellas => valoracion / 10.0;

  // ── Serialización ──────────────────────────────────────────────────────────

  /// Construye un [Articulo] desde el JSON de la API o de la BD.
  factory Articulo.fromJson(Map<String, dynamic> json) => Articulo(
        id:            json['id'] as int?,
        articulo:      json['articulo'] as String,
        precio:        _toDouble(json['precio']),
        descuento:     _toDouble(json['descuento']),
        urlimagen:     json['urlimagen'] as String? ?? '',
        valoracion:    _toDouble(json['valoracion']),
        calificaciones: _toInt(json['calificaciones']),
        descripcion:   json['descripcion'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id':            id,
        'articulo':      articulo,
        'precio':        precio,
        'descuento':     descuento,
        'urlimagen':     urlimagen,
        'valoracion':    valoracion,
        'calificaciones': calificaciones,
        'descripcion':   descripcion,
      };

  // ── Helpers ────────────────────────────────────────────────────────────────

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }
}
