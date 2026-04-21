/// lista_ofertas.dart
///
/// Widget ListaOfertas (8pts)
///
/// Pantalla que carga y muestra SOLO los artículos con descuento > 0.
/// Idéntica a [ListaArticulos] en estructura, pero consume /api/ofertas
/// y añade un encabezado con el conteo de ofertas activas.

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/articulo.dart';
import '../services/api_service.dart';
import 'item_articulo.dart';
import 'ficha_articulo.dart';

/// Lista de artículos en oferta (descuento > 0).
///
/// [apiService] : instancia con el JWT de sesión ya configurado.
class ListaOfertas extends StatefulWidget {
  final ApiService apiService;

  const ListaOfertas({super.key, required this.apiService});

  @override
  State<ListaOfertas> createState() => _ListaOfertasState();
}

class _ListaOfertasState extends State<ListaOfertas> {
  List<Articulo> _ofertas   = [];
  bool           _isLoading = true;
  String?        _errorMsg;

  @override
  void initState() {
    super.initState();
    _loadOfertas();
  }

  // ── Carga de datos ───────────────────────────────────────────────────────────

  Future<void> _loadOfertas() async {
    setState(() { _isLoading = true; _errorMsg = null; });
    try {
      final lista = await widget.apiService.getOfertas();
      if (mounted) setState(() { _ofertas = lista; _isLoading = false; });
    } on ApiException catch (e) {
      if (mounted) setState(() { _errorMsg = e.message; _isLoading = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg = 'Error inesperado: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  void _openFicha(Articulo articulo) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FichaArticulo(articulo: articulo)),
    );
  }

  // ── UI ────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _isLoading ? 'Ofertas' : 'Ofertas (${_ofertas.length})',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isLoading)
            IconButton(
              tooltip: 'Recargar',
              icon: const Icon(Icons.refresh_rounded,
                  color: AppColors.accentGreen),
              onPressed: _loadOfertas,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return _LoadingView();
    if (_errorMsg != null) {
      return _ErrorView(msg: _errorMsg!, onRetry: _loadOfertas);
    }
    if (_ofertas.isEmpty) {
      return _EmptyView();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado con resumen de ofertas
        _OfertasHeader(count: _ofertas.length),

        // Lista
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 4, bottom: 24),
            itemCount: _ofertas.length,
            itemBuilder: (_, i) => ItemArticulo(
              articulo: _ofertas[i],
              onTap: () => _openFicha(_ofertas[i]),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

/// Encabezado decorativo de la sección de ofertas.
class _OfertasHeader extends StatelessWidget {
  final int count;
  const _OfertasHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentGreen.withOpacity(0.4),
            AppColors.accentBlue.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_offer_rounded,
                color: AppColors.priceDiscount, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ofertas especiales',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '$count productos con descuento',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(color: AppColors.accentGreen),
        SizedBox(height: 16),
        Text('Cargando ofertas…',
            style: TextStyle(color: AppColors.textSecondary)),
      ],
    ),
  );
}

class _ErrorView extends StatelessWidget {
  final String       msg;
  final VoidCallback onRetry;
  const _ErrorView({required this.msg, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: AppColors.accentPink.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.wifi_off_rounded,
                size: 38, color: AppColors.accentPink),
          ),
          const SizedBox(height: 20),
          const Text('Ocurrió un problema',
              style: TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(msg,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13.5, color: AppColors.textSecondary, height: 1.5)),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    ),
  );
}

class _EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.local_offer_outlined,
            size: 56, color: AppColors.accentGreen),
        SizedBox(height: 16),
        Text('No hay ofertas disponibles en este momento',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
      ],
    ),
  );
}
