import 'package:cloud_firestore/cloud_firestore.dart';

class AppConfigModel {
  final String id;
  final String streamUrl;
  final String stationName;
  final String whatsappNumber;
  final String facebookUrl;
  final String youtubeUrl;
  final bool isMaintenanceMode;
  final Map<String, bool> activeSections;

  AppConfigModel({
    this.id = 'default',
    this.streamUrl = '',
    this.stationName = 'Radio Nueva Esperanza',
    this.whatsappNumber = '',
    this.facebookUrl = '',
    this.youtubeUrl = '',
    this.isMaintenanceMode = false,
    this.activeSections = const {
      'announcements': true,
      'activities': true,
      'about': true,
      'podcasts': true,
      'prayer_requests': true,
      'daily_verse': true,
    },
  });

  factory AppConfigModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AppConfigModel(
      id: doc.id,
      streamUrl: data['streamUrl'] ?? '',
      stationName: data['stationName'] ?? 'Radio Nueva Esperanza',
      whatsappNumber: data['whatsappNumber'] ?? '',
      facebookUrl: data['facebookUrl'] ?? '',
      youtubeUrl: data['youtubeUrl'] ?? '',
      isMaintenanceMode: data['isMaintenanceMode'] ?? false,
      activeSections: {
        'announcements': true,
        'activities': true,
        'about': true,
        'podcasts': true,
        'prayer_requests': true,
        'daily_verse': true,
        ...(data['activeSections'] as Map<String, dynamic>? ?? {})
            .cast<String, bool>(),
      },
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'streamUrl': streamUrl,
      'stationName': stationName,
      'whatsappNumber': whatsappNumber,
      'facebookUrl': facebookUrl,
      'youtubeUrl': youtubeUrl,
      'isMaintenanceMode': isMaintenanceMode,
      'activeSections': activeSections,
    };
  }

  AppConfigModel copyWith({
    String? streamUrl,
    String? stationName,
    String? whatsappNumber,
    String? facebookUrl,
    String? youtubeUrl,
    bool? isMaintenanceMode,
    Map<String, bool>? activeSections,
  }) {
    return AppConfigModel(
      id: id,
      streamUrl: streamUrl ?? this.streamUrl,
      stationName: stationName ?? this.stationName,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      facebookUrl: facebookUrl ?? this.facebookUrl,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      isMaintenanceMode: isMaintenanceMode ?? this.isMaintenanceMode,
      activeSections: activeSections ?? this.activeSections,
    );
  }
}
