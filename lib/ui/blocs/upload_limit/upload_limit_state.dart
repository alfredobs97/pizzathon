import 'package:equatable/equatable.dart';

abstract class UploadLimitState extends Equatable {
  const UploadLimitState();

  @override
  List<Object?> get props => [];
}

class UploadLimitInitial extends UploadLimitState {}

class UploadLimitChecking extends UploadLimitState {}

class UploadLimitAllowed extends UploadLimitState {}

class UploadLimitReached extends UploadLimitState {}

class UploadLimitError extends UploadLimitState {
  final String message;

  const UploadLimitError(this.message);

  @override
  List<Object?> get props => [message];
}
