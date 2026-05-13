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
  final bool hasMore;
  final bool isFetchingMore;

  const ScoreboardLoaded({
    required this.topEntries,
    this.userRank,
    this.lastUpdated,
    this.hasMore = true,
    this.isFetchingMore = false,
  });

  ScoreboardLoaded copyWith({
    List<ScoreboardEntry>? topEntries,
    int? userRank,
    String? lastUpdated,
    bool? hasMore,
    bool? isFetchingMore,
  }) {
    return ScoreboardLoaded(
      topEntries: topEntries ?? this.topEntries,
      userRank: userRank ?? this.userRank,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      hasMore: hasMore ?? this.hasMore,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
    );
  }

  @override
  List<Object?> get props => [
        topEntries,
        userRank,
        lastUpdated,
        hasMore,
        isFetchingMore,
      ];
}

class ScoreboardError extends ScoreboardState {
  final String message;

  const ScoreboardError(this.message);

  @override
  List<Object?> get props => [message];
}
