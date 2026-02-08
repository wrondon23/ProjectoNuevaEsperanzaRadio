import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class DailyCount {
  final DateTime date;
  final int count;
  DailyCount(this.date, this.count);
}

class DashboardService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream total count of a collection
  Stream<int> getCollectionCount(String collection) {
    return _db
        .collection(collection)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  // Get last 7 days count for a collection (based on createdAt)
  Stream<List<DailyCount>> getLast7DaysCounts(String collection) {
    // Note: For large collections, aggregation queries are better.
    // For this admin panel size, downloading recent docs is fine.
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

    return _db
        .collection(collection)
        .where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo))
        .snapshots()
        .map((snapshot) {
      Map<int, int> counts = {};
      // Initialize last 7 days with 0
      for (int i = 0; i < 7; i++) {
        final d = DateTime.now().subtract(Duration(days: i));
        final key = _dateKey(d);
        counts[key] = 0;
      }

      for (var doc in snapshot.docs) {
        if (doc.data().containsKey('createdAt')) {
          final ts = doc['createdAt'] as Timestamp;
          final key = _dateKey(ts.toDate());
          if (counts.containsKey(key)) {
            counts[key] = (counts[key] ?? 0) + 1;
          }
        }
      }

      return counts.entries
          .map((e) => DailyCount(_parseKey(e.key), e.value))
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));
    });
  }

  // Helper to format date key YYYYMMDD
  int _dateKey(DateTime date) {
    return date.year * 10000 + date.month * 100 + date.day;
  }

  DateTime _parseKey(int key) {
    int year = key ~/ 10000;
    int month = (key % 10000) ~/ 100;
    int day = key % 100;
    return DateTime(year, month, day);
  }

  // Get active sessions count (active in last 10 minutes)
  Stream<int> getActiveSessionsCount() {
    // 10 minutes ago
    final cutoff = DateTime.now().subtract(const Duration(minutes: 10));

    return _db
        .collection('sessions')
        .where('lastActive', isGreaterThan: Timestamp.fromDate(cutoff))
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  // Seed sample data for emulators
  Future<void> seedSampleData() async {
    final batch = _db.batch();
    final now = DateTime.now();

    // 1. Announcements
    for (int i = 0; i < 5; i++) {
      final ref = _db.collection('announcements').doc();
      batch.set(ref, {
        'title': 'Anuncio de Prueba ${i + 1}',
        'description': 'Descripción generada para el dashboard',
        'createdAt': Timestamp.fromDate(now.subtract(Duration(days: i))),
        'category': 'General',
        'isPublic': true,
      });
    }

    // 2. Activities
    for (int i = 0; i < 3; i++) {
      final ref = _db.collection('activities').doc();
      batch.set(ref, {
        'title': 'Actividad Joven ${i + 1}',
        'description': 'Evento de prueba',
        'date':
            Timestamp.fromDate(now.add(Duration(days: i + 1))), // Future date
        'startDate': Timestamp.fromDate(now.add(Duration(days: i + 1))),
        'endDate': Timestamp.fromDate(now.add(Duration(days: i + 1, hours: 2))),
        'location': 'Iglesia Central',
        'createdAt': Timestamp.fromDate(now.subtract(Duration(hours: i * 5))),
      });
    }

    // 3. Conferences (New collection)
    for (int i = 0; i < 8; i++) {
      final ref = _db.collection('conferences').doc();
      batch.set(ref, {
        'title': 'Conferencia ${i + 1}',
        'speaker': 'Pr. Invitado',
        'createdAt': Timestamp.fromDate(now.subtract(Duration(days: i % 7))),
        'type': i % 2 == 0 ? 'Salud' : 'Espiritual',
      });
    }

    await batch.commit();
    debugPrint('--- SEED DATA INSERTED ---');
  }
}
