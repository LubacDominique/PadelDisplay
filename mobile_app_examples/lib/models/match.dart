/// Modèle de données pour un match de Padel

class Match {
  final int? id;
  final DateTime matchDate;
  final int player1Id;
  final int player2Id;
  final int player1Sets;
  final int player2Sets;
  final int durationSeconds;
  final bool completed;
  final int? winnerId;
  
  Match({
    this.id,
    DateTime? matchDate,
    required this.player1Id,
    required this.player2Id,
    this.player1Sets = 0,
    this.player2Sets = 0,
    this.durationSeconds = 0,
    this.completed = false,
    this.winnerId,
  }) : matchDate = matchDate ?? DateTime.now();
  
  factory Match.fromMap(Map<String, dynamic> map) {
    return Match(
      id: map['id'],
      matchDate: DateTime.parse(map['match_date']),
      player1Id: map['player1_id'],
      player2Id: map['player2_id'],
      player1Sets: map['player1_sets'] ?? 0,
      player2Sets: map['player2_sets'] ?? 0,
      durationSeconds: map['duration_seconds'] ?? 0,
      completed: map['completed'] == 1,
      winnerId: map['winner_id'],
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'match_date': matchDate.toIso8601String(),
      'player1_id': player1Id,
      'player2_id': player2Id,
      'player1_sets': player1Sets,
      'player2_sets': player2Sets,
      'duration_seconds': durationSeconds,
      'completed': completed ? 1 : 0,
      'winner_id': winnerId,
    };
  }
  
  /// Durée formatée
  String get durationFormatted {
    final hours = durationSeconds ~/ 3600;
    final minutes = (durationSeconds % 3600) ~/ 60;
    final seconds = durationSeconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
    }
    return '${minutes}m ${seconds.toString().padLeft(2, '0')}s';
  }
  
  Match copyWith({
    int? id,
    DateTime? matchDate,
    int? player1Id,
    int? player2Id,
    int? player1Sets,
    int? player2Sets,
    int? durationSeconds,
    bool? completed,
    int? winnerId,
  }) {
    return Match(
      id: id ?? this.id,
      matchDate: matchDate ?? this.matchDate,
      player1Id: player1Id ?? this.player1Id,
      player2Id: player2Id ?? this.player2Id,
      player1Sets: player1Sets ?? this.player1Sets,
      player2Sets: player2Sets ?? this.player2Sets,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      completed: completed ?? this.completed,
      winnerId: winnerId ?? this.winnerId,
    );
  }
}

/// Détail d'un set dans un match
class MatchSet {
  final int? id;
  final int matchId;
  final int setNumber;
  final int player1Games;
  final int player2Games;
  final int durationSeconds;
  
  MatchSet({
    this.id,
    required this.matchId,
    required this.setNumber,
    this.player1Games = 0,
    this.player2Games = 0,
    this.durationSeconds = 0,
  });
  
  factory MatchSet.fromMap(Map<String, dynamic> map) {
    return MatchSet(
      id: map['id'],
      matchId: map['match_id'],
      setNumber: map['set_number'],
      player1Games: map['player1_games'] ?? 0,
      player2Games: map['player2_games'] ?? 0,
      durationSeconds: map['duration_seconds'] ?? 0,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'match_id': matchId,
      'set_number': setNumber,
      'player1_games': player1Games,
      'player2_games': player2Games,
      'duration_seconds': durationSeconds,
    };
  }
  
  String get scoreDisplay => '$player1Games-$player2Games';
}

/// Point dans un match
class MatchPoint {
  final int? id;
  final int matchId;
  final int setNumber;
  final int gameNumber;
  final int pointWinner; // 1 ou 2
  final DateTime timestamp;
  final String scoreAfter;
  
  MatchPoint({
    this.id,
    required this.matchId,
    required this.setNumber,
    required this.gameNumber,
    required this.pointWinner,
    DateTime? timestamp,
    required this.scoreAfter,
  }) : timestamp = timestamp ?? DateTime.now();
  
  factory MatchPoint.fromMap(Map<String, dynamic> map) {
    return MatchPoint(
      id: map['id'],
      matchId: map['match_id'],
      setNumber: map['set_number'],
      gameNumber: map['game_number'],
      pointWinner: map['point_winner'],
      timestamp: DateTime.parse(map['timestamp']),
      scoreAfter: map['score_after'],
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'match_id': matchId,
      'set_number': setNumber,
      'game_number': gameNumber,
      'point_winner': pointWinner,
      'timestamp': timestamp.toIso8601String(),
      'score_after': scoreAfter,
    };
  }
}
