import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizzathon/data/services/local_storage_service.dart';
import 'package:pizzathon/data/services/remote_config_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/firestore_service.dart';
import 'enrollment_state.dart';

class EnrollmentCubit extends Cubit<EnrollmentState> {
  final FirestoreService _firestoreService;
  final AuthService _authService;
  final LocalStorageService _localStorageService;
  final RemoteConfigService _remoteConfigService;

  EnrollmentCubit(
    this._firestoreService,
    this._authService,
    this._localStorageService,
    this._remoteConfigService,
  ) : super(EnrollmentInitial());

  final _enrollmentDelay = Duration(seconds: 2);

  Future<void> checkEnrollmentStatus() async {
    emit(EnrollmentLoading());

    try {
      await _remoteConfigService.forceFetch();
    } catch (e) {
      debugPrint('Error al obtener el estado del remote config: $e');
    }

    final user = _authService.currentUser;
    final isActive = _remoteConfigService.isEnrollmentOpen;

    if (user == null) {
      emit(EnrollmentStatusChecked(isEnrollmentActive: isActive, isEnrolled: false));
      return;
    }

    try {
      final isEnrolledInCache = await _localStorageService.isUserEnrolled(user.uid);

      if (isEnrolledInCache) {
        emit(EnrollmentStatusChecked(isEnrollmentActive: isActive, isEnrolled: true));
        return;
      }

      final isEnrolledInFirestore = await _firestoreService.isUserEnrolled(user.uid);

      if (isEnrolledInFirestore) {
        await _localStorageService.saveEnrollment(user.uid);
      }

      emit(
        EnrollmentStatusChecked(isEnrollmentActive: isActive, isEnrolled: isEnrolledInFirestore),
      );
    } catch (e) {
      emit(EnrollmentError(e.toString()));
    }
  }

  Future<void> enroll() async {
    final user = _authService.currentUser;
    if (user == null) {
      emit(const EnrollmentError('Usuario no autenticado'));
      return;
    }

    emit(EnrollmentLoading());
    try {
      final email = user.email;
      final currentName = user.displayName;

      String finalNameToSave = currentName ?? "";

      if (currentName == null || currentName.trim().isEmpty || currentName == email) {
        if (email != null && email.contains('@')) {
          finalNameToSave = email.split('@').first;
        }
      }
      await Future.wait([
        _firestoreService.saveUser(user, customName: finalNameToSave ),
        _localStorageService.saveEnrollment(user.uid),
        Future.delayed(_enrollmentDelay),
      ]);

      emit(
        EnrollmentStatusChecked(
          isEnrollmentActive: _remoteConfigService.isEnrollmentOpen,
          isEnrolled: true,
        ),
      );
    } catch (e) {
      emit(EnrollmentError(e.toString()));
    }
  }
}
