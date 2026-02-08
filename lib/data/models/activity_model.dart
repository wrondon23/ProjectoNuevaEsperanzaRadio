import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ActivityModel {
  final String id;
  final String title;
  final String date;
  final String location;
  final String description;

  final DateTime? startDate;
  final DateTime? endDate;

  ActivityModel({
    required this.id,
    required this.title,
    required this.date,
    this.startDate,
    this.endDate,
    required this.location,
    required this.description,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] as String,
      title: json['title'] as String,
      date: json['date'] as String,
      location: json['location'] as String,
      description: json['description'] as String,
    );
  }

  factory ActivityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    DateTime? start;
    DateTime? end;

    if (data['startDate'] is Timestamp)
      start = (data['startDate'] as Timestamp).toDate();
    if (data['endDate'] is Timestamp)
      end = (data['endDate'] as Timestamp).toDate();

    // Fallback for old data or if one is missing
    if (start == null && data['date'] is Timestamp) {
      start = (data['date'] as Timestamp).toDate();
    }

    String displayDate = '';
    if (start != null) {
      final dateFormat = DateFormat('EEE d MMM', 'es'); // Lun 10 Feb
      final timeFormat = DateFormat('h:mm a'); // 10:00 AM

      displayDate = "${dateFormat.format(start)}, ${timeFormat.format(start)}";

      if (end != null) {
        // If same day, just show end time
        if (start.year == end.year &&
            start.month == end.month &&
            start.day == end.day) {
          displayDate += " - ${timeFormat.format(end)}";
        } else {
          // Different day
          displayDate +=
              " - ${dateFormat.format(end)} ${timeFormat.format(end)}";
        }
      }
    } else {
      displayDate = data['date']?.toString() ?? '';
    }

    return ActivityModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      date: displayDate,
      startDate: start,
      endDate: end,
      location: data['location'] as String? ?? '',
      description: data['description'] as String? ?? '',
    );
  }
}
