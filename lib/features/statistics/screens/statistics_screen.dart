import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/database/database_helper.dart';
import 'dart:math';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  List<Map<String, dynamic>> _books = [];
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final books = await DatabaseHelper.instance.getBooks();
    final transactions = await DatabaseHelper.instance.getBorrowingHistory();
    setState(() {
      _books = books;
      _transactions = transactions;
    });
  }

  // =================== Popular Books ===================
  List<BarChartGroupData> _getPopularBooksData() {
    // Hitung frekuensi peminjaman tiap buku
    final Map<String, int> borrowCount = {};
    for (var t in _transactions) {
      final title = t['title'];
      borrowCount[title] = (borrowCount[title] ?? 0) + 1;
    }

    final topBooks = borrowCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top5 = topBooks.take(5).toList();

    return List.generate(top5.length, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: top5[i].value.toDouble(),
            color: Colors.blue,
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
        showingTooltipIndicators: [0],
      );
    });
  }

  List<String> _getTopBookTitles() {
    final Map<String, int> borrowCount = {};
    for (var t in _transactions) {
      final title = t['title'];
      borrowCount[title] = (borrowCount[title] ?? 0) + 1;
    }
    final topBooks = borrowCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top5 = topBooks.take(5).toList();
    return top5.map((e) => e.key).toList();
  }

  // =================== Monthly Borrow Summary ===================
  List<FlSpot> _getMonthlyBorrowData() {
    final Map<int, int> monthly = {};
    for (var t in _transactions) {
      final date = DateTime.parse(t['borrow_date']);
      monthly[date.month] = (monthly[date.month] ?? 0) + 1;
    }
    return List.generate(12, (i) {
      final month = i + 1;
      return FlSpot(month.toDouble(), (monthly[month] ?? 0).toDouble());
    });
  }

  // =================== Overdue Books ===================
  List<Map<String, dynamic>> _getOverdueBooks() {
    final today = DateTime.now();
    return _transactions.where((t) {
      final returnDate = t['return_date'];
      final status = t['status'];
      if (returnDate == null || status != 'returned') {
        final borrowDate = DateTime.parse(t['borrow_date']);
        return today.difference(borrowDate).inDays > 14; // 2 minggu
      }
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final topTitles = _getTopBookTitles();
    final overdueBooks = _getOverdueBooks();

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📊 Popular Books', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _transactions.length.toDouble() + 1,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < topTitles.length) {
                            return Text(topTitles[index], textAlign: TextAlign.center, style: const TextStyle(fontSize: 10));
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _getPopularBooksData(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('📈 Monthly Borrow Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}', style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _getMonthlyBorrowData(),
                      isCurved: true,
                      barWidth: 3,
                      color: Colors.green,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('📌 Overdue Books', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            overdueBooks.isEmpty
                ? const Text('Tidak ada buku yang telat dikembalikan')
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: overdueBooks.length,
              itemBuilder: (context, index) {
                final t = overdueBooks[index];
                return ListTile(
                  leading: const Icon(Icons.warning, color: Colors.red),
                  title: Text('${t['title']}'),
                  subtitle: Text('Dipinjam oleh: ${t['name']}'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
