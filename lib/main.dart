import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// We will create this login page in the next step.
// import 'admin_login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with the SAME credentials as the player app
  await Supabase.initialize(
    url: 'https://efzutfrykarzqbfurkhw.supabase.co', // Paste your Project URL here
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVmenV0ZnJ5a2FyenFiZnVya2h3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc4Mzg2ODMsImV4cCI6MjA3MzQxNDY4M30.MERlzLikedbA8OzMalSTbtepW0VsErjDQY3EzQLuyQ0', // Paste your anon public key here
  );

  runApp(const AdminApp());
}

final supabase = Supabase.instance.client;

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

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
      // For now, a placeholder. We will change this to AdminLoginPage next.
      home: const Scaffold(
        body: Center(
          child: Text('Admin Panel Initialized!'),
        ),
      ),
    );
  }
}
