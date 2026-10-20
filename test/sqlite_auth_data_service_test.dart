import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:moto_monitor/db/database_helper.dart';
import 'package:moto_monitor/models/moto.dart';
import 'package:moto_monitor/services/auth_service.dart';
import 'package:moto_monitor/services/data_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    await DatabaseHelper.instance.useInMemoryDatabaseForTesting();

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    await AuthService().logout();
  });

  tearDown(() async {
    await DatabaseHelper.instance.resetForTesting();

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    await AuthService().logout();
  });

  test('crear usuario guarda passwordHash distinto al password plano', () async {
    final auth = AuthService();

    final result = await auth.register(
      name: 'Ana Gómez',
      email: 'ana@test.com',
      password: 'SuperSecret123',
      phone: '3001234567',
    );

    expect(result.success, isTrue, reason: result.message);
    expect(auth.currentUser, isNotNull);

    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: ['ana@test.com'],
      limit: 1,
    );

    expect(rows, isNotEmpty);
    final storedHash = rows.first['passwordHash'] as String?;
    expect(storedHash, isNotNull);
    expect(storedHash, isNotEmpty);
    expect(storedHash, isNot(equals('SuperSecret123')));

    final loginResult = await auth.login(
      email: 'ana@test.com',
      password: 'SuperSecret123',
    );
    expect(loginResult.success, isTrue, reason: loginResult.message);
  });

  test('registrar una moto con userId válido', () async {
    final auth = AuthService();
    final registerResult = await auth.register(
      name: 'Luis',
      email: 'luis@test.com',
      password: 'Pass1234',
    );

    expect(registerResult.success, isTrue, reason: registerResult.message);
    final user = registerResult.user;
    expect(user, isNotNull);

    final moto = Moto(
      id: 'moto-001',
      userId: user!.id,
      marca: 'Yamaha',
      modelo: 'MT-03',
      ano: 2024,
      placa: 'ABC123',
      kilometraje: 1200,
      fechaCompra: DateTime.now().subtract(const Duration(days: 50)),
      fechaUltimaActualizacion: DateTime.now(),
      color: 'Azul',
      motor: '321cc',
      observaciones: 'Primera moto',
    );

    await DataService.instance.saveMoto(moto);

    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'motos',
      where: 'id = ?',
      whereArgs: [moto.id],
      limit: 1,
    );

    expect(rows, isNotEmpty);
    expect(rows.first['userId'], equals(user.id));
    expect(rows.first['marca'], equals('Yamaha'));
    expect(rows.first['modelo'], equals('MT-03'));
  });

  test('rechaza un mantenimiento con motoId inexistente por integridad referencial', () async {
    final db = await DatabaseHelper.instance.database;

    await db.insert(
      'users',
      {
        'id': 'user-ref',
        'name': 'Ref User',
        'email': 'ref@test.com',
        'phone': '111',
        'passwordHash': 'hash',
        'createdAt': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.abort,
    );

    final badMaintenance = {
      'id': 'mant-999',
      'motoId': 'moto-inexistente',
      'fecha': DateTime.now().toIso8601String(),
      'kilometraje': 5000,
      'tipo': 'Preventivo',
      'descripcion': 'Falla de referencia',
      'costo': 200.0,
      'taller': 'El taller',
      'tecnico': 'Tecnico',
      'trabajosRealizados': jsonEncode(['Cambio de aceite']),
      'repuestosUsados': jsonEncode(['Filtro']),
      'intervaloRecomendado': 5000,
      'observaciones': 'Debe fallar',
      'completado': 1,
    };

    expect(
      () async => db.insert(
        'mantenimientos',
        badMaintenance,
        conflictAlgorithm: ConflictAlgorithm.abort,
      ),
      throwsException,
    );
  });
}
