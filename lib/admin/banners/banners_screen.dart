import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:radio_nueva_esperanza/data/services/banner_service.dart';
import 'package:radio_nueva_esperanza/core/constants/app_colors.dart';

class BannersScreen extends StatefulWidget {
  const BannersScreen({super.key});

  @override
  State<BannersScreen> createState() => _BannersScreenState();
}

class _BannersScreenState extends State<BannersScreen> {
  final BannerService _bannerService = BannerService();
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920, // Optimize size
        maxHeight: 1080,
        imageQuality: 80, // Compress to 80%
      );

      if (image != null) {
        // Check file size BEFORE reading all bytes
        final int sizeInBytes = await image.length();
        final double sizeInMB = sizeInBytes / (1024 * 1024);

        if (sizeInMB > 5) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'La imagen es muy pesada (${sizeInMB.toStringAsFixed(1)} MB). Intenta con una imagen de menos de 5MB.'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 5),
              ),
            );
          }
          return;
        }

        setState(() => _isUploading = true);

        // Read bytes
        final Uint8List fileBytes = await image.readAsBytes();

        // Upload
        await _bannerService.uploadBanner(fileBytes, image.name);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Banner subido correctamente')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al subir imagen: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _deleteBanner(BannerModel banner) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Banner'),
        content:
            const Text('¿Estás seguro de que quieres eliminar este banner?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child:
                  const Text('Eliminar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await _bannerService.deleteBanner(banner.id, banner.storagePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Gestión de Banners",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
                const Text(
                  "Sube imágenes para el carrusel de la App (Máx recomendado: 5)",
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _pickAndUploadImage,
              icon: _isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.add_photo_alternate),
              label: Text(_isUploading ? "Subiendo..." : "Nuevo Banner"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: StreamBuilder<List<BannerModel>>(
            stream: _bannerService.getBanners(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              final banners = snapshot.data ?? [];

              if (banners.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_not_supported_outlined,
                          size: 64,
                          color:
                              AppColors.textSecondary.withValues(alpha: 0.3)),
                      const SizedBox(height: 10),
                      Text("No hay banners activos",
                          style: TextStyle(color: Colors.grey.shade500)),
                    ],
                  ),
                );
              }

              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 400,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 16 / 9,
                ),
                itemCount: banners.length,
                itemBuilder: (context, index) {
                  final banner = banners[index];
                  return Card(
                    color: AppColors.cardBackground, // Dark Card
                    clipBehavior: Clip.antiAlias,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          banner.imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, event) {
                            if (event == null) return child;
                            return Center(
                                child: CircularProgressIndicator(
                                    value: event.expectedTotalBytes != null
                                        ? event.cumulativeBytesLoaded /
                                            event.expectedTotalBytes!
                                        : null));
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(child: Icon(Icons.error)),
                        ),
                        // Overlay gradient for text/buttons
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.7),
                                  Colors.transparent
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Delete Button
                        Positioned(
                          top: 8,
                          right: 8,
                          child: CircleAvatar(
                            backgroundColor: Colors.white.withOpacity(0.8),
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteBanner(banner),
                              tooltip: 'Eliminar',
                            ),
                          ),
                        ),
                        // Toggle Active/Inactive (Optional, implemented logic exists in service)
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Switch(
                            value: banner.isActive,
                            onChanged: (val) {
                              _bannerService.toggleActive(banner.id, val);
                            },
                            activeThumbColor: Colors.teal,
                          ),
                        ),
                        Positioned(
                            bottom: 12,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(4)),
                              child: Text("Orden: ${banner.order}",
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12)),
                            ))
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
