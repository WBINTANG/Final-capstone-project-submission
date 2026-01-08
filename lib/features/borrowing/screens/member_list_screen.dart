import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/database/database_helper.dart';
import 'add_member_screen.dart';
import 'borrowing_history_screen.dart';

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  List<Map<String, dynamic>> _members = [];

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    final data = await DatabaseHelper.instance.getMembers();
    setState(() => _members = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Members')),
      body: _members.isEmpty
          ? const Center(child: Text('Belum ada member'))
          : ListView.builder(
        itemCount: _members.length,
        itemBuilder: (context, index) {
          final member = _members[index];
          return ListTile(
            leading: member['photo'] != null
                ? CircleAvatar(
              backgroundImage: FileImage(File(member['photo'])),
            )
                : const CircleAvatar(child: Icon(Icons.person)),
            title: Text(member['name']),
            subtitle: Text(member['member_id']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tombol riwayat peminjaman
                IconButton(
                  icon: const Icon(Icons.history, color: Colors.blue),
                  tooltip: 'Riwayat Peminjaman',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BorrowingHistoryScreen(
                          memberId: member['id'],
                          memberName: member['name'],
                        ),
                      ),
                    );
                  },
                ),
                // Tombol delete
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await DatabaseHelper.instance
                        .deleteMember(member['id']);
                    _loadMembers();
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddMemberScreen(),
            ),
          );
          _loadMembers();
        },
      ),
    );
  }
}
