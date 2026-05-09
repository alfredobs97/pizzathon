import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pizzathon/data/services/auth_service.dart';
import 'package:pizzathon/data/services/firestore_service.dart';
import 'package:pizzathon/data/services/upload_limit_service.dart';
import 'package:pizzathon/domain/entities/tracked_error.dart';
import 'package:pizzathon/domain/services/error_tracker_service.dart';
import 'package:pizzathon/ui/blocs/upload_limit/upload_limit_cubit.dart';
import 'package:pizzathon/ui/blocs/upload_limit/upload_limit_state.dart';

class MockUploadLimitService extends Mock implements UploadLimitCacheService {}

class MockFirestoreService extends Mock implements FirestoreService {}

class MockErrorTrackerService extends Mock implements ErrorTrackerService {}

class MockAuthService extends Mock implements AuthService {}

class MockUser extends Mock implements User {}

void main() {
  late UploadLimitCubit uploadLimitCubit;
  late MockUploadLimitService mockUploadLimitService;
  late MockFirestoreService mockFirestoreService;
  late MockErrorTrackerService mockErrorTrackerService;
  late MockAuthService mockAuthService;
  late MockUser mockUser;

  const String userId = 'test_user_id';
  final DateTime startOfDay = DateTime(2026, 5, 7, 0, 0, 0);
  final DateTime endOfDay = DateTime(2026, 5, 7, 23, 59, 59);

  setUp(() {
    mockUploadLimitService = MockUploadLimitService();
    mockFirestoreService = MockFirestoreService();
    mockErrorTrackerService = MockErrorTrackerService();
    mockAuthService = MockAuthService();
    mockUser = MockUser();

    uploadLimitCubit = UploadLimitCubit(
      mockUploadLimitService,
      mockFirestoreService,
      mockErrorTrackerService,
      mockAuthService,
    );

    registerFallbackValue(TrackedError(error: Exception()));
    registerFallbackValue(DateTime(0));
    registerFallbackValue(UploadLimitInitial());
    when(() => mockUser.uid).thenReturn(userId);
    when(() => mockErrorTrackerService.trackError(any())).thenAnswer((_) async => {});
    when(() => mockUploadLimitService.getStartAndEndOfDay())
        .thenAnswer((_) async => (startOfDay, endOfDay));
    when(() => mockUploadLimitService.setLimitCache(any(), any())).thenAnswer((_) async => {});
  });

  tearDown(() {
    uploadLimitCubit.close();
  });

  group('UploadLimitCubit', () {
    blocTest<UploadLimitCubit, UploadLimitState>(
      'emits [UploadLimitChecking, UploadLimitReached] when cache says reached',
      build: () {
        when(() => mockAuthService.currentUser).thenReturn(mockUser);
        when(() => mockUploadLimitService.checkCacheLimit(userId)).thenAnswer((_) async => false);
        return uploadLimitCubit;
      },
      act: (cubit) => cubit.checkLimit(),
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
        when(() => mockAuthService.currentUser).thenReturn(mockUser);
        when(() => mockUploadLimitService.checkCacheLimit(userId)).thenAnswer((_) async => null);
        when(() => mockFirestoreService.countPizzasToday(
          uid: userId,
          startOfDay: startOfDay,
          endOfDay: endOfDay,
        )).thenAnswer((_) async => 0);
        return uploadLimitCubit;
      },
      act: (cubit) => cubit.checkLimit(),
      expect: () => [UploadLimitChecking(), UploadLimitAllowed()],
      verify: (_) {
        verify(() => mockUploadLimitService.checkCacheLimit(userId)).called(1);
        verify(() => mockFirestoreService.countPizzasToday(
              uid: userId,
              startOfDay: startOfDay,
              endOfDay: endOfDay,
            )).called(1);
        verify(() => mockUploadLimitService.setLimitCache(userId, 0)).called(1);
      },
    );

    blocTest<UploadLimitCubit, UploadLimitState>(
      'falls back to Firestore when cache returns null and limit reached',
      build: () {
        when(() => mockAuthService.currentUser).thenReturn(mockUser);
        when(() => mockUploadLimitService.checkCacheLimit(userId)).thenAnswer((_) async => null);
        when(() => mockFirestoreService.countPizzasToday(
          uid: userId,
          startOfDay: startOfDay,
          endOfDay: endOfDay,
        )).thenAnswer((_) async => 3);
        return uploadLimitCubit;
      },
      act: (cubit) => cubit.checkLimit(),
      expect: () => [UploadLimitChecking(), UploadLimitReached()],
      verify: (_) {
        verify(() => mockUploadLimitService.checkCacheLimit(userId)).called(1);
        verify(() => mockFirestoreService.countPizzasToday(
              uid: userId,
              startOfDay: startOfDay,
              endOfDay: endOfDay,
            )).called(1);
        verify(() => mockUploadLimitService.setLimitCache(userId, 3)).called(1);
      },
    );

    blocTest<UploadLimitCubit, UploadLimitState>(
      'tracks error and falls back to Firestore when cache throws exception',
      build: () {
        when(() => mockAuthService.currentUser).thenReturn(mockUser);
        when(() => mockUploadLimitService.checkCacheLimit(userId))
            .thenThrow(Exception('Cache error'));
        when(() => mockFirestoreService.countPizzasToday(
          uid: userId,
          startOfDay: startOfDay,
          endOfDay: endOfDay,
        )).thenAnswer((_) async => 0);
        return uploadLimitCubit;
      },
      act: (cubit) => cubit.checkLimit(),
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
      'emits [UploadLimitError] when user is not authenticated',
      build: () {
        when(() => mockAuthService.currentUser).thenReturn(null);
        return uploadLimitCubit;
      },
      act: (cubit) => cubit.checkLimit(),
      expect: () => [const UploadLimitError('Usuario no autenticado')],
      verify: (_) {
        verifyNever(() => mockUploadLimitService.checkCacheLimit(any()));
        verifyNoMoreInteractions(mockFirestoreService);
      },
    );
  });
}
