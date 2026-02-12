import 'dart:convert';
import 'package:http/http.dart' as http;

class MixlrService {
  static const String _baseUrl = 'https://api.mixlr.com';

  /// Resolves a Mixlr URL to a direct stream URL and metadata
  Future<Map<String, String>?> resolveStream(String url) async {
    // 1. Check if it's already a direct stream
    if (url.contains('edge.mixlr.com') ||
        url.endsWith('.mp3') ||
        url.endsWith('.aac') ||
        url.endsWith('.m3u8')) {
      return {'streamUrl': url, 'title': ''};
    }

    // 2. Check if it's a Mixlr Profile URL
    final uri = Uri.parse(url);
    if (uri.host.contains('mixlr.com')) {
      final slug = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
      if (slug.isNotEmpty && slug != 'users') {
        return await _resolveFromSlug(slug);
      }
    }

    return null; // Not a resolvable Mixlr URL
  }

  Future<Map<String, String>?> _resolveFromSlug(String slug) async {
    try {
      // Step A: Get User ID from Profile Page
      final profileResponse =
          await http.get(Uri.parse('https://mixlr.com/$slug'));

      if (profileResponse.statusCode != 200) return null;

      // Regex to find user_id in the HTML source
      // Pattern often appears as "user_id":123456 or "id":123456 inside user context
      final idMatch =
          RegExp(r'"user_id":(\d+)').firstMatch(profileResponse.body);

      if (idMatch != null) {
        final userId = idMatch.group(1);
        if (userId != null) {
          return await _fetchStreamFromApi(userId);
        }
      }

      // Fallback: Try searching via simple API if possible (less reliable) or just return null
      return null;
    } catch (e) {
      print("Error resolving Mixlr slug: $e");
      return null;
    }
  }

  Future<Map<String, String>?> _fetchStreamFromApi(String userId) async {
    try {
      final apiUrl = '$_baseUrl/users/$userId?source=embed';
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check if live
        final isLive = data['is_live'] == true;

        // Get Live Stream URL
        if (isLive && data['broadcasts'] != null) {
          final broadcasts = data['broadcasts'] as List;
          if (broadcasts.isNotEmpty) {
            final broadcast = broadcasts.first;
            final streams = broadcast['streams'];

            // Prefer Progressive (MP3) over HLS for simplicity, or HLS if needed
            final streamUrl = streams['progressive'] ?? streams['hls'] ?? '';
            final title = broadcast['title'] ?? 'En Vivo';

            if (streamUrl.isNotEmpty) {
              return {'streamUrl': streamUrl, 'title': title, 'status': 'live'};
            }
          }
        } else {
          // Not live, maybe return a recording? Or just indicate offline.
          // For now, return null or status offline
          return {'status': 'offline'};
        }
      }
    } catch (e) {
      print("Error fetching Mixlr API: $e");
    }
    return null;
  }
}
