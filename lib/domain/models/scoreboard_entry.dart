class ScoreboardEntry {
  final String uid;
  final String displayName;
  final String photoUrl;
  final int score;
  final int rank;

  ScoreboardEntry({
    required this.uid,
    required this.displayName,
    required this.photoUrl,
    required this.score,
    required this.rank,
  });

  factory ScoreboardEntry.fromJson(Map<dynamic, dynamic> json) {
    return ScoreboardEntry(
      uid: json['uid'] as String? ?? '',
      displayName: json['displayName'] as String? ?? 'Anonymous',
      photoUrl: json['photoUrl'] as String? ?? '',
      score: (json['score'] as num?)?.toInt() ?? 0,
      rank: (json['rank'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'score': score,
      'rank': rank,
    };
  }
}
