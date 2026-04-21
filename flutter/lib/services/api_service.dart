/// api_service.dart
///
/// Servicio de acceso a datos.
/// Todas las peticiones incluyen el JWT de sesión en el header Authorization.
/// El backend valida ese token antes de responder.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/articulo.dart';

class ApiService {
  /// URL base del backend. Ajusta según el entorno.
  static const String _baseUrl = 'https://backendloginbio-1.onrender.com';

  final String _sessionToken;

  /// [sessionToken] es el JWT de corta vida obtenido tras el login.
  const ApiService({required String sessionToken})
      : _sessionToken = sessionToken;

  // ── Headers comunes ─────────────────────────────────────────────────────────

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        // JWT de sesión enviado en CADA solicitud (requisito del ejercicio)
        'Authorization': 'Bearer $_sessionToken',
      };

  // ── Artículos ───────────────────────────────────────────────────────────────

  /// Obtiene todos los artículos desde el backend.
  ///
  /// El servidor consulta su BD relacional (que fue sincronizada desde npoint).
  /// Lanza [ApiException] si la petición falla o el token es inválido.
  Future<List<Articulo>> getArticulos() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/articulos'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data  = jsonDecode(response.body) as Map<String, dynamic>;
        final lista = data['articulos'] as List<dynamic>;
        return lista
            .map((j) => Articulo.fromJson(j as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 401) {
        throw ApiException('Sesión expirada. Por favor, vuelve a iniciar sesión.');
      } else {
        throw ApiException('Error al cargar artículos: ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('No se pudo conectar al servidor: ${e.toString()}');
    }
  }

  // ── Ofertas ─────────────────────────────────────────────────────────────────

  /// Obtiene únicamente los artículos con descuento > 0.
  ///
  /// El servidor filtra y ordena por descuento descendente.
  /// Lanza [ApiException] si la petición falla o el token es inválido.
  Future<List<Articulo>> getOfertas() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/ofertas'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data  = jsonDecode(response.body) as Map<String, dynamic>;
        final lista = data['ofertas'] as List<dynamic>;
        return lista
            .map((j) => Articulo.fromJson(j as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 401) {
        throw ApiException('Sesión expirada. Por favor, vuelve a iniciar sesión.');
      } else {
        throw ApiException('Error al cargar ofertas: ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('No se pudo conectar al servidor: ${e.toString()}');
    }
  }
}

/// Excepción personalizada para errores de red o API.
class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}
