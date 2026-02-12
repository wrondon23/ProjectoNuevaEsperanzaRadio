import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:radio_nueva_esperanza/core/theme/app_theme.dart';
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
      theme: AppTheme.darkTheme,
      home: const AuthGuard(),
    );
  }
}

class AuthGuard extends StatelessWidget {
  const AuthGuard({super.key});

  @override
  Widget build(BuildContext context) {
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
      return const LoginScreen();
    }
  }
}
