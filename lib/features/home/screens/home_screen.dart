import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:radio_nueva_esperanza/core/constants/app_colors.dart';
import 'package:radio_nueva_esperanza/features/about/screens/about_screen.dart';
import 'package:radio_nueva_esperanza/features/activities/screens/activities_screen.dart';
import 'package:radio_nueva_esperanza/features/announcements/screens/announcements_screen.dart';
import 'package:radio_nueva_esperanza/features/podcasts/screens/podcasts_screen.dart';
import 'package:radio_nueva_esperanza/features/prayer/screens/prayer_request_screen.dart';
import 'package:radio_nueva_esperanza/features/bible/screens/daily_verse_screen.dart';
import 'package:radio_nueva_esperanza/features/home/widgets/radio_player_view.dart';
import 'package:radio_nueva_esperanza/features/home/providers/config_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _navigateToDrawerItem(
      BuildContext context, String title, Widget widget) {
    // If opening from Drawer, pop the drawer first
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(title),
            centerTitle: true,
          ),
          body: widget,
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint("Could not launch $url");
    }
  }

  // Custom navigation handler for RadioPlayerView quick actions
  void _handlePlayerNavigation(int actionIndex) {
    if (!mounted) return;

    // 4: Podcasts -> Navigate to Podcasts Screen directly
    if (actionIndex == 4) {
      final config = Provider.of<ConfigProvider>(context, listen: false).config;
      if (config?.activeSections['podcasts'] == true) {
        _navigateToDrawerItem(context, 'Sermones', const PodcastsScreen());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Esta sección no está activa currently.")),
        );
      }
      return;
    }

    // Calculate target index based on config
    final config = Provider.of<ConfigProvider>(context, listen: false).config;
    if (config == null) return;

    int targetIndex = -1;
    int currentNavIndex = 0; // Radio starts at 0

    // Check sections in the exact order they are added to bottomNavScreens

    // 1. Anuncios
    if (config.activeSections['announcements'] == true) {
      currentNavIndex++;
      if (actionIndex == 1) targetIndex = currentNavIndex;
    }

    // 2. Actividades
    if (config.activeSections['activities'] == true) {
      currentNavIndex++;
      if (actionIndex == 2) targetIndex = currentNavIndex;
    }

    // 3. Oración
    if (config.activeSections['prayer_requests'] == true) {
      currentNavIndex++;
      if (actionIndex == 3) targetIndex = currentNavIndex;
    }

    // 5. Palabra (Daily Verse)
    if (config.activeSections['daily_verse'] == true) {
      currentNavIndex++;
      if (actionIndex == 5) targetIndex = currentNavIndex;
    }

    if (targetIndex != -1 && targetIndex != _currentIndex) {
      setState(() => _currentIndex = targetIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final configProvider = Provider.of<ConfigProvider>(context);
    final config = configProvider.config;

    if (configProvider.isLoading) {
      return const Scaffold(
        body: Center(
            child: CircularProgressIndicator(color: AppColors.secondary)),
      );
    }

    // 1. Bottom Navigation Items (Main Sections)
    final bottomNavScreens = <Map<String, dynamic>>[
      {
        'title': config?.stationName.isNotEmpty == true
            ? config!.stationName
            : 'Radio Nueva Esperanza',
        'widget': RadioPlayerView(onNavigate: _handlePlayerNavigation),
        'icon': Icons.radio,
        'label': 'Radio',
      }
    ];

    if (config?.activeSections['announcements'] == true) {
      bottomNavScreens.add({
        'title': 'Anuncios',
        'widget': const AnnouncementsScreen(),
        'icon': Icons.campaign,
        'label': 'Anuncios',
      });
    }

    if (config?.activeSections['activities'] == true) {
      bottomNavScreens.add({
        'title': 'Actividades',
        'widget': const ActivitiesScreen(),
        'icon': Icons.calendar_month,
        'label': 'Actividades',
      });
    }

    if (config?.activeSections['prayer_requests'] == true) {
      bottomNavScreens.add({
        'title': 'Oración',
        'widget': const PrayerRequestScreen(),
        'icon': Icons.volunteer_activism,
        'label': 'Oración',
      });
    }

    if (config?.activeSections['daily_verse'] == true) {
      bottomNavScreens.add({
        'title': 'Palabra',
        'widget': const DailyVerseScreen(),
        'icon': Icons.auto_stories,
        'label': 'Palabra',
      });
    }

    // 2. Drawer Items (Secondary Sections)
    final drawerScreens = <Map<String, dynamic>>[];

    if (config?.activeSections['podcasts'] == true) {
      drawerScreens.add({
        'title': 'Sermones',
        'widget': const PodcastsScreen(),
        'icon': Icons.podcasts,
        'label': 'Sermones',
      });
    }

    if (config?.activeSections['about'] == true) {
      drawerScreens.add({
        'title': 'Quiénes Somos',
        'widget': const AboutScreen(),
        'icon': Icons.info,
        'label': 'Nosotros',
      });
    }

    // Safety check
    if (_currentIndex >= bottomNavScreens.length) {
      _currentIndex = 0;
    }

    final currentScreen = bottomNavScreens[_currentIndex];
    final isRadioTab = _currentIndex == 0;

    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: isRadioTab, // Extend for full screen radio
      appBar: isRadioTab
          ? null
          : AppBar(
              title: Text(currentScreen['title'] as String),
              centerTitle: true,
            ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: AppColors.drawerBackground,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.radio,
                    size: 60,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    config?.stationName.isNotEmpty == true
                        ? config!.stationName
                        : 'Radio Nueva Esperanza',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '© 2024 Iglesia Adventista Nueva Esperanza',
                    style: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Drawer items behave as buttons to push new screens
            ...drawerScreens.map((screen) {
              return ListTile(
                leading: Icon(screen['icon'] as IconData, color: Colors.grey),
                title: Text(
                  screen['label'] as String,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                onTap: () => _navigateToDrawerItem(
                  context,
                  screen['title'] as String,
                  screen['widget'] as Widget,
                ),
              );
            }),
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Síguenos",
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.facebook, color: Colors.blue),
                  onPressed: () =>
                      _launchUrl('https://facebook.com/IglesiaAdventista'),
                ),
                IconButton(
                  icon: const Icon(Icons.video_library, color: Colors.red),
                  onPressed: () =>
                      _launchUrl('https://youtube.com/IglesiaAdventista'),
                ),
                IconButton(
                  icon: const Icon(Icons.public, color: Colors.green),
                  onPressed: () =>
                      _launchUrl('https://radionuevaesperanza.com'),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      body: currentScreen['widget'] as Widget,
      bottomNavigationBar: isRadioTab
          ? null
          : BottomNavigationBar(
              type: BottomNavigationBarType.fixed, // Ensure buttons don't shift
              currentIndex: _currentIndex,
              onTap: _onBottomNavTapped,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: Colors.grey,
              items: bottomNavScreens.map((screen) {
                return BottomNavigationBarItem(
                  icon: Icon(screen['icon'] as IconData),
                  label: screen['label'] as String,
                );
              }).toList(),
            ),
    );
  }
}
