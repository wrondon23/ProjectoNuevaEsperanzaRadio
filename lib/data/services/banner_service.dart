import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class BannerModel {
  final String id;
  final String imageUrl;
  final int order;
  final bool isActive;
  final DateTime createdAt;
  final String? storagePath;

  BannerModel({
    required this.id,
    required this.imageUrl,
    required this.order,
    this.isActive = true,
    required this.createdAt,
    this.storagePath,
  });

  factory BannerModel.fromMap(String id, Map<String, dynamic> map) {
    return BannerModel(
      id: id,
      imageUrl: map['imageUrl'] ?? '',
      order: map['order'] ?? 0,
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      storagePath: map['storagePath'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'order': order,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'storagePath': storagePath,
    };
  }
}

class BannerService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Stream of all banners ordered by 'order'
  Stream<List<BannerModel>> getBanners() {
    return _db
        .collection('banners')
        .orderBy('order')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => BannerModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  // Stream of ACTIVE banners for the App
  Stream<List<BannerModel>> getActiveBanners() {
    return _db
        .collection('banners')
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => BannerModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  // Upload a new banner
  Future<void> uploadBanner(Uint8List fileData, String fileName) async {
    try {
      // 1. Upload to Storage
      final String uuid = const Uuid().v4();
      final String path =
          'banners/${DateTime.now().millisecondsSinceEpoch}_$uuid';
      final Reference ref = _storage.ref().child(path);

      final SettableMetadata metadata = SettableMetadata(
        customMetadata: {'picked-file-path': fileName},
      );

      final UploadTask uploadTask = ref.putData(fileData, metadata);

      // Add timeout to prevent hanging indefinitely
      final TaskSnapshot snapshot =
          await uploadTask.timeout(const Duration(seconds: 120), onTimeout: () {
        uploadTask.cancel();
        throw Exception("La subida tardó demasiado. Verifica tu conexión.");
      });

      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // 2. Save to Firestore
      // Get current max order to append at the end
      final query = await _db
          .collection('banners')
          .orderBy('order', descending: true)
          .limit(1)
          .get();
      int nextOrder = 0;
      if (query.docs.isNotEmpty) {
        nextOrder = (query.docs.first.data()['order'] as int) + 1;
      }

      await _db.collection('banners').add({
        'imageUrl': downloadUrl,
        'order': nextOrder,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'storagePath': path, // Save path to delete later
      });
    } catch (e) {
      print("Error uploading banner: $e");
      throw Exception("Error uploading banner: $e");
    }
  }

  // Delete banner
  Future<void> deleteBanner(String id, String? storagePath) async {
    try {
      // 1. Delete from Firestore
      await _db.collection('banners').doc(id).delete();

      // 2. Delete from Storage if path exists
      if (storagePath != null && storagePath.isNotEmpty) {
        // Handle cases where image might not exist or path is invalid
        try {
          await _storage.ref().child(storagePath).delete();
        } catch (e) {
          print(
              "Error deleting file from storage (might actrally be missing): $e");
        }
      }
    } catch (e) {
      print("Error deleting banner: $e");
      throw Exception("Error deleting banner");
    }
  }

  // Reorder banners (update 'order' field)
  Future<void> updateOrder(List<BannerModel> banners) async {
    final batch = _db.batch();
    for (int i = 0; i < banners.length; i++) {
      final docRef = _db.collection('banners').doc(banners[i].id);
      batch.update(docRef, {'order': i});
    }
    await batch.commit();
  }

  // Toggle Active Status
  Future<void> toggleActive(String id, bool currentState) async {
    await _db.collection('banners').doc(id).update({'isActive': !currentState});
  }
}
