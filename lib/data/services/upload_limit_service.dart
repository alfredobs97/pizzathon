import 'package:ntp/ntp.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UploadLimitCacheService {
  final SharedPreferences _prefs;
  final Future<DateTime> Function() _nowProvider;

  static const int maxPizzasPerDay = 3;

  UploadLimitCacheService({
    required SharedPreferences prefs,
    Future<DateTime> Function()? nowProvider,
  }) : _prefs = prefs,
       _nowProvider = nowProvider ?? (() => NTP.now());

  Future<bool?> checkCacheLimit(String userId) async {
    final now = await _nowProvider();
    final slotKey = _getSlotKey(userId, now);

    final cachedCount = _prefs.getInt(slotKey);
    if (cachedCount != null && cachedCount >= maxPizzasPerDay) {
      return false;
    }

    return null;
  }

  Future<(DateTime, DateTime)> getStartAndEndOfDay() async {
    final now = await _nowProvider();
    return (
      DateTime(now.year, now.month, now.day),
      DateTime(now.year, now.month, now.day, 23, 59, 59),
    );
  }

  Future<void> incrementLimitCacheByOne(String userId) async {
    final now = await _nowProvider();
    final slotKey = _getSlotKey(userId, now);

    final currentCount = _prefs.getInt(slotKey) ?? 0;
    await _prefs.setInt(slotKey, currentCount + 1);
  }

  Future<void> incrementLimitCache(String userId, int increment) async {
    final now = await _nowProvider();
    final slotKey = _getSlotKey(userId, now);

    final currentCount = _prefs.getInt(slotKey) ?? 0;
    await _prefs.setInt(slotKey, currentCount + increment);
  }

  String _getSlotKey(String userId, DateTime date) {
    final year = date.year;
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return 'limit_${userId}_$year-$month-$day';
  }
}
