import 'package:flutter/material.dart';
import '../../../core/database/database_helper.dart';

class BorrowBookScreen extends StatefulWidget {
  const BorrowBookScreen({super.key});

  @override
  State<BorrowBookScreen> createState() => _BorrowBookScreenState();
}

class _BorrowBookScreenState extends State<BorrowBookScreen> {
  int? _selectedMemberId;
  int? _selectedBookId;

  List<Map<String, dynamic>> _members = [];
  List<Map<String, dynamic>> _books = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final members = await DatabaseHelper.instance.getMembers();
    final books = await DatabaseHelper.instance.getBooks();

    setState(() {
      _members = members;
      _books = books.where((b) => b['stock'] > 0).toList();
    });
  }

  Future<void> _borrowBook() async {
    if (_selectedMemberId == null || _selectedBookId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih member dan buku')),
      );
      return;
    }

    final borrowDate = DateTime.now().toIso8601String();

    await DatabaseHelper.instance.borrowBook({
      'member_id': _selectedMemberId,
      'book_id': _selectedBookId,
      'borrow_date': borrowDate,
      'return_date': null,
      'fine': 0,
      'status': 'borrowed',
    });

    final book =
    _books.firstWhere((b) => b['id'] == _selectedBookId);

    await DatabaseHelper.instance.updateBook({
      ...book,
      'stock': book['stock'] - 1,
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Buku berhasil dipinjam')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pinjam Buku')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // DROPDOWN MEMBER
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Pilih Member'),
              value: _selectedMemberId,
              items: _members
                  .map<DropdownMenuItem<int>>(
                    (m) => DropdownMenuItem<int>(
                  value: m['id'] as int,
                  child: Text(m['name']),
                ),
              )
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedMemberId = value);
              },
            ),

            const SizedBox(height: 16),

            // DROPDOWN BUKU
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Pilih Buku'),
              value: _selectedBookId,
              items: _books
                  .map<DropdownMenuItem<int>>(
                    (b) => DropdownMenuItem<int>(
                  value: b['id'] as int,
                  child: Text(
                    '${b['title']} (stok ${b['stock']})',
                  ),
                ),
              )
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedBookId = value);
              },
            ),

            const SizedBox(height: 30),

            ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('Pinjam'),
              onPressed: _borrowBook,
            ),
          ],
        ),
      ),
    );
  }
}
