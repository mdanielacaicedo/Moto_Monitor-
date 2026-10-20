import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;
  static String? _databasePathOverride;

  Future<void> useInMemoryDatabaseForTesting() async {
    await resetForTesting();
    _databasePathOverride = inMemoryDatabasePath;
  }

  Future<void> resetForTesting() async {
    final db = _database;
    if (db != null && db.isOpen) {
      await db.close();
    }
    _database = null;
    _databasePathOverride = null;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final resolvedPath = _databasePathOverride ?? p.join(await getDatabasesPath(), 'moto_monitor.db');

    return openDatabase(
      resolvedPath,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id TEXT PRIMARY KEY,
            name TEXT,
            email TEXT UNIQUE,
            phone TEXT,
            passwordHash TEXT,
            createdAt TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE motos(
            id TEXT PRIMARY KEY,
            userId TEXT REFERENCES users(id) ON DELETE CASCADE,
            marca TEXT,
            modelo TEXT,
            ano INTEGER,
            placa TEXT,
            kilometraje INTEGER CHECK(kilometraje >= 0),
            fechaCompra TEXT,
            fechaUltimaActualizacion TEXT,
            color TEXT,
            motor TEXT,
            observaciones TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE documentos(
            id TEXT PRIMARY KEY,
            motoId TEXT REFERENCES motos(id) ON DELETE CASCADE,
            tipo TEXT,
            numero TEXT,
            fechaExpedicion TEXT,
            fechaVencimiento TEXT,
            entidadExpedidora TEXT,
            observaciones TEXT,
            activo INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE mantenimientos(
            id TEXT PRIMARY KEY,
            motoId TEXT REFERENCES motos(id) ON DELETE CASCADE,
            fecha TEXT,
            kilometraje INTEGER,
            tipo TEXT,
            descripcion TEXT,
            costo REAL,
            taller TEXT,
            tecnico TEXT,
            trabajosRealizados TEXT,
            repuestosUsados TEXT,
            intervaloRecomendado INTEGER,
            observaciones TEXT,
            completado INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE recordatorios(
            id TEXT PRIMARY KEY,
            motoId TEXT REFERENCES motos(id) ON DELETE CASCADE,
            titulo TEXT,
            descripcion TEXT,
            fechaCreacion TEXT,
            fechaVencimiento TEXT,
            tipo TEXT,
            prioridad TEXT,
            completado INTEGER,
            accion TEXT,
            metadata TEXT
          )
        ''');
      },
    );
  }
}
