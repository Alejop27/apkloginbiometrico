/// ficha_articulo.dart
///
/// Widget FichaArticulo (16pts)
///
/// Vista de detalle completo de un artículo. Muestra:
///  1. Imagen grande del artículo.
///  2. Badge de descuento (si aplica).
///  3. Nombre del artículo.
///  4. Precio final con descuento aplicado (en verde) o precio normal.
///  5. Precio original tachado (solo si tiene descuento) — "Antes $X".
///  6. Widget [Valoracion] con número de estrellas y valor numérico.
///  7. Número de calificaciones.
///  8. Descripción completa del producto.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/articulo.dart';
import 'valoracion.dart';

/// Pantalla de detalle de un artículo.
///
/// [articulo] : datos completos del producto a mostrar.
class FichaArticulo extends StatelessWidget {
  final Articulo articulo;

  const FichaArticulo({super.key, required this.articulo});

  // ── Helpers de formato ────────────────────────────────────────────────────

  /// Formatea un número como precio en COP: $1.234.567
  String _formatPrice(double v) {
    final parts = v.toStringAsFixed(0).split('');
    final reversed = parts.reversed.toList();
    final withDots = <String>[];
    for (int i = 0; i < reversed.length; i++) {
      if (i > 0 && i % 3 == 0) withDots.add('.');
      withDots.add(reversed[i]);
    }
    return '\$${withDots.reversed.join('')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── AppBar con imagen de fondo ──────────────────────────────────
          _buildSliverAppBar(context),

          // ── Contenido ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Badge de descuento
                  if (articulo.tieneDescuento) ...[
                    _DiscountBadgeLarge(percent: articulo.descuento),
                    const SizedBox(height: 12),
                  ],

                  // 2. Nombre del artículo
                  Text(
                    articulo.articulo,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.3,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3 + 4. Precios
                  _PriceSection(articulo: articulo, formatPrice: _formatPrice),
                  const SizedBox(height: 16),

                  // Separador
                  const Divider(color: AppColors.divider, height: 1),
                  const SizedBox(height: 16),

                  // 5. Valoración con conteo
                  _RatingSection(articulo: articulo),
                  const SizedBox(height: 20),

                  // Separador
                  const Divider(color: AppColors.divider, height: 1),
                  const SizedBox(height: 20),

                  // 6. Descripción
                  _DescripcionSection(descripcion: articulo.descripcion),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── SliverAppBar con imagen hero ──────────────────────────────────────────

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.background,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.card.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: AppTheme.cardShadow,
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 18),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: _HeroImage(url: articulo.urlimagen),
      ),
    );
  }
}

// ── Sub-widgets de FichaArticulo ─────────────────────────────────────────────

/// Imagen hero de gran tamaño con degradado inferior.
class _HeroImage extends StatelessWidget {
  final String url;
  const _HeroImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.contain,
          placeholder: (_, __) => Container(
            color: AppColors.accentBlue.withOpacity(0.1),
            child: const Center(
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.accentBlue),
            ),
          ),
          errorWidget: (_, __, ___) => Container(
            color: AppColors.accentBlue.withOpacity(0.08),
            child: const Icon(Icons.image_not_supported_outlined,
                size: 48, color: AppColors.textSecondary),
          ),
        ),
        // Degradado para mejorar legibilidad del appbar
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.background.withOpacity(0.3),
                Colors.transparent,
                AppColors.background.withOpacity(0.6),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}

/// Badge grande de descuento con ícono de etiqueta.
class _DiscountBadgeLarge extends StatelessWidget {
  final double percent;
  const _DiscountBadgeLarge({required this.percent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accentGreen.withOpacity(0.25),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: AppColors.accentGreen.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_offer_rounded,
              size: 14, color: AppColors.priceDiscount),
          const SizedBox(width: 6),
          Text(
            '${percent.toStringAsFixed(0)}% DE DESCUENTO',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.priceDiscount,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Sección de precios: precio final + precio original tachado.
class _PriceSection extends StatelessWidget {
  final Articulo          articulo;
  final String Function(double) formatPrice;

  const _PriceSection(
      {required this.articulo, required this.formatPrice});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Precio final
        Text(
          formatPrice(articulo.precioFinal),
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: articulo.tieneDescuento
                ? AppColors.priceDiscount
                : AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        // Precio original tachado
        if (articulo.tieneDescuento) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Text(
                'Antes ',
                style: TextStyle(
                    fontSize: 13, color: AppColors.textSecondary),
              ),
              Text(
                formatPrice(articulo.precioOriginal),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.priceOriginal,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: AppColors.priceOriginal,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Sección de valoración: estrellas + número de calificaciones.
class _RatingSection extends StatelessWidget {
  final Articulo articulo;
  const _RatingSection({required this.articulo});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Estrellas y valor numérico
        Valoracion(
          valoracion: articulo.valoracion,
          size: 22,
        ),
        const Spacer(),
        // Número de calificaciones
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.accentBlue.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.people_outline_rounded,
                  size: 15, color: AppColors.accentBlue),
              const SizedBox(width: 5),
              Text(
                '${articulo.calificaciones} calificaciones',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Sección de descripción del producto.
class _DescripcionSection extends StatelessWidget {
  final String descripcion;
  const _DescripcionSection({required this.descripcion});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descripción',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          descripcion.isEmpty ? 'Sin descripción disponible.' : descripcion,
          style: const TextStyle(
            fontSize: 14.5,
            color: AppColors.textSecondary,
            height: 1.65,
          ),
        ),
      ],
    );
  }
}
