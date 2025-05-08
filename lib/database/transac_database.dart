import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../transac_item.dart'; // Ajusta el path si está en una subcarpeta como 'pages/home.dart'
import 'dart:developer';
import '../models/user_model.dart'; // Ajusta el path si está en una subcarpeta como 'pages/home.dart'
// Ajusta el path si está en una subcarpeta como 'pages/home.dart'


class TransacDatabase {
  static final TransacDatabase instance = TransacDatabase._init();
  static Database? _database;
  TransacDatabase._init();

 // static const String tableTransac = 'table_transac'; // <-- ¡CORREGIDO!
  final String tableTransac = 'table_transac';    
  final String tableUser = 'users';


  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('transac.db');

    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _onCreateDB);
  }

  Future _onCreateDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableTransac(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        description TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableUser(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

  // Usuario por defecto
    await db.insert('users', {
      'username': 'admin',
      'password': '1234',
    });
  }

// INICIO funciones CRUD para transacciones
  Future<void> insertTransac(TransacItem item) async {
    final db = await instance.database;
    await db.insert(
      tableTransac, // <- ya lo puede usar directamente
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print("Transacción guardada: ${item.toMap()}");  // Agregar esto para verificar
    log("Insert ejecutado con: ${item.toMap()}");
  }

  Future<void> deleteTransac(int id) async {
    final db = await instance.database;
    await db.delete('transacciones', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateTransac(TransacItem item) async {
    final db = await instance.database;
    await db.update(
      'transacciones',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<List<TransacItem>> getAllTransacs() async {
    final db = await instance.database;
    final result = await db.query(tableTransac);
    print("Transacciones recuperadas: $result"); // Esto te dirá si la consulta está devolviendo datos
    return result.map((json) => TransacItem.fromMap(json)).toList();
  }

  Future<double> getTotalAmount(String type) async {
    final db = await database;

    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM $tableTransac WHERE type = ?',
      [type],
    );

    final value = result.first['total'];
    return (value != null) ? (value as num).toDouble() : 0.0;
  }

  // INICIO funciones CRUD para transacciones


  Future<void> insertUser(UserModel user) async {
  final db = await instance.database;
  await db.insert(tableUser, user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<UserModel?> login(String username, String password) async {
      final db = await instance.database;
      final result = await db.query(tableUser,
          where: 'username = ? AND password = ?', whereArgs: [username, password]);
      if (result.isNotEmpty) {
        return UserModel.fromMap(result.first);
      }
      return null;
  }
}
