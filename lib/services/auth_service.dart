// lib/services/auth_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import '../models/user.dart';

class AuthService {
  static const String _keyCurrentUser = 'current_user';
  static const String _keyUsers = 'registered_users';

  // Singleton
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  /// Inicializa el servicio y carga el usuario actual si existe
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_keyCurrentUser);

      if (userJson != null) {
        final userData = jsonDecode(userJson);
        _currentUser = User.fromJson(userData);
        print('✅ Usuario cargado: ${_currentUser?.email}');
      }
    } catch (e) {
      print('❌ Error inicializando AuthService: $e');
      _currentUser = null;
    }
  }

  /// Registra un nuevo usuario
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      // Validar entrada
      if (name.trim().isEmpty) {
        return AuthResult(success: false, message: 'El nombre es requerido');
      }
      if (!_isValidEmail(email)) {
        return AuthResult(success: false, message: 'Email inválido');
      }
      if (password.length < 6) {
        return AuthResult(success: false, message: 'La contraseña debe tener al menos 6 caracteres');
      }

      // Verificar si el usuario ya existe
      if (await _userExists(email)) {
        return AuthResult(success: false, message: 'El email ya está registrado');
      }

      // Crear nuevo usuario
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name.trim(),
        email: email.toLowerCase().trim(),
        phone: phone?.trim(),
        createdAt: DateTime.now(),
      );

      // Guardar usuario en la lista de usuarios registrados
      await _saveUser(user, password);

      // Establecer como usuario actual
      await _setCurrentUser(user);

      return AuthResult(success: true, message: 'Registro exitoso', user: user);
    } catch (e) {
      return AuthResult(success: false, message: 'Error en el registro: $e');
    }
  }

  /// Inicia sesión
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      if (!_isValidEmail(email)) {
        return AuthResult(success: false, message: 'Email inválido');
      }
      if (password.isEmpty) {
        return AuthResult(success: false, message: 'La contraseña es requerida');
      }

      final user = await _authenticateUser(email.toLowerCase().trim(), password);

      if (user != null) {
        await _setCurrentUser(user);
        return AuthResult(success: true, message: 'Inicio de sesión exitoso', user: user);
      } else {
        return AuthResult(success: false, message: 'Email o contraseña incorrectos');
      }
    } catch (e) {
      return AuthResult(success: false, message: 'Error en el inicio de sesión: $e');
    }
  }

  /// Cierra sesión
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyCurrentUser);
      _currentUser = null;
      print('✅ Sesión cerrada');
    } catch (e) {
      print('❌ Error cerrando sesión: $e');
    }
  }

  /// Actualiza el perfil del usuario actual
  Future<AuthResult> updateProfile({
    String? name,
    String? phone,
  }) async {
    try {
      if (_currentUser == null) {
        return AuthResult(success: false, message: 'No hay usuario autenticado');
      }

      final updatedUser = User(
        id: _currentUser!.id,
        name: name ?? _currentUser!.name,
        email: _currentUser!.email,
        phone: phone ?? _currentUser!.phone,
        createdAt: _currentUser!.createdAt,
      );

      await _setCurrentUser(updatedUser);
      await _updateUserInRegistry(updatedUser);

      return AuthResult(success: true, message: 'Perfil actualizado', user: updatedUser);
    } catch (e) {
      return AuthResult(success: false, message: 'Error actualizando perfil: $e');
    }
  }

  /// Elimina la cuenta del usuario actual
  Future<AuthResult> deleteAccount() async {
    try {
      if (_currentUser == null) {
        return AuthResult(success: false, message: 'No hay usuario autenticado');
      }

      final email = _currentUser!.email;
      await logout();
      await _removeUser(email);

      return AuthResult(success: true, message: 'Cuenta eliminada exitosamente');
    } catch (e) {
      return AuthResult(success: false, message: 'Error eliminando cuenta: $e');
    }
  }

  // Métodos privados

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> _userExists(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_keyUsers) ?? '{}';
      final users = jsonDecode(usersJson) as Map<String, dynamic>;
      return users.containsKey(email.toLowerCase());
    } catch (e) {
      return false;
    }
  }

  Future<void> _saveUser(User user, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_keyUsers) ?? '{}';
      final users = jsonDecode(usersJson) as Map<String, dynamic>;

      users[user.email] = {
        'user': user.toJson(),
        'passwordHash': _hashPassword(password),
      };

      await prefs.setString(_keyUsers, jsonEncode(users));
    } catch (e) {
      throw Exception('Error guardando usuario: $e');
    }
  }

  Future<User?> _authenticateUser(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_keyUsers) ?? '{}';
      final users = jsonDecode(usersJson) as Map<String, dynamic>;

      final userData = users[email];
      if (userData == null) return null;

      final passwordHash = userData['passwordHash'] as String?;
      if (passwordHash != _hashPassword(password)) return null;

      return User.fromJson(userData['user']);
    } catch (e) {
      return null;
    }
  }

  Future<void> _setCurrentUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyCurrentUser, jsonEncode(user.toJson()));
      _currentUser = user;
    } catch (e) {
      throw Exception('Error estableciendo usuario actual: $e');
    }
  }

  Future<void> _updateUserInRegistry(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_keyUsers) ?? '{}';
      final users = jsonDecode(usersJson) as Map<String, dynamic>;

      if (users.containsKey(user.email)) {
        users[user.email]['user'] = user.toJson();
        await prefs.setString(_keyUsers, jsonEncode(users));
      }
    } catch (e) {
      throw Exception('Error actualizando usuario en registro: $e');
    }
  }

  Future<void> _removeUser(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_keyUsers) ?? '{}';
      final users = jsonDecode(usersJson) as Map<String, dynamic>;

      users.remove(email.toLowerCase());
      await prefs.setString(_keyUsers, jsonEncode(users));
    } catch (e) {
      throw Exception('Error eliminando usuario: $e');
    }
  }
}

/// Clase para resultados de operaciones de autenticación
class AuthResult {
  final bool success;
  final String message;
  final User? user;

  AuthResult({
    required this.success,
    required this.message,
    this.user,
  });

  @override
  String toString() {
    return 'AuthResult{success: $success, message: $message, user: ${user?.email}}';
  }
}