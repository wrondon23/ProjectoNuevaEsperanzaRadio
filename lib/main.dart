import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:radio_nueva_esperanza/core/theme/app_theme.dart';
import 'package:radio_nueva_esperanza/features/home/providers/radio_provider.dart';
import 'package:radio_nueva_esperanza/features/home/screens/home_screen.dart';
import 'package:radio_nueva_esperanza/data/services/audio_handler.dart';
import 'package:audio_service/audio_service.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:radio_nueva_esperanza/data/services/session_service.dart';

import 'package:intl/date_symbol_data_local.dart';

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

  if (audioHandler != null) {
    runApp(MyApp(audioHandler: audioHandler));
  } else {
    // If audio handler failed, we still want to show the app, maybe with a dummy handler or error state
    // For now, let's try to run MyApp with a dummy/null handler if possible, or show explicit error.
    // Given the architecture requires it, let's just show the error screen but allowing entry is better.
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

class MyApp extends StatelessWidget {
  final AudioHandler audioHandler;

  const MyApp({super.key, required this.audioHandler});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RadioProvider(audioHandler)),
      ],
      child: MaterialApp(
        title: 'Radio Nueva Esperanza',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
