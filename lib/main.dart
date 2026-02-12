import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:radio_nueva_esperanza/core/theme/app_theme.dart';
import 'package:radio_nueva_esperanza/features/home/providers/radio_provider.dart';
import 'package:radio_nueva_esperanza/features/home/screens/home_screen.dart';
import 'package:radio_nueva_esperanza/features/home/providers/config_provider.dart';
import 'package:radio_nueva_esperanza/data/services/audio_handler.dart';
import 'package:audio_service/audio_service.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:radio_nueva_esperanza/data/services/session_service.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:radio_nueva_esperanza/admin/main_admin.dart' show AdminApp;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);

  print("--- DEBUG: Starting App ---");

  try {
    print("--- DEBUG: Initializing Firebase... ---");
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 5));
    print("--- DEBUG: Firebase Initialized ---");

    // Initialize Session Heartbeat
    try {
      await SessionService().initialize();
      print("--- DEBUG: SessionService Initialized ---");
    } catch (e) {
      print("--- ERROR: SessionService Initialization Failed: $e ---");
    }
  } catch (e) {
    print("--- ERROR: Firebase Initialization Failed: $e ---");
    // Continue anyway, maybe offline mode or just audio works
  }

  AudioHandler? audioHandler;
  try {
    print("--- DEBUG: Initializing AudioService ---");
    // Initialize Audio Service with timeout
    audioHandler = await initAudioService().timeout(const Duration(seconds: 5));
    print("--- DEBUG: AudioService Initialized Successfully ---");
  } catch (e, stack) {
    print("--- ERROR: Failed to initialize AudioService: $e ---");
    print(stack);
  }

  if (kIsWeb) {
    // On Web, launch the Admin Panel
    print("--- DEBUG: Launching Admin Panel (Web) ---");
    runApp(const AdminApp());
  } else {
    // On Mobile/Desktop, launch the Radio App
    if (audioHandler != null) {
      runApp(MyApp(audioHandler: audioHandler));
    } else {
      runApp(const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              "Error crítico al iniciar servicios.\nRevisa los logs.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red, fontSize: 20),
            ),
          ),
        ),
      ));
    }
  }
}

class MyApp extends StatelessWidget {
  final AudioHandler audioHandler;

  const MyApp({super.key, required this.audioHandler});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RadioProvider(audioHandler)),
        ChangeNotifierProvider(create: (_) => ConfigProvider()..loadConfig()),
      ],
      child: MaterialApp(
        title: 'Radio Nueva Esperanza',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode:
            ThemeMode.light, // Enforce light theme as per new design request
        home: const HomeScreen(),
      ),
    );
  }
}
