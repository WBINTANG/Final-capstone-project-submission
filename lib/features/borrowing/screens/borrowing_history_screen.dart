// lib/features/borrowing/screens/borrowing_history_screen.dart
import 'package:flutter/material.dart';
import '../../../core/database/database_helper.dart';

class BorrowingHistoryScreen extends StatefulWidget {
  final int memberId;
  final String memberName;

  const BorrowingHistoryScreen({
    super.key,
    required this.memberId,
    required this.memberName,
  });

  @override
  State<BorrowingHistoryScreen> createState() => _BorrowingHistoryScreenState();
}

class _BorrowingHistoryScreenState extends State<BorrowingHistoryScreen> {
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final data = await DatabaseHelper.instance
        .getTransactionsByMember(widget.memberId);
    setState(() {
      _transactions = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Peminjaman - ${widget.memberName}'),
      ),
      body: _transactions.isEmpty
          ? const Center(child: Text('Belum ada transaksi.'))
          : ListView.builder(
        itemCount: _transactions.length,
        itemBuilder: (context, index) {
          final tx = _transactions[index];
          final status = tx['status'] == 'returned'
              ? 'Dikembalikan'
              : 'Dipinjam';
          final statusColor = tx['status'] == 'returned'
              ? Colors.green
              : Colors.red;

          return Card(
            margin:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(tx['title']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pinjam: ${tx['borrow_date']}'),
                  Text('Kembali: ${tx['return_date'] ?? "-"}'),
                  if (tx['fine'] != null && tx['fine'] > 0)
                    Text('Denda: Rp${tx['fine']}',
                        style: const TextStyle(color: Colors.orange)),
                ],
              ),
              trailing: Text(
                status,
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: statusColor),
              ),
            ),
          );
        },
      ),
    );
  }
}
