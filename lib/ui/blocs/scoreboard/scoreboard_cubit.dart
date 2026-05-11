import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/services/rtdb_service.dart';
import 'scoreboard_state.dart';

class ScoreboardCubit extends Cubit<ScoreboardState> {
  final RtdbService _rtdbService;

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

      final entries = await _rtdbService.getTopEntries();

      emit(ScoreboardLoaded(
        topEntries: entries,
        userRank: userRank,
        lastUpdated: lastUpdated,
      ));
    } catch (e) {
      emit(ScoreboardError(e.toString()));
    }
  }
}
