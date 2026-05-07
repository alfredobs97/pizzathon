import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pizzathon/data/services/firestore_service.dart';
import 'package:pizzathon/data/services/upload_limit_service.dart';
import 'package:pizzathon/domain/entities/tracked_error.dart';
import 'package:pizzathon/domain/services/error_tracker_service.dart';
import 'package:pizzathon/ui/blocs/upload_limit/upload_limit_cubit.dart';
import 'package:pizzathon/ui/blocs/upload_limit/upload_limit_state.dart';

class MockUploadLimitService extends Mock implements UploadLimitCacheService {}

class MockFirestoreService extends Mock implements FirestoreService {}

class MockErrorTrackerService extends Mock implements ErrorTrackerService {}

void main() {
  late UploadLimitCubit uploadLimitCubit;
  late MockUploadLimitService mockUploadLimitService;
  late MockFirestoreService mockFirestoreService;
  late MockErrorTrackerService mockErrorTrackerService;

  const String userId = 'test_user_id';
  final DateTime startOfDay = DateTime(2026, 5, 7, 0, 0, 0);
  final DateTime endOfDay = DateTime(2026, 5, 7, 23, 59, 59);

  setUp(() {
    mockUploadLimitService = MockUploadLimitService();
    mockFirestoreService = MockFirestoreService();
    mockErrorTrackerService = MockErrorTrackerService();
    uploadLimitCubit = UploadLimitCubit(
      mockUploadLimitService,
      mockFirestoreService,
      mockErrorTrackerService,
    );

    registerFallbackValue(TrackedError(error: Exception()));
    when(() => mockErrorTrackerService.trackError(any())).thenAnswer((_) async => {});
    when(() => mockUploadLimitService.getStartAndEndOfDay()).thenAnswer((_) async => (startOfDay, endOfDay));
    when(() => mockUploadLimitService.incrementLimitCache(any(), any())).thenAnswer((_) async => {});
  });

  tearDown(() {
    uploadLimitCubit.close();
  });

  group('UploadLimitCubit', () {
    blocTest<UploadLimitCubit, UploadLimitState>(
      'emits [UploadLimitChecking, UploadLimitReached] when cache says reached',
      build: () {
        when(() => mockUploadLimitService.checkCacheLimit(userId)).thenAnswer((_) async => false);
        return uploadLimitCubit;
      },
      act: (cubit) => cubit.checkLimit(userId),
      expect: () => [UploadLimitChecking(), UploadLimitReached()],
      verify: (_) {
        verify(() => mockUploadLimitService.checkCacheLimit(userId)).called(1);
        verifyNever(() => mockFirestoreService.countPizzasToday(
              uid: any(named: 'uid'),
              startOfDay: any(named: 'startOfDay'),
              endOfDay: any(named: 'endOfDay'),
            ));
      },
    );

    blocTest<UploadLimitCubit, UploadLimitState>(
      'falls back to Firestore when cache returns null and limit NOT reached',
      build: () {
        when(() => mockUploadLimitService.checkCacheLimit(userId)).thenAnswer((_) async => null);
        when(() => mockFirestoreService.countPizzasToday(
              uid: userId,
              startOfDay: startOfDay,
              endOfDay: endOfDay,
            )).thenAnswer((_) async => 0);
        return uploadLimitCubit;
      },
      act: (cubit) => cubit.checkLimit(userId),
      expect: () => [UploadLimitChecking(), UploadLimitAllowed()],
      verify: (_) {
        verify(() => mockUploadLimitService.checkCacheLimit(userId)).called(1);
        verify(() => mockFirestoreService.countPizzasToday(
              uid: userId,
              startOfDay: startOfDay,
              endOfDay: endOfDay,
            )).called(1);
        verify(() => mockUploadLimitService.incrementLimitCache(userId, 0)).called(1);
      },
    );

    blocTest<UploadLimitCubit, UploadLimitState>(
      'falls back to Firestore when cache returns null and limit reached',
      build: () {
        when(() => mockUploadLimitService.checkCacheLimit(userId)).thenAnswer((_) async => null);
        when(() => mockFirestoreService.countPizzasToday(
              uid: userId,
              startOfDay: startOfDay,
              endOfDay: endOfDay,
            )).thenAnswer((_) async => 3);
        return uploadLimitCubit;
      },
      act: (cubit) => cubit.checkLimit(userId),
      expect: () => [UploadLimitChecking(), UploadLimitReached()],
      verify: (_) {
        verify(() => mockUploadLimitService.checkCacheLimit(userId)).called(1);
        verify(() => mockFirestoreService.countPizzasToday(
              uid: userId,
              startOfDay: startOfDay,
              endOfDay: endOfDay,
            )).called(1);
      },
    );

    blocTest<UploadLimitCubit, UploadLimitState>(
      'tracks error and falls back to Firestore when cache throws exception',
      build: () {
        when(() => mockUploadLimitService.checkCacheLimit(userId)).thenThrow(Exception('Cache error'));
        when(() => mockFirestoreService.countPizzasToday(
              uid: userId,
              startOfDay: startOfDay,
              endOfDay: endOfDay,
            )).thenAnswer((_) async => 0);
        return uploadLimitCubit;
      },
      act: (cubit) => cubit.checkLimit(userId),
      expect: () => [UploadLimitChecking(), UploadLimitAllowed()],
      verify: (_) {
        verify(() => mockErrorTrackerService.trackError(any())).called(1);
        verify(() => mockFirestoreService.countPizzasToday(
              uid: userId,
              startOfDay: startOfDay,
              endOfDay: endOfDay,
            )).called(1);
      },
    );

    blocTest<UploadLimitCubit, UploadLimitState>(
      'emits [UploadLimitChecking, UploadLimitError] when Firestore fails',
      build: () {
        when(() => mockUploadLimitService.checkCacheLimit(userId)).thenAnswer((_) async => null);
        when(() => mockFirestoreService.countPizzasToday(
              uid: userId,
              startOfDay: startOfDay,
              endOfDay: endOfDay,
            )).thenThrow(Exception('Firestore error'));
        return uploadLimitCubit;
      },
      act: (cubit) => cubit.checkLimit(userId),
      expect: () => [UploadLimitChecking(), isA<UploadLimitError>()],
    );
  });
}
