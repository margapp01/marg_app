/// Abstraction over unencrypted key-value persistence (backed by
/// SharedPreferences). Only NON-sensitive data belongs here — tokens and
/// secrets go through [SecureStore].
abstract interface class KeyValueStore {
  Future<String?> getString(String key);
  Future<void> setString(String key, String value);
  Future<bool?> getBool(String key);
  Future<void> setBool(String key, {required bool value});
  Future<void> remove(String key);
}
