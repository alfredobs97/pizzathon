import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizzathon/data/services/firestore_service.dart';
import 'package:pizzathon/domain/entities/pizza_limit_constants.dart';
import 'package:pizzathon/domain/entities/tracked_error.dart';
import 'package:pizzathon/domain/services/error_tracker_service.dart';
import '../../../data/services/upload_limit_service.dart';
import 'upload_limit_state.dart';

class UploadLimitCubit extends Cubit<UploadLimitState> {
  final UploadLimitCacheService _uploadLimitService;
  final FirestoreService _firestoreService;
  final ErrorTrackerService _errorTrackerService;

  UploadLimitCubit(this._uploadLimitService, this._firestoreService, this._errorTrackerService)
    : super(UploadLimitInitial());

  Future<void> checkLimit(String userId) async {
    try {
      emit(UploadLimitChecking());

      // 1. Try Cache first
      try {
        final canUploadCache = await _uploadLimitService.checkCacheLimit(userId);
        if (canUploadCache == false) {
          emit(UploadLimitReached());
          return;
        }
      } catch (e, stackTrace) {
        // If cache fails, track it but continue with Firestore
        _errorTrackerService.trackError(
          TrackedError(
            error: e,
            stackTrace: stackTrace,
            extra: {'component': 'UploadLimitCubit', 'action': 'checkCacheLimit', 'userId': userId},
          ),
        );
      }

      final (startDate, endDate) = await _uploadLimitService.getStartAndEndOfDay();

      // 2. Fallback to Firestore (or use it if cache was null)
      final count = await _firestoreService.countPizzasToday(
        uid: userId,
        startOfDay: startDate,
        endOfDay: endDate,
      );

      if (count >= PizzaLimitConstants.maxPizzasPerDay) {
        emit(UploadLimitReached());
      } else {
        emit(UploadLimitAllowed());
      }

      try {
        await _uploadLimitService.incrementLimitCache(userId, count);
      } catch (e, stackTrace) {
        _errorTrackerService.trackError(
          TrackedError(
            error: e,
            stackTrace: stackTrace,
            extra: {
              'component': 'UploadLimitCubit',
              'action': 'incrementLimitCache',
              'userId': userId,
            },
          ),
        );
      }
    } catch (e) {
      emit(UploadLimitError("Error al comprobar el límite de subidas: ${e.toString()}"));
    }
  }

  void reset() {
    emit(UploadLimitInitial());
  }
}
