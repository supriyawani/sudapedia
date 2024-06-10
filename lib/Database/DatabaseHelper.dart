/*import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE employees(id INTEGER PRIMARY KEY AUTOINCREMENT, employeeID TEXT, userToken TEXT)',
        );
      },
    );
  }

  */ /* Future<void> insertEmployeeID(String employeeID) async {
    final db = await database;
    // Clear existing employeeID before inserting new one
    await db.delete('employees');
    await db.insert(
      'employees',
      {'employeeID': employeeID},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }*/ /*
  Future<void> insertEmployeeID(String employeeID) async {
    final db = await database;
    await db.insert(
      'employees',
      {'employeeID': employeeID},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print("Inserted employeeID: $employeeID");
  }

  Future<String?> getEmployeeID() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('employees');

    if (maps.isNotEmpty) {
      return maps.first['employeeID'] as String?;
    } else {
      return null; // or you can handle it accordingly if no employee ID is found
    }
  }



  Future<bool> insertToken1(String userToken) async {
    try {
      final db = await database;
      // Clear existing data before inserting new one
      await db.delete('employees');
      await db.insert(
        'employees',
        {'userToken': userToken},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return true; // Insertion successful
    } catch (e) {
      print("Error inserting user token: $e");
      return false; // Insertion failed
    }
  }

  Future<String?> getToken() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('employees', columns: ['userToken']);

    if (maps.isNotEmpty) {
      return maps.first['userToken'] as String?;
    } else {
      return null; // or you can handle it accordingly if no token is found
    }
  }
}*/
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE employees(id INTEGER PRIMARY KEY AUTOINCREMENT, employeeID TEXT, userToken TEXT)',
        );
      },
    );
  }

  Future<void> insertEmployeeID(String employeeID) async {
    final db = await database;
    // Check if there's an existing row
    final List<Map<String, dynamic>> maps = await db.query('employees');

    if (maps.isEmpty) {
      await db.insert(
        'employees',
        {'employeeID': employeeID},
      );
    } else {
      await db.update(
        'employees',
        {'employeeID': employeeID},
        where: 'id = ?',
        whereArgs: [maps.first['id']],
      );
    }

    print("Inserted employeeID: $employeeID");
  }

  Future<void> insertToken(String userToken) async {
    final db = await database;
    // Check if there's an existing row
    final List<Map<String, dynamic>> maps = await db.query('employees');

    if (maps.isEmpty) {
      await db.insert(
        'employees',
        {'userToken': userToken},
      );
    } else {
      await db.update(
        'employees',
        {'userToken': userToken},
        where: 'id = ?',
        whereArgs: [maps.first['id']],
      );
    }
  }

  Future<bool> insertToken1(String userToken) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('employees');

      if (maps.isEmpty) {
        await db.insert(
          'employees',
          {'userToken': userToken},
        );
      } else {
        await db.update(
          'employees',
          {'userToken': userToken},
          where: 'id = ?',
          whereArgs: [maps.first['id']],
        );
      }

      return true;
    } catch (e) {
      print("Error inserting user token: $e");
      return false;
    }
  }

  Future<String?> getToken() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('employees', columns: ['userToken']);

    if (maps.isNotEmpty) {
      return maps.first['userToken'] as String?;
    } else {
      return null;
    }
  }

  Future<String?> getEmployeeID() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('employees', columns: ['employeeID']);

    if (maps.isNotEmpty) {
      return maps.first['employeeID'] as String?;
    } else {
      return null;
    }
  }

  Future<bool> isUserLoggedIn() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('employees');
    return maps.isNotEmpty;
  }

  Future<void> clearUserSession() async {
    final db = await database;
    await db.delete('employees');
  }
}
