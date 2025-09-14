import 'package:flutter/material.dart';
import 'main.dart'; // To access supabase

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _totalUsers = 0;
  int _totalTournaments = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() => _isLoading = true);
    try {
      // CORRECTED CODE: This is the new, correct way to get the count.
      final usersCount = await supabase.from('users').count();
      final tournamentsCount = await supabase.from('tournaments').count();

      if (mounted) {
        setState(() {
          _totalUsers = usersCount;
          _totalTournaments = tournamentsCount;
        });
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
      ? const Center(child: CircularProgressIndicator())
      : RefreshIndicator(
          onRefresh: _fetchStats,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildStatCard('Total Users', _totalUsers.toString(), Icons.people, Colors.blue),
                  _buildStatCard('Total Tournaments', _totalTournaments.toString(), Icons.gamepad, Colors.orange),
                  _buildStatCard('Prize Distributed', '₹0', Icons.emoji_events, Colors.green),
                  _buildStatCard('Total Revenue', '₹0', Icons.trending_up, Colors.red),
                ],
              ),
            ],
          ),
        );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(color: Colors.grey[600])),
                Icon(icon, color: color),
              ],
            ),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
