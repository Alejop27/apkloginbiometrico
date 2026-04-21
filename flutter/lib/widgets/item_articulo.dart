/// item_articulo.dart
///
/// Widget ItemArticulo (10pts)
///
/// Tarjeta compacta para usar en listas ([ListaArticulos] y [ListaOfertas]).
/// Muestra:
///  1. Imagen del artículo (con caché).
///  2. Nombre del artículo.
///  3. Precio: si tiene descuento → precio final; si no → precio normal.
///  4. Badge de porcentaje de descuento (solo si aplica).
///  5. Widget [Valoracion].

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/articulo.dart';
import 'valoracion.dart';

/// Tarjeta de artículo para listas.
///
/// [articulo]  : datos del producto.
/// [onTap]     : callback al pulsar la tarjeta (navega a [FichaArticulo]).
class ItemArticulo extends StatelessWidget {
  final Articulo     articulo;
  final VoidCallback onTap;

  const ItemArticulo({
    super.key,
    required this.articulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Imagen ────────────────────────────────────────────────────────
            _ArticuloImage(url: articulo.urlimagen),

            // ── Contenido ─────────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge de descuento
                    if (articulo.tieneDescuento)
                      _DiscountBadge(percent: articulo.descuento),

                    const SizedBox(height: 4),

                    // Nombre
                    Text(
                      articulo.articulo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.35,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Precio
                    _PriceRow(articulo: articulo),

                    const SizedBox(height: 8),

                    // Valoración
                    Valoracion(
                      valoracion: articulo.valoracion,
                      size: 15,
                    ),
                  ],
                ),
              ),
            ),

            // Chevron
            const Padding(
              padding: EdgeInsets.only(top: 14, right: 8),
              child: Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondary, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

/// Imagen con bordes redondeados izquierdos y placeholder de carga.
class _ArticuloImage extends StatelessWidget {
  final String url;
  const _ArticuloImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
      child: CachedNetworkImage(
        imageUrl: url,
        width: 100,
        height: 110,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          width: 100, height: 110,
          color: AppColors.accentBlue.withOpacity(0.12),
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2, color: AppColors.accentBlue),
          ),
        ),
        errorWidget: (_, __, ___) => Container(
          width: 100, height: 110,
          color: AppColors.accentBlue.withOpacity(0.1),
          child: const Icon(Icons.image_not_supported_outlined,
              color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

/// Badge de descuento: muestra "X% OFF" en verde menta.
class _DiscountBadge extends StatelessWidget {
  final double percent;
  const _DiscountBadge({required this.percent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.accentGreen.withOpacity(0.25),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '${percent.toStringAsFixed(0)}% OFF',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.priceDiscount,
        ),
      ),
    );
  }
}

/// Fila de precio: muestra precio final y, si hay descuento, tachado el original.
class _PriceRow extends StatelessWidget {
  final Articulo articulo;
  const _PriceRow({required this.articulo});

  String _format(double v) =>
      '\$${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Precio final (normal o con descuento)
        Text(
          _format(articulo.precioFinal),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: articulo.tieneDescuento
                ? AppColors.priceDiscount
                : AppColors.textPrimary,
          ),
        ),
        // Precio original tachado (solo si tiene descuento)
        if (articulo.tieneDescuento)
          Text(
            _format(articulo.precioOriginal),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.priceOriginal,
              decoration: TextDecoration.lineThrough,
              decorationColor: AppColors.priceOriginal,
            ),
          ),
      ],
    );
  }
}
