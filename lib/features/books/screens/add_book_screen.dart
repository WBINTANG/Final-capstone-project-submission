import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/database/database_helper.dart';

class AddBookScreen extends StatefulWidget {
  final Map<String, dynamic>? book;

  const AddBookScreen({super.key, this.book});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _isbnController = TextEditingController();
  final _categoryController = TextEditingController();
  final _stockController = TextEditingController();

  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    if (widget.book != null) {
      _titleController.text = widget.book!['title'];
      _authorController.text = widget.book!['author'];
      _isbnController.text = widget.book!['isbn'] ?? '';
      _categoryController.text = widget.book!['category'] ?? '';
      _stockController.text = widget.book!['stock'].toString();

      if (widget.book!['cover_photo'] != null) {
        _image = File(widget.book!['cover_photo']);
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
    await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book == null ? 'Tambah Buku' : 'Edit Buku'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: Column(
                  children: [
                    _image != null
                        ? Image.file(_image!, height: 150)
                        : const Icon(Icons.book, size: 100),
                    TextButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Ambil Cover'),
                      onPressed: _pickImage,
                    ),
                  ],
                ),
              ),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Judul Buku'),
                validator: (value) =>
                value!.isEmpty ? 'Judul wajib diisi' : null,
              ),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(labelText: 'Pengarang'),
                validator: (value) =>
                value!.isEmpty ? 'Pengarang wajib diisi' : null,
              ),
              TextFormField(
                controller: _isbnController,
                decoration: const InputDecoration(labelText: 'ISBN'),
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Kategori'),
              ),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(labelText: 'Stok'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value!.isEmpty ? 'Stok wajib diisi' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final book = {
                      'id': widget.book?['id'],
                      'title': _titleController.text,
                      'author': _authorController.text,
                      'isbn': _isbnController.text,
                      'category': _categoryController.text,
                      'stock': int.parse(_stockController.text),
                      'cover_photo': _image?.path,
                    };

                    if (widget.book == null) {
                      await DatabaseHelper.instance.insertBook(book);
                    } else {
                      await DatabaseHelper.instance.updateBook(book);
                    }

                    Navigator.pop(context);
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
