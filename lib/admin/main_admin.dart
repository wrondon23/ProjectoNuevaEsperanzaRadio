import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:google_fonts/google_fonts.dart';
import 'layout/admin_shell.dart';
import 'auth/login_screen.dart';
import '../firebase_options.dart';

const bool USE_EMULATOR =
    bool.fromEnvironment('USE_EMULATOR', defaultValue: false);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (USE_EMULATOR) {
    try {
      await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
      FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
      print('--- MODO EMULADOR ACTIVADO ---');
    } catch (e) {
      print('Error configurando emuladores: $e');
    }
  }

  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Radio Nueva Esperanza - Admin',
      debugShowCheckedModeBanner: false,
      theme: _buildAdminTheme(),
      // AuthGuard handles the redirection between Login and Dashboard
      home: const AuthGuard(),
    );
  }

  ThemeData _buildAdminTheme() {
    return ThemeData.light().copyWith(
      scaffoldBackgroundColor:
          const Color(0xFFF4F7F6), // Light Grey (AdminDek style)
      primaryColor: const Color(0xFF142F30), // Dark Green
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF142F30),
        secondary: Color(0xFFFAAD8E), // Salmon
        tertiary: Color(0xFF4DB6AC), // Teal
      ),
      textTheme: GoogleFonts.poppinsTextTheme(),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        color: Colors.white,
      ),
    );
  }
}

class AuthGuard extends StatelessWidget {
  const AuthGuard({super.key});

  @override
  Widget build(BuildContext context) {
    // If Firebase is not initialized, we might get an error here.
    // In a real scenario, we'd handle that.
    // For this delivery, we assume the user will configure Firebase.
    try {
      return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }

          if (snapshot.hasData) {
            return const AdminShell();
          }

          return const LoginScreen();
        },
      );
    } catch (e) {
      // Fallback if Firebase is not initialized (for UI preview)
      return const LoginScreen();
    }
  }
}
