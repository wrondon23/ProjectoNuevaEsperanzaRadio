import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:radio_nueva_esperanza/core/constants/app_colors.dart';
import 'package:radio_nueva_esperanza/features/home/providers/radio_provider.dart';
import 'package:radio_nueva_esperanza/features/home/providers/config_provider.dart';
import 'package:radio_nueva_esperanza/features/home/widgets/banner_carousel.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui'; // Keep for future blur effects if needed

class RadioPlayerView extends StatelessWidget {
  final Function(int index)? onNavigate;

  const RadioPlayerView({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double carouselSize =
        size.width * 0.65; // Slightly smaller for balance

    return Stack(
      children: [
        // 1. Background Layer (Blurred Image)
        Positioned.fill(
          child: Image.network(
            'https://lh3.googleusercontent.com/aida-public/AB6AXuC-FUr20MnRGL9RkM3oydrpKc4HVSrIaqQkls2g4jfUr3shMftSEM5beSWJ3N_abBJjOiB-JgQWhv9xYov1IOBZmVU1IEHJf0W-HZQK8rZ2wWTSH2MBxosceyiLWl6auaQZngmy5L0ZcaIlUCHkuXpFmzVyHewePfCDMYKb4-hkFrne5Ickd8HRmNEnG-YTm1_tOhzcua4BOHaVglmvZeJOvXNoW7i4tAAS4VDQ24wRA4zxLPQRjKB14FPALk5R8v_T8Zoa8vQ5kpya',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: AppColors.background,
            ),
          ),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color:
                  AppColors.background.withValues(alpha: 0.6), // Dark overlay
            ),
          ),
        ),

        // Gradient Fade from Bottom
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.background.withValues(alpha: 0.8),
                  AppColors.background,
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),
        ),

        // 2. Main Content
        SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu_rounded, color: Colors.white),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                    Column(
                      children: [
                        Text(
                          "ESTÁS ESCUCHANDO",
                          style: TextStyle(
                            color: AppColors.primary.withValues(alpha: 0.8),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Radio Nueva Esperanza",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.share_rounded, color: Colors.white),
                      onPressed: () {
                        Share.share(
                            'Escucha Radio Nueva Esperanza: https://radionuevaesperanza.com');
                      },
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Live Indicator
              Consumer<RadioProvider>(builder: (context, provider, _) {
                if (!provider.isPlaying) return const SizedBox.shrink();
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "EN VIVO",
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // Circular Artwork
              Container(
                width: carouselSize,
                height: carouselSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1), width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const ClipOval(
                  child: BannerCarousel(),
                ),
              ),

              const SizedBox(height: 40),

              // Metadata
              Consumer<RadioProvider>(
                builder: (context, provider, _) {
                  return Column(
                    children: [
                      Text(
                        provider.currentMediaItem?.title ??
                            "Radio Nueva Esperanza",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        provider.currentMediaItem?.artist ??
                            "Transmitiendo esperanza y vida",
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 30),

              // Progress Bar (Visual)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("STREAMING",
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                        Text("HD AUDIO",
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 65,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(3),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.5),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Spacer(flex: 35),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.skip_previous_rounded,
                          color: Colors.white.withValues(alpha: 0.6), size: 32),
                      onPressed: () {},
                    ),
                    Consumer<RadioProvider>(
                      builder: (context, provider, _) {
                        return Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.4),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: provider.togglePlay,
                            icon: Icon(
                              provider.isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.skip_next_rounded,
                          color: Colors.white.withValues(alpha: 0.6), size: 32),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Volume Slider (Visual)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  children: [
                    Icon(Icons.volume_mute_rounded,
                        color: Colors.white.withValues(alpha: 0.4), size: 20),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            Container(
                              width: 150, // Approx 75%
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            Positioned(
                              left: 145,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black26, blurRadius: 4)
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.volume_up_rounded,
                        color: Colors.white.withValues(alpha: 0.4), size: 20),
                  ],
                ),
              ),

              const Spacer(),

              // Bottom Quick Actions
              Padding(
                padding: const EdgeInsets.only(bottom: 30, left: 24, right: 24),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Consumer<ConfigProvider>(
                    builder: (context, configProvider, _) {
                      final config = configProvider.config;
                      final activeSections = config?.activeSections ?? {};

                      List<Widget> actions = [];

                      // Defined Sections as per App logic

                      // 1. Oración (Priority in Image)
                      if (activeSections['prayer_requests'] == true) {
                        actions.add(_QuickAction(
                          icon: Icons.volunteer_activism_rounded,
                          label: "Oración",
                          isSelected: false,
                          onTap: () => onNavigate?.call(3), // ID 3 for Oración
                        ));
                      }

                      // 2. Actividades / Horarios
                      if (activeSections['activities'] == true) {
                        actions.add(_QuickAction(
                          icon: Icons.calendar_month_rounded,
                          label: "Actividades",
                          isSelected: false,
                          onTap: () =>
                              onNavigate?.call(2), // ID 2 for Actividades
                        ));
                      }

                      // 3. Anuncios (If active)
                      if (activeSections['announcements'] == true) {
                        actions.add(_QuickAction(
                          icon: Icons.campaign_rounded,
                          label: "Anuncios",
                          isSelected: false,
                          onTap: () => onNavigate?.call(1), // ID 1 for Anuncios
                        ));
                      }

                      // 4. Podcasts / Sermones
                      if (activeSections['podcasts'] == true) {
                        actions.add(_QuickAction(
                          icon: Icons.podcasts_rounded,
                          label: "Sermones",
                          isSelected: false,
                          onTap: () => onNavigate?.call(4), // ID 4 for Podcasts
                        ));
                      }

                      // 5. Palabra (Daily Verse) - If space permits or desired
                      if (activeSections['daily_verse'] == true &&
                          actions.length < 4) {
                        actions.add(_QuickAction(
                          icon: Icons.auto_stories_rounded,
                          label: "Palabra",
                          isSelected: false,
                          onTap: () => onNavigate?.call(5), // ID 5 for Palabra
                        ));
                      }

                      // Fallback if empty (shouldn't happen with default config)
                      if (actions.isEmpty) return const SizedBox.shrink();

                      // Limit to 4 items for UI balance if needed, or allow scrolling?
                      // The dock design fits ~4 items comfortably.
                      // Let's take the first 4.
                      if (actions.length > 4) {
                        actions = actions.sublist(0, 4);
                      }

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: actions,
                      );
                    },
                  ),
                ),
              ),

              // Home Indicator Spacing
              Container(
                width: 130,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2.5),
                ),
                margin: const EdgeInsets.only(bottom: 8),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isSelected
                  ? AppColors.primary
                  : Colors.white.withValues(alpha: 0.6),
              size: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          )
        ],
      ),
    );
  }
}
