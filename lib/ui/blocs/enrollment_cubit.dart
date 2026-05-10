import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizzathon/data/services/local_storage_service.dart';
import 'package:pizzathon/data/services/remote_config_service.dart';
import 'package:pizzathon/domain/entities/tracked_error.dart';
import 'package:pizzathon/domain/services/error_tracker_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/firestore_service.dart';
import 'enrollment_state.dart';

class EnrollmentCubit extends Cubit<EnrollmentState> {
  final FirestoreService _firestoreService;
  final AuthService _authService;
  final LocalStorageService _localStorageService;
  final RemoteConfigService _remoteConfigService;
  final ErrorTrackerService _errorTrackerService;
  StreamSubscription<User?>? _authSubscription;

  EnrollmentCubit(
    this._firestoreService,
    this._authService,
    this._localStorageService,
    this._remoteConfigService,
    this._errorTrackerService,
  ) : super(EnrollmentInitial()) {
    _authSubscription = _authService.authStateChanges.listen((user) {
      if (user != null) {
        checkUserEnrollment();
      } else {
        emit(
          EnrollmentStatusChecked(
            isEnrolled: false,
            isEnrollmentActive: _remoteConfigService.isEnrollmentOpen,
          ),
        );
      }
    });
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }

  final _enrollmentDelay = Duration(seconds: 2);

  Future<void> checkEnrollmentStatus() async {
    emit(EnrollmentLoading());
    await checkEnrollmentAvailability();
    await checkUserEnrollment();
  }

  Future<void> checkEnrollmentAvailability() async {
    try {
      await _remoteConfigService.forceFetch();
    } catch (e, stackTrace) {
      _errorTrackerService.trackError(
        TrackedError(
          error: e,
          stackTrace: stackTrace,
          extra: {'component': 'EnrollmentCubit', 'action': 'forceFetchRemoteConfig'},
        ),
      );
      debugPrint('Error fetching remote config status: $e');
    }
    _syncStatus();
  }

  Future<void> checkUserEnrollment() async {
    final user = _authService.currentUser;
    if (user == null) {
      _syncStatus();
      return;
    }

    try {
      final isEnrolledInCache = await _localStorageService.isUserEnrolled(user.uid);

      if (isEnrolledInCache) {
        emit(
          EnrollmentStatusChecked(
            isEnrollmentActive: _remoteConfigService.isEnrollmentOpen,
            isEnrolled: true,
          ),
        );
        return;
      }

      final isEnrolledInFirestore = await _firestoreService.isUserEnrolled(user.uid);

      if (isEnrolledInFirestore) {
        await _localStorageService.saveEnrollment(user.uid);
      }

      emit(
        EnrollmentStatusChecked(
          isEnrollmentActive: _remoteConfigService.isEnrollmentOpen,
          isEnrolled: isEnrolledInFirestore,
        ),
      );
    } catch (e, stackTrace) {
      _errorTrackerService.trackError(
        TrackedError(
          error: e,
          stackTrace: stackTrace,
          extra: {'component': 'EnrollmentCubit', 'action': 'checkUserEnrollment'},
        ),
      );
      emit(EnrollmentError(e.toString()));
    }
  }

  void _syncStatus() {
    final isActive = _remoteConfigService.isEnrollmentOpen;
    final currentState = state;

    bool isEnrolled = false;
    if (currentState is EnrollmentStatusChecked) {
      isEnrolled = currentState.isEnrolled;
    }

    emit(EnrollmentStatusChecked(isEnrollmentActive: isActive, isEnrolled: isEnrolled));
  }

  Future<void> enroll() async {
    final user = _authService.currentUser;
    if (user == null) {
      emit(const EnrollmentError('Usuario no autenticado'));
      return;
    }

    emit(EnrollmentLoading());
    try {
      await Future.wait([
        _firestoreService.saveUser(user),
        _localStorageService.saveEnrollment(user.uid),
        Future.delayed(_enrollmentDelay),
      ]);

      emit(
        EnrollmentStatusChecked(
          isEnrollmentActive: _remoteConfigService.isEnrollmentOpen,
          isEnrolled: true,
        ),
      );
    } catch (e, stackTrace) {
      _errorTrackerService.trackError(
        TrackedError(
          error: e,
          stackTrace: stackTrace,
          extra: {'component': 'EnrollmentCubit', 'action': 'enroll'},
        ),
      );
      emit(EnrollmentError(e.toString()));
    }
  }
}
