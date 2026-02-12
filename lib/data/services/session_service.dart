import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timer? _heartbeatTimer;
  String? _deviceId;
  String? _country;
  String? _city;
  String? _platform;

  Future<void> initialize() async {
    try {
      await _loadDeviceId();
      await _detectPlatform();
      await _fetchLocation();
      await _sendHeartbeat();

      // Start heartbeat every 3 minutes
      _heartbeatTimer?.cancel();
      _heartbeatTimer = Timer.periodic(const Duration(minutes: 3), (timer) {
        _sendHeartbeat();
      });
    } catch (e) {
      print("Error initializing SessionService: $e");
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

  Future<void> _detectPlatform() async {
    final deviceInfo = DeviceInfoPlugin();
    if (kIsWeb) {
      _platform = 'Web';
    } else if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      _platform = 'Android ${androidInfo.version.release}';
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      _platform = 'iOS ${iosInfo.systemName}';
    } else {
      _platform = 'Desktop';
    }
  }

  Future<void> _fetchLocation() async {
    try {
      // Use a free IP geolocation API
      final response = await http.get(Uri.parse('http://ip-api.com/json'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          _country = data['country'];
          _city = data['city'];
        }
      }
    } catch (e) {
      print("Error fetching location: $e");
    }
  }

  Future<void> _sendHeartbeat() async {
    if (_deviceId == null) return;

    try {
      await _firestore.collection('active_sessions').doc(_deviceId).set({
        'last_seen': FieldValue.serverTimestamp(),
        'platform': _platform ?? 'Unknown',
        'country': _country ?? 'Unknown',
        'city': _city ?? 'Unknown',
        'is_online': true, // Helper for simple queries
      }, SetOptions(merge: true));
    } catch (e) {
      print("Error sending heartbeat: $e");
    }
  }

  void dispose() {
    _heartbeatTimer?.cancel();
  }
}
