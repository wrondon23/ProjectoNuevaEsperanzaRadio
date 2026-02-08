import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:radio_nueva_esperanza/core/constants/app_colors.dart';
import 'package:radio_nueva_esperanza/data/models/about_us_model.dart';
import 'package:radio_nueva_esperanza/data/repositories/data_repository.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark, // Dark Teal Background
      appBar: AppBar(
        title: const Text('Quiénes Somos',
            style: TextStyle(color: AppColors.textDark)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: FutureBuilder<AboutUsModel>(
        future: DataRepository().getAboutUs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.secondary));
          }

          final about = snapshot.data ?? AboutUsModel(content: '');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Logo Section & Church Image
                if (about.churchImageUrl.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: about.churchImageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                  )
                else
                  const Icon(Icons.church,
                      size: 80, color: AppColors.secondary), // Gold Icon

                const SizedBox(height: 16),
                Text(
                  'Iglesia Adventista Nueva Esperanza',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary, // Gold Header
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // General Description
                Text(
                  about.content.isNotEmpty
                      ? about.content
                      : 'Somos una comunidad cristiana dedicada a compartir el evangelio y servir al prójimo.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16, color: AppColors.textDark), // Cream Text
                ),

                const SizedBox(height: 32),
                const Divider(color: AppColors.secondary),
                const SizedBox(height: 16),

                // Pastor Section
                if (about.pastorName.isNotEmpty) ...[
                  Text(
                    'Conozca a Nuestro Pastor',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary, // Gold Header
                        ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.secondary, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: about.pastorImageUrl.isNotEmpty
                          ? CachedNetworkImageProvider(about.pastorImageUrl)
                          : const AssetImage('assets/image/pastor.jpg')
                              as ImageProvider,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    about.pastorName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark, // Cream Text
                        ),
                  ),
                  if (about.pastorBio.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      '"${about.pastorBio}"',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          color: AppColors.textDark),
                    ),
                  ],
                  const SizedBox(height: 32),
                  const Divider(color: AppColors.secondary),
                  const SizedBox(height: 16),
                ],

                // Social Media Section
                if (about.facebookUrl.isNotEmpty ||
                    about.youtubeUrl.isNotEmpty) ...[
                  Text(
                    'Síguenos en Redes',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (about.facebookUrl.isNotEmpty)
                        _SocialButton(
                          icon: Icons.facebook,
                          label: 'Facebook',
                          color: const Color(0xFF1877F2),
                          url: about.facebookUrl,
                        ),
                      if (about.youtubeUrl.isNotEmpty)
                        _SocialButton(
                          icon: Icons.video_library,
                          label: 'YouTube',
                          color: const Color(0xFFFF0000),
                          url: about.youtubeUrl,
                        ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Divider(color: AppColors.secondary),
                ],

                // Contact Info
                if (about.address.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.location_on,
                        color: AppColors.secondary),
                    title: const Text('Dirección',
                        style: TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold)),
                    subtitle: Text(about.address,
                        style: const TextStyle(color: AppColors.textDark)),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String url;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        final uri = Uri.parse(url);
        try {
          if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
            debugPrint('Could not launch $url');
          }
        } catch (e) {
          debugPrint('Error launching URL: $e');
        }
      },
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }
}
