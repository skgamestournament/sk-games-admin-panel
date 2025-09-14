import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'admin_login_page.dart';
import 'admin_dashboard_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://efzutfrykarzqbfurkhw.supabase.co', // Paste your Project URL here
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVmenV0ZnJ5a2FyenFiZnVya2h3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc4Mzg2ODMsImV4cCI6MjA3MzQxNDY4M30.MERlzLikedbA8OzMalSTbtepW0VsErjDQY3EzQLuyQ0', // Paste your anon public key here
  );

  final prefs = await SharedPreferences.getInstance();
  final isAdminLoggedIn = prefs.getBool('isAdminLoggedIn') ?? false;

  runApp(AdminApp(isAdminLoggedIn: isAdminLoggedIn));
}

final supabase = Supabase.instance.client;

class AdminApp extends StatelessWidget {
  final bool isAdminLoggedIn;
  const AdminApp({super.key, required this.isAdminLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SK Games Admin Panel',
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF4F7FC),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          ),
        ),
      ),
      home: isAdminLoggedIn ? const AdminDashboardPage() : const AdminLoginPage(),
    );
  }
}
