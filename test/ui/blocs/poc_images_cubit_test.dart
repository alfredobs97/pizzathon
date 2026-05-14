import 'dart:typed_data';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pizzathon/data/services/auth_service.dart';
import 'package:pizzathon/data/services/firestore_service.dart';
import 'package:pizzathon/data/services/image_metadata_service.dart';
import 'package:pizzathon/data/services/image_processing_service.dart';
import 'package:pizzathon/data/services/pizza_storage_service.dart';
import 'package:pizzathon/data/services/pizza_validation_service.dart';
import 'package:pizzathon/data/services/remote_config_service.dart';
import 'package:pizzathon/data/services/heic_conversion_service.dart';
import 'package:pizzathon/data/services/upload_limit_service.dart';
import 'package:pizzathon/domain/entities/pizza_image_metadata.dart';
import 'package:pizzathon/domain/entities/validation_result.dart';
import 'package:pizzathon/domain/services/error_tracker_service.dart';
import 'package:pizzathon/ui/blocs/poc_images/poc_images_cubit.dart';
import 'package:pizzathon/ui/blocs/poc_images/poc_images_state.dart';
import 'package:pizzathon/domain/models/compression_settings.dart';

class MockImageProcessingService extends Mock implements ImageProcessingService {}
class MockRemoteConfigService extends Mock implements RemoteConfigService {}
class MockImageMetadataService extends Mock implements ImageMetadataService {}
class MockPizzaValidationService extends Mock implements PizzaValidationService {}
class MockErrorTrackerService extends Mock implements ErrorTrackerService {}
class MockAuthService extends Mock implements AuthService {}
class MockPizzaStorageService extends Mock implements PizzaStorageService {}
class MockFirestoreService extends Mock implements FirestoreService {}
class MockUploadLimitCacheService extends Mock implements UploadLimitCacheService {}
class MockHeicConversionService extends Mock implements HeicConversionService {}
class MockXFile extends Mock implements XFile {}

void main() {
  late PocImagesCubit pocImagesCubit;
  late MockImageProcessingService mockImageProcessingService;
  late MockRemoteConfigService mockRemoteConfigService;
  late MockImageMetadataService mockImageMetadataService;
  late MockPizzaValidationService mockPizzaValidationService;
  late MockErrorTrackerService mockErrorTrackerService;
  late MockAuthService mockAuthService;
  late MockPizzaStorageService mockPizzaStorageService;
  late MockFirestoreService mockFirestoreService;
  late MockUploadLimitCacheService mockUploadLimitCacheService;
  late MockHeicConversionService mockHeicConversionService;

  setUp(() {
    mockImageProcessingService = MockImageProcessingService();
    mockRemoteConfigService = MockRemoteConfigService();
    mockImageMetadataService = MockImageMetadataService();
    mockPizzaValidationService = MockPizzaValidationService();
    mockErrorTrackerService = MockErrorTrackerService();
    mockAuthService = MockAuthService();
    mockPizzaStorageService = MockPizzaStorageService();
    mockFirestoreService = MockFirestoreService();
    mockUploadLimitCacheService = MockUploadLimitCacheService();
    mockHeicConversionService = MockHeicConversionService();

    pocImagesCubit = PocImagesCubit(
      mockImageProcessingService,
      mockRemoteConfigService,
      mockImageMetadataService,
      mockPizzaValidationService,
      mockErrorTrackerService,
      mockAuthService,
      mockPizzaStorageService,
      mockFirestoreService,
      mockUploadLimitCacheService,
      mockHeicConversionService,
    );

    registerFallbackValue(CompressionSettings(quality: 80));
    registerFallbackValue(MockXFile());
    registerFallbackValue(EmptyImageMetadata());
    registerFallbackValue(Uint8List(0));
  });

  group('PocImagesCubit - pickSingleImage', () {
    final mockFile = MockXFile();
    final bytes = Uint8List.fromList([1, 2, 3]);
    final metadata = EmptyImageMetadata(bytes: bytes);

    setUp(() {
      when(() => mockImageProcessingService.pickSingleImage())
          .thenAnswer((_) async => mockFile);
      when(() => mockHeicConversionService.convertIfNeeded(any()))
          .thenAnswer((invocation) async => invocation.positionalArguments[0] as XFile);
      when(() => mockImageMetadataService.extractMetadata(any()))
          .thenAnswer((_) async => metadata);
      when(() => mockPizzaValidationService.validate(any()))
          .thenAnswer((_) async => const ValidationSuccess());
      when(() => mockRemoteConfigService.imageCompressionQuality).thenReturn(80);
    });

    blocTest<PocImagesCubit, PocImagesState>(
      'should successfully pick and compress image',
      build: () {
        when(() => mockImageProcessingService.compressImage(
              any(),
              any(),
              settings: any(named: 'settings'),
            )).thenAnswer((_) async => mockFile);
        when(() => mockFile.readAsBytes()).thenAnswer((_) async => bytes);
        return pocImagesCubit;
      },
      act: (cubit) => cubit.pickSingleImage(),
      expect: () => [
        isA<PocImagesState>().having((s) => s.isLoading, 'isLoading', true),
        isA<PocImagesState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.pendingImage, 'pendingImage', mockFile)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
      ],
    );

    blocTest<PocImagesCubit, PocImagesState>(
      'should fail when compression fails',
      build: () {
        when(() => mockImageProcessingService.compressImage(
              any(),
              any(),
              settings: any(named: 'settings'),
            )).thenAnswer((_) async => null);
        return pocImagesCubit;
      },
      act: (cubit) => cubit.pickSingleImage(),
      expect: () => [
        isA<PocImagesState>().having((s) => s.isLoading, 'isLoading', true),
        isA<PocImagesState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.errorMessage, 'errorMessage', 'No se pudo comprimir la imagen.'),
      ],
    );
  });
}
