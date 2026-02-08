import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:radio_nueva_esperanza/data/models/activity_model.dart';
import 'package:radio_nueva_esperanza/data/models/announcement_model.dart';
import 'package:radio_nueva_esperanza/data/models/about_us_model.dart';

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
}
