import 'dart:async';

import 'package:get/get.dart';
import 'package:intro_project/models/user.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  final databaseName = "users.db";
  Database? db;
  bool initialise = false;
  String users =
      "create table users (userId INTEGER PRIMARY KEY AUTOINCREMENT, userName TEXT UNIQUE, userPassword TEXT)";

  RxList filteredData = [].obs;
  List<User> userData = [];

  Future<Database> initDB() async {
    if (initialise) {
      return db!;
    }
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);
    db = await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(users);
    });
    return db!;
  }

  init() async {
    db = await initDB();
    initialise = true;
  }

  Future<bool> login(User user) async {
    final Database db = await initDB();
    var result = await db.rawQuery(
        "select * from users where userName = '${user.userName}' AND userPassword = '${user.userPassword}'");
    if (result.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  //Sign up
  Future<int> signup(User user) async {
    final Database db = await initDB();
    return db.insert('users', user.toJson());
  }

  //check duplicates
  Future<bool> checkUserExist(String username) async {
    final Database db = await initDB();
    final List<Map<String, dynamic>> response =
        await db.query("users", where: "userName = ?", whereArgs: [username]);
    return response.isNotEmpty;
  }

  //get All users
  Future<List<User>> getUsers() async {
    print("Kiser");
    final Database db = await initDB();
    List<Map<String, Object?>> result = await db.query('users');
    print(result);
    userData = result.map((e) => User.fromJson(e)).toList();
    filteredData.value = userData;
    return userData;
  }

  //Create User
  Future<int> createUser(User user) async {
    var result = await db!.insert('users', user.toJson());
    getUsers();
    return result;
  }

  //Update User
  Future<int> updateUser(userName, userPassword, userId) async {
    var result = await db!.rawUpdate(
        'update users set userName = ?, userPassword = ? where userId = ?',
        [userName, userPassword, userId]);
    getUsers();
    return result;
  }

  //Delete User
  Future<int> deleteUser(int userId) async {
    var result =
        await db!.delete('users', where: 'userId = ?', whereArgs: [userId]);
    getUsers();
    return result;
  }
}
