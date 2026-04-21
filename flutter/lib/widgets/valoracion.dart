/// valoracion.dart
///
/// Widget Valoracion (6pts)
///
/// Muestra la calificación de un artículo como estrellas pastel.
/// El campo [valoracion] de la API está en escala 0–50; se divide entre 10
/// para obtener los puntos 0–5 de estrellas.
///
/// Ejemplo: valoracion = 32 → 3.2 estrellas → 3 llenas, 1 parcial, 1 vacía.

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Widget de valoración con estrellas.
///
/// [valoracion] : valor crudo de la API (0–50).
/// [calificaciones] : número de reseñas (opcional; se muestra si > 0).
/// [showCount] : si true, muestra el conteo de calificaciones al lado.
/// [size] : tamaño de cada estrella en puntos lógicos.
class Valoracion extends StatelessWidget {
  /// Valor bruto de la API en escala 0–50.
  final double valoracion;

  /// Número total de calificaciones recibidas.
  final int calificaciones;

  /// Si true muestra "(N calificaciones)" junto a las estrellas.
  final bool showCount;

  /// Tamaño de cada icono de estrella.
  final double size;

  const Valoracion({
    super.key,
    required this.valoracion,
    this.calificaciones = 0,
    this.showCount = false,
    this.size = 18,
  });

  /// Convierte el valor 0–50 a escala 0–5 con un decimal.
  double get _estrellas => (valoracion / 10.0).clamp(0.0, 5.0);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Estrellas
        ...List.generate(5, (i) => _buildStar(i)),

        // Valor numérico (e.g. "3.2")
        const SizedBox(width: 6),
        Text(
          _estrellas.toStringAsFixed(1),
          style: TextStyle(
            fontSize: size * 0.75,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),

        // Número de calificaciones
        if (showCount && calificaciones > 0) ...[
          const SizedBox(width: 4),
          Text(
            '($calificaciones)',
            style: TextStyle(
              fontSize: size * 0.7,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  /// Construye una estrella en la posición [index] (0-based).
  ///
  /// Lógica:
  ///  - Si index < parte entera → estrella completa.
  ///  - Si index == parte entera y fracción >= 0.25 → estrella media.
  ///  - En otro caso → estrella vacía.
  Widget _buildStar(int index) {
    final full     = _estrellas.floor();
    final fraction = _estrellas - full;

    IconData icon;
    Color    color;

    if (index < full) {
      icon  = Icons.star_rounded;
      color = AppColors.starFilled;
    } else if (index == full && fraction >= 0.25) {
      icon  = Icons.star_half_rounded;
      color = AppColors.starFilled;
    } else {
      icon  = Icons.star_outline_rounded;
      color = AppColors.starEmpty;
    }

    return Icon(icon, size: size, color: color);
  }
}
