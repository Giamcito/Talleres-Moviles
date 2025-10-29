import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/auth.dart';

class AuthService {
  final String baseUrl;
  final http.Client _client;

  AuthService({http.Client? client, this.baseUrl = 'https://parking.visiontic.com.co'})
      : _client = client ?? http.Client();

  Map<String, String> get _jsonHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Map<String, String> _authHeaders(String accessToken) => {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      };

  Future<User> register({required String name, required String email, required String password, String? passwordConfirmation}) async {
    // Algunos backends usan rutas distintas para registro; probamos candidatos.
    final candidates = <String>['/register', '/registro', '/auth/register'];
    final jsonPayload = jsonEncode({
      'name': name,
      'email': email,
      'password': password,
      if (passwordConfirmation != null) 'password_confirmation': passwordConfirmation,
    });

    AuthException? lastError;
    for (final path in candidates) {
      final url = Uri.parse('$baseUrl$path');
      http.Response res = await _client.post(url, headers: _jsonHeaders, body: jsonPayload);

      // Si el servidor exige x-www-form-urlencoded, reintentar
      if (res.statusCode == 415 || res.statusCode == 400) {
        final formHeaders = {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        };
        final formBody = 'name=${Uri.encodeQueryComponent(name)}&email=${Uri.encodeQueryComponent(email)}&password=${Uri.encodeQueryComponent(password)}'
            '${passwordConfirmation != null ? '&password_confirmation=${Uri.encodeQueryComponent(passwordConfirmation)}' : ''}';
        res = await _client.post(url, headers: formHeaders, body: formBody);
      }

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final body = res.body.isEmpty ? '{}' : res.body;
        final data = jsonDecode(body) as Map<String, dynamic>;
        if (data['success'] == false) {
          lastError = AuthException((data['message'] as String?) ?? 'Registro rechazado', statusCode: res.statusCode);
          continue; // intenta siguiente ruta si aplica
        }
        final userJson = (data['user'] is Map)
            ? data['user'] as Map<String, dynamic>
            : (data['data'] is Map)
                ? data['data'] as Map<String, dynamic>
                : data;
        return User.fromJson(userJson);
      }

      // Si 404, probar la siguiente ruta; en otros casos, guardar error y continuar
      if (res.statusCode == 404) {
        lastError = AuthException('The route ${url.path} could not be found.', statusCode: res.statusCode);
        continue;
      }
      lastError = _mapError(res);
    }

    throw lastError ?? AuthException('No se encontró un endpoint de registro compatible');
  }

  Future<AuthResponse> login({required String email, required String password}) async {
    final url = Uri.parse('$baseUrl/api/login');
    final jsonBody = jsonEncode({'email': email, 'password': password});

    // Primer intento: JSON
    http.Response res = await _client.post(url, headers: _jsonHeaders, body: jsonBody);

    // Si el servidor respondió con 415/400 probamos como x-www-form-urlencoded
    if (res.statusCode == 415 || res.statusCode == 400) {
      final formHeaders = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      };
      final formBody = 'email=${Uri.encodeQueryComponent(email)}&password=${Uri.encodeQueryComponent(password)}';
      res = await _client.post(url, headers: formHeaders, body: formBody);
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final raw = res.body.isEmpty ? '{}' : res.body;
      final data = jsonDecode(raw) as Map<String, dynamic>;

      // Muchas APIs devuelven { success: false, message: '...' } con 200
      if (data['success'] == false) {
        final msg = (data['message'] as String?) ?? 'Credenciales inválidas';
        throw AuthException(msg, statusCode: res.statusCode);
      }

      final auth = AuthResponse.fromJson(data);
      if (auth.accessToken.isEmpty) {
        final msg = (data['message'] as String?) ?? 'La respuesta no contiene access_token';
        throw AuthException(msg, statusCode: res.statusCode);
      }
      return auth;
    }
    throw _mapError(res);
  }

  Future<User> profile({required String accessToken}) async {
    final url = Uri.parse('$baseUrl/perfil');
    final res = await _client.get(url, headers: _authHeaders(accessToken));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body.isEmpty ? '{}' : res.body);
      if (data is Map<String, dynamic>) {
        // Try common shapes: { user: {...} } or { data: {...} } or flat
        final Map<String, dynamic> userJson =
            (data['user'] is Map)
                ? data['user'] as Map<String, dynamic>
                : (data['data'] is Map)
                    ? data['data'] as Map<String, dynamic>
                    : data;
        return User.fromJson(userJson);
      }
      throw AuthException('Respuesta de perfil no válida');
    }
    throw _mapError(res);
  }

  Future<void> logout({required String accessToken}) async {
    final url = Uri.parse('$baseUrl/logout');
    final res = await _client.post(url, headers: _authHeaders(accessToken));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return;
    }
    throw _mapError(res);
  }

  AuthException _mapError(http.Response res) {
    try {
      final data = jsonDecode(res.body);
      final msg = (data is Map && data['message'] is String)
          ? data['message'] as String
          : res.reasonPhrase ?? 'Error ${res.statusCode}';
      return AuthException(msg, statusCode: res.statusCode);
    } catch (_) {
      return AuthException(res.reasonPhrase ?? 'Error ${res.statusCode}', statusCode: res.statusCode);
    }
  }
}
