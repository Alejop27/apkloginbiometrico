/// auth_service.dart
///
/// Servicio de autenticación. Gestiona:
///  - Login clásico (usuario + clave) → JWT de sesión (en memoria).
///  - Habilitación biométrica → JWT de larga vida (en SecureStorage).
///  - Login biométrico → envía el JWT largo al backend → recibe JWT de sesión.
///  - Deshabilitación biométrica.
///
/// ┌─────────────────────────────────────────────────────┐
/// │  sessionToken  → en memoria; se destruye al cerrar  │
/// │  biometricToken→ en SecureStorage; persiste         │
/// └─────────────────────────────────────────────────────┘

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';

class AuthService extends ChangeNotifier {
  // ── Dependencias ────────────────────────────────────────────────────────────
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // ── Estado interno ──────────────────────────────────────────────────────────
  /// JWT de sesión (corta vida). NO se persiste en ningún almacenamiento.
  String? _sessionToken;

  /// Indica si la sesión está activa.
  bool get isAuthenticated => _sessionToken != null;

  /// Expone el token de sesión solo para peticiones HTTP.
  String? get sessionToken => _sessionToken;

  // ── Claves de SecureStorage ─────────────────────────────────────────────────
  static const _kBiometricToken = 'biometric_token';
  static const _kBiometricUsername = 'biometric_username';

  // ── URL base del backend ─────────────────────────────────────────────────────
  /// ⚠️ Cambia esta URL según tu entorno (localhost en emulador Android = 10.0.2.2)
  static const String _baseUrl = 'https://backendloginbio-1.onrender.com';

  // ── Login clásico ───────────────────────────────────────────────────────────

  /// Autentica con usuario y clave.
  /// Si tiene éxito, guarda el [sessionToken] en memoria y notifica a los listeners.
  ///
  /// Lanza [AuthException] si las credenciales son inválidas.
  Future<void> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      _sessionToken = data['sessionToken'] as String;

      // 🔥 NUEVO: guardar biometricToken si existe
      final biometricToken = data['biometricToken'];
      if (biometricToken != null) {
        await _secureStorage.write(
          key: _kBiometricToken,
          value: biometricToken,
        );
        await _secureStorage.write(
          key: _kBiometricUsername,
          value: username,
        );
      }

      notifyListeners();
    } else {
      final err = jsonDecode(response.body)['error'] ?? 'Error desconocido';
      throw AuthException(err.toString());
    }
  }

  // ── Habilitar biometría ────────────────────────────────────────────────────

  /// Habilita la autenticación biométrica para el usuario.
  ///
  /// Flujo:
  ///  1. Verifica que el dispositivo soporte biometría.
  ///  2. Solicita al backend el JWT de larga vida (usando usuario + clave).
  ///  3. Guarda el JWT en [FlutterSecureStorage].
  ///
  /// Lanza [AuthException] si las credenciales son inválidas o si el
  /// dispositivo no soporta biometría.
  Future<void> enableBiometric(String username, String password) async {
    // 1. Verificar soporte biométrico
    final canCheck = await _localAuth.canCheckBiometrics;
    final isDeviceSupported = await _localAuth.isDeviceSupported();
    if (!canCheck || !isDeviceSupported) {
      throw AuthException(
          'Este dispositivo no soporta autenticación biométrica');
    }

    // 2. Obtener JWT de larga vida del backend
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/enable-biometric'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode != 200) {
      final err =
          jsonDecode(response.body)['error'] ?? 'Error al habilitar biometría';
      throw AuthException(err.toString());
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final biometricToken = data['biometricToken'] as String;

    // 3. Persistir en almacenamiento seguro
    await _secureStorage.write(key: _kBiometricToken, value: biometricToken);
    await _secureStorage.write(key: _kBiometricUsername, value: username);
    notifyListeners();
  }

  // ── Login biométrico ────────────────────────────────────────────────────────

  /// Inicia sesión usando la huella dactilar / Face ID.
  ///
  /// Flujo:
  ///  1. Lee el JWT largo desde SecureStorage.
  ///  2. Presenta el prompt biométrico del SO.
  ///  3. Si la biometría pasa, envía el JWT largo al backend.
  ///  4. Backend retorna un nuevo JWT de sesión.
  ///
  /// Lanza [AuthException] si la biometría no está habilitada o falla.
  Future<void> loginWithBiometric() async {
    // 1. Leer token almacenado
    final biometricToken = await _secureStorage.read(key: _kBiometricToken);
    if (biometricToken == null) {
      throw AuthException('La autenticación biométrica no está habilitada');
    }

    // 2. Presentar prompt biométrico del SO
    bool authenticated = false;
    try {
      authenticated = await _localAuth.authenticate(
        localizedReason: 'Confirma tu identidad para ingresar',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      throw AuthException('Error al leer biometría: ${e.toString()}');
    }

    if (!authenticated) {
      throw AuthException('Autenticación biométrica cancelada o fallida');
    }

    // 3. Enviar JWT largo al backend → obtener JWT de sesión
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login-biometric'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'biometricToken': biometricToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      _sessionToken = data['sessionToken'] as String;
      notifyListeners();
    } else {
      final err =
          jsonDecode(response.body)['error'] ?? 'Error en login biométrico';
      throw AuthException(err.toString());
    }
  }

  // ── Deshabilitar biometría ─────────────────────────────────────────────────

  /// Deshabilita la autenticación biométrica.
  ///
  /// Notifica al backend y elimina el token del almacenamiento seguro.
  /// Requiere sesión activa.
  Future<void> disableBiometric() async {
    if (_sessionToken == null) {
      throw AuthException(
          'Debes estar autenticado para deshabilitar la biometría');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/auth/disable-biometric'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_sessionToken',
      },
    );

    if (response.statusCode != 200) {
      final err = jsonDecode(response.body)['error'] ?? 'Error al deshabilitar';
      throw AuthException(err.toString());
    }

    // Eliminar del almacenamiento seguro
    await _secureStorage.delete(key: _kBiometricToken);
    await _secureStorage.delete(key: _kBiometricUsername);
    notifyListeners();
  }

  // ── Estado de biometría ────────────────────────────────────────────────────

  /// Retorna true si existe un token biométrico guardado en SecureStorage.
  Future<bool> get isBiometricEnabled async {
    final token = await _secureStorage.read(key: _kBiometricToken);
    return token != null;
  }

  /// Retorna true si el dispositivo soporta biometría.
  Future<bool> get isDeviceBiometricCapable async {
    final canCheck = await _localAuth.canCheckBiometrics;
    final isSupported = await _localAuth.isDeviceSupported();
    return canCheck && isSupported;
  }

  // ── Cerrar sesión ──────────────────────────────────────────────────────────

  /// Cierra la sesión. Elimina el JWT de sesión de la memoria.
  /// El JWT biométrico NO se elimina (solo se elimina con [disableBiometric]).
  void logout() {
    _sessionToken = null;
    notifyListeners();
  }
}

/// Excepción personalizada para errores de autenticación.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}
