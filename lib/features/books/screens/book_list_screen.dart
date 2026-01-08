import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/database/database_helper.dart';
import 'add_book_screen.dart';
import 'book_detail_screen.dart';

// MODULE 2 – BORROWING SYSTEM
import '../../borrowing/screens/member_list_screen.dart';
import '../../borrowing/screens/borrow_book_screen.dart';
import '../../borrowing/screens/return_book_screen.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  List<Map<String, dynamic>> _books = [];
  List<Map<String, dynamic>> _filteredBooks = [];

  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    final data = await DatabaseHelper.instance.getBooks();
    setState(() {
      _books = data;
      _filteredBooks = data;
    });
  }

  void _searchBook(String query) {
    final result = _books.where((book) {
      final title = book['title'].toString().toLowerCase();
      final author = book['author'].toString().toLowerCase();
      return title.contains(query.toLowerCase()) ||
          author.contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredBooks = result;
    });
  }

  List<String> get categories {
    final cats = _books.map((b) => b['category'] ?? '').toSet().toList();
    cats.removeWhere((e) => e.isEmpty);
    return ['Semua', ...cats];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Cari buku...',
            border: InputBorder.none,
          ),
          onChanged: _searchBook,
        ),
        actions: [
          // MEMBER
          IconButton(
            icon: const Icon(Icons.people),
            tooltip: 'Member',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MemberListScreen(),
                ),
              );
            },
          ),

          // PINJAM BUKU
          IconButton(
            icon: const Icon(Icons.assignment),
            tooltip: 'Pinjam Buku',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BorrowBookScreen(),
                ),
              );
            },
          ),

          // RETURN BUKU
          IconButton(
            icon: const Icon(Icons.assignment_return),
            tooltip: 'Pengembalian Buku',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ReturnBookScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // FILTER KATEGORI
          Padding(
            padding: const EdgeInsets.all(8),
            child: DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              items: categories
                  .map(
                    (c) => DropdownMenuItem<String>(
                  value: c,
                  child: Text(c),
                ),
              )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                  if (value == 'Semua') {
                    _filteredBooks = _books;
                  } else {
                    _filteredBooks =
                        _books.where((b) => b['category'] == value).toList();
                  }
                });
              },
            ),
          ),

          // LIST BUKU
          Expanded(
            child: _filteredBooks.isEmpty
                ? const Center(
              child: Text(
                'Belum ada buku 📚',
                style: TextStyle(fontSize: 16),
              ),
            )
                : ListView.builder(
              itemCount: _filteredBooks.length,
              itemBuilder: (context, index) {
                final book = _filteredBooks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: book['cover_photo'] != null
                        ? Image.file(
                      File(book['cover_photo']),
                      width: 50,
                      fit: BoxFit.cover,
                    )
                        : const Icon(Icons.book),

                    title: Text(book['title']),
                    subtitle: Text(book['author']),

                    // 👉 NAVIGASI KE DETAIL BUKU
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              BookDetailScreen(book: book),
                        ),
                      );
                    },

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit,
                              color: Colors.blue),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AddBookScreen(book: book),
                              ),
                            );
                            _loadBooks();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.red),
                          onPressed: () async {
                            await DatabaseHelper.instance
                                .deleteBook(book['id']);
                            _loadBooks();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddBookScreen(),
            ),
          );
          _loadBooks();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
