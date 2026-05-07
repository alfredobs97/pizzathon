import 'package:flutter_test/flutter_test.dart';
import 'package:pizzathon/data/services/upload_limit_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late UploadLimitCacheService service;
  late SharedPreferences prefs;

  const String userId = 'test_user_123';
  final DateTime fakeNow = DateTime(2026, 5, 5, 12, 0);
  final String slotKey = 'limit_${userId}_2026-05-05';

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();

    service = UploadLimitCacheService(
      prefs: prefs,
      nowProvider: () async => fakeNow,
    );
  });

  group('UploadLimitCacheService Tests', () {
    test('checkCacheLimit returns null when cache is empty', () async {
      final result = await service.checkCacheLimit(userId);
      expect(result, isNull);
    });

    test('checkCacheLimit returns false when limit reached in cache', () async {
      await prefs.setInt(slotKey, UploadLimitCacheService.maxPizzasPerDay);
      final result = await service.checkCacheLimit(userId);
      expect(result, isFalse);
    });

    test('checkCacheLimit returns null when under limit in cache', () async {
      await prefs.setInt(slotKey, UploadLimitCacheService.maxPizzasPerDay - 1);
      final result = await service.checkCacheLimit(userId);
      expect(result, isNull);
    });

    test('incrementLimitCache correctly increments the value in SharedPreferences', () async {
      await service.incrementLimitCache(userId, 1);
      expect(prefs.getInt(slotKey), 1);

      await service.incrementLimitCache(userId, 2);
      expect(prefs.getInt(slotKey), 3);
    });

    test('getStartAndEndOfDay returns correct time range for the day', () async {
      final (start, end) = await service.getStartAndEndOfDay();

      expect(start, DateTime(fakeNow.year, fakeNow.month, fakeNow.day));
      expect(end, DateTime(fakeNow.year, fakeNow.month, fakeNow.day, 23, 59, 59));
    });

    test('key generation respects date and user', () async {
      // We can indirectly test this by changing the fakeNow in a new service instance
      final otherDate = DateTime(2026, 12, 31);
      final otherService = UploadLimitCacheService(
        prefs: prefs,
        nowProvider: () async => otherDate,
      );

      await otherService.incrementLimitCache(userId, 1);
      expect(prefs.getInt('limit_${userId}_2026-12-31'), 1);
    });
  });
}
