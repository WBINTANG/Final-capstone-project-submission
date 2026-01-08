import 'package:flutter/material.dart';

// MODULE 1
import 'features/books/screens/book_list_screen.dart';

// MODULE 2
import 'features/borrowing/screens/member_list_screen.dart';

// MODULE 3
import 'features/statistics/screens/statistics_screen.dart';

void main() {
  runApp(const PerpusKuApp());
}

class PerpusKuApp extends StatelessWidget {
  const PerpusKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PerpusKu',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: false, // supaya BottomNavigation stabil
      ),
      home: const MainScreen(),
    );
  }
}

/// ===============================
/// MAIN SCREEN (Bottom Navigation)
/// ===============================
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    BookListScreen(),       // Modul 1 - Book Catalog
    MemberListScreen(),     // Modul 2 - Borrowing System
    StatisticsScreen(),     // Modul 3 - Statistics
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Books',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Borrowing',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statistics',
          ),
        ],
      ),
    );
  }
}
