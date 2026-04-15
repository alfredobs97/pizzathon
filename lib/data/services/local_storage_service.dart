import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  SharedPreferences? _prefsInstance;
  final Map<String, bool> _enrollmentMemoryCache = {};

  static const String _enrollmentCachePrefix = 'nbdeu6EgYTe_';

  Future<SharedPreferences> _getPrefs() async {
    _prefsInstance ??= await SharedPreferences.getInstance();
    return _prefsInstance!;
  }

  Future<void> saveEnrollment(String uid) async {
    final prefs = await _getPrefs();
    final cacheKey = '$_enrollmentCachePrefix$uid';

    // Update persistent and memory cache
    await prefs.setBool(cacheKey, true);
    _enrollmentMemoryCache[uid] = true;
  }

  Future<bool> isUserEnrolled(String uid) async {
    // Check memory cache first
    if (_enrollmentMemoryCache[uid] == true) {
      return true;
    }

    final prefs = await _getPrefs();
    final cacheKey = '$_enrollmentCachePrefix$uid';

    // Check persistent cache
    if (prefs.getBool(cacheKey) == true) {
      _enrollmentMemoryCache[uid] = true;
      return true;
    }

    return false;
  }
}
