/// biometric_setup_screen.dart
///
/// Pantalla de configuración biométrica.
/// Permite al usuario habilitar o deshabilitar la autenticación con huella.

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_colors.dart';
import '../services/auth_service.dart';

class BiometricSetupScreen extends StatefulWidget {
  final AuthService authService;
  const BiometricSetupScreen({super.key, required this.authService});

  @override
  State<BiometricSetupScreen> createState() => _BiometricSetupScreenState();
}

class _BiometricSetupScreenState extends State<BiometricSetupScreen> {
  final _formKey  = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _storage  = const FlutterSecureStorage();

  bool _isLoading        = false;
  bool _biometricEnabled = false;
  bool _obscurePass      = true;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final enabled = await widget.authService.isBiometricEnabled;
    if (mounted) setState(() => _biometricEnabled = enabled);
  }

  Future<void> _handleEnable() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await widget.authService.enableBiometric(
        _userCtrl.text.trim(), _passCtrl.text.trim());
      if (mounted) {
        setState(() => _biometricEnabled = true);
        _showMsg('Huella habilitada exitosamente', success: true);
      }
    } on AuthException catch (e) {
      _showMsg(e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDisable() async {
    setState(() => _isLoading = true);
    try {
      if (widget.authService.isAuthenticated) {
        await widget.authService.disableBiometric();
      } else {
        await _storage.delete(key: 'biometric_token');
        await _storage.delete(key: 'biometric_username');
      }
      if (mounted) {
        setState(() => _biometricEnabled = false);
        _showMsg('Autenticación biométrica deshabilitada', success: true);
      }
    } on AuthException catch (e) {
      _showMsg(e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMsg(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: success
          ? AppColors.accentGreen.withOpacity(0.9)
          : AppColors.accentPink.withOpacity(0.9),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  void dispose() { _userCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Configurar Huella'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: _biometricEnabled ? _enabledView() : _enableForm(),
      ),
    );
  }

  Widget _enabledView() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
        width: 100, height: 100,
        decoration: BoxDecoration(
          color: AppColors.accentGreen.withOpacity(0.2),
          shape: BoxShape.circle),
        child: const Icon(Icons.fingerprint, size: 54, color: AppColors.accentGreen),
      ),
      const SizedBox(height: 24),
      const Text('Inicio de sesión con huella\nhabilitado',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
            color: AppColors.textPrimary, height: 1.4)),
      const SizedBox(height: 10),
      const Text('Puedes deshabilitar el acceso biométrico en cualquier momento.',
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5, height: 1.5)),
      const SizedBox(height: 40),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _isLoading ? null : _handleDisable,
          icon: _isLoading
              ? const SizedBox(height: 18, width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2,
                      color: AppColors.accentPink))
              : const Icon(Icons.no_encryption_outlined, color: AppColors.accentPink),
          label: const Text('Deshabilitar inicio de sesión con huella',
              style: TextStyle(color: AppColors.textPrimary)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.accentPink),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(vertical: 14)),
        ),
      ),
    ],
  );

  Widget _enableForm() => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: AppColors.accentBlue.withOpacity(0.15),
            shape: BoxShape.circle),
          child: const Icon(Icons.fingerprint, size: 44, color: AppColors.accentBlue),
        ),
        const SizedBox(height: 20),
        const Text('Habilitar inicio de sesión\ncon huella',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
              color: AppColors.textPrimary, height: 1.3)),
        const SizedBox(height: 8),
        const Text('Confirma tus credenciales para vincular tu huella a esta cuenta.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5)),
        const SizedBox(height: 32),
        Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              controller: _userCtrl,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Usuario',
                prefixIcon: Icon(Icons.person_outline, color: AppColors.accentBlue)),
              validator: (v) => (v == null || v.isEmpty) ? 'Ingresa tu usuario' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _passCtrl,
              obscureText: _obscurePass,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleEnable(),
              decoration: InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.accentBlue),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePass
                      ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppColors.textSecondary),
                  onPressed: () => setState(() => _obscurePass = !_obscurePass),
                )),
              validator: (v) => (v == null || v.isEmpty) ? 'Ingresa tu contraseña' : null,
            ),
          ]),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _handleEnable,
            icon: _isLoading
                ? const SizedBox(height: 18, width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2,
                        color: AppColors.textPrimary))
                : const Icon(Icons.fingerprint),
            label: const Text('Confirmar y Habilitar Huella'),
          ),
        ),
      ],
    ),
  );
}
