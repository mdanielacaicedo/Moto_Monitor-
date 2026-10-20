import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../db/database_helper.dart';
import '../models/user.dart';

class AuthService {
  static const String _keyCurrentUserId = 'active_user_id';

  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_keyCurrentUserId);
      if (userId == null || userId.isEmpty) {
        _currentUser = null;
        return;
      }

      final db = await DatabaseHelper.instance.database;
      final rows = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
        limit: 1,
      );

      if (rows.isNotEmpty) {
        _currentUser = _userFromRow(rows.first);
      } else {
        _currentUser = null;
        await prefs.remove(_keyCurrentUserId);
      }
    } catch (e) {
      _currentUser = null;
    }
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      if (name.trim().isEmpty) {
        return AuthResult(success: false, message: 'El nombre es requerido');
      }
      if (!_isValidEmail(email)) {
        return AuthResult(success: false, message: 'Email inválido');
      }
      if (password.length < 6) {
        return AuthResult(success: false, message: 'La contraseña debe tener al menos 6 caracteres');
      }

      if (await _userExists(email)) {
        return AuthResult(success: false, message: 'El email ya está registrado');
      }

      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name.trim(),
        email: email.toLowerCase().trim(),
        phone: phone?.trim(),
        createdAt: DateTime.now(),
      );

      await _saveUser(user, password);
      await _setCurrentUser(user);

      return AuthResult(success: true, message: 'Registro exitoso', user: user);
    } catch (e) {
      return AuthResult(success: false, message: 'Error en el registro: $e');
    }
  }

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
      }

      return AuthResult(success: false, message: 'Email o contraseña incorrectos');
    } catch (e) {
      return AuthResult(success: false, message: 'Error en el inicio de sesión: $e');
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyCurrentUserId);
      _currentUser = null;
    } catch (_) {
      // no-op: el cierre de sesión ya intentó limpiar la sesión
    }
  }

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

  Future<AuthResult> deleteAccount() async {
    try {
      if (_currentUser == null) {
        return AuthResult(success: false, message: 'No hay usuario autenticado');
      }

      final email = _currentUser!.email;
      await _removeUser(email);
      await logout();

      return AuthResult(success: true, message: 'Cuenta eliminada exitosamente');
    } catch (e) {
      return AuthResult(success: false, message: 'Error eliminando cuenta: $e');
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> _userExists(String email) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email.toLowerCase().trim()],
        limit: 1,
      );
      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> _saveUser(User user, String password) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.insert(
        'users',
        {
          'id': user.id,
          'name': user.name,
          'email': user.email,
          'phone': user.phone,
          'passwordHash': _hashPassword(password),
          'createdAt': user.createdAt.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } catch (e) {
      throw Exception('Error guardando usuario: $e');
    }
  }

  Future<User?> _authenticateUser(String email, String password) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final rows = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
        limit: 1,
      );

      if (rows.isEmpty) return null;

      final user = _userFromRow(rows.first);
      final storedHash = rows.first['passwordHash'] as String?;
      if (storedHash == null || storedHash != _hashPassword(password)) {
        return null;
      }

      return user;
    } catch (e) {
      return null;
    }
  }

  Future<void> _setCurrentUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyCurrentUserId, user.id);
      _currentUser = user;
    } catch (e) {
      throw Exception('Error estableciendo usuario actual: $e');
    }
  }

  Future<void> _updateUserInRegistry(User user) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.update(
        'users',
        {
          'name': user.name,
          'email': user.email,
          'phone': user.phone,
          'createdAt': user.createdAt.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [user.id],
      );
    } catch (e) {
      throw Exception('Error actualizando usuario en registro: $e');
    }
  }

  Future<void> _removeUser(String email) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.delete(
        'users',
        where: 'email = ?',
        whereArgs: [email.toLowerCase()],
      );
    } catch (e) {
      throw Exception('Error eliminando usuario: $e');
    }
  }

  User _userFromRow(Map<String, dynamic> row) {
    return User(
      id: row['id']?.toString() ?? '',
      name: row['name']?.toString() ?? 'Usuario',
      email: row['email']?.toString() ?? '',
      phone: row['phone']?.toString(),
      createdAt: _parseDateTime(row['createdAt']) ?? DateTime.now(),
    );
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
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