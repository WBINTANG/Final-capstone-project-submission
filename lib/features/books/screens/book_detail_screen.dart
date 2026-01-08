import 'dart:io';
import 'package:flutter/material.dart';

class BookDetailScreen extends StatelessWidget {
  final Map<String, dynamic> book;

  const BookDetailScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Buku')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (book['cover_photo'] != null)
              Center(
                child: Image.file(
                  File(book['cover_photo']),
                  height: 200,
                ),
              ),
            const SizedBox(height: 16),
            Text('Judul: ${book['title']}',
                style: const TextStyle(fontSize: 16)),
            Text('Pengarang: ${book['author']}'),
            Text('ISBN: ${book['isbn']}'),
            Text('Kategori: ${book['category']}'),
            Text('Stok: ${book['stock']}'),
          ],
        ),
      ),
    );
  }
}
