import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizzathon/data/services/local_storage_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/firestore_service.dart';
import 'enrollment_state.dart';

class EnrollmentCubit extends Cubit<EnrollmentState> {
  final FirestoreService _firestoreService;
  final AuthService _authService;
  final LocalStorageService _localStorageService;

  EnrollmentCubit(this._firestoreService, this._authService, this._localStorageService)
    : super(EnrollmentInitial());

  final _enrollmentDelay = Duration(seconds: 2);

  Future<void> checkEnrollmentStatus() async {
    final user = _authService.currentUser;
    if (user == null) {
      emit(const EnrollmentStatusChecked(false));
      return;
    }

    try {
      final isEnrolledInCache = await _localStorageService.isUserEnrolled(user.uid);

      if (isEnrolledInCache) {
        emit(const EnrollmentStatusChecked(true));
        return;
      }

      final isEnrolledInFirestore = await _firestoreService.isUserEnrolled(user.uid);

      if (isEnrolledInFirestore) {
        await _localStorageService.saveEnrollment(user.uid);
        emit(const EnrollmentStatusChecked(true));
      }
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
      await Future.wait([
        _firestoreService.saveUser(user),
        _localStorageService.saveEnrollment(user.uid),
        Future.delayed(_enrollmentDelay),
      ]);

      emit(const EnrollmentStatusChecked(true));
    } catch (e) {
      emit(EnrollmentError(e.toString()));
    }
  }
}
