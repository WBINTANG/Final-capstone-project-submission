import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /* ===================== DATABASE INIT ===================== */

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('perpusku.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // BOOKS
    await db.execute('''
      CREATE TABLE books (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        isbn TEXT,
        category TEXT,
        stock INTEGER,
        cover_photo TEXT
      )
    ''');

    // MEMBERS
    await db.execute('''
      CREATE TABLE members (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        member_id TEXT NOT NULL,
        phone TEXT,
        photo TEXT
      )
    ''');

    // TRANSACTIONS (BORROWING)
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        book_id INTEGER,
        member_id INTEGER,
        borrow_date TEXT,
        return_date TEXT,
        fine INTEGER,
        status TEXT
      )
    ''');
  }

  /* ===================== BOOK CRUD ===================== */

  Future<int> insertBook(Map<String, dynamic> book) async {
    final db = await database;
    return await db.insert('books', book);
  }

  Future<List<Map<String, dynamic>>> getBooks() async {
    final db = await database;
    return await db.query('books');
  }

  Future<int> updateBook(Map<String, dynamic> book) async {
    final db = await database;
    return await db.update(
      'books',
      book,
      where: 'id = ?',
      whereArgs: [book['id']],
    );
  }

  Future<int> deleteBook(int id) async {
    final db = await database;
    return await db.delete(
      'books',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /* ===================== MEMBER CRUD ===================== */

  Future<int> insertMember(Map<String, dynamic> member) async {
    final db = await database;
    return await db.insert('members', member);
  }

  Future<List<Map<String, dynamic>>> getMembers() async {
    final db = await database;
    return await db.query('members');
  }

  Future<int> deleteMember(int id) async {
    final db = await database;
    return await db.delete(
      'members',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /* ===================== TRANSACTIONS ===================== */

  Future<int> borrowBook(Map<String, dynamic> transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction);
  }

  // Ambil semua transaksi
  Future<List<Map<String, dynamic>>> getBorrowingHistory() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT transactions.*, books.title, members.name
      FROM transactions
      JOIN books ON transactions.book_id = books.id
      JOIN members ON transactions.member_id = members.id
      ORDER BY borrow_date DESC
    ''');
  }

  // Ambil transaksi berdasarkan memberId
  Future<List<Map<String, dynamic>>> getTransactionsByMember(int memberId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT t.id, b.title, t.borrow_date, t.return_date, t.status, t.fine
      FROM transactions t
      JOIN books b ON t.book_id = b.id
      WHERE t.member_id = ?
      ORDER BY t.borrow_date DESC
    ''', [memberId]);
  }

  Future<int> returnBook({
    required int transactionId,
    required String returnDate,
    required int fine,
  }) async {
    final db = await database;
    return await db.update(
      'transactions',
      {
        'return_date': returnDate,
        'fine': fine,
        'status': 'returned',
      },
      where: 'id = ?',
      whereArgs: [transactionId],
    );
  }
}
