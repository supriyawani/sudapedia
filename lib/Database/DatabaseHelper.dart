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
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
//import 'package:sqflite/sqflitepackage:path/path.dart';

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
          //  'CREATE TABLE employees(id INTEGER PRIMARY KEY AUTOINCREMENT, employeeID TEXT, userToken TEXT)',
          //   'CREATE TABLE employees(id INTEGER PRIMARY KEY AUTOINCREMENT, employeeID TEXT, userToken TEXT, insertedAt INTEGER)',
          'CREATE TABLE employees(id INTEGER PRIMARY KEY AUTOINCREMENT, employeeID TEXT,groupID TEXT, userToken TEXT, insertedAt INTEGER,notificationCount INTEGER DEFAULT 3)',
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

  Future<void> insertGroupID(String groupID) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('employees');

    if (maps.isEmpty) {
      await db.insert(
        'employees',
        {'groupID': groupID},
      );
    } else {
      await db.update(
        'employees',
        {'groupID': groupID},
        where: 'id = ?',
        whereArgs: [maps.first['id']],
      );
    }

    print("Inserted groupID: $groupID");
  }

  /*Future<void> insertToken(String userToken) async {
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
  }*/

  Future<bool> insertToken1(String userToken) async {
    try {
      final db = await database;
      final int currentTime = DateTime.now().millisecondsSinceEpoch;
      final List<Map<String, dynamic>> maps = await db.query('employees');

      if (maps.isEmpty) {
        await db.insert(
          'employees',
          {'userToken': userToken, 'insertedAt': currentTime},
        );
      } else {
        await db.update(
          'employees',
          {'userToken': userToken, 'insertedAt': currentTime},
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

  /* void startTokenExpiryCheck() {
    Timer.periodic(Duration(hours: 1), (timer) async {
      final db = await database;
      final int currentTime = DateTime.now().millisecondsSinceEpoch;
      final int twentyFourHours = 24 * 60 * 60 * 1000;

      final List<Map<String, dynamic>> maps =
          await db.query('employees', columns: ['id', 'insertedAt']);

      for (var map in maps) {
        final int insertedAt = map['insertedAt'] as int;
        if (currentTime - insertedAt > twentyFourHours) {
          await db.delete('employees', where: 'id = ?', whereArgs: [map['id']]);
        }
      }
    });
  }*/

  Future<String?> getToken1(BuildContext context) async {
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

  Future<String?> getGroupID() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('employees', columns: ['groupID']);

    print("Group ID Query Result: $maps"); // Add this line to check the result

    if (maps.isNotEmpty) {
      return maps.first['groupID'] as String?;
    } else {
      return null;
    }
  }

  Future<void> clearTable() async {
    final db = await database;
    await db.delete('employees');
    //print("tokendeleted:"+getToken1(context as BuildContext));
  }

  Future<bool> isUserLoggedIn() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('employees');
    return maps.isNotEmpty;
  }

  /*Future<void> clearUserSession() async {
    final db = await database;
    await db.delete('employees');
  }*/

  Future<void> insertNotificationCount(int notificationCount) async {
    final db = await database;
    // Check if there's an existing row
    final List<Map<String, dynamic>> maps = await db.query('employees');

    if (maps.isEmpty) {
      await db.insert(
        'employees',
        {'notificationCount': notificationCount},
      );
    } else {
      await db.update(
        'employees',
        {'notificationCount': notificationCount},
        where: 'id = ?',
        whereArgs: [maps.first['id']],
      );
    }

    print("Inserted notificationCount: $notificationCount");
  }

  Future<void> updateNotificationCount(int count) async {
    final db = await database;
    await db.update(
      'employees',
      {'notificationCount': count},
      where: 'id = ?',
      whereArgs: [1], // Assuming you have a single row for notification count
    );
    print("updateNotificationCount: $count");
  }

  Future<int?> getNotificationCount() async {
    final db = await database;
    final result = await db.query(
      'employees',
      columns: ['notificationCount'],
      where: 'id = ?',
      whereArgs: [1],
    );

    if (result.isNotEmpty) {
      print("notificationCountFromDB:" +
          result.first['notificationCount'].toString());
      return result.first['notificationCount'] as int?;
    }
    return null;
  }
}
