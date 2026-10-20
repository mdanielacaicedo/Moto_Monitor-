import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../db/database_helper.dart';
import '../models/documento.dart';
import '../models/mantenimiento.dart';
import '../models/moto.dart';
import '../models/recordatorio.dart';
import 'auth_service.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  static DataService get instance => _instance;

  DataService._internal();

  Future<Database> _db() async {
    return DatabaseHelper.instance.database;
  }

  Future<String?> _currentMotoId() async {
    final user = AuthService().currentUser;
    if (user == null) return null;

    final db = await _db();
    final rows = await db.query(
      'motos',
      where: 'userId = ?',
      whereArgs: [user.id],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return rows.first['id'] as String?;
  }

  Future<bool> hasData() async {
    try {
      final user = AuthService().currentUser;
      if (user == null) return false;

      final db = await _db();
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM motos WHERE userId = ?', [user.id]),
      );
      return (count ?? 0) > 0;
    } catch (e) {
      debugPrint('Error verificando datos existentes: $e');
      return false;
    }
  }

  Future<bool> hasUserData() async {
    return hasData();
  }

  Future<void> initializeUserData() async {
    final user = AuthService().currentUser;
    if (user == null) {
      throw Exception('No hay usuario autenticado');
    }

    debugPrint('✅ Usuario inicializado sin moto todavía; no se crean datos dependientes de moto');
  }

  Future<void> saveInitialData() async {
    await initializeUserData();
  }

  Future<void> clearCurrentUserData() async {
    try {
      final user = AuthService().currentUser;
      if (user == null) return;

      final db = await _db();
      await db.delete(
        'documentos',
        where: 'motoId IN (SELECT id FROM motos WHERE userId = ?)',
        whereArgs: [user.id],
      );
      await db.delete(
        'mantenimientos',
        where: 'motoId IN (SELECT id FROM motos WHERE userId = ?)',
        whereArgs: [user.id],
      );
      await db.delete(
        'recordatorios',
        where: 'motoId IN (SELECT id FROM motos WHERE userId = ?)',
        whereArgs: [user.id],
      );
      await db.delete(
        'motos',
        where: 'userId = ?',
        whereArgs: [user.id],
      );

      debugPrint('Datos del usuario actual eliminados');
    } catch (e) {
      debugPrint('Error limpiando datos del usuario: $e');
    }
  }

  Future<Moto?> loadMoto() async {
    return getMoto();
  }

  Future<Moto?> getMoto() async {
    try {
      final user = AuthService().currentUser;
      if (user == null) return null;

      final db = await _db();
      final rows = await db.query(
        'motos',
        where: 'userId = ?',
        whereArgs: [user.id],
        limit: 1,
      );

      if (rows.isEmpty) return null;
      return Moto.fromJson(rows.first.map((key, value) => MapEntry(key, value)));
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

      final db = await _db();

      await db.delete(
        'motos',
        where: 'userId = ?',
        whereArgs: [user.id],
      );

      final row = {
        'id': moto.id,
        'userId': moto.userId.isNotEmpty ? moto.userId : user.id,
        'marca': moto.marca,
        'modelo': moto.modelo,
        'ano': moto.ano,
        'placa': moto.placa,
        'kilometraje': moto.kilometraje,
        'fechaCompra': moto.fechaCompra.toIso8601String(),
        'fechaUltimaActualizacion': moto.fechaUltimaActualizacion.toIso8601String(),
        'color': moto.color,
        'motor': moto.motor,
        'observaciones': moto.observaciones,
      };

      await db.insert('motos', row, conflictAlgorithm: ConflictAlgorithm.replace);

      final documentos = await getDocumentos();
      if (documentos.isEmpty) {
        final documentosIniciales = [
          Documento(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            motoId: moto.id,
            tipo: 'SOAT',
            numero: '',
            fechaExpedicion: DateTime.now(),
            fechaVencimiento: DateTime.now().add(const Duration(days: 365)),
            entidadExpedidora: 'Por definir',
            observaciones: 'Pendiente por configurar',
          ),
          Documento(
            id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
            motoId: moto.id,
            tipo: 'Revisión Técnico-Mecánica',
            numero: '',
            fechaExpedicion: DateTime.now(),
            fechaVencimiento: DateTime.now().add(const Duration(days: 730)),
            entidadExpedidora: 'Por definir',
            observaciones: 'Pendiente por configurar',
          ),
        ];
        await saveDocumentos(documentosIniciales);
        debugPrint('✅ Documentos iniciales creados para la moto: ${moto.marca} ${moto.modelo}');
      }
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
        userId: moto.userId,
        marca: moto.marca,
        modelo: moto.modelo,
        ano: moto.ano,
        placa: moto.placa,
        kilometraje: nuevoKilometraje,
        fechaCompra: moto.fechaCompra,
        fechaUltimaActualizacion: DateTime.now(),
        color: moto.color,
        motor: moto.motor,
        observaciones: moto.observaciones,
      );

      await saveMoto(motoActualizada);
    } catch (e) {
      debugPrint('Error actualizando kilometraje: $e');
      throw Exception('No se pudo actualizar el kilometraje: $e');
    }
  }

  Future<List<Documento>> getDocumentos() async {
    try {
      final motoId = await _currentMotoId();
      if (motoId == null) return <Documento>[];

      final db = await _db();
      final rows = await db.query(
        'documentos',
        where: 'motoId = ?',
        whereArgs: [motoId],
      );

      return rows
          .map(
            (row) => Documento.fromJson({
              ...row,
              'activo': (row['activo'] as int? ?? 0) == 1,
            }),
          )
          .toList();
    } catch (e) {
      debugPrint('Error cargando documentos: $e');
      return <Documento>[];
    }
  }

  Future<void> saveDocumentos(List<Documento> documentos) async {
    try {
      final motoId = await _currentMotoId();
      if (motoId == null) {
        throw Exception('No hay moto configurada');
      }

      final db = await _db();
      await db.delete(
        'documentos',
        where: 'motoId = ?',
        whereArgs: [motoId],
      );

      for (final doc in documentos) {
        final row = {
          'id': doc.id,
          'motoId': motoId,
          'tipo': doc.tipo,
          'numero': doc.numero,
          'fechaExpedicion': doc.fechaExpedicion.toIso8601String(),
          'fechaVencimiento': doc.fechaVencimiento.toIso8601String(),
          'entidadExpedidora': doc.entidadExpedidora,
          'observaciones': doc.observaciones,
          'activo': doc.activo ? 1 : 0,
        };
        await db.insert('documentos', row, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    } catch (e) {
      debugPrint('Error guardando documentos: $e');
      throw Exception('No se pudieron guardar los documentos: $e');
    }
  }

  Future<List<Mantenimiento>> getMantenimientos() async {
    try {
      final motoId = await _currentMotoId();
      if (motoId == null) return <Mantenimiento>[];

      final db = await _db();
      final rows = await db.query(
        'mantenimientos',
        where: 'motoId = ?',
        whereArgs: [motoId],
      );

      return rows
          .map(
            (row) => Mantenimiento.fromJson({
              ...row,
              'completado': (row['completado'] as int? ?? 0) == 1,
              'trabajosRealizados': _decodeStringList(row['trabajosRealizados']),
              'repuestosUsados': _decodeStringList(row['repuestosUsados']),
              'costo': row['costo'] ?? 0.0,
            }),
          )
          .toList();
    } catch (e) {
      debugPrint('Error cargando mantenimientos: $e');
      return <Mantenimiento>[];
    }
  }

  Future<void> saveMantenimientos(List<Mantenimiento> mantenimientos) async {
    try {
      final motoId = await _currentMotoId();
      if (motoId == null) {
        throw Exception('No hay moto configurada');
      }

      final db = await _db();
      await db.delete(
        'mantenimientos',
        where: 'motoId = ?',
        whereArgs: [motoId],
      );

      for (final item in mantenimientos) {
        final row = {
          'id': item.id,
          'motoId': motoId,
          'fecha': item.fecha.toIso8601String(),
          'kilometraje': item.kilometraje,
          'tipo': item.tipo,
          'descripcion': item.descripcion,
          'costo': item.costo,
          'taller': item.taller,
          'tecnico': item.tecnico,
          'trabajosRealizados': jsonEncode(item.trabajosRealizados),
          'repuestosUsados': jsonEncode(item.repuestosUsados),
          'intervaloRecomendado': item.intervaloRecomendado,
          'observaciones': item.observaciones,
          'completado': item.completado ? 1 : 0,
        };
        await db.insert('mantenimientos', row, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    } catch (e) {
      debugPrint('Error guardando mantenimientos: $e');
      throw Exception('No se pudieron guardar los mantenimientos: $e');
    }
  }

  Future<List<Recordatorio>> getRecordatorios() async {
    try {
      final motoId = await _currentMotoId();
      if (motoId == null) return <Recordatorio>[];

      final db = await _db();
      final rows = await db.query(
        'recordatorios',
        where: 'motoId = ?',
        whereArgs: [motoId],
      );

      return rows
          .map(
            (row) => Recordatorio.fromJson({
              ...row,
              'completado': (row['completado'] as int? ?? 0) == 1,
              'metadata': _decodeMetadata(row['metadata']),
            }),
          )
          .toList();
    } catch (e) {
      debugPrint('Error cargando recordatorios: $e');
      return <Recordatorio>[];
    }
  }

  Future<void> saveRecordatorios(List<Recordatorio> recordatorios) async {
    try {
      final motoId = await _currentMotoId();
      if (motoId == null) {
        throw Exception('No hay moto configurada');
      }

      final db = await _db();
      await db.delete(
        'recordatorios',
        where: 'motoId = ?',
        whereArgs: [motoId],
      );

      for (final item in recordatorios) {
        final row = {
          'id': item.id,
          'motoId': motoId,
          'titulo': item.titulo,
          'descripcion': item.descripcion,
          'fechaCreacion': item.fechaCreacion.toIso8601String(),
          'fechaVencimiento': item.fechaVencimiento.toIso8601String(),
          'tipo': item.tipo,
          'prioridad': item.prioridad,
          'completado': item.completado ? 1 : 0,
          'accion': item.accion,
          'metadata': item.metadata == null ? null : jsonEncode(item.metadata),
        };
        await db.insert('recordatorios', row, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    } catch (e) {
      debugPrint('Error guardando recordatorios: $e');
      throw Exception('No se pudieron guardar los recordatorios: $e');
    }
  }

  Future<void> clearAllData() async {
    await clearCurrentUserData();
  }

  Future<Map<String, dynamic>> exportAllData() async {
    try {
      final user = AuthService().currentUser;
      if (user == null) throw Exception('No hay usuario autenticado');

      final moto = await getMoto();
      final documentos = await getDocumentos();
      final mantenimientos = await getMantenimientos();
      final recordatorios = await getRecordatorios();

      return {
        'user_id': user.id,
        'user_email': user.email,
        'moto': moto == null ? null : jsonEncode(moto.toJson()),
        'documentos': jsonEncode(documentos.map((e) => e.toJson()).toList()),
        'mantenimientos': jsonEncode(mantenimientos.map((e) => e.toJson()).toList()),
        'recordatorios': jsonEncode(recordatorios.map((e) => e.toJson()).toList()),
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

      if (data['moto'] != null) {
        final motoValue = data['moto'];
        final motoMap = motoValue is String ? jsonDecode(motoValue) : motoValue;
        final moto = Moto.fromJson(Map<String, dynamic>.from(motoMap));
        final motoToSave = moto.copyWith(userId: user.id);
        await saveMoto(motoToSave);
      }

      if (data['documentos'] != null) {
        final documentosValue = data['documentos'];
        final list = documentosValue is String ? jsonDecode(documentosValue) as List : documentosValue as List;
        final docs = list
            .map((e) => Documento.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        await saveDocumentos(docs);
      }

      if (data['mantenimientos'] != null) {
        final value = data['mantenimientos'];
        final list = value is String ? jsonDecode(value) as List : value as List;
        final mantenimientos = list
            .map((e) => Mantenimiento.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        await saveMantenimientos(mantenimientos);
      }

      if (data['recordatorios'] != null) {
        final value = data['recordatorios'];
        final list = value is String ? jsonDecode(value) as List : value as List;
        final recordatorios = list
            .map((e) => Recordatorio.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        await saveRecordatorios(recordatorios);
      }
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

      final moto = await getMoto();
      final documentos = await getDocumentos();
      final mantenimientos = await getMantenimientos();
      final recordatorios = await getRecordatorios();

      return {
        'authenticated': true,
        'user': user.email,
        'moto': moto != null,
        'documentos': documentos.isNotEmpty,
        'mantenimientos': mantenimientos.isNotEmpty,
        'recordatorios': recordatorios.isNotEmpty,
        'initialized': moto != null,
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
      final db = await _db();

      final motoCount = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM motos WHERE userId = ?', [user?.id]),
          ) ??
          0;
      final documentosCount = Sqflite.firstIntValue(
            await db.rawQuery(
              'SELECT COUNT(*) FROM documentos WHERE motoId IN (SELECT id FROM motos WHERE userId = ?)',
              [user?.id],
            ),
          ) ??
          0;
      final mantenimientosCount = Sqflite.firstIntValue(
            await db.rawQuery(
              'SELECT COUNT(*) FROM mantenimientos WHERE motoId IN (SELECT id FROM motos WHERE userId = ?)',
              [user?.id],
            ),
          ) ??
          0;
      final recordatoriosCount = Sqflite.firstIntValue(
            await db.rawQuery(
              'SELECT COUNT(*) FROM recordatorios WHERE motoId IN (SELECT id FROM motos WHERE userId = ?)',
              [user?.id],
            ),
          ) ??
          0;

      return {
        'authenticated_user': user?.email ?? 'none',
        'user_id': user?.id ?? 'none',
        'motos': motoCount,
        'documentos': documentosCount,
        'mantenimientos': mantenimientosCount,
        'recordatorios': recordatoriosCount,
      };
    } catch (e) {
      debugPrint('Error obteniendo información de diagnóstico: $e');
      return {'error': e.toString()};
    }
  }

  List<String> _decodeStringList(dynamic value) {
    if (value == null || value.toString().isEmpty) return <String>[];
    try {
      final decoded = jsonDecode(value.toString());
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {}
    return <String>[];
  }

  Map<String, dynamic>? _decodeMetadata(dynamic value) {
    if (value == null || value.toString().isEmpty) return null;
    try {
      final decoded = jsonDecode(value.toString());
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {}
    return null;
  }
}
