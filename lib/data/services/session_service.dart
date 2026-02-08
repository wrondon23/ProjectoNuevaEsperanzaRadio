import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Timer? _heartbeatTimer;
  String? _deviceId;

  // Interval matches typical "online" definition (e.g., 5 mins)
  static const Duration _heartbeatInterval = Duration(minutes: 5);

  Future<void> initialize() async {
    try {
      await _loadDeviceId();
      _startHeartbeat();
      // Send first heartbeat immediately
      await _sendHeartbeat();
    } catch (e) {
      debugPrint("Error initializing SessionService: $e");
    }
  }

  Future<void> _loadDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    _deviceId = prefs.getString('device_id');

    if (_deviceId == null) {
      _deviceId = const Uuid().v4();
      await prefs.setString('device_id', _deviceId!);
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) async {
      await _sendHeartbeat();
    });
  }

  Future<void> _sendHeartbeat() async {
    if (_deviceId == null) return;

    try {
      final docRef = _db.collection('sessions').doc(_deviceId);

      final data = {
        'lastActive': FieldValue.serverTimestamp(),
        'platform': kIsWeb ? 'web' : (Platform.isAndroid ? 'android' : 'ios'),
        'deviceId': _deviceId,
        // Optional: Add app version or other metadata
      };

      await docRef.set(data, SetOptions(merge: true));
      debugPrint("Session heartbeat sent for device: $_deviceId");
    } catch (e) {
      debugPrint("Error sending heartbeat: $e");
    }
  }

  void dispose() {
    _heartbeatTimer?.cancel();
  }
}
