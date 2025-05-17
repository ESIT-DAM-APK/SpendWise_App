import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transac_item.dart';
import 'dart:developer';
import '../models/user_model.dart';

class TransacDatabase {
  static final TransacDatabase instance = TransacDatabase._init();
  static Database? _database;
  
  TransacDatabase._init();

  final String tableTransac = 'transactions'; // Cambiado a nombre más descriptivo
  final String tableUser = 'users';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('transac.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // Versión incrementada por cambios de esquema
      onCreate: _onCreateDB,
      onUpgrade: _onUpgradeDB,
      onOpen: (db) async {
        await _verifyTables(db);
      },
    );
  }

  Future<void> _verifyTables(Database db) async {
    try {
      await db.rawQuery('SELECT 1 FROM $tableUser LIMIT 1');
      await db.rawQuery('SELECT 1 FROM $tableTransac LIMIT 1');
    } catch (e) {
      log('Error verificando tablas: $e');
      await _onCreateDB(db, 1);
    }
  }

  Future<void> _onCreateDB(Database db, int version) async {
    await db.execute(''' 
      CREATE TABLE IF NOT EXISTS $tableUser (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableTransac (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        description TEXT NOT NULL,
        userId INTEGER NOT NULL, 
        FOREIGN KEY (userId) REFERENCES $tableUser(id) ON DELETE CASCADE
      )
    ''');

    // Usuario por defecto
    await db.insert(tableUser, {
      'username': 'admin',
      'password': '1234',
    });
  }

  Future<void> _onUpgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tableTransac (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          type TEXT NOT NULL,
          amount REAL NOT NULL,
          date TEXT NOT NULL,
          description TEXT NOT NULL,
          userId INTEGER NOT NULL,
          FOREIGN KEY (userId) REFERENCES $tableUser(id) ON DELETE CASCADE
        )
      ''');
    }
  }

  // CRUD para transacciones
  Future<List<TransacItem>> getTransacsByUser(int userId) async {
    final db = await instance.database;
    try {
      final maps = await db.query(
        tableTransac,
        where: 'userId = ?',
        whereArgs: [userId],
      );
      return List.generate(maps.length, (i) => TransacItem.fromMap(maps[i]));
    } catch (e) {
      log('Error en getTransacsByUser: $e');
      return [];
    }
  }
  
  Future<int> insertTransac(TransacItem item) async {
    final db = await instance.database;
    try {
      final id = await db.insert(
        tableTransac,
        item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      log("Transacción guardada con ID: $id");
      return id;
    } catch (e) {
      log('Error en insertTransac: $e');
      return -1;
    }
  }

  Future<int> deleteTransac(int id) async {
    final db = await instance.database;
    try {
      return await db.delete(
        tableTransac, 
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      log('Error en deleteTransac: $e');
      return 0;
    }
  }

  Future<int> updateTransac(TransacItem item) async {
    final db = await instance.database;
    try {
      return await db.update(
        tableTransac,
        item.toMap(),
        where: 'id = ?',
        whereArgs: [item.id],
      );
    } catch (e) {
      log('Error en updateTransac: $e');
      return 0;
    }
  }

  Future<List<TransacItem>> getAllTransacs() async {
    final db = await instance.database;
    try {
      final result = await db.query(tableTransac);
      return result.map((json) => TransacItem.fromMap(json)).toList();
    } catch (e) {
      log('Error en getAllTransacs: $e');
      return [];
    }
  }

  Future<double> getTotalAmount(String type, int userId) async {
    final db = await instance.database;
    try {
      final result = await db.rawQuery('''
        SELECT SUM(amount) as total 
        FROM $tableTransac 
        WHERE type = ? AND userId = ?
      ''', [type, userId]);
      return result.first['total'] as double? ?? 0.0;
    } catch (e) {
      log('Error en getTotalAmount: $e');
      return 0.0;
    }
  }

  // CRUD para usuarios
  Future<int> insertUser(UserModel user) async {
    final db = await instance.database;
    try {
      return await db.insert(
        tableUser, 
        user.toMap(), 
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      log('Error en insertUser: $e');
      return -1;
    }
  }

  Future<Map<String, dynamic>?> login(String username, String password) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Método para desarrollo: eliminar base de datos
  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }

  Future<void> deleteAppDatabase() async {  // Cambia el nombre del método
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'transac.db');
    await deleteDatabase(path);  // Ahora llama a la función de sqflite sin conflicto
  }
}