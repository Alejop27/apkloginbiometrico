/// home_screen.dart
///
/// Pantalla principal post-login. Actúa como host del [MenuPrincipal]
/// y gestiona la navegación a [ListaArticulos] y [ListaOfertas].

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../widgets/menu_principal.dart';
import '../widgets/lista_articulos.dart';
import '../widgets/lista_ofertas.dart';

class HomeScreen extends StatelessWidget {
  final AuthService authService;

  const HomeScreen({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    // ApiService se construye con el token de sesión activo
    final apiService = ApiService(sessionToken: authService.sessionToken!);

    return MenuPrincipal(
      onArticulosPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ListaArticulos(apiService: apiService),
        ),
      ),
      onOfertasPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ListaOfertas(apiService: apiService),
        ),
      ),
      onLogoutPressed: () {
        authService.logout();
        Navigator.of(context).popUntil((r) => r.isFirst);
      },
    );
  }
}
