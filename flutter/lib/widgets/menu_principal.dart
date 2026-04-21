/// menu_principal.dart
///
/// Widget MenuPrincipal (2pts)
///
/// Presenta el menú de navegación principal con dos acciones:
///  - Artículos → navega a la lista completa.
///  - Ofertas    → navega a la lista filtrada con descuento.

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Menú principal de la aplicación.
///
/// Recibe callbacks para desacoplar la navegación del widget
/// y mantenerlo puro (sin dependencias de Navigator).
class MenuPrincipal extends StatelessWidget {
  final VoidCallback onArticulosPressed;
  final VoidCallback onOfertasPressed;
  final VoidCallback onLogoutPressed;

  const MenuPrincipal({
    super.key,
    required this.onArticulosPressed,
    required this.onOfertasPressed,
    required this.onLogoutPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Menú Principal'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout_rounded, color: AppColors.textSecondary),
            onPressed: onLogoutPressed,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Explora nuestro catálogo',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Elige una sección para continuar',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 40),
            _MenuCard(
              icon: Icons.inventory_2_outlined,
              title: 'Artículos',
              subtitle: 'Ver todos los productos disponibles',
              color: AppColors.accentBlue,
              onTap: onArticulosPressed,
            ),
            const SizedBox(height: 18),
            _MenuCard(
              icon: Icons.local_offer_outlined,
              title: 'Ofertas',
              subtitle: 'Productos con descuento especial',
              color: AppColors.accentGreen,
              onTap: onOfertasPressed,
            ),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta de menú individual con ícono, título y subtítulo.
class _MenuCard extends StatelessWidget {
  final IconData     icon;
  final String       title;
  final String       subtitle;
  final Color        color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                  color: color.withOpacity(0.2), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color, size: 26),
          ],
        ),
      ),
    );
  }
}
