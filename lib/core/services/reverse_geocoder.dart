import 'package:dio/dio.dart';

// Turns coordinates into a short place name such as "Cairo, Egypt" using
// OpenStreetMap's Nominatim. It has its own Dio on purpose: the app's main
// Dio carries the course API key, which must never be sent to a third party.
class ReverseGeocoder {
  ReverseGeocoder._();

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://nominatim.openstreetmap.org',
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
      headers: {
        'User-Agent': 'com.example.easy_shop_client',
        'Accept-Language': 'en',
      },
    ),
  );

  static final Map<String, String?> _cache = {};

  // Null when the place can't be resolved (no internet, open sea, ...).
  static Future<String?> labelFor(double latitude, double longitude) async {
    final key =
        '${latitude.toStringAsFixed(3)},${longitude.toStringAsFixed(3)}';
    if (_cache.containsKey(key)) return _cache[key];

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/reverse',
        queryParameters: {
          'format': 'jsonv2',
          'lat': latitude,
          'lon': longitude,
          'zoom': 10,
          'addressdetails': 1,
        },
      );
      final label = labelFromResponse(response.data);
      _cache[key] = label;
      return label;
    } catch (_) {
      return null;
    }
  }

  static String? labelFromResponse(Map<String, dynamic>? data) {
    final address = data?['address'];
    if (address is! Map) return null;

    final place =
        address['city'] ??
        address['town'] ??
        address['village'] ??
        address['state'] ??
        address['county'];
    final country = address['country'];
    final parts = [place, country].whereType<String>().toList();
    return parts.isEmpty ? null : parts.join(', ');
  }
}
