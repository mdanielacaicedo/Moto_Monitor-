// lib/services/data_service.dart (TIPOS CORREGIDOS)
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/moto.dart';
import '../models/documento.dart';
import '../models/mantenimiento.dart';
import '../models/recordatorio.dart';
import 'auth_service.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  static DataService get instance => _instance;
  DataService._internal();

  SharedPreferences? _prefs;

  // Keys específicas del usuario autenticado
  String get _keyMoto => 'moto_data_${AuthService().currentUser?.id ?? 'guest'}';
  String get _keyDocumentos => 'documentos_data_${AuthService().currentUser?.id ?? 'guest'}';
  String get _keyMantenimientos => 'mantenimientos_data_${AuthService().currentUser?.id ?? 'guest'}';
  String get _keyRecordatorios => 'recordatorios_data_${AuthService().currentUser?.id ?? 'guest'}';
  String get _keyInitialized => 'app_initialized_${AuthService().currentUser?.id ?? 'guest'}';
  String get _keyAppVersion => 'app_version_${AuthService().currentUser?.id ?? 'guest'}';

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<bool> hasData() async {
    try {
      final prefs = await _getPrefs();
      // Corrección del error de tipos: usar getBool en lugar de getString
      return prefs.getBool(_keyInitialized) ?? false;
    } catch (e) {
      debugPrint('Error verificando datos existentes: $e');
      return false;
    }
  }

  Future<bool> hasUserData() async {
    try {
      final user = AuthService().currentUser;
      if (user == null) return false;

      final prefs = await _getPrefs();
      return prefs.getBool(_keyInitialized) ?? false;
    } catch (e) {
      debugPrint('Error verificando datos del usuario: $e');
      return false;
    }
  }

  Future<void> initializeUserData() async {
    final user = AuthService().currentUser;
    if (user == null) {
      throw Exception('No hay usuario autenticado');
    }

    debugPrint('Inicializando datos para usuario: ${user.email}');
    await saveInitialData();
  }

  Future<void> saveInitialData() async {
    try {
      final prefs = await _getPrefs();

      if (!prefs.containsKey(_keyMoto)) {
        final motoInicial = Moto(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          marca: 'Sin configurar',
          modelo: 'Sin configurar',
          ano: DateTime.now().year,
          placa: '',
          kilometraje: 0,
          fechaCompra: DateTime.now(),
          fechaUltimaActualizacion: DateTime.now(),
        );
        await saveMoto(motoInicial);
      }

      if (!prefs.containsKey(_keyDocumentos)) {
        final documentosIniciales = [
          Documento(
            id: '1',
            tipo: 'SOAT',
            numero: '',
            fechaExpedicion: DateTime.now(),
            fechaVencimiento: DateTime.now().add(const Duration(days: 365)),
            entidadExpedidora: 'Por definir',
            observaciones: 'Pendiente por configurar',
          ),
          Documento(
            id: '2',
            tipo: 'Revisión Técnico-Mecánica',
            numero: '',
            fechaExpedicion: DateTime.now(),
            fechaVencimiento: DateTime.now().add(const Duration(days: 730)),
            entidadExpedidora: 'Por definir',
            observaciones: 'Pendiente por configurar',
          ),
        ];
        await saveDocumentos(documentosIniciales);
      }

      if (!prefs.containsKey(_keyMantenimientos)) {
        await saveMantenimientos(<Mantenimiento>[]);
      }

      if (!prefs.containsKey(_keyRecordatorios)) {
        await saveRecordatorios(<Recordatorio>[]);
      }

      // CORRECCIÓN: Usar setBool para valores boolean
      await prefs.setBool(_keyInitialized, true);
      await prefs.setString(_keyAppVersion, '1.0.0');

      debugPrint('Datos iniciales guardados correctamente para usuario: ${AuthService().currentUser?.email}');
    } catch (e) {
      debugPrint('Error guardando datos iniciales: $e');
      throw Exception('No se pudieron crear los datos iniciales: $e');
    }
  }

  Future<void> clearCurrentUserData() async {
    try {
      final prefs = await _getPrefs();
      await Future.wait([
        prefs.remove(_keyMoto),
        prefs.remove(_keyDocumentos),
        prefs.remove(_keyMantenimientos),
        prefs.remove(_keyRecordatorios),
        prefs.remove(_keyInitialized),
        prefs.remove(_keyAppVersion),
      ]);
      debugPrint('Datos del usuario actual eliminados');
    } catch (e) {
      debugPrint('Error limpiando datos del usuario: $e');
    }
  }

  // Método para compatibilidad con AppProvider existente
  Future<Moto?> loadMoto() async {
    return await getMoto();
  }

  Future<Moto?> getMoto() async {
    try {
      final user = AuthService().currentUser;
      if (user == null) {
        debugPrint('No hay usuario autenticado');
        return null;
      }

      final prefs = await _getPrefs();
      final motoJson = prefs.getString(_keyMoto);

      if (motoJson == null || motoJson.isEmpty) {
        debugPrint('No hay datos de moto guardados para usuario: ${user.email}');
        return null;
      }

      final Map<String, dynamic> motoMap = jsonDecode(motoJson);
      final moto = Moto.fromJson(motoMap);
      debugPrint('Moto cargada correctamente: ${moto.marca} ${moto.modelo} para ${user.email}');
      return moto;
    } catch (e) {
      debugPrint('Error cargando moto: $e');
      return null;
    }
  }

  Future<void> saveMoto(Moto moto) async {
    try {
      final user = AuthService().currentUser;
      if (user == null) {
        throw Exception('No hay usuario autenticado');
      }

      final prefs = await _getPrefs();
      final motoJson = jsonEncode(moto.toJson());
      await prefs.setString(_keyMoto, motoJson);
      debugPrint('Moto guardada correctamente para usuario: ${user.email}');
    } catch (e) {
      debugPrint('Error guardando moto: $e');
      throw Exception('No se pudo guardar la moto: $e');
    }
  }

  Future<void> updateKilometraje(int nuevoKilometraje) async {
    try {
      final moto = await getMoto();
      if (moto == null) {
        throw Exception('No hay moto configurada');
      }

      final motoActualizada = Moto(
        id: moto.id,
        marca: moto.marca,
        modelo: moto.modelo,
        ano: moto.ano,
        placa: moto.placa,
        kilometraje: nuevoKilometraje,
        fechaCompra: moto.fechaCompra,
        fechaUltimaActualizacion: DateTime.now(),
      );

      await saveMoto(motoActualizada);
      debugPrint('Kilometraje actualizado a: $nuevoKilometraje km');
    } catch (e) {
      debugPrint('Error actualizando kilometraje: $e');
      throw Exception('No se pudo actualizar el kilometraje: $e');
    }
  }

  Future<List<Documento>> getDocumentos() async {
    try {
      final user = AuthService().currentUser;
      if (user == null) return <Documento>[];

      final prefs = await _getPrefs();
      final documentosJson = prefs.getString(_keyDocumentos);

      if (documentosJson == null || documentosJson.isEmpty) {
        debugPrint('No hay documentos guardados para usuario: ${user.email}');
        return <Documento>[];
      }

      final List<dynamic> documentosList = jsonDecode(documentosJson);
      final documentos = documentosList
          .map((json) => Documento.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint('${documentos.length} documentos cargados para ${user.email}');
      return documentos;
    } catch (e) {
      debugPrint('Error cargando documentos: $e');
      return <Documento>[];
    }
  }

  Future<void> saveDocumentos(List<Documento> documentos) async {
    try {
      final user = AuthService().currentUser;
      if (user == null) throw Exception('No hay usuario autenticado');

      final prefs = await _getPrefs();
      final documentosJson = jsonEncode(
        documentos.map((doc) => doc.toJson()).toList(),
      );
      await prefs.setString(_keyDocumentos, documentosJson);
      debugPrint('${documentos.length} documentos guardados para ${user.email}');
    } catch (e) {
      debugPrint('Error guardando documentos: $e');
      throw Exception('No se pudieron guardar los documentos: $e');
    }
  }

  Future<List<Mantenimiento>> getMantenimientos() async {
    try {
      final user = AuthService().currentUser;
      if (user == null) return <Mantenimiento>[];

      final prefs = await _getPrefs();
      final mantenimientosJson = prefs.getString(_keyMantenimientos);

      if (mantenimientosJson == null || mantenimientosJson.isEmpty) {
        debugPrint('No hay mantenimientos guardados para ${user.email}');
        return <Mantenimiento>[];
      }

      final List<dynamic> mantenimientosList = jsonDecode(mantenimientosJson);
      return mantenimientosList
          .map((json) => Mantenimiento.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error cargando mantenimientos: $e');
      return <Mantenimiento>[];
    }
  }

  Future<void> saveMantenimientos(List<Mantenimiento> mantenimientos) async {
    try {
      final user = AuthService().currentUser;
      if (user == null) throw Exception('No hay usuario autenticado');

      final prefs = await _getPrefs();
      final mantenimientosJson = jsonEncode(
        mantenimientos.map((mant) => mant.toJson()).toList(),
      );
      await prefs.setString(_keyMantenimientos, mantenimientosJson);
      debugPrint('${mantenimientos.length} mantenimientos guardados para ${user.email}');
    } catch (e) {
      debugPrint('Error guardando mantenimientos: $e');
      throw Exception('No se pudieron guardar los mantenimientos: $e');
    }
  }

  Future<List<Recordatorio>> getRecordatorios() async {
    try {
      final user = AuthService().currentUser;
      if (user == null) return <Recordatorio>[];

      final prefs = await _getPrefs();
      final recordatoriosJson = prefs.getString(_keyRecordatorios);

      if (recordatoriosJson == null || recordatoriosJson.isEmpty) {
        debugPrint('No hay recordatorios guardados para ${user.email}');
        return <Recordatorio>[];
      }

      final List<dynamic> recordatoriosList = jsonDecode(recordatoriosJson);
      return recordatoriosList
          .map((json) => Recordatorio.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error cargando recordatorios: $e');
      return <Recordatorio>[];
    }
  }

  Future<void> saveRecordatorios(List<Recordatorio> recordatorios) async {
    try {
      final user = AuthService().currentUser;
      if (user == null) throw Exception('No hay usuario autenticado');

      final prefs = await _getPrefs();
      final recordatoriosJson = jsonEncode(
        recordatorios.map((rec) => rec.toJson()).toList(),
      );
      await prefs.setString(_keyRecordatorios, recordatoriosJson);
      debugPrint('${recordatorios.length} recordatorios guardados para ${user.email}');
    } catch (e) {
      debugPrint('Error guardando recordatorios: $e');
      throw Exception('No se pudieron guardar los recordatorios: $e');
    }
  }

  Future<void> clearAllData() async {
    return await clearCurrentUserData();
  }

  Future<Map<String, dynamic>> exportAllData() async {
    try {
      final user = AuthService().currentUser;
      if (user == null) throw Exception('No hay usuario autenticado');

      final prefs = await _getPrefs();
      return {
        'user_id': user.id,
        'user_email': user.email,
        'moto': prefs.getString(_keyMoto),
        'documentos': prefs.getString(_keyDocumentos),
        'mantenimientos': prefs.getString(_keyMantenimientos),
        'recordatorios': prefs.getString(_keyRecordatorios),
        'initialized': prefs.getBool(_keyInitialized), // CORRECCIÓN: getBool
        'version': prefs.getString(_keyAppVersion),
        'export_date': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('Error exportando datos: $e');
      throw Exception('No se pudieron exportar los datos: $e');
    }
  }

  Future<void> importAllData(Map<String, dynamic> data) async {
    try {
      final user = AuthService().currentUser;
      if (user == null) throw Exception('No hay usuario autenticado');

      final prefs = await _getPrefs();

      if (data['moto'] != null) {
        await prefs.setString(_keyMoto, data['moto']);
      }
      if (data['documentos'] != null) {
        await prefs.setString(_keyDocumentos, data['documentos']);
      }
      if (data['mantenimientos'] != null) {
        await prefs.setString(_keyMantenimientos, data['mantenimientos']);
      }
      if (data['recordatorios'] != null) {
        await prefs.setString(_keyRecordatorios, data['recordatorios']);
      }

      // CORRECCIÓN: setBool para valor boolean
      await prefs.setBool(_keyInitialized, true);
      debugPrint('Datos importados correctamente para ${user.email}');
    } catch (e) {
      debugPrint('Error importando datos: $e');
      throw Exception('No se pudieron importar los datos: $e');
    }
  }

  Future<Map<String, dynamic>> checkDataIntegrity() async {
    try {
      final user = AuthService().currentUser;
      if (user == null) {
        return {
          'authenticated': false,
          'moto': false,
          'documentos': false,
          'mantenimientos': false,
          'recordatorios': false,
          'initialized': false,
        };
      }

      final prefs = await _getPrefs();

      return {
        'authenticated': true,
        'user': user.email,
        'moto': await getMoto() != null,
        'documentos': (await getDocumentos()).isNotEmpty,
        'mantenimientos': true,
        'recordatorios': true,
        'initialized': prefs.getBool(_keyInitialized) ?? false, // CORRECCIÓN: getBool
      };
    } catch (e) {
      debugPrint('Error verificando integridad: $e');
      return {
        'authenticated': false,
        'moto': false,
        'documentos': false,
        'mantenimientos': false,
        'recordatorios': false,
        'initialized': false,
      };
    }
  }

  Future<Map<String, dynamic>> getDiagnosticInfo() async {
    try {
      final user = AuthService().currentUser;
      final prefs = await _getPrefs();
      final keys = prefs.getKeys();

      return {
        'authenticated_user': user?.email ?? 'none',
        'user_id': user?.id ?? 'none',
        'total_keys': keys.length,
        'user_keys': keys.where((key) => key.contains(user?.id ?? 'none')).length,
        'app_keys': keys.where((key) => key.startsWith('moto') ||
            key.startsWith('documentos') ||
            key.startsWith('mantenimientos') ||
            key.startsWith('recordatorios') ||
            key.startsWith('app_')).length,
        'initialized': prefs.getBool(_keyInitialized) ?? false, // CORRECCIÓN: getBool
        'version': prefs.getString(_keyAppVersion) ?? 'unknown',
        'all_keys': keys.toList(),
      };
    } catch (e) {
      debugPrint('Error obteniendo información de diagnóstico: $e');
      return {'error': e.toString()};
    }
  }
}