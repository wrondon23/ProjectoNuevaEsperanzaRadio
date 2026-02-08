import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';
import '../engine/metadata_registry.dart';
import '../engine/crud_table_view.dart';
import '../dashboard/dashboard_screen.dart';

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
      backgroundColor: const Color(0xFFF4F7F6),
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
        color: Colors.white,
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
                  color: const Color(0xFF142F30),
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
                return const Icon(Icons.person, color: Color(0xFF142F30));
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
          color: const Color(0xFF142F30),
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
            color: const Color(0xFFFAAD8E).withOpacity(0.37),
          ),
          gradient: const LinearGradient(
            colors: [Color(0xFF1E3A3B), Color(0xFF142F30)],
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
          color: Color(0xFFFAAD8E),
          size: 20,
        ),
      ),
      extendedTheme: const SidebarXTheme(
        width: 250,
        decoration: BoxDecoration(
          color: Color(0xFF142F30),
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
          // Use USE_EMULATOR from main_admin if reachable, or just pass false for now to test compilation
          // Better: We can check if we are in debug mode or use the const if we move it to a shared file.
          // For now, let's assume we can import it or just use kDebugMode/kProfileMode if we wanted.
          // Since I can't easily import main_admin.dart due to circular deps if main imports shell,
          // I'll assume standard Flutter behavior.
          // Let's import the dashboard screen first.
          return const DashboardScreen(
              isEmulator: bool.fromEnvironment('USE_EMULATOR'));
        }

        // Calculate module index (subtract 1 for Dashboard item)
        final moduleIndex = controller.selectedIndex - 1;

        if (moduleIndex >= 0 && moduleIndex < modules.length) {
          final module = modules[moduleIndex];
          // Return the CRUD View for this module
          return CrudTableView(module: module);
        }

        return const Center(child: Text('Configuración / Otro'));
      },
    );
  }
}
