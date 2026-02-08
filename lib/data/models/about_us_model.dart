import 'package:cloud_firestore/cloud_firestore.dart';

class AboutUsModel {
  final String content;
  final String pastorName;
  final String pastorBio;
  final String pastorImageUrl;
  final String churchImageUrl;
  final String address;
  final String facebookUrl;
  final String youtubeUrl;

  AboutUsModel({
    required this.content,
    this.pastorName = '',
    this.pastorBio = '',
    this.pastorImageUrl = '',
    this.churchImageUrl = '',
    this.address = '',
    this.facebookUrl = '',
    this.youtubeUrl = '',
  });

  factory AboutUsModel.fromFirestore(DocumentSnapshot? doc) {
    if (doc == null || !doc.exists || doc.data() == null) {
      return AboutUsModel(content: 'Información no disponible.');
    }

    final data = doc.data() as Map<String, dynamic>;

    return AboutUsModel(
      content: data['content'] as String? ?? '',
      pastorName: data['pastorName'] as String? ?? '',
      pastorBio: data['pastorBio'] as String? ?? '',
      pastorImageUrl: data['pastorImageUrl'] as String? ?? '',
      churchImageUrl: data['churchImageUrl'] as String? ?? '',
      address: data['address'] as String? ?? '',
      facebookUrl: data['facebookUrl'] as String? ?? '',
      youtubeUrl: data['youtubeUrl'] as String? ?? '',
    );
  }
}
