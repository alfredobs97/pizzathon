import 'package:equatable/equatable.dart';
import '../../../domain/models/scoreboard_entry.dart';

abstract class ScoreboardState extends Equatable {
  const ScoreboardState();

  @override
  List<Object?> get props => [];
}

class ScoreboardInitial extends ScoreboardState {}

class ScoreboardLoading extends ScoreboardState {}

class ScoreboardLoaded extends ScoreboardState {
  final List<ScoreboardEntry> topEntries;
  final int? userRank;
  final String? lastUpdated;

  const ScoreboardLoaded({
    required this.topEntries,
    this.userRank,
    this.lastUpdated,
  });

  @override
  List<Object?> get props => [topEntries, userRank, lastUpdated];
}

class ScoreboardError extends ScoreboardState {
  final String message;

  const ScoreboardError(this.message);

  @override
  List<Object?> get props => [message];
}
