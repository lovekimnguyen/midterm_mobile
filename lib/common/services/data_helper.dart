import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../features/main_page/model/order.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // Table and column names
  static const String tableOrders = 'orders';
  static const String columnId = 'id';
  static const String columnQuantity = 'quantity';
  static const String columnStatus = 'status';
  static const String columnIsWhippedCream = 'isWhippedCream';
  static const String columnIsChocolate = 'isChocolate';
  static const String columnPrice = 'price';

  // Singleton pattern
  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'coffee_orders.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Create table (Initial schema with the new 'price' column)
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableOrders (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnQuantity INTEGER,
        $columnStatus TEXT,
        $columnIsWhippedCream INTEGER,
        $columnIsChocolate INTEGER,
        $columnPrice REAL  
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        ALTER TABLE $tableOrders ADD COLUMN $columnPrice REAL;
      ''');
    }
  }

  Future<int> _getNextId() async {
    final db = await database;

    var result = await db.rawQuery("SELECT MAX($columnId) FROM $tableOrders");

    if (result.isEmpty || result.first.values.first == null) {
      return 1;
    }
    int maxId = result.first.values.first as int;
    return maxId + 1;
  }

  // Insert a new order
  Future<void> insertOrder(Order order) async {
    final db = await database;

    // Get the next ID for the new order
    int newId = await _getNextId();

    // Insert the new order with the generated ID
    await db.insert(
      tableOrders,
      {
        columnId: newId,
        columnQuantity: order.quantity,
        columnStatus: order.status,
        columnIsWhippedCream: order.isWhippedCream ? 1 : 0,
        columnIsChocolate: order.isChocolate ? 1 : 0,
        columnPrice: order.price,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all orders
  Future<List<Order>> getOrders() async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(tableOrders);
    return List.generate(maps.length, (i) => Order.fromMap(maps[i]));
  }

  // Update the status of an order
  Future<void> updateOrderStatus(String id, String newStatus) async {
    final db = await database;
    await db.update(
      tableOrders,
      {columnStatus: newStatus},
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  // Delete an order
  Future<void> deleteOrder(String id) async {
    final db = await database;
    await db.delete(
      tableOrders,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  // Search orders by ID
  Future<List<Order>> searchOrdersById(String id) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      tableOrders,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    return List.generate(maps.length, (i) => Order.fromMap(maps[i]));
  }
}
