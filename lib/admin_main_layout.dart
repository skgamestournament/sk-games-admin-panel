import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'admin_dashboard_page.dart';
import 'admin_login_page.dart';
import 'admin_tournaments_page.dart';
import 'admin_users_page.dart';

class AdminMainLayout extends StatefulWidget {
  const AdminMainLayout({super.key});

  @override
  State<AdminMainLayout> createState() => _AdminMainLayoutState();
}

class _AdminMainLayoutState extends State<AdminMainLayout> {
  Widget _currentPage = const AdminDashboardPage();
  String _currentPageTitle = 'Dashboard';

  void _navigateTo(Widget page, String title) {
    Navigator.of(context).pop(); // Close the drawer
    setState(() {
      _currentPage = page;
      _currentPageTitle = title;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAdminLoggedIn', false);
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AdminLoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentPageTitle),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.indigo),
              child: Text('SK Games Admin', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () => _navigateTo(const AdminDashboardPage(), 'Dashboard'),
            ),
            ListTile(
              leading: const Icon(Icons.gamepad),
              title: const Text('Tournaments'),
              onTap: () => _navigateTo(const AdminTournamentsPage(), 'Tournaments'),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Users'),
              onTap: () => _navigateTo(const AdminUsersPage(), 'Users'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: _currentPage,
    );
  }
}
