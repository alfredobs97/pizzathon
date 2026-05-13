import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/services/rtdb_service.dart';
import 'scoreboard_state.dart';

class ScoreboardCubit extends Cubit<ScoreboardState> {
  final RtdbService _rtdbService;
  static const int _pageSize = 10;

  ScoreboardCubit({required RtdbService rtdbService})
    : _rtdbService = rtdbService,
      super(ScoreboardInitial());

  Future<void> init(String? currentUserId) async {
    emit(ScoreboardLoading());

    try {
      final lastUpdated = await _rtdbService.getLastUpdated();
      
      int? userRank;
      if (currentUserId != null) {
        userRank = await _rtdbService.getUserRank(currentUserId);
      }

      final entries = await _rtdbService.getTopEntries(limit: _pageSize);

      emit(ScoreboardLoaded(
        topEntries: entries,
        userRank: userRank,
        lastUpdated: lastUpdated,
        hasMore: entries.length >= _pageSize,
      ));
    } catch (e) {
      emit(ScoreboardError(e.toString()));
    }
  }

  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! ScoreboardLoaded || currentState.isFetchingMore || !currentState.hasMore) {
      return;
    }

    emit(currentState.copyWith(isFetchingMore: true));

    try {
      // Use the last entry's index as the starting point for the next page
      final lastEntry = currentState.topEntries.last;
      final startAfterKey = (lastEntry.rank - 1).toString();

      final newEntries = await _rtdbService.getTopEntries(
        limit: _pageSize, 
        startAfterKey: startAfterKey,
      );

      emit(currentState.copyWith(
        topEntries: [...currentState.topEntries, ...newEntries],
        isFetchingMore: false,
        hasMore: newEntries.length >= _pageSize,
      ));
    } catch (e) {
      emit(currentState.copyWith(isFetchingMore: false));
    }
  }
}
