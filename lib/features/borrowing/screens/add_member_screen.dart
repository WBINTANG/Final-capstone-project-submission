import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/database/database_helper.dart';

class AddMemberScreen extends StatefulWidget {
  const AddMemberScreen({super.key});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _memberIdController = TextEditingController();
  final _phoneController = TextEditingController();

  File? _photo;
  final _picker = ImagePicker();

  Future<void> _pickPhoto() async {
    final picked =
    await _picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() => _photo = File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Member')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: Column(
                  children: [
                    _photo != null
                        ? CircleAvatar(
                      radius: 50,
                      backgroundImage: FileImage(_photo!),
                    )
                        : const CircleAvatar(
                      radius: 50,
                      child: Icon(Icons.person),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.camera),
                      label: const Text('Ambil Foto'),
                      onPressed: _pickPhoto,
                    )
                  ],
                ),
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama'),
                validator: (v) =>
                v!.isEmpty ? 'Nama wajib diisi' : null,
              ),
              TextFormField(
                controller: _memberIdController,
                decoration:
                const InputDecoration(labelText: 'Member ID'),
                validator: (v) =>
                v!.isEmpty ? 'ID wajib diisi' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration:
                const InputDecoration(labelText: 'No. HP'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Simpan'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await DatabaseHelper.instance.insertMember({
                      'name': _nameController.text,
                      'member_id': _memberIdController.text,
                      'phone': _phoneController.text,
                      'photo': _photo?.path,
                    });
                    Navigator.pop(context);
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
