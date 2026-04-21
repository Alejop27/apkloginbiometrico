/// lista_articulos.dart
///
/// Widget ListaArticulos (8pts)
///
/// Pantalla que carga y muestra TODOS los artículos desde el backend.
/// Cada artículo se renderiza con [ItemArticulo].
/// Al pulsar un ítem, navega a [FichaArticulo].
///
/// Gestiona tres estados: cargando, error, y datos listos.

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/articulo.dart';
import '../services/api_service.dart';
import 'item_articulo.dart';
import 'ficha_articulo.dart';

/// Lista completa de artículos.
///
/// [apiService] : instancia con el JWT de sesión ya configurado.
class ListaArticulos extends StatefulWidget {
  final ApiService apiService;

  const ListaArticulos({super.key, required this.apiService});

  @override
  State<ListaArticulos> createState() => _ListaArticulosState();
}

class _ListaArticulosState extends State<ListaArticulos> {
  // ── Estado ──────────────────────────────────────────────────────────────────
  List<Articulo> _articulos   = [];
  bool           _isLoading   = true;
  String?        _errorMsg;

  @override
  void initState() {
    super.initState();
    _loadArticulos();
  }

  // ── Carga de datos ───────────────────────────────────────────────────────────

  /// Solicita los artículos al backend y actualiza el estado.
  /// Maneja errores de red y sesión expirada.
  Future<void> _loadArticulos() async {
    setState(() { _isLoading = true; _errorMsg = null; });
    try {
      final lista = await widget.apiService.getArticulos();
      if (mounted) setState(() { _articulos = lista; _isLoading = false; });
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

  // ── Navegación ───────────────────────────────────────────────────────────────

  void _openFicha(Articulo articulo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FichaArticulo(articulo: articulo),
      ),
    );
  }

  // ── UI ────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _isLoading ? 'Artículos' : 'Artículos (${_articulos.length})',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Botón de recarga
          if (!_isLoading)
            IconButton(
              tooltip: 'Recargar',
              icon: const Icon(Icons.refresh_rounded,
                  color: AppColors.accentBlue),
              onPressed: _loadArticulos,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return _LoadingView();
    if (_errorMsg != null) return _ErrorView(msg: _errorMsg!, onRetry: _loadArticulos);
    if (_articulos.isEmpty) return _EmptyView(label: 'No hay artículos disponibles');
    return _ArticulosList(
      articulos: _articulos,
      onTap: _openFicha,
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

/// Lista con scroll de todos los artículos.
class _ArticulosList extends StatelessWidget {
  final List<Articulo>             articulos;
  final ValueChanged<Articulo>     onTap;

  const _ArticulosList({required this.articulos, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: articulos.length,
      itemBuilder: (_, i) => ItemArticulo(
        articulo: articulos[i],
        onTap: () => onTap(articulos[i]),
      ),
    );
  }
}

/// Vista de carga con indicador y texto.
class _LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.accentBlue),
          SizedBox(height: 16),
          Text('Cargando artículos…',
              style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

/// Vista de error con mensaje y botón de reintento.
class _ErrorView extends StatelessWidget {
  final String       msg;
  final VoidCallback onRetry;

  const _ErrorView({required this.msg, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
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
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
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
}

/// Vista cuando la lista está vacía.
class _EmptyView extends StatelessWidget {
  final String label;
  const _EmptyView({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 56, color: AppColors.accentBlue.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 15)),
        ],
      ),
    );
  }
}
