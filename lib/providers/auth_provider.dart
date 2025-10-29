import 'package:flutter/foundation.dart';

import '../models/auth.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

enum AuthStatus { idle, loading, authenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final StorageService _storage;

  AuthStatus status = AuthStatus.idle;
  String? errorMessage;
  User? user;
  String? accessToken;

  bool _initialized = false;
  bool get initialized => _initialized;

  AuthProvider({AuthService? authService, StorageService? storage})
      : _authService = authService ?? AuthService(),
        _storage = storage ?? const StorageService();

  Future<void> init() async {
    final has = await _storage.hasToken();
    if (has) {
      accessToken = await _storage.getAccessToken();
      final info = await _storage.getUserInfo();
      user = User(name: info['name'], email: info['email']);
      status = AuthStatus.authenticated;
    } else {
      status = AuthStatus.idle;
    }
    _initialized = true;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();
    try {
      final auth = await _authService.login(email: email, password: password);
      accessToken = auth.accessToken;
      user = auth.user ?? User(email: email);

      await _storage.saveTokens(accessToken: auth.accessToken, refreshToken: auth.refreshToken);

      // Intentar hidratar datos de usuario desde /perfil si no vinieron en login
      try {
        final fetched = await _authService.profile(accessToken: auth.accessToken);
        user = User(name: fetched.name ?? user?.name, email: fetched.email ?? user?.email);
      } catch (_) {
        // Ignorar y seguir con lo que tengamos
      }

      await _storage.saveUserInfo(name: user?.name, email: user?.email);

      status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, String? passwordConfirmation) async {
    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();
    try {
      final created = await _authService.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      // Save non-sensitive info
      await _storage.saveUserInfo(name: created.name ?? name, email: created.email ?? email);
      status = AuthStatus.idle; // Keep user on login screen after registration
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final token = accessToken;
    if (token != null && token.isNotEmpty) {
      try {
        await _authService.logout(accessToken: token);
      } catch (_) {
        // Si falla, continuar limpiando localmente
      }
    }
    await _storage.clearTokens();
    await _storage.clearUserInfo();
    user = null;
    accessToken = null;
    status = AuthStatus.idle;
    notifyListeners();
  }

  Future<Map<String, String?>> evidence() async {
    final info = await _storage.getUserInfo();
    final has = await _storage.hasToken();
    return {
      'name': info['name'],
      'email': info['email'],
      'token': has ? 'presente' : 'ausente',
    };
  }
}
