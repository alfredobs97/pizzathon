import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pizzathon/data/services/upload_limit_service.dart';
import 'package:pizzathon/domain/entities/tracked_error.dart';
import 'package:pizzathon/domain/services/error_tracker_service.dart';
import 'package:pizzathon/ui/blocs/upload_limit/upload_limit_cubit.dart';
import 'package:pizzathon/ui/blocs/upload_limit/upload_limit_state.dart';

class MockUploadLimitService extends Mock implements UploadLimitService {}
class MockErrorTrackerService extends Mock implements ErrorTrackerService {}

void main() {
  late UploadLimitCubit uploadLimitCubit;
  late MockUploadLimitService mockUploadLimitService;
  late MockErrorTrackerService mockErrorTrackerService;

  const String userId = 'test_user_id';

  setUp(() {
    mockUploadLimitService = MockUploadLimitService();
    mockErrorTrackerService = MockErrorTrackerService();
    uploadLimitCubit = UploadLimitCubit(mockUploadLimitService, mockErrorTrackerService);

    registerFallbackValue(TrackedError(error: Exception()));
    when(() => mockErrorTrackerService.trackError(any())).thenAnswer((_) async => {});
  });

  tearDown(() {
    uploadLimitCubit.close();
  });

  group('UploadLimitCubit - Refactor', () {
    blocTest<UploadLimitCubit, UploadLimitState>(
      'emits [UploadLimitChecking, UploadLimitReached] when cache says reached',
      build: () {
        when(() => mockUploadLimitService.checkCacheLimit(userId))
            .thenAnswer((_) async => false);
        return uploadLimitCubit;
      },
      act: (cubit) => cubit.checkLimit(userId),
      expect: () => [
        UploadLimitChecking(),
        UploadLimitReached(),
      ],
      verify: (_) {
        verify(() => mockUploadLimitService.checkCacheLimit(userId)).called(1);
        verifyNever(() => mockUploadLimitService.checkFirestoreLimit(any()));
      },
    );

    blocTest<UploadLimitCubit, UploadLimitState>(
      'falls back to Firestore when cache returns null',
      build: () {
        when(() => mockUploadLimitService.checkCacheLimit(userId))
            .thenAnswer((_) async => null);
        when(() => mockUploadLimitService.checkFirestoreLimit(userId))
            .thenAnswer((_) async => true);
        return uploadLimitCubit;
      },
      act: (cubit) => cubit.checkLimit(userId),
      expect: () => [
        UploadLimitChecking(),
        UploadLimitAllowed(),
      ],
      verify: (_) {
        verify(() => mockUploadLimitService.checkCacheLimit(userId)).called(1);
        verify(() => mockUploadLimitService.checkFirestoreLimit(userId)).called(1);
      },
    );

    blocTest<UploadLimitCubit, UploadLimitState>(
      'tracks error and falls back to Firestore when cache throws exception',
      build: () {
        when(() => mockUploadLimitService.checkCacheLimit(userId))
            .thenThrow(Exception('Cache error'));
        when(() => mockUploadLimitService.checkFirestoreLimit(userId))
            .thenAnswer((_) async => true);
        return uploadLimitCubit;
      },
      act: (cubit) => cubit.checkLimit(userId),
      expect: () => [
        UploadLimitChecking(),
        UploadLimitAllowed(),
      ],
      verify: (_) {
        verify(() => mockErrorTrackerService.trackError(any())).called(1);
        verify(() => mockUploadLimitService.checkFirestoreLimit(userId)).called(1);
      },
    );

    blocTest<UploadLimitCubit, UploadLimitState>(
      'emits [UploadLimitChecking, UploadLimitError] when Firestore fails',
      build: () {
        when(() => mockUploadLimitService.checkCacheLimit(userId))
            .thenAnswer((_) async => null);
        when(() => mockUploadLimitService.checkFirestoreLimit(userId))
            .thenThrow(Exception('Firestore error'));
        return uploadLimitCubit;
      },
      act: (cubit) => cubit.checkLimit(userId),
      expect: () => [
        UploadLimitChecking(),
        isA<UploadLimitError>(),
      ],
    );
  });
}
