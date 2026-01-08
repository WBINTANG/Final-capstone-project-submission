import 'package:flutter/material.dart';
import '../../../core/database/database_helper.dart';

class ReturnBookScreen extends StatefulWidget {
  const ReturnBookScreen({super.key});

  @override
  State<ReturnBookScreen> createState() => _ReturnBookScreenState();
}

class _ReturnBookScreenState extends State<ReturnBookScreen> {
  List<Map<String, dynamic>> _borrowedBooks = [];

  @override
  void initState() {
    super.initState();
    _loadBorrowedBooks();
  }

  Future<void> _loadBorrowedBooks() async {
    final data =
    await DatabaseHelper.instance.getBorrowingHistory();

    setState(() {
      _borrowedBooks =
          data.where((t) => t['status'] == 'borrowed').toList();
    });
  }

  int _calculateFine(String borrowDate) {
    final borrowed = DateTime.parse(borrowDate);
    final dueDate = borrowed.add(const Duration(days: 7));
    final now = DateTime.now();

    if (now.isBefore(dueDate)) return 0;

    final lateDays = now.difference(dueDate).inDays;
    return lateDays * 1000;
  }

  Future<void> _returnBook(Map<String, dynamic> trx) async {
    final fine = _calculateFine(trx['borrow_date']);
    final returnDate = DateTime.now().toIso8601String();

    await DatabaseHelper.instance.returnBook(
      transactionId: trx['id'],
      returnDate: returnDate,
      fine: fine,
    );

    // tambah stok buku
    final book = (await DatabaseHelper.instance.getBooks())
        .firstWhere((b) => b['id'] == trx['book_id']);

    await DatabaseHelper.instance.updateBook({
      ...book,
      'stock': book['stock'] + 1,
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          fine > 0
              ? 'Buku dikembalikan. Denda: Rp$fine'
              : 'Buku dikembalikan tanpa denda',
        ),
      ),
    );

    _loadBorrowedBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengembalian Buku')),
      body: _borrowedBooks.isEmpty
          ? const Center(child: Text('Tidak ada buku dipinjam'))
          : ListView.builder(
        itemCount: _borrowedBooks.length,
        itemBuilder: (context, index) {
          final trx = _borrowedBooks[index];
          final fine = _calculateFine(trx['borrow_date']);

          return Card(
            margin:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              title: Text(trx['title']),
              subtitle: Text('Peminjam: ${trx['name']}'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    fine > 0 ? 'Denda: Rp$fine' : 'Tanpa denda',
                    style: TextStyle(
                      color: fine > 0 ? Colors.red : Colors.green,
                      fontSize: 12,
                    ),
                  ),
                  ElevatedButton(
                    child: const Text('Kembalikan'),
                    onPressed: () => _returnBook(trx),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
