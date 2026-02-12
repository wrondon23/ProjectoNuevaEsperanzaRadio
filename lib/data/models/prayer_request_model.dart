import 'package:cloud_firestore/cloud_firestore.dart';

class PrayerRequestModel {
  final String id;
  final String senderName;
  final String content;
  final DateTime date;
  final bool isRead;

  PrayerRequestModel({
    required this.id,
    required this.senderName,
    required this.content,
    required this.date,
    this.isRead = false,
  });

  factory PrayerRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PrayerRequestModel(
      id: doc.id,
      senderName: data['senderName'] ?? 'Anónimo',
      content: data['content'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderName': senderName,
      'content': content,
      'date': Timestamp.fromDate(date),
      'isRead': isRead,
    };
  }
}
