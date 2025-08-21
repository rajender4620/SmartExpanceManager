import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import '../models/expense.dart';

class DatabaseService {
  static Database? _database;
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // Database constants
  static const String _databaseName = 'smart_expense_manager.db';
  static const int _databaseVersion = 1;
  
  // Table names
  static const String _expensesTable = 'expenses';
  
  // Get database instance
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  // Initialize database
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Create tables
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_expensesTable (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        description TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Insert some sample data
    await _insertSampleData(db);
  }

  // Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle future database schema changes
  }

  // Insert sample data for testing
  Future<void> _insertSampleData(Database db) async {
    final uuid = Uuid();
    final now = DateTime.now();
    
    final sampleExpenses = [
      Expense(
        id: uuid.v4(),
        title: 'Restaurant Dinner',
        amount: 85.50,
        category: 'Food & Dining',
        date: now.subtract(const Duration(days: 1)),
        description: 'Dinner with family',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      Expense(
        id: uuid.v4(),
        title: 'Grocery Shopping',
        amount: 120.75,
        category: 'Food & Dining',
        date: now.subtract(const Duration(days: 2)),
        description: 'Weekly groceries',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      Expense(
        id: uuid.v4(),
        title: 'Taxi Ride',
        amount: 25.00,
        category: 'Travel',
        date: now.subtract(const Duration(days: 1)),
        description: 'Ride to airport',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      Expense(
        id: uuid.v4(),
        title: 'Electricity Bill',
        amount: 150.00,
        category: 'Bills & Utilities',
        date: now.subtract(const Duration(days: 5)),
        description: 'Monthly electricity bill',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      Expense(
        id: uuid.v4(),
        title: 'New Shoes',
        amount: 120.00,
        category: 'Shopping',
        date: now.subtract(const Duration(days: 3)),
        description: 'Running shoes',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
    ];

    for (final expense in sampleExpenses) {
      await db.insert(_expensesTable, expense.toMap());
    }
  }

  // CRUD Operations for Expenses

  // Create expense
  Future<String> insertExpense(Expense expense) async {
    final db = await database;
    final uuid = Uuid();
    final id = uuid.v4();
    final now = DateTime.now();
    
    final expenseWithId = expense.copyWith(
      id: id,
      createdAt: now,
      updatedAt: now,
    );
    
    await db.insert(_expensesTable, expenseWithId.toMap());
    return id;
  }

  // Read all expenses
  Future<List<Expense>> getAllExpenses() async {
    final db = await database;
    final result = await db.query(
      _expensesTable,
      orderBy: 'date DESC',
    );
    
    return result.map((map) => Expense.fromMap(map)).toList();
  }

  // Read expenses by date range
  Future<List<Expense>> getExpensesByDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final result = await db.query(
      _expensesTable,
      where: 'date >= ? AND date <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );
    
    return result.map((map) => Expense.fromMap(map)).toList();
  }

  // Read expenses by category
  Future<List<Expense>> getExpensesByCategory(String category) async {
    final db = await database;
    final result = await db.query(
      _expensesTable,
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'date DESC',
    );
    
    return result.map((map) => Expense.fromMap(map)).toList();
  }

  // Read expense by ID
  Future<Expense?> getExpenseById(String id) async {
    final db = await database;
    final result = await db.query(
      _expensesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (result.isNotEmpty) {
      return Expense.fromMap(result.first);
    }
    return null;
  }

  // Update expense
  Future<void> updateExpense(Expense expense) async {
    final db = await database;
    final updatedExpense = expense.copyWith(updatedAt: DateTime.now());
    
    await db.update(
      _expensesTable,
      updatedExpense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  // Delete expense
  Future<void> deleteExpense(String id) async {
    final db = await database;
    await db.delete(
      _expensesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get total expenses
  Future<double> getTotalExpenses() async {
    final db = await database;
    final result = await db.rawQuery('SELECT SUM(amount) as total FROM $_expensesTable');
    return (result.first['total'] as double?) ?? 0.0;
  }

  // Get total expenses by category
  Future<Map<String, double>> getTotalExpensesByCategory() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT category, SUM(amount) as total 
      FROM $_expensesTable 
      GROUP BY category
    ''');
    
    final Map<String, double> categoryTotals = {};
    for (final row in result) {
      categoryTotals[row['category'] as String] = (row['total'] as double?) ?? 0.0;
    }
    return categoryTotals;
  }

  // Get recent expenses (last 10)
  Future<List<Expense>> getRecentExpenses({int limit = 10}) async {
    final db = await database;
    final result = await db.query(
      _expensesTable,
      orderBy: 'date DESC',
      limit: limit,
    );
    
    return result.map((map) => Expense.fromMap(map)).toList();
  }

  // Get expenses for current month
  Future<List<Expense>> getCurrentMonthExpenses() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    return getExpensesByDateRange(startOfMonth, endOfMonth);
  }

  // Clear all data (for testing purposes)
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete(_expensesTable);
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
