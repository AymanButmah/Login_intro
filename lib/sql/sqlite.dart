import 'dart:async';
import 'package:get/get.dart';
import 'package:intro_project/models/currency.dart';
import 'package:intro_project/models/order.dart';
import 'package:intro_project/models/user.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  final databaseName = "archive.db";
  Database? db;
  bool initialise = false;
  String users =
      "create table users (userId INTEGER PRIMARY KEY AUTOINCREMENT, userName TEXT UNIQUE, userPassword TEXT)";

  String orders =
      "create table orders (orderId INTEGER PRIMARY KEY AUTOINCREMENT,orderDate TEXT,orderAmount REAL,equalOrderAmount REAL,currencyId INTEGER,status BOOLEAN,orderType TEXT,userId INTEGER,FOREIGN KEY (userId) REFERENCES users(userId),FOREIGN KEY (currencyId) REFERENCES currency(currencyId))";

  String currency =
      "create table currency (currencyId INTEGER PRIMARY KEY AUTOINCREMENT,currencyName TEXT UNIQUE,currencySymbol TEXT UNIQUE,currencyRate REAL)";

  RxList<User> filteredUserData = <User>[].obs;
  List<User> userData = [];

  RxList filteredOrderData = [].obs;
  List<Order> orderData = [];

  RxList<Currency> filteredCurrencyData = <Currency>[].obs;
  List<Currency> currencyData = [];

  Future<Database> initDB() async {
    if (initialise) {
      //To Make sure database initialise normally
      return db!;
    }
    //init database skeletonCode
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);
    db = await openDatabase(path, version: 1, onConfigure: _onConfigure,
        onCreate: (db, version) async {
      await db.execute(users);
      await db.execute(currency);
      await db.execute(orders);
    });
    return db!;
  }

  // to Activate foreign key in tables
  static Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  init() async {
    db = await initDB();
    initialise = true;
  }

  //-------------------------------------------------------------------------------------------------------------
  //Sign in
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
    //to prevent the duplicated users scenario
    final Database db = await initDB();
    final List<Map<String, dynamic>> response =
        await db.query("users", where: "userName = ?", whereArgs: [username]);
    return response.isNotEmpty;
  }

  //-------------------------------------------------------------------------------------------------------------
  //get All users
  Future<List<User>> getUsers() async {
    final Database db = await initDB();
    List<Map<String, Object?>> result = await db.query('users');
    userData = result.map((e) => User.fromJson(e)).toList();
    filteredUserData.value = userData;
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

  //-------------------------------------------------------------------------------------------------------------
  //get all Orders
  Future<List<Order>> getOrders() async {
    final Database db = await initDB();
    List<Map<String, Object?>> result = await db.query('orders');
    orderData = result.map((e) => Order.fromJson(e)).toList();
    filteredOrderData.value = orderData;
    return orderData;
  }

//get all Orders by User
  Future<List<Order>> getAllOrdersByUser(userId) async {
    final Database db = await initDB();
    List<Map<String, dynamic>> allRows = await db.rawQuery('''
    SELECT * FROM orders 
    WHERE userId = $userId
    ''');
    List<Order> orders = allRows.map((order) => Order.fromJson(order)).toList();
    return orders;
  }

  //Create Order
  Future<int> createOrder(Order order) async {
    var result = await db!.insert('orders', order.toJson());
    getOrders();
    return result;
  }

  //Update Order
  Future<int> updateOrder(
    orderId,
    orderDate,
    orderAmount,
    equalOrderAmount,
    currencyId,
    status,
    orderType,
    userId,
  ) async {
    var result = await db!.rawUpdate(
      'update orders set orderAmount = ?,equalOrderAmount = ?, orderDate = ?, currencyId = ?, status = ?,orderType = ? WHERE orderId = ? AND userId = ?',
      [
        orderAmount,
        equalOrderAmount,
        orderDate,
        currencyId,
        status,
        orderType,
        orderId,
        userId
      ],
    );
    getOrders();
    return result;
  }

  Future<int> updateStatusOrder(status, orderId) async {
    var result = await db!.rawUpdate(
      'update orders set status = ? WHERE orderId = ?',
      [
        status,
        orderId,
      ],
    );
    getOrders();
    return result;
  }

  //Delete Order
  Future<int> deleteOrder(int orderId) async {
    var result =
        await db!.delete('orders', where: 'orderId = ?', whereArgs: [orderId]);
    getOrders();
    return result;
  }

  //-------------------------------------------------------------------------------------------------------------
  //get all Currency
  Future<List<Currency>> getCurrencies() async {
    final Database db = await initDB();
    List<Map<String, Object?>> result = await db.query('currency');
    currencyData = result.map((e) => Currency.fromJson(e)).toList();
    filteredCurrencyData.value = currencyData;
    return currencyData;
  }

  //Create Order
  Future<int> createCurrency(Currency currency) async {
    var result = await db!.insert('currency', currency.toJson());
    getCurrencies();
    return result;
  }

  //Update Order
  Future<int> updateCurrency(
    currencyId,
    currencyName,
    currencySymbol,
    currencyRate,
  ) async {
    var result = await db!.rawUpdate(
      'update currency set currencyName = ?,currencySymbol = ?, currencyRate = ? where currencyId = ?',
      [currencyName, currencySymbol, currencyRate, currencyId],
    );
    getCurrencies();
    return result;
  }

  //Delete Order
  Future<int> deleteCurrency(int currencyId) async {
    var result = await db!
        .delete('currency', where: 'currencyId = ?', whereArgs: [currencyId]);
    getCurrencies();
    return result;
  }
}
