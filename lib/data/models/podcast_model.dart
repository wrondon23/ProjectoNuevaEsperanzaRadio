import 'package:cloud_firestore/cloud_firestore.dart';

class PodcastModel {
  final String id;
  final String title;
  final String speaker;
  final String description;
  final String audioUrl;
  final DateTime date;

  PodcastModel({
    required this.id,
    required this.title,
    required this.speaker,
    this.description = '',
    required this.audioUrl,
    required this.date,
  });

  factory PodcastModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PodcastModel(
      id: doc.id,
      title: data['title'] ?? '',
      speaker: data['speaker'] ?? '',
      description: data['description'] ?? '',
      audioUrl: data['audioUrl'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'speaker': speaker,
      'description': description,
      'audioUrl': audioUrl,
      'date': Timestamp.fromDate(date),
    };
  }
}
