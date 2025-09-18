// lib/providers/app_provider.dart (ACTUALIZADO)
import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../services/auth_service.dart';
import '../models/moto.dart';

class AppProvider extends ChangeNotifier {
  final DataService _dataService = DataService.instance;
  final AuthService _authService = AuthService();

  // Estados de autenticación
  bool _isAuthenticated = false;
  String? _authError;

  // Estados existentes
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  Moto? _moto;
  int _totalAlertas = 0;

  // Getters de autenticación
  bool get isAuthenticated => _isAuthenticated;
  String? get authError => _authError;

  // Getters existentes
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  Moto? get moto => _moto;
  int get totalAlertas => _totalAlertas;
  bool get hasData => _moto != null;

  // ✅ NUEVO: Inicializar con autenticación
  Future<void> initializeApp() async {
    _setLoading(true);

    try {
      // Inicializar AuthService
      await _authService.initialize();

      if (_authService.isLoggedIn) {
        debugPrint('Usuario autenticado: ${_authService.currentUser?.email}');
        _isAuthenticated = true;

        // Verificar si el usuario tiene datos
        final hasUserData = await _dataService.hasUserData();

        if (!hasUserData) {
          debugPrint('Inicializando datos para nuevo usuario');
          await _dataService.initializeUserData();
        }

        // Cargar datos del usuario
        await _loadUserData();
        _isInitialized = true;
      } else {
        debugPrint('No hay usuario autenticado');
        _isAuthenticated = false;
        _isInitialized = true; // Permite mostrar login
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

  // ✅ NUEVO: Login
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _authError = null;

    try {
      final result = await _authService.login(email: email, password: password);

      if (result.success) {
        _isAuthenticated = true;

        // Verificar si el usuario tiene datos
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

  // ✅ NUEVO: Registro
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

        // Crear datos iniciales para nuevo usuario
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

  // ✅ NUEVO: Logout
  Future<void> logout() async {
    try {
      await _authService.logout();

      // Limpiar estados
      _isAuthenticated = false;
      _isInitialized = false;
      _moto = null;
      _totalAlertas = 0;
      _errorMessage = null;
      _authError = null;

      notifyListeners();
    } catch (e) {
      debugPrint('Error en logout: $e');
    }
  }

  // ✅ MÉTODO ACTUALIZADO: Cargar datos del usuario
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

  // ✅ MÉTODO ACTUALIZADO: Refrescar datos (solo si está autenticado)
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

  // ✅ MÉTODO ACTUALIZADO: Actualizar kilometraje
  Future<void> actualizarKilometraje(int nuevoKm) async {
    if (!_isAuthenticated) {
      throw Exception('Usuario no autenticado');
    }

    _setLoading(true);

    try {
      await _dataService.updateKilometraje(nuevoKm);
      await _loadUserData(); // Recargar datos
      debugPrint('Kilometraje actualizado a: $nuevoKm km');
    } catch (e) {
      debugPrint('Error actualizando kilometraje: $e');
      throw e;
    } finally {
      _setLoading(false);
    }
  }

  // ✅ MÉTODO NUEVO: Agregar moto (desde pantalla de agregar)
  Future<void> addMoto(Moto nuevaMoto) async {
    if (!_isAuthenticated) {
      throw Exception('Usuario no autenticado');
    }

    _setLoading(true);

    try {
      await _dataService.saveMoto(nuevaMoto);
      await _loadUserData();
      debugPrint('Moto agregada: ${nuevaMoto.marca} ${nuevaMoto.modelo}');
    } catch (e) {
      debugPrint('Error agregando moto: $e');
      throw e;
    } finally {
      _setLoading(false);
    }
  }

  // Métodos privados existentes
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> _calculateAlertas() async {
    try {
      int alertas = 0;

      final documentos = await _dataService.getDocumentos();
      for (final doc in documentos) {
        final diasRestantes = doc.fechaVencimiento.difference(DateTime.now()).inDays;
        if (diasRestantes <= 30) {
          alertas++;
        }
      }

      _totalAlertas = alertas;
    } catch (e) {
      debugPrint('Error calculando alertas: $e');
      _totalAlertas = 0;
    }
  }

  void clearError() {
    _errorMessage = null;
    _authError = null;
    notifyListeners();
  }

  // ✅ MÉTODO NUEVO: Obtener información del usuario actual
  String? get currentUserEmail => _authService.currentUser?.email;
  String? get currentUserName => _authService.currentUser?.name;

  // ✅ MÉTODO NUEVO: Verificar integridad de datos
  Future<Map<String, dynamic>> checkDataIntegrity() async {
    return await _dataService.checkDataIntegrity();
  }
}