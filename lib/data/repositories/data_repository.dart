import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:radio_nueva_esperanza/data/models/activity_model.dart';
import 'package:radio_nueva_esperanza/data/models/announcement_model.dart';
import 'package:radio_nueva_esperanza/data/models/about_us_model.dart';
import 'package:radio_nueva_esperanza/data/models/app_config_model.dart';
import 'package:radio_nueva_esperanza/data/models/podcast_model.dart';
import 'package:radio_nueva_esperanza/data/models/prayer_request_model.dart';

class DataRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<AnnouncementModel>> getAnnouncements() async {
    try {
      final snapshot = await _firestore.collection('announcements').get();
      return snapshot.docs
          .map((doc) => AnnouncementModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("Error loading announcements from Firestore: $e");
      return [];
    }
  }

  Future<List<ActivityModel>> getActivities() async {
    try {
      final snapshot = await _firestore.collection('activities').get();
      return snapshot.docs
          .map((doc) => ActivityModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("Error loading activities from Firestore: $e");
      return [];
    }
  }

  Future<AboutUsModel> getAboutUs() async {
    try {
      final snapshot = await _firestore.collection('about_us').limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        return AboutUsModel.fromFirestore(snapshot.docs.first);
      }
      return AboutUsModel(content: 'Información no disponible.');
    } catch (e) {
      print("Error loading About Us from Firestore: $e");
      return AboutUsModel(content: 'Error al cargar la información.');
    }
  }

  // Configuration Methods
  Future<AppConfigModel> getAppConfig() async {
    try {
      final doc =
          await _firestore.collection('config').doc('main_config').get();
      if (doc.exists) {
        return AppConfigModel.fromFirestore(doc);
      }
      return AppConfigModel(); // Return default if exists
    } catch (e) {
      print("Error loading config from Firestore: $e");
      return AppConfigModel();
    }
  }

  Future<void> saveAppConfig(AppConfigModel config) async {
    try {
      await _firestore
          .collection('config')
          .doc('main_config')
          .set(config.toMap(), SetOptions(merge: true));
    } catch (e) {
      print("Error saving config to Firestore: $e");
      throw e;
    }
  }

  // Podcast Methods
  Future<List<PodcastModel>> getPodcasts() async {
    try {
      final snapshot = await _firestore
          .collection('podcasts')
          .orderBy('date', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => PodcastModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("Error fetching podcasts: $e");
      return [];
    }
  }

  // Prayer Request Methods
  Future<void> sendPrayerRequest(PrayerRequestModel request) async {
    try {
      await _firestore.collection('prayer_requests').add(request.toMap());
    } catch (e) {
      print("Error sending prayer request: $e");
      throw e;
    }
  }
}
