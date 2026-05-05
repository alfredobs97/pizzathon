import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pizzathon/data/services/firestore_service.dart';
import 'package:pizzathon/data/services/upload_limit_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockFirestoreService extends Mock implements FirestoreService {}

void main() {
  late UploadLimitService service;
  late MockFirestoreService mockFirestore;
  late SharedPreferences prefs;

  const String userId = 'test_user_123';
  final DateTime fakeNow = DateTime(2026, 5, 5, 12, 0); 
  final String slotKey = 'limit_${userId}_2026-05-05';

  setUpAll(() {
    registerFallbackValue(DateTime(2000));
  });

  setUp(() async {
    mockFirestore = MockFirestoreService();
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();

    service = UploadLimitService(
      firestoreService: mockFirestore,
      prefs: prefs,
      nowProvider: () async => fakeNow,
    );

    when(() => mockFirestore.countPizzasToday(
          uid: any(named: 'uid'),
          startOfDay: any(named: 'startOfDay'),
          endOfDay: any(named: 'endOfDay'),
        )).thenAnswer((_) async => 0);
  });

  group('UploadLimitService - Cache & Firestore Split', () {
    test('checkCacheLimit returns null when cache is empty', () async {
      final result = await service.checkCacheLimit(userId);
      expect(result, isNull);
    });

    test('checkCacheLimit returns false when limit reached in cache', () async {
      await prefs.setInt(slotKey, 3);
      final result = await service.checkCacheLimit(userId);
      expect(result, isFalse);
    });

    test('checkFirestoreLimit updates cache and returns true if under limit', () async {
      when(() => mockFirestore.countPizzasToday(
            uid: any(named: 'uid'),
            startOfDay: any(named: 'startOfDay'),
            endOfDay: any(named: 'endOfDay'),
          )).thenAnswer((_) async => 1);

      final result = await service.checkFirestoreLimit(userId);

      expect(result, isTrue);
      expect(prefs.getInt(slotKey), 1);
    });

    test('checkFirestoreLimit updates cache and returns false if limit reached', () async {
      when(() => mockFirestore.countPizzasToday(
            uid: any(named: 'uid'),
            startOfDay: any(named: 'startOfDay'),
            endOfDay: any(named: 'endOfDay'),
          )).thenAnswer((_) async => 3);

      final result = await service.checkFirestoreLimit(userId);

      expect(result, isFalse);
      expect(prefs.getInt(slotKey), 3);
    });

    test('incrementLimitCache works as expected', () async {
      await prefs.setInt(slotKey, 1);
      await service.incrementLimitCache(userId);
      expect(prefs.getInt(slotKey), 2);
    });
  });
}
