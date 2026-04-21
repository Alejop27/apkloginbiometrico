/// main.dart
///
/// Punto de entrada de la aplicación Seg4.
/// Configura el tema global y arranca desde [LoginScreen].

import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Seg4App());
}

/// Widget raíz de la aplicación.
class Seg4App extends StatelessWidget {
  const Seg4App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seg4 — Artículos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const LoginScreen(),
    );
  }
}
