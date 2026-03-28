import 'package:equatable/equatable.dart';

abstract class EnrollmentState extends Equatable {
  const EnrollmentState();

  @override
  List<Object?> get props => [];
}

class EnrollmentInitial extends EnrollmentState {}

class EnrollmentStatusChecked extends EnrollmentState {
  final bool isEnrolled;
  const EnrollmentStatusChecked(this.isEnrolled);

  @override
  List<Object?> get props => [isEnrolled];
}

class EnrollmentLoading extends EnrollmentState {}

class EnrollmentError extends EnrollmentState {
  final String message;
  const EnrollmentError(this.message);

  @override
  List<Object?> get props => [message];
}
