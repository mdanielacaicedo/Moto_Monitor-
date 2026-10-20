import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../services/data_service.dart';
import '../services/auth_service.dart';
import '../models/moto.dart';

class AppProvider extends ChangeNotifier {
  final DataService _dataService = DataService.instance;
  final AuthService _authService = AuthService();

  bool _isAuthenticated = false;
  String? _authError;

  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  Moto? _moto;
  int _totalAlertas = 0;

  bool get isAuthenticated => _isAuthenticated;
  String? get authError => _authError;

  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  Moto? get moto => _moto;
  int get totalAlertas => _totalAlertas;
  String? get currentUserId => _authService.currentUser?.id;
  String? get currentUserName => _authService.currentUser?.name;
  String? get currentUserEmail => _authService.currentUser?.email;

  void clearError() {
    _authError = null;
    _errorMessage = null;
    notifyListeners();
  }

  bool get hasData {
    if (_moto == null) return false;
    if (_moto!.marca == 'Sin configurar' && _moto!.modelo == 'Sin configurar') {
      return false;
    }
    return true;
  }

  Future<void> initializeApp() async {
    _setLoading(true);

    try {
      await _authService.initialize();

      if (_authService.isLoggedIn) {
        debugPrint('Usuario autenticado: ${_authService.currentUser?.email}');
        _isAuthenticated = true;

        final hasUserData = await _dataService.hasUserData();

        if (!hasUserData) {
          debugPrint('Inicializando datos para nuevo usuario');
          await _dataService.initializeUserData();
        }

        await _loadUserData();

        if (_moto != null && _moto!.marca == 'Sin configurar' && _moto!.modelo == 'Sin configurar') {
          debugPrint('🧹 Limpiando moto placeholder detectada');
          final db = await DatabaseHelper.instance.database;
          await db.delete(
            'motos',
            where: 'userId = ?',
            whereArgs: [_authService.currentUser?.id],
          );
          _moto = null;
        }

        _isInitialized = true;
      } else {
        debugPrint('No hay usuario autenticado');
        _isAuthenticated = false;
        _isInitialized = true;
      }

      _errorMessage = null;
    } catch (e) {
      debugPrint('Error inicializando app: $e');
      _errorMessage = 'Error inicializando la aplicación: $e';
      _isAuthenticated = false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _authError = null;

    try {
      final result = await _authService.login(email: email, password: password);

      if (result.success) {
        _isAuthenticated = true;

        final hasUserData = await _dataService.hasUserData();

        if (!hasUserData) {
          await _dataService.initializeUserData();
        }

        await _loadUserData();
        _isInitialized = true;

        notifyListeners();
        return true;
      } else {
        _authError = result.message;
        _isAuthenticated = false;
        return false;
      }
    } catch (e) {
      _authError = 'Error en el login: $e';
      _isAuthenticated = false;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    _setLoading(true);
    _authError = null;

    try {
      final result = await _authService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );

      if (result.success) {
        _isAuthenticated = true;

        await _dataService.initializeUserData();
        await _loadUserData();
        _isInitialized = true;

        notifyListeners();
        return true;
      } else {
        _authError = result.message;
        _isAuthenticated = false;
        return false;
      }
    } catch (e) {
      _authError = 'Error en el registro: $e';
      _isAuthenticated = false;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();

      _isAuthenticated = false;
      _isInitialized = true;
      _moto = null;
      _totalAlertas = 0;
      _errorMessage = null;
      _authError = null;
      _isLoading = false;

      notifyListeners();
      debugPrint('✅ Sesión cerrada correctamente');
    } catch (e) {
      debugPrint('❌ Error en logout: $e');
      _errorMessage = 'Error cerrando sesión: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadUserData() async {
    try {
      _moto = await _dataService.getMoto();
      await _calculateAlertas();

      debugPrint('Datos cargados: moto=${_moto?.marca}, alertas=$_totalAlertas');
    } catch (e) {
      debugPrint('Error cargando datos del usuario: $e');
      _errorMessage = 'Error cargando datos: $e';
    }
  }

  Future<void> refreshData() async {
    if (!_isAuthenticated) {
      debugPrint('No se puede refrescar datos: usuario no autenticado');
      return;
    }

    _setLoading(true);

    try {
      await _loadUserData();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error actualizando datos: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> actualizarKilometraje(int nuevoKm) async {
    if (!_isAuthenticated) {
      throw Exception('Usuario no autenticado');
    }

    _setLoading(true);

    try {
      await _dataService.updateKilometraje(nuevoKm);
      await _loadUserData();
      debugPrint('Kilometraje actualizado a: $nuevoKm km');
    } catch (e) {
      debugPrint('Error actualizando kilometraje: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addMoto(Moto nuevaMoto) async {
    if (!_isAuthenticated) {
      throw Exception('Usuario no autenticado');
    }

    _setLoading(true);

    try {
      await _dataService.saveMoto(nuevaMoto);
      _moto = nuevaMoto;
      await _calculateAlertas();
      notifyListeners();
    } catch (e) {
      debugPrint('Error agregando moto: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _calculateAlertas() async {
    _totalAlertas = 0;
    if (_moto == null) return;

    if (_moto!.kilometraje > 0 && _moto!.kilometraje > 10000) {
      _totalAlertas++;
    }

    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}