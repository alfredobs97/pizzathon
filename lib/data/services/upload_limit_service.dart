import 'package:ntp/ntp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'firestore_service.dart';

class UploadLimitService {
  final FirestoreService _firestoreService;
  final SharedPreferences _prefs;
  final Future<DateTime> Function() _nowProvider;

  static const int maxPizzasPerDay = 3;

  UploadLimitService({
    required FirestoreService firestoreService,
    required SharedPreferences prefs,
    Future<DateTime> Function()? nowProvider,
  })  : _firestoreService = firestoreService,
        _prefs = prefs,
        _nowProvider = nowProvider ?? (() => NTP.now());

  Future<bool?> checkCacheLimit(String userId) async {
    final now = await _nowProvider();
    final slotKey = _getSlotKey(userId, now);

    final cachedCount = _prefs.getInt(slotKey);
    if (cachedCount != null && cachedCount >= maxPizzasPerDay) {
      return false;
    }

    // Return null if cache data is missing or not reaching limit yet,
    // to signal that we should check Firestore.
    return null;
  }

  Future<bool> checkFirestoreLimit(String userId) async {
    final now = await _nowProvider();
    final slotKey = _getSlotKey(userId, now);

    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final dbCount = await _firestoreService.countPizzasToday(
      uid: userId,
      startOfDay: startOfDay,
      endOfDay: endOfDay,
    );

    // Update Cache
    await _prefs.setInt(slotKey, dbCount);

    return dbCount < maxPizzasPerDay;
  }
  Future<void> incrementLimitCache(String userId) async {
    final now = await _nowProvider();
    final slotKey = _getSlotKey(userId, now);
    
    final currentCount = _prefs.getInt(slotKey) ?? 0;
    await _prefs.setInt(slotKey, currentCount + 1);
  }

  String _getSlotKey(String userId, DateTime date) {
    final year = date.year;
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return 'limit_${userId}_$year-$month-$day';
  }

}
