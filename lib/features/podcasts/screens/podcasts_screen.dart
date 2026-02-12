import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:radio_nueva_esperanza/core/constants/app_colors.dart';
import 'package:radio_nueva_esperanza/data/models/podcast_model.dart';
import 'package:radio_nueva_esperanza/data/repositories/data_repository.dart';
import 'package:radio_nueva_esperanza/features/home/providers/radio_provider.dart';

class PodcastsScreen extends StatelessWidget {
  const PodcastsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold/AppBar Removed
    return FutureBuilder<List<PodcastModel>>(
      future: DataRepository().getPodcasts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.secondary));
        }
        if (snapshot.hasError) {
          return Center(
              child: Text('Error al cargar sermones: ${snapshot.error}'));
        }

        final podcasts = snapshot.data ?? [];

        if (podcasts.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mic_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No hay sermones disponibles aún.',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: podcasts.length,
          itemBuilder: (context, index) {
            final podcast = podcasts[index];
            return _PodcastCard(podcast: podcast);
          },
        );
      },
    );
  }
}

class _PodcastCard extends StatelessWidget {
  final PodcastModel podcast;

  const _PodcastCard({required this.podcast});

  @override
  Widget build(BuildContext context) {
    final radioProvider = context.watch<RadioProvider>();
    final isPlayingThis = radioProvider.currentMediaItem == podcast.audioUrl;
    final isPlaying = radioProvider.isPlaying;

    return Card(
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          if (isPlayingThis) {
            radioProvider.togglePlay();
          } else {
            // Play podcast
            context.read<RadioProvider>().playPodcast(podcast);
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Reproduciendo: ${podcast.title}')));
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                    isPlayingThis && isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: AppColors.primary,
                    size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      podcast.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18, // Increased
                            color: const Color(0xFF142F30), // Dark Teal
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      podcast.speaker,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16, // Increased from 14
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('dd MMM yyyy', 'es').format(podcast.date),
                      style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14), // Increased from 12
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
