import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class KeychainService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveCredentials(Map<String, String> credentials) async {
    await _storage.write(key: 'credentials', value: jsonEncode(credentials));
  }

  Future<Map<String, String>?> getCredentials() async {
    String? data = await _storage.read(key: 'credentials');
    if (data != null) {
      return Map<String, String>.from(jsonDecode(data));
    }
    return null;
  }

  Future<String?> getLoginSecretKey() async {
    Map<String, String>? creds = await getCredentials();
    return creds?['loginSecretKey'];
  }

  Future<void> clearCredentials() async {
    await _storage.delete(key: 'credentials');
  }

  /// Stores the blocked status in the secure keychain.
  Future<void> storeBlockedStatus(bool isBlocked) async {
    await _storage.write(key: "blocked_status", value: isBlocked.toString());
  }

  /// Retrieves the blocked status from the keychain.
  Future<bool> getBlockedStatus() async {
    String? value = await _storage.read(key: "blocked_status");
    return value == "true";
  }

  Future<void> clearBlockedStatus() async {
    await _storage.delete(key: 'blocked_status');
  }
}
