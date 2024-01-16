import 'package:intro_project/models/user.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  final databaseName = "users.db";

  String users =
      "create table users (userId INTEGER PRIMARY KEY AUTOINCREMENT, userName TEXT UNIQUE, userPassword TEXT)";

  Future<Database> initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);
    return openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(users);
    });
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

  //Sign up / add User
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
    final Database db = await initDB();
    List<Map<String, Object?>> result = await db.query('users');
    return result.map((e) => User.fromJson(e)).toList();
  }

  Stream<List<User>> listenAllUsers() async* {
    final Database db = await initDB();
    yield* db
        .query('users', orderBy: 'userId')
        .asStream()
        .map((List<Map<String, dynamic>> rows) {
      return rows
          .map((Map<String, dynamic> row) => User.fromJson(row))
          .toList();
    });
  }

  // get the last user
  Future<User> getLastUser() async {
    final Database db = await initDB();
    List<Map<String, Object?>> result =
        await db.query('users', orderBy: 'id DESC', limit: 1);

    if (result.isEmpty) {
      throw Exception("No users found");
    }

    return User.fromJson(result.first);
  }

  //filter
  Future<List<User>> searchUser(String inputKey) async {
    final Database db = await initDB();
    List<Map<String, Object?>> searchResult = await db
        .rawQuery("select * from users where userName LIKE ?", ["%$inputKey%"]);
    return searchResult.map((e) => User.fromJson(e)).toList();
  }

  //Create User
  Future<int> createUser(User user) async {
    final Database db = await initDB();

    return db.insert('users', user.toJson());
  }

  //Update User
  Future<int> updateUser(userName, userPassword, userId) async {
    final Database db = await initDB();
    return db.rawUpdate(
        'update users set userName = ?, userPassword = ? where userId = ?',
        [userName, userPassword, userId]);
  }

  //Delete User
  Future<int> deleteUser(int userId) async {
    final Database db = await initDB();
    return db.delete('users', where: 'userId = ?', whereArgs: [userId]);
  }
}
