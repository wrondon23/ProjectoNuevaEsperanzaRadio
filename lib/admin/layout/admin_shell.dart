import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';
import '../engine/metadata_registry.dart';
import '../engine/crud_table_view.dart';
import '../dashboard/dashboard_screen.dart';
import '../dashboard/config_screen.dart';
import '../banners/banners_screen.dart';
import 'package:radio_nueva_esperanza/core/constants/app_colors.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  final _controller = SidebarXController(selectedIndex: 0, extended: true);
  final _key = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Initialize modules
    MetadataRegistry().initializeDefaults();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      backgroundColor: AppColors.background, // Dark Background
      drawer: AdminSidebar(controller: _controller), // Mobile drawer
      body: Row(
        children: [
          // Sidebar for Desktop
          if (MediaQuery.of(context).size.width > 600)
            AdminSidebar(controller: _controller),

          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: _Screens(controller: _controller),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: AppColors.drawerBackground, // Dark TopBar
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          if (MediaQuery.of(context).size.width <= 600)
            IconButton(
              onPressed: () => _key.currentState?.openDrawer(),
              icon: const Icon(Icons.menu),
            ),
          const SizedBox(width: 10),
          Text(
            "Panel de Control",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // White Text
                ),
          ),
          const Spacer(),
          CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 20,
            child: ClipOval(
                child: Image.asset(
              'assets/icon/app_icon.png',
              fit: BoxFit.cover,
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.person, color: Colors.white);
              },
            )),
          ),
        ],
      ),
    );
  }
}

class AdminSidebar extends StatelessWidget {
  final SidebarXController controller;
  const AdminSidebar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // Get modules from registry
    final modules = MetadataRegistry().modules;

    return SidebarX(
      controller: controller,
      theme: SidebarXTheme(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.drawerBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        textStyle: const TextStyle(color: Colors.white70),
        selectedTextStyle: const TextStyle(color: Colors.white),
        itemTextPadding: const EdgeInsets.only(left: 30),
        selectedItemTextPadding: const EdgeInsets.only(left: 30),
        itemDecoration: BoxDecoration(
          border: Border.all(color: Colors.transparent),
        ),
        selectedItemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.37),
          ),
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.1),
              AppColors.primary.withValues(alpha: 0.2)
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 30,
            )
          ],
        ),
        iconTheme: const IconThemeData(
          color: Colors.white70,
          size: 20,
        ),
        selectedIconTheme: const IconThemeData(
          color: AppColors.primary,
          size: 20,
        ),
      ),
      extendedTheme: const SidebarXTheme(
        width: 250,
        decoration: BoxDecoration(
          color: AppColors.drawerBackground,
        ),
      ),
      headerBuilder: (context, extended) {
        return SizedBox(
          height: 100,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: extended
                ? const Text(
                    "ADMIN NE",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : const Icon(Icons.radio, color: Colors.white, size: 30),
          ),
        );
      },
      items: [
        const SidebarXItem(icon: Icons.dashboard, label: 'Dashboard'),
        const SidebarXItem(
            icon: Icons.view_carousel, label: 'Banners'), // New Item
        // Dynamically map modules to sidebar items
        ...modules.map((m) => SidebarXItem(icon: m.icon, label: m.title)),
        const SidebarXItem(icon: Icons.settings, label: 'Configuración'),
      ],
    );
  }
}

class _Screens extends StatelessWidget {
  final SidebarXController controller;
  const _Screens({required this.controller});

  @override
  Widget build(BuildContext context) {
    final modules = MetadataRegistry().modules;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        if (controller.selectedIndex == 0) {
          // Dashboard
          return const DashboardScreen(
              isEmulator: bool.fromEnvironment('USE_EMULATOR'));
        }

        if (controller.selectedIndex == 1) {
          // Banners Screen
          return const BannersScreen();
        }

        // Calculate module index (subtract 2 for Dashboard and Banners)
        final moduleIndex = controller.selectedIndex - 2;

        if (moduleIndex >= 0 && moduleIndex < modules.length) {
          final module = modules[moduleIndex];
          // Return the CRUD View for this module
          return CrudTableView(module: module);
        }

        return const ConfigScreen();
      },
    );
  }
}
