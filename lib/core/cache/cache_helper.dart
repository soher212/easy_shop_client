import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CacheHelper {
  CacheHelper._();

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static Future<void> saveSecureData({
    required String key,
    required String value,
  }) {
    return _secureStorage.write(key: key, value: value);
  }

  static Future<String?> getSecureData({required String key}) {
    return _secureStorage.read(key: key);
  }

  static Future<void> deleteSecureData({required String key}) {
    return _secureStorage.delete(key: key);
  }
}
