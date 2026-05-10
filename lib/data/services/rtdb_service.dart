import 'package:firebase_database/firebase_database.dart';
import '../../domain/models/scoreboard_entry.dart';

class RtdbService {
  final FirebaseDatabase _db;

  RtdbService({FirebaseDatabase? database}) : _db = database ?? FirebaseDatabase.instance;

  static const String _scoreboardPath = 'scoreboard';

  /// Get a single snapshot of the top scoreboard entries.
  Future<List<ScoreboardEntry>> getTopEntries() async {
    final snapshot = await _db.ref('$_scoreboardPath/top').get();
    final data = snapshot.value as List<dynamic>?;
    if (data == null) return [];

    return data
        .where((e) => e != null)
        .map((e) => ScoreboardEntry.fromJson(e as Map<dynamic, dynamic>))
        .toList();
  }

  /// Stream of the top scoreboard entries.
  Stream<List<ScoreboardEntry>> getTopScoreboard() {
    return _db.ref('$_scoreboardPath/top').onValue.map((event) {
      final data = event.snapshot.value as List<dynamic>?;
      if (data == null) return [];
      
      return data
          .where((e) => e != null)
          .map((e) => ScoreboardEntry.fromJson(e as Map<dynamic, dynamic>))
          .toList();
    });
  }

  /// Get the rank of a specific user.
  Future<int?> getUserRank(String uid) async {
    final snapshot = await _db.ref('$_scoreboardPath/positions/$uid').get();
    if (snapshot.exists) {
      return (snapshot.value as num).toInt();
    }
    return null;
  }

  /// Get the last updated timestamp of the scoreboard.
  Future<String?> getLastUpdated() async {
    final snapshot = await _db.ref('$_scoreboardPath/lastUpdated').get();
    if (snapshot.exists) {
      return snapshot.value as String?;
    }
    return null;
  }
}
