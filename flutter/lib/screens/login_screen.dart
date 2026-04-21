/// login_screen.dart
///
/// Pantalla de inicio de sesión.
/// Presenta el formulario usuario/clave y, si la biometría está habilitada,
/// muestra el botón "Iniciar con huella".

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/auth_service.dart';
import 'biometric_setup_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey         = GlobalKey<FormState>();
  final _usernameCtrl    = TextEditingController();
  final _passwordCtrl    = TextEditingController();
  final _authService     = AuthService();

  bool _isLoading         = false;
  bool _obscurePassword   = true;
  bool _biometricEnabled  = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricStatus();
  }

  Future<void> _checkBiometricStatus() async {
    final enabled = await _authService.isBiometricEnabled;
    if (mounted) setState(() => _biometricEnabled = enabled);
  }

  // ── Acciones ─────────────────────────────────────────────────────────────────

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _authService.login(
        _usernameCtrl.text.trim(),
        _passwordCtrl.text.trim(),
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(authService: _authService),
          ),
        );
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleBiometricLogin() async {
    setState(() => _isLoading = true);
    try {
      await _authService.loginWithBiometric();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(authService: _authService),
          ),
        );
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.accentPink.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ── UI ────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo / ícono
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.fingerprint,
                    size: 48,
                    color: AppColors.accentBlue,
                  ),
                ),
                const SizedBox(height: 28),

                // Título
                const Text(
                  'Bienvenido',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Inicia sesión para continuar',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 36),

                // Formulario
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Campo usuario
                      TextFormField(
                        controller: _usernameCtrl,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Usuario',
                          prefixIcon: Icon(Icons.person_outline,
                              color: AppColors.accentBlue),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Ingresa tu usuario' : null,
                      ),
                      const SizedBox(height: 14),

                      // Campo clave
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _handleLogin(),
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock_outline,
                              color: AppColors.accentBlue),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () =>
                                setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Ingresa tu contraseña' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Botón login
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.textPrimary,
                            ),
                          )
                        : const Text('Iniciar Sesión'),
                  ),
                ),

                // Botón biométrico (solo si está habilitado)
                if (_biometricEnabled) ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _handleBiometricLogin,
                      icon: const Icon(Icons.fingerprint,
                          color: AppColors.accentBlue),
                      label: const Text(
                        'Iniciar con Huella',
                        style: TextStyle(color: AppColors.accentBlue),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.accentBlue),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Enlace a configuración biométrica
                TextButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              BiometricSetupScreen(authService: _authService)),
                    );
                    _checkBiometricStatus();
                  },
                  icon: const Icon(Icons.settings_outlined,
                      size: 18, color: AppColors.textSecondary),
                  label: const Text(
                    'Configurar huella',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
