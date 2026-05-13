import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/services/rtdb_service.dart';
import 'scoreboard_state.dart';

class ScoreboardCubit extends Cubit<ScoreboardState> {
  final RtdbService _rtdbService;
  static const int _pageSize = 10;
  int _currentLimit = _pageSize;

  ScoreboardCubit({required RtdbService rtdbService})
    : _rtdbService = rtdbService,
      super(ScoreboardInitial());

  Future<void> init(String? currentUserId) async {
    emit(ScoreboardLoading());
    _currentLimit = _pageSize;

    try {
      final lastUpdated = await _rtdbService.getLastUpdated();
      
      int? userRank;
      if (currentUserId != null) {
        userRank = await _rtdbService.getUserRank(currentUserId);
      }

      final entries = await _rtdbService.getTopEntries(limit: _currentLimit);

      emit(ScoreboardLoaded(
        topEntries: entries,
        userRank: userRank,
        lastUpdated: lastUpdated,
        hasMore: entries.length >= _currentLimit,
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
      _currentLimit += _pageSize;
      final entries = await _rtdbService.getTopEntries(limit: _currentLimit);

      emit(currentState.copyWith(
        topEntries: entries,
        isFetchingMore: false,
        hasMore: entries.length >= _currentLimit,
      ));
    } catch (e) {
      emit(currentState.copyWith(isFetchingMore: false));
    }
  }
}
