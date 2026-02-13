import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:radio_nueva_esperanza/data/services/banner_service.dart';
import 'package:flutter/services.dart';

class BannerCarousel extends StatelessWidget {
  const BannerCarousel({super.key});

  Future<List<String>> _getLocalImages(BuildContext context) async {
    final List<String> manualList = [
      'assets/image/homeFinal.png',
      'assets/image/Salud y vida.png',
      'assets/image/Restuarando la familia.png',
      'assets/image/momentos de oracion.png',
    ];

    try {
      final manifest = await AssetManifest.loadFromAssetBundle(
          DefaultAssetBundle.of(context));
      final assets = manifest.listAssets();

      // Filter for images in assets/image/ directory
      // We check for common image extensions
      final filtered = assets
          .where((key) =>
              key.startsWith('assets/image/') &&
              (key.toLowerCase().endsWith('.png') ||
                  key.toLowerCase().endsWith('.jpg') ||
                  key.toLowerCase().endsWith('.jpeg') ||
                  key.toLowerCase().endsWith('.webp')))
          .toList();

      if (filtered.isNotEmpty) {
        return filtered;
      }
    } catch (e) {
      debugPrint('Error loading asset manifest: $e');
    }

    // Fallback: Verify which manual images actually exist
    final List<String> verifiedAssets = [];
    for (final asset in manualList) {
      try {
        await DefaultAssetBundle.of(context).load(asset);
        verifiedAssets.add(asset);
      } catch (e) {
        debugPrint('Asset not found: $asset');
      }
    }
    return verifiedAssets;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BannerModel>>(
      stream: BannerService().getActiveBanners(),
      builder: (context, snapshot) {
        final remoteBanners = snapshot.data ?? [];

        // If we have remote banners, show them immediately
        if (remoteBanners.isNotEmpty) {
          return _buildCarousel(context, remoteBanners);
        }

        // Otherwise, load local images dynamically
        return FutureBuilder<List<String>>(
          future: _getLocalImages(context),
          builder: (context, localSnapshot) {
            if (localSnapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                  height: 300,
                  child: Center(child: CircularProgressIndicator()));
            }

            final localBanners = localSnapshot.data ?? [];
            if (localBanners.isEmpty) {
              return const SizedBox.shrink();
            }

            return _buildCarousel(context, localBanners);
          },
        );
      },
    );
  }

  Widget _buildCarousel(BuildContext context, List<dynamic> items) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 300.0,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 5),
        enlargeCenterPage: false,
        aspectRatio: 1.0,
        viewportFraction: 1.0,
      ),
      items: items.map((item) {
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
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
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
                                    item.toString().split('/').last,
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.black54),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Theme.of(context)
                              .scaffoldBackgroundColor
                              .withOpacity(0.0),
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
  }
}
