import 'package:flutter/material.dart';
import 'package:radio_nueva_esperanza/core/constants/app_colors.dart';
import 'package:radio_nueva_esperanza/data/models/announcement_model.dart';
import 'package:radio_nueva_esperanza/data/repositories/data_repository.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final DataRepository _repository = DataRepository();
  late Future<List<AnnouncementModel>> _announcementsFuture;

  @override
  void initState() {
    super.initState();
    _announcementsFuture = _repository.getAnnouncements();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Anuncios')),
      body: FutureBuilder<List<AnnouncementModel>>(
        future: _announcementsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.campaign, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No hay anuncios por ahora'),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                // Theme handles shape and elevation now due to global CardTheme
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(item.imageUrl!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.campaign,
                                color: AppColors.secondary), // Gold Icon
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        18, // Increased from default (~16)
                                    color: AppColors.secondary, // Gold Title
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 16, // Slightly larger icon
                              color: AppColors.secondary),
                          const SizedBox(width: 6),
                          Text(
                            item.date,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium // Changed from bodySmall
                                ?.copyWith(
                                    fontSize: 14, // Explicit size
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Divider(
                            color:
                                AppColors.textSecondary.withValues(alpha: 0.1)),
                      ),
                      Text(
                        item.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 16, // Increased from default (~14)
                            color:
                                AppColors.textPrimary.withValues(alpha: 0.8)),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
