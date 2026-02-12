import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:radio_nueva_esperanza/core/constants/app_colors.dart';
import 'package:radio_nueva_esperanza/data/models/activity_model.dart';
import 'package:radio_nueva_esperanza/data/repositories/data_repository.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  final DataRepository _repository = DataRepository();
  late Future<List<ActivityModel>> _activitiesFuture;

  @override
  void initState() {
    super.initState();
    _activitiesFuture = _repository.getActivities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColors.backgroundDark, // REMOVED
      appBar: AppBar(
        title: const Text('Actividades'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<ActivityModel>>(
        future: _activitiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.secondary));
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: AppColors.textPrimary)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No hay actividades programadas',
                      style: TextStyle(
                          fontSize: 14, color: AppColors.textPrimary)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final item = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                // Theme handles shape and elevation
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.event_note,
                                color: AppColors.secondary), // Gold Icon
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.title,
                              style: GoogleFonts.outfit(
                                fontStyle: FontStyle.italic,
                                color: AppColors.textPrimary, // Dark Text
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.calendar_month,
                              size: 18, // Increased from 16
                              color: AppColors.secondary),
                          const SizedBox(width: 4),
                          Text(
                            item.date,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16, // Explicit size added
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (item.location.isNotEmpty)
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 16, color: AppColors.secondary),
                            const SizedBox(width: 4),
                            Text("📍 ${item.location}",
                                style: const TextStyle(
                                    color: AppColors.textPrimary)), // Dark Text
                          ],
                        ),
                      Divider(color: AppColors.textSecondary.withOpacity(0.1)),
                      Text(
                        item.description,
                        style: TextStyle(
                          color: AppColors.textPrimary.withOpacity(0.8),
                          fontSize: 16, // Increased from default (~14)
                          height: 1.4,
                        ),
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
