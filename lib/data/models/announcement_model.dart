import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AnnouncementModel {
  final String id;
  final String title;
  final String date;
  final String description;
  final String? imageUrl;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.date,
    required this.description,
    this.imageUrl,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'] as String,
      title: json['title'] as String,
      date: json['date'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  factory AnnouncementModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Handle date conversion from Timestamp or String
    String dateStr = '';
    if (data['date'] is Timestamp) {
      dateStr =
          DateFormat('yyyy-MM-dd').format((data['date'] as Timestamp).toDate());
    } else if (data['date'] is String) {
      dateStr = data['date'];
    }

    return AnnouncementModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      date: dateStr,
      description: data['description'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': date,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}
