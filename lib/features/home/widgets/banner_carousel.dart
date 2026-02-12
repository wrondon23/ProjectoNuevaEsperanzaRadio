import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:radio_nueva_esperanza/data/services/banner_service.dart';

class BannerCarousel extends StatelessWidget {
  const BannerCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BannerModel>>(
      stream: BannerService().getActiveBanners(),
      builder: (context, snapshot) {
        // Removed early return for empty data to allow local fallback logic

        // Check if there are remote banners
        final remoteBanners = snapshot.data ?? [];

        // Define local fallback banners (user requested specific names)
        final localBanners = [
          'assets/image/homeFinal.png', // Note: Case sensitive
          'assets/image/Salud y vida.png',
          'assets/image/Restuarando la familia.png', // Keeping original filename typo
          'assets/image/momentos de oracion.png',
        ];

        // Decide what to show: Remote > Local > Nothing
        List<dynamic> itemsToShow = [];
        if (remoteBanners.isNotEmpty) {
          itemsToShow = remoteBanners;
        } else {
          itemsToShow = localBanners;
        }

        if (itemsToShow.isEmpty) {
          return const SizedBox.shrink();
        }

        return CarouselSlider(
          options: CarouselOptions(
            height: 300.0, // Matches circular container size
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            enlargeCenterPage: false,
            aspectRatio: 1.0, // Square for circle
            viewportFraction: 1.0,
          ),
          items: itemsToShow.map((item) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.zero,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      item is BannerModel
                          ? CachedNetworkImage(
                              imageUrl: item.imageUrl,
                              fit: BoxFit.fill,
                              placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            )
                          : Image.asset(
                              item as String,
                              fit: BoxFit.fill,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade300,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.broken_image,
                                          size: 40, color: Colors.grey),
                                      const SizedBox(height: 8),
                                      Text(
                                        item.split('/').last,
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                      // Gradient Overlay for "Fade" effect
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Theme.of(context)
                                  .scaffoldBackgroundColor
                                  .withValues(alpha: 0.0),
                              Theme.of(context).scaffoldBackgroundColor,
                            ],
                            stops: const [0.6, 0.8, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}
