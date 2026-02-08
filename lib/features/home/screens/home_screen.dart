import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:radio_nueva_esperanza/core/constants/app_colors.dart';
import 'package:radio_nueva_esperanza/features/about/screens/about_screen.dart';
import 'package:radio_nueva_esperanza/features/activities/screens/activities_screen.dart';
import 'package:radio_nueva_esperanza/features/announcements/screens/announcements_screen.dart';
import 'package:radio_nueva_esperanza/features/home/providers/radio_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const RadioPlayerView(),
    const AnnouncementsScreen(),
    const ActivitiesScreen(),
    const AboutScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.radio),
            label: 'Radio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign),
            label: 'Anuncios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Actividades',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Nosotros',
          ),
        ],
      ),
    );
  }
}

class RadioPlayerView extends StatelessWidget {
  const RadioPlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark, // Force dark background
      appBar: AppBar(
        title: const Text('Radio Nueva Esperanza',
            style: TextStyle(color: AppColors.textDark)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundDark,
              AppColors.primary.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo / Cover Art
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  // Remove solid white background to blend better if logo has none
                  // or keep it if logo needs it. Let's make it dark teal surface.
                  color: AppColors.surfaceDark,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    width: 250,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 60),

              // Status Indicator
              Consumer<RadioProvider>(
                builder: (context, provider, child) {
                  return Column(
                    children: [
                      Text(
                        provider.isPlaying ? "En Vivo" : "Detenido",
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.secondary, // Gold
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                      ),
                      const SizedBox(height: 30),
                      if (provider.isLoading)
                        const CircularProgressIndicator(
                            color: AppColors.secondary)
                      else
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.secondary.withValues(alpha: 0.4),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: FloatingActionButton.large(
                            onPressed: provider.togglePlay,
                            backgroundColor: AppColors.secondary, // Gold Button
                            elevation: 0,
                            shape: const CircleBorder(),
                            child: Icon(
                              provider.isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 30),

              // Now Playing / Metadata (Placeholder)
              Text(
                "Transmitiendo Bendición",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.textDark, // Cream text
                      fontWeight: FontWeight.w300,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
