// lib/features/statistics/helpers/statistics_helper.dart
import '../../../core/database/database_helper.dart';
import 'package:intl/intl.dart';

class StatisticsHelper {
  // Popular books: ambil top N buku berdasarkan jumlah transaksi
  static Future<List<Map<String, dynamic>>> getPopularBooks({int top = 5}) async {
    final db = DatabaseHelper.instance;
    final data = await db.database;
    final result = await data.rawQuery('''
      SELECT b.title, COUNT(t.id) AS borrow_count
      FROM transactions t
      JOIN books b ON t.book_id = b.id
      GROUP BY b.id
      ORDER BY borrow_count DESC
      LIMIT ?
    ''', [top]);
    return result;
  }

  // Monthly transaction summary (jumlah transaksi tiap bulan)
  static Future<List<Map<String, dynamic>>> getMonthlySummary() async {
    final db = DatabaseHelper.instance;
    final result = await (await db.database).rawQuery('''
      SELECT strftime('%Y-%m', borrow_date) AS month, COUNT(*) AS total
      FROM transactions
      GROUP BY month
      ORDER BY month ASC
    ''');
    return result;
  }

  // Daftar buku overdue (status != returned dan return_date < today)
  static Future<List<Map<String, dynamic>>> getOverdueBooks() async {
    final db = DatabaseHelper.instance;
    final today = DateTime.now().toIso8601String();
    final result = await (await db.database).rawQuery('''
      SELECT t.id, b.title, m.name AS member_name, t.borrow_date, t.return_date
      FROM transactions t
      JOIN books b ON t.book_id = b.id
      JOIN members m ON t.member_id = m.id
      WHERE t.status != 'returned' AND t.return_date < ?
      ORDER BY t.return_date ASC
    ''', [today]);
    return result;
  }
}
