import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../firebase_options.dart';
import '../../domain/models/scoreboard_entry.dart';

class RtdbService {
  final FirebaseDatabase _db;

  RtdbService({FirebaseDatabase? database})
    : _db =
          database ??
          FirebaseDatabase.instanceFor(
            app: Firebase.app(),
            databaseURL: DefaultFirebaseOptions.currentPlatform.databaseURL,
          );

  static const String _scoreboardPath = 'scoreboard';

  /// Get a single snapshot of the top scoreboard entries.
  Future<List<ScoreboardEntry>> getTopEntries({int limit = 10, String? startAfterKey}) async {
    Query query = _db.ref('$_scoreboardPath/top').orderByKey();

    if (startAfterKey != null) {
      query = query.startAfter(startAfterKey);
    }

    final snapshot = await query.limitToFirst(limit).get();

    if (!snapshot.exists || snapshot.value == null) return [];

    // RTDB returns a List if keys are 0, 1, 2... but returns a Map if we start elsewhere
    final dynamic data = snapshot.value;

    if (data is List) {
      return data
          .where((e) => e != null)
          .map((e) => ScoreboardEntry.fromJson(e as Map<dynamic, dynamic>))
          .toList();
    } else if (data is Map) {
      // Sort keys to maintain order as Map keys aren't guaranteed to be sorted
      final sortedKeys = data.keys.toList()..sort((a, b) => int.parse(a.toString()).compareTo(int.parse(b.toString())));
      return sortedKeys
          .map((key) => ScoreboardEntry.fromJson(data[key] as Map<dynamic, dynamic>))
          .toList();
    }

    return [];
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
