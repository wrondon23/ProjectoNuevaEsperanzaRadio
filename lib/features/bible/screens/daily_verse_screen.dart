import 'package:flutter/material.dart';
import 'package:radio_nueva_esperanza/core/constants/app_colors.dart';
import 'package:radio_nueva_esperanza/data/services/bible_service.dart';
import 'package:share_plus/share_plus.dart';

class DailyVerseScreen extends StatelessWidget {
  const DailyVerseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final verse = BibleService().getDailyVerse();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Palabra Diaria'),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              AppColors.primary.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_stories,
                size: 64, color: AppColors.secondary),
            const SizedBox(height: 32),
            Text(
              verse.text,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Fixed visibility on dark background
                    height: 1.5,
                    fontFamily:
                        'Serif', // Use a serif font if available, or fallbacks
                  ),
            ),
            const SizedBox(height: 24),
            Text(
              verse.reference,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              verse.version,
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () {
                Share.share(
                    '"${verse.text}" - ${verse.reference} \n\nCompartido desde Radio Nueva Esperanza');
              },
              icon: const Icon(Icons.share),
              label: const Text("Compartir Bendición"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
